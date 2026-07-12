from datetime import datetime, timedelta, timezone
from io import BytesIO
from uuid import UUID, uuid4
import warnings

from PIL import Image, UnidentifiedImageError

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.core.errors import ApiError, ErrorCode
from app.db.models.cross_cutting import MediaAsset, VerificationCase
from app.db.models.marketplace import WorkCard, WorkNeededPost
from app.integrations.supabase_storage import MediaStorageGateway, SignedUpload
from app.integrations.supabase_storage import StorageObjectNotFound
from app.integrations.supabase_storage import StorageProviderError
from app.modules.media.repository import MediaRepository, MediaTarget, OwnedMedia
from app.modules.media.schemas import MediaAssetResponse, UploadDetails
from app.modules.media.schemas import UploadIntentRequest, UploadIntentResponse
from app.modules.profiles.repository import ProfileRepository
from app.modules.profiles.service import ProfileService


IMAGE_MIME_BY_FORMAT = {
    "JPEG": "image/jpeg",
    "PNG": "image/png",
    "WEBP": "image/webp",
}
EXTENSION_BY_MIME = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "application/pdf": ".pdf",
}
PRIVATE_DOCUMENT_TYPES = {"identity_proof", "masked_aadhaar", "gst_proof", "other"}
SENSITIVE_PROFILE_PHOTO_TYPES = {"shop_photo", "workplace_photo"}


class InvalidMediaContent(Exception):
    pass


class MediaService:
    def __init__(
        self,
        *,
        repository: MediaRepository,
        profile_repository: ProfileRepository,
        storage: MediaStorageGateway,
        settings: Settings,
    ) -> None:
        self.repository = repository
        self.profile_repository = profile_repository
        self.profile_service = ProfileService(profile_repository)
        self.storage = storage
        self.settings = settings

    def create_upload_intent(
        self,
        *,
        current_user: CurrentUser,
        payload: UploadIntentRequest,
    ) -> UploadIntentResponse:
        target = self._get_target(
            current_user=current_user,
            entity_type=payload.entity_type,
            entity_id=payload.entity_id,
        )
        self._validate_target(target, payload)
        self._validate_declared_file(payload)
        media_id = uuid4()
        extension = EXTENSION_BY_MIME[payload.mime_type]
        path = self._initial_path(
            user_id=current_user.user_id,
            media_id=media_id,
            target=target,
            visibility=payload.visibility,
            extension=extension,
        )
        media = MediaAsset(
            id=media_id,
            entity_type=payload.entity_type,
            entity_id=payload.entity_id,
            media_kind=payload.media_kind,
            document_type=payload.document_type,
            visibility=payload.visibility,
            upload_status="pending_upload",
            original_path=path,
            sort_order=self.repository.next_sort_order(
                entity_type=payload.entity_type,
                entity_id=payload.entity_id,
            ),
            file_size_bytes=payload.byte_size,
            mime_type=payload.mime_type,
            uploaded_by_user_id=current_user.user_id,
        )
        self.repository.add(media)
        self.repository.flush()
        signed = self._create_signed_upload(path)
        self.repository.commit()
        return self._intent_response(media, signed)

    def complete_upload(
        self,
        *,
        current_user: CurrentUser,
        media_asset_id: UUID,
    ) -> MediaAssetResponse:
        owned = self._get_media(current_user, media_asset_id)
        media = owned.media
        if media.upload_status == "ready":
            return self._media_response(media)
        if media.upload_status != "pending_upload":
            raise self._invalid_state("This upload cannot be completed.")
        self._ensure_target_mutable(
            owned.target, for_private=media.visibility != "public"
        )
        source_bucket = self.settings.supabase_private_verification_bucket
        try:
            self.storage.object_info(bucket=source_bucket, path=media.original_path)
            content = self.storage.download(
                bucket=source_bucket, path=media.original_path
            )
        except StorageObjectNotFound as error:
            raise ApiError(
                status_code=409,
                code=ErrorCode.UPLOAD_NOT_READY,
                message="Upload has not finished. Please retry.",
            ) from error
        except StorageProviderError as error:
            raise self._provider_error() from error

        try:
            actual_mime, width, height = self._inspect_content(media, content)
        except InvalidMediaContent as error:
            media.upload_status = "failed"
            self._remove_if_exists(bucket=source_bucket, path=media.original_path)
            self.repository.commit()
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message=str(error),
            ) from error

        if media.visibility == "public":
            final_path = self._public_path(media, actual_mime)
            try:
                self.storage.upload(
                    bucket=self.settings.supabase_public_media_bucket,
                    path=final_path,
                    content=content,
                    mime_type=actual_mime,
                )
            except StorageProviderError as error:
                raise self._provider_error() from error
            self._remove_if_exists(bucket=source_bucket, path=media.original_path)
            media.original_path = final_path

        media.file_size_bytes = len(content)
        media.mime_type = actual_mime
        media.width = width
        media.height = height
        media.upload_status = "ready"
        self.repository.flush()
        self.repository.sync_target_photo_count(owned.target)
        self._refresh_profile_after_change(owned, current_user.user_id)
        self.repository.commit()
        return self._media_response(media)

    def retry_upload(
        self,
        *,
        current_user: CurrentUser,
        media_asset_id: UUID,
    ) -> UploadIntentResponse:
        owned = self._get_media(current_user, media_asset_id)
        media = owned.media
        if media.upload_status not in {"pending_upload", "failed"}:
            raise self._invalid_state("Only pending or failed uploads can be retried.")
        self._ensure_target_mutable(
            owned.target, for_private=media.visibility != "public"
        )
        self._remove_if_exists(
            bucket=self.settings.supabase_private_verification_bucket,
            path=media.original_path,
        )
        media.upload_status = "pending_upload"
        media.width = None
        media.height = None
        signed = self._create_signed_upload(media.original_path)
        self.repository.commit()
        return self._intent_response(media, signed)

    def cancel_upload(
        self,
        *,
        current_user: CurrentUser,
        media_asset_id: UUID,
    ) -> None:
        owned = self._get_media(current_user, media_asset_id)
        media = owned.media
        if media.upload_status not in {"pending_upload", "failed"}:
            raise self._invalid_state(
                "Only pending or failed uploads can be cancelled."
            )
        self._ensure_target_mutable(
            owned.target, for_private=media.visibility != "public"
        )
        self._remove_for_mutation(
            bucket=self.settings.supabase_private_verification_bucket,
            path=media.original_path,
        )
        self._mark_deleted(media)
        self.repository.commit()

    def delete_media(
        self,
        *,
        current_user: CurrentUser,
        media_asset_id: UUID,
    ) -> None:
        owned = self._get_media(current_user, media_asset_id)
        media = owned.media
        self._ensure_target_mutable(
            owned.target, for_private=media.visibility != "public"
        )
        self._protect_minimum_photos(owned)
        bucket = (
            self.settings.supabase_public_media_bucket
            if media.visibility == "public" and media.upload_status == "ready"
            else self.settings.supabase_private_verification_bucket
        )
        self._remove_for_mutation(bucket=bucket, path=media.original_path)
        self._mark_deleted(media)
        self.repository.flush()
        self.repository.sync_target_photo_count(owned.target)
        self._refresh_profile_after_change(owned, current_user.user_id)
        self.repository.commit()

    def _get_target(
        self,
        *,
        current_user: CurrentUser,
        entity_type: str,
        entity_id: UUID,
    ) -> MediaTarget:
        target = self.repository.get_owned_target(
            user_id=current_user.user_id,
            entity_type=entity_type,
            entity_id=entity_id,
            for_update=True,
        )
        if target is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Media target not found.",
            )
        self._ensure_target_mutable(
            target, for_private=entity_type == "verification_case"
        )
        return target

    def _get_media(self, current_user: CurrentUser, media_asset_id: UUID) -> OwnedMedia:
        owned = self.repository.get_owned_media(
            user_id=current_user.user_id,
            media_asset_id=media_asset_id,
            for_update=True,
        )
        if owned is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Media not found.",
            )
        return owned

    def _validate_target(
        self,
        target: MediaTarget,
        payload: UploadIntentRequest,
    ) -> None:
        if target.entity_type == "profile":
            expected = {
                "business": "shop_photo",
                "job_worker": "workplace_photo",
                "skilled_worker": "other",
            }[target.profile.role]
            valid = (
                payload.media_kind == "image"
                and payload.visibility == "public"
                and payload.document_type == expected
            )
        elif target.entity_type in {"work_card", "work_needed_post"}:
            valid = (
                payload.media_kind == "image"
                and payload.visibility == "public"
                and payload.document_type == "work_photo"
            )
        else:
            valid = (
                payload.media_kind == "document"
                and payload.visibility == "private_admin_only"
                and payload.document_type in PRIVATE_DOCUMENT_TYPES
            )
        if not valid:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Media type does not match its target.",
            )

    def _validate_declared_file(self, payload: UploadIntentRequest) -> None:
        allowed = (
            {"image/jpeg", "image/png", "image/webp"}
            if payload.media_kind == "image"
            else {"image/jpeg", "image/png", "image/webp", "application/pdf"}
        )
        if payload.mime_type not in allowed:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Unsupported file type.",
                field_errors={"mime_type": "Choose a JPG, PNG, WEBP, or PDF file."},
            )
        if payload.byte_size > self.settings.max_upload_mb * 1024 * 1024:
            raise ApiError(
                status_code=413,
                code=ErrorCode.VALIDATION_FAILED,
                message=f"File must be {self.settings.max_upload_mb} MB or smaller.",
                field_errors={"byte_size": "File is too large."},
            )

    def _inspect_content(
        self,
        media: MediaAsset,
        content: bytes,
    ) -> tuple[str, int | None, int | None]:
        if not content or len(content) > self.settings.max_upload_mb * 1024 * 1024:
            raise InvalidMediaContent("Uploaded file is empty or too large.")
        if media.file_size_bytes is not None and len(content) != media.file_size_bytes:
            raise InvalidMediaContent("Uploaded file size does not match the request.")
        if media.mime_type == "application/pdf":
            if not content.startswith(b"%PDF-"):
                raise InvalidMediaContent("Uploaded document is not a valid PDF.")
            return "application/pdf", None, None

        try:
            with warnings.catch_warnings():
                warnings.simplefilter("error", Image.DecompressionBombWarning)
                Image.MAX_IMAGE_PIXELS = self.settings.max_image_pixels
                with Image.open(BytesIO(content)) as image:
                    image.verify()
                with Image.open(BytesIO(content)) as image:
                    actual_mime = IMAGE_MIME_BY_FORMAT.get(image.format or "")
                    width, height = image.size
        except (UnidentifiedImageError, OSError, Image.DecompressionBombError) as error:
            raise InvalidMediaContent("Uploaded image is not valid.") from error
        except Image.DecompressionBombWarning as error:
            raise InvalidMediaContent(
                "Uploaded image dimensions are too large."
            ) from error
        if actual_mime is None or actual_mime != media.mime_type:
            raise InvalidMediaContent("Uploaded file type does not match the request.")
        if width <= 0 or height <= 0:
            raise InvalidMediaContent("Uploaded image dimensions are invalid.")
        if (
            width > self.settings.max_image_dimension
            or height > self.settings.max_image_dimension
        ):
            raise InvalidMediaContent("Uploaded image dimensions are too large.")
        return actual_mime, width, height

    def _ensure_target_mutable(self, target: MediaTarget, *, for_private: bool) -> None:
        if target.profile.verification_status == "pending":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VERIFICATION_PENDING_LOCKED,
                message="Profile editing is locked while verification is pending.",
            )
        if target.entity_type == "work_card" and target.entity.status in {
            "removed_by_admin",
            "deleted",
        }:
            raise self._invalid_state("This work cannot be changed.")
        if target.entity_type == "work_needed_post" and target.entity.status in {
            "removed_by_admin",
            "deleted",
        }:
            raise self._invalid_state("This post cannot be changed.")
        if target.entity_type == "verification_case":
            case = target.entity
            if not isinstance(case, VerificationCase) or case.status not in {
                "draft",
                "changes_requested",
            }:
                raise self._invalid_state(
                    "Verification documents cannot be changed now."
                )
        if for_private and target.entity_type != "verification_case":
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Private documents require a verification case.",
            )

    def _protect_minimum_photos(self, owned: OwnedMedia) -> None:
        media = owned.media
        if (
            media.upload_status != "ready"
            or media.visibility != "public"
            or media.media_kind != "image"
        ):
            return
        target = owned.target
        required = False
        document_type: str | None = None
        if target.entity_type == "profile":
            required = target.profile.completion_score == 100
            document_type = media.document_type
        elif target.entity_type == "work_card":
            required = isinstance(target.entity, WorkCard) and target.entity.status in {
                "published",
                "hidden_by_user",
            }
        elif target.entity_type == "work_needed_post":
            required = isinstance(
                target.entity, WorkNeededPost
            ) and target.entity.status in {
                "active",
                "paused",
                "closed_by_user",
            }
        if not required:
            return
        count = self.repository.ready_public_photo_count(
            entity_type=target.entity_type,
            entity_id=target.entity.id,
            document_type=document_type if target.entity_type == "profile" else None,
        )
        if count <= 3:
            raise ApiError(
                status_code=409,
                code=ErrorCode.MINIMUM_PHOTOS_REQUIRED,
                message="Minimum 3 photos required. Upload a replacement first.",
            )

    def _refresh_profile_after_change(self, owned: OwnedMedia, user_id: UUID) -> None:
        media = owned.media
        profile = owned.target.profile
        if (
            owned.target.entity_type == "profile"
            and media.document_type in SENSITIVE_PROFILE_PHOTO_TYPES
            and (profile.is_verified or profile.verification_status == "verified")
        ):
            before = {
                "verification_status": profile.verification_status,
                "is_verified": profile.is_verified,
            }
            profile.verification_status = "unverified"
            profile.is_verified = False
            profile.reverification_required = True
            self.profile_repository.add_change_history(
                profile_id=profile.id,
                user_id=user_id,
                before=before,
                after={
                    "verification_status": "unverified",
                    "is_verified": False,
                    "profile_photos_changed": True,
                },
                requires_reverification=True,
            )
        profile.last_activity_at = datetime.now(timezone.utc)
        self.profile_service.refresh_completion(profile.id)

    def _create_signed_upload(self, path: str) -> SignedUpload:
        try:
            return self.storage.create_signed_upload(
                bucket=self.settings.supabase_private_verification_bucket,
                path=path,
            )
        except StorageProviderError as error:
            raise self._provider_error() from error

    def _intent_response(
        self,
        media: MediaAsset,
        signed: SignedUpload,
    ) -> UploadIntentResponse:
        return UploadIntentResponse(
            media_asset=self._media_response(media),
            upload=UploadDetails(
                url=signed.url,
                headers={},
                expires_at=datetime.now(timezone.utc)
                + timedelta(seconds=signed.expires_in_seconds),
            ),
        )

    def _media_response(self, media: MediaAsset) -> MediaAssetResponse:
        url = None
        if media.visibility == "public" and media.upload_status == "ready":
            url = self.storage.public_url(
                bucket=self.settings.supabase_public_media_bucket,
                path=media.original_path,
            )
        safe_name = None
        if media.visibility == "private_admin_only":
            safe_name = (media.document_type or "document").replace("_", " ").title()
        return MediaAssetResponse(
            id=media.id,
            media_kind=media.media_kind,
            visibility=media.visibility,
            upload_status=media.upload_status,
            url=url,
            sort_order=media.sort_order,
            document_type=media.document_type,
            safe_display_name=safe_name,
        )

    def _initial_path(
        self,
        *,
        user_id: UUID,
        media_id: UUID,
        target: MediaTarget,
        visibility: str,
        extension: str,
    ) -> str:
        if visibility == "public":
            return f"staging/{user_id}/{media_id}{extension}"
        return f"verification/{target.entity.id}/{media_id}{extension}"

    @staticmethod
    def _public_path(media: MediaAsset, mime_type: str) -> str:
        return (
            f"{media.entity_type}/{media.entity_id}/{media.id}"
            f"{EXTENSION_BY_MIME[mime_type]}"
        )

    @staticmethod
    def _mark_deleted(media: MediaAsset) -> None:
        media.upload_status = "deleted"
        media.deleted_at = datetime.now(timezone.utc)

    def _remove_if_exists(self, *, bucket: str, path: str) -> None:
        try:
            self.storage.remove(bucket=bucket, path=path)
        except (StorageObjectNotFound, StorageProviderError):
            return

    def _remove_for_mutation(self, *, bucket: str, path: str) -> None:
        try:
            self.storage.remove(bucket=bucket, path=path)
        except StorageObjectNotFound:
            return
        except StorageProviderError as error:
            raise self._provider_error() from error

    @staticmethod
    def _invalid_state(message: str) -> ApiError:
        return ApiError(
            status_code=409,
            code=ErrorCode.UPLOAD_NOT_READY,
            message=message,
        )

    @staticmethod
    def _provider_error() -> ApiError:
        return ApiError(
            status_code=503,
            code=ErrorCode.PROVIDER_UNAVAILABLE,
            message="Media storage is temporarily unavailable. Please retry.",
        )
