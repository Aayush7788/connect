from io import BytesIO
from uuid import uuid4

import pytest
from PIL import Image

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.core.errors import ApiError, ErrorCode
from app.db.models.cross_cutting import MediaAsset, VerificationCase
from app.db.models.marketplace import WorkCard
from app.db.models.profile import Profile
from app.integrations.supabase_storage import SignedUpload, StorageObjectNotFound
from app.modules.media.repository import MediaTarget, OwnedMedia
from app.modules.media.schemas import UploadIntentRequest
from app.modules.media.service import MediaService


class FakeMediaRepository:
    def __init__(self, target: MediaTarget, user_id) -> None:
        self.target = target
        self.user_id = user_id
        self.media: dict = {}
        self.commits = 0

    def get_owned_target(self, *, user_id, entity_type, entity_id, for_update=False):
        if (
            user_id == self.user_id
            and entity_type == self.target.entity_type
            and entity_id == self.target.entity.id
        ):
            return self.target
        return None

    def get_owned_media(self, *, user_id, media_asset_id, for_update=False):
        media = self.media.get(media_asset_id)
        if media is None or user_id != self.user_id or media.deleted_at is not None:
            return None
        return OwnedMedia(media=media, target=self.target)

    def next_sort_order(self, *, entity_type, entity_id):
        return len(self.media)

    def ready_public_photo_count(
        self,
        *,
        entity_type,
        entity_id,
        document_type=None,
    ):
        return sum(
            1
            for media in self.media.values()
            if media.entity_type == entity_type
            and media.entity_id == entity_id
            and media.visibility == "public"
            and media.media_kind == "image"
            and media.upload_status == "ready"
            and media.deleted_at is None
            and (document_type is None or media.document_type == document_type)
        )

    def sync_target_photo_count(self, target):
        target.entity.photo_count = self.ready_public_photo_count(
            entity_type=target.entity_type,
            entity_id=target.entity.id,
        )

    def add(self, media):
        self.media[media.id] = media

    def flush(self):
        return None

    def commit(self):
        self.commits += 1


class FakeProfileRepository:
    def __init__(self) -> None:
        self.histories: list[dict] = []

    def add_change_history(self, **values):
        self.histories.append(values)


class FakeProfileService:
    def __init__(self) -> None:
        self.refreshed: list = []

    def refresh_completion(self, profile_id):
        self.refreshed.append(profile_id)


class FakeStorage:
    def __init__(self) -> None:
        self.objects: dict[tuple[str, str], bytes] = {}

    def create_signed_upload(self, *, bucket, path):
        return SignedUpload(url=f"https://storage.test/{bucket}/{path}?token=signed")

    def object_info(self, *, bucket, path):
        content = self.objects.get((bucket, path))
        if content is None:
            raise StorageObjectNotFound(path)
        return {"metadata": {"size": len(content)}}

    def download(self, *, bucket, path):
        content = self.objects.get((bucket, path))
        if content is None:
            raise StorageObjectNotFound(path)
        return content

    def upload(self, *, bucket, path, content, mime_type):
        self.objects[(bucket, path)] = content

    def remove(self, *, bucket, path):
        if self.objects.pop((bucket, path), None) is None:
            raise StorageObjectNotFound(path)

    def public_url(self, *, bucket, path):
        return f"https://storage.test/public/{bucket}/{path}"


def make_png() -> bytes:
    output = BytesIO()
    Image.new("RGB", (320, 240), "white").save(output, format="PNG")
    return output.getvalue()


def make_service(*, completion_score: int = 50, verified: bool = False):
    user_id = uuid4()
    profile = Profile(
        id=uuid4(),
        owner_user_id=user_id,
        role="business",
        visibility_status="draft",
        verification_status="verified" if verified else "unverified",
        completion_score=completion_score,
        completion_flags={},
        photo_count=0,
        is_verified=verified,
        reverification_required=False,
    )
    target = MediaTarget(entity_type="profile", entity=profile, profile=profile)
    repository = FakeMediaRepository(target, user_id)
    profile_repository = FakeProfileRepository()
    storage = FakeStorage()
    service = MediaService(
        repository=repository,
        profile_repository=profile_repository,
        storage=storage,
        settings=Settings(app_env="test"),
    )
    profile_service = FakeProfileService()
    service.profile_service = profile_service
    current_user = CurrentUser(
        user_id=user_id,
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    return service, repository, storage, profile_service, current_user


def upload_request(content: bytes) -> UploadIntentRequest:
    return UploadIntentRequest(
        entity_type="profile",
        entity_id=uuid4(),
        media_kind="image",
        visibility="public",
        document_type="shop_photo",
        filename="shop.png",
        mime_type="image/png",
        byte_size=len(content),
    )


def create_intent(service, repository, current_user, content):
    payload = upload_request(content)
    payload.entity_id = repository.target.entity.id
    return service.create_upload_intent(current_user=current_user, payload=payload)


def test_public_image_is_staged_then_promoted_after_byte_validation() -> None:
    service, repository, storage, profile_service, current_user = make_service()
    content = make_png()

    intent = create_intent(service, repository, current_user, content)
    media = repository.media[intent.media_asset.id]
    private_bucket = service.settings.supabase_private_verification_bucket
    storage.objects[(private_bucket, media.original_path)] = content

    response = service.complete_upload(
        current_user=current_user,
        media_asset_id=media.id,
    )

    assert response.upload_status == "ready"
    assert response.url is not None
    assert response.thumbnail_url is not None
    assert media.width == 320
    assert media.height == 240
    assert media.original_path.startswith(f"profile/{repository.target.entity.id}/")
    assert media.thumbnail_path == (
        f"profile/{repository.target.entity.id}/{media.id}-thumbnail.jpg"
    )
    assert (
        service.settings.supabase_public_media_bucket,
        media.thumbnail_path,
    ) in storage.objects
    assert (private_bucket, f"staging/{current_user.user_id}/{media.id}.png") not in (
        storage.objects
    )
    assert profile_service.refreshed == [repository.target.profile.id]


def test_invalid_image_is_failed_and_never_promoted_publicly() -> None:
    service, repository, storage, _, current_user = make_service()
    content = b"not-an-image"
    intent = create_intent(service, repository, current_user, content)
    media = repository.media[intent.media_asset.id]
    private_bucket = service.settings.supabase_private_verification_bucket
    storage.objects[(private_bucket, media.original_path)] = content

    with pytest.raises(ApiError) as exc_info:
        service.complete_upload(
            current_user=current_user,
            media_asset_id=media.id,
        )

    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED
    assert media.upload_status == "failed"
    assert not any(
        bucket == service.settings.supabase_public_media_bucket
        for bucket, _ in storage.objects
    )

    with pytest.raises(ApiError):
        service.complete_upload(
            current_user=current_user,
            media_asset_id=media.id,
        )
    retried = service.retry_upload(
        current_user=current_user,
        media_asset_id=media.id,
    )
    assert retried.media_asset.upload_status == "pending_upload"


def test_missing_storage_object_keeps_upload_pending() -> None:
    service, repository, _, _, current_user = make_service()
    content = make_png()
    intent = create_intent(service, repository, current_user, content)
    media = repository.media[intent.media_asset.id]

    with pytest.raises(ApiError) as exc_info:
        service.complete_upload(
            current_user=current_user,
            media_asset_id=media.id,
        )

    assert exc_info.value.code == ErrorCode.UPLOAD_NOT_READY
    assert media.upload_status == "pending_upload"


def test_cancel_marks_pending_upload_deleted() -> None:
    service, repository, _, _, current_user = make_service()
    intent = create_intent(service, repository, current_user, make_png())
    media = repository.media[intent.media_asset.id]

    service.cancel_upload(current_user=current_user, media_asset_id=media.id)

    assert media.upload_status == "deleted"
    assert media.deleted_at is not None


def test_delete_allows_completed_profile_to_drop_below_photo_minimum() -> None:
    service, repository, storage, _, current_user = make_service(completion_score=100)
    for index in range(3):
        media = MediaAsset(
            id=uuid4(),
            entity_type="profile",
            entity_id=repository.target.entity.id,
            media_kind="image",
            document_type="shop_photo",
            visibility="public",
            upload_status="ready",
            original_path=f"profile/photo-{index}.png",
            sort_order=index,
            uploaded_by_user_id=current_user.user_id,
        )
        repository.media[media.id] = media
        storage.objects[
            (service.settings.supabase_public_media_bucket, media.original_path)
        ] = make_png()

    selected = next(iter(repository.media.values()))
    service.delete_media(current_user=current_user, media_asset_id=selected.id)

    assert selected.upload_status == "deleted"
    assert selected.deleted_at is not None
    assert repository.target.entity.photo_count == 2


def test_delete_still_protects_published_work_card_photo_minimum() -> None:
    service, repository, storage, _, current_user = make_service()
    card = WorkCard(
        id=uuid4(),
        profile_id=uuid4(),
        title="Flat hemming",
        status="published",
        photo_count=3,
    )
    repository.target = MediaTarget(
        entity_type="work_card",
        entity=card,
        profile=repository.target.profile,
    )
    for index in range(3):
        media = MediaAsset(
            id=uuid4(),
            entity_type="work_card",
            entity_id=card.id,
            media_kind="image",
            document_type="work_photo",
            visibility="public",
            upload_status="ready",
            original_path=f"work-card/photo-{index}.png",
            sort_order=index,
            uploaded_by_user_id=current_user.user_id,
        )
        repository.media[media.id] = media
        storage.objects[
            (service.settings.supabase_public_media_bucket, media.original_path)
        ] = make_png()

    selected = next(iter(repository.media.values()))
    with pytest.raises(ApiError) as exc_info:
        service.delete_media(current_user=current_user, media_asset_id=selected.id)

    assert exc_info.value.code == ErrorCode.MINIMUM_PHOTOS_REQUIRED
    assert selected.upload_status == "ready"


def test_delete_allows_completed_profile_after_replacement_is_ready() -> None:
    service, repository, storage, _, current_user = make_service(completion_score=100)
    for index in range(4):
        media = MediaAsset(
            id=uuid4(),
            entity_type="profile",
            entity_id=repository.target.entity.id,
            media_kind="image",
            document_type="shop_photo",
            visibility="public",
            upload_status="ready",
            original_path=f"profile/photo-{index}.png",
            thumbnail_path=f"profile/photo-{index}-thumbnail.jpg",
            sort_order=index,
            uploaded_by_user_id=current_user.user_id,
        )
        repository.media[media.id] = media
        storage.objects[
            (service.settings.supabase_public_media_bucket, media.original_path)
        ] = make_png()
        storage.objects[
            (service.settings.supabase_public_media_bucket, media.thumbnail_path)
        ] = make_png()

    selected = next(iter(repository.media.values()))
    service.delete_media(current_user=current_user, media_asset_id=selected.id)

    assert selected.upload_status == "deleted"
    assert selected.deleted_at is not None
    assert repository.target.entity.photo_count == 3


def test_private_document_response_never_contains_download_url() -> None:
    service, repository, storage, _, current_user = make_service()
    verification_case = VerificationCase(
        id=uuid4(),
        profile_id=repository.target.profile.id,
        case_reason="initial_verification",
        status="draft",
    )
    repository.target = MediaTarget(
        entity_type="verification_case",
        entity=verification_case,
        profile=repository.target.profile,
    )
    content = b"%PDF-1.7\nprivate proof"
    payload = UploadIntentRequest(
        entity_type="verification_case",
        entity_id=verification_case.id,
        media_kind="document",
        visibility="private_admin_only",
        document_type="identity_proof",
        filename="aadhaar.pdf",
        mime_type="application/pdf",
        byte_size=len(content),
    )
    intent = service.create_upload_intent(current_user=current_user, payload=payload)
    media = repository.media[intent.media_asset.id]
    storage.objects[
        (service.settings.supabase_private_verification_bucket, media.original_path)
    ] = content

    response = service.complete_upload(
        current_user=current_user,
        media_asset_id=media.id,
    )

    assert response.upload_status == "ready"
    assert response.url is None
    assert response.safe_display_name == "Identity Proof"


def test_ready_shop_photo_change_removes_verification_badge() -> None:
    service, repository, storage, _, current_user = make_service(verified=True)
    content = make_png()
    intent = create_intent(service, repository, current_user, content)
    media = repository.media[intent.media_asset.id]
    storage.objects[
        (service.settings.supabase_private_verification_bucket, media.original_path)
    ] = content

    service.complete_upload(current_user=current_user, media_asset_id=media.id)

    profile = repository.target.profile
    assert profile.is_verified is False
    assert profile.verification_status == "unverified"
    assert profile.reverification_required is True
    assert service.profile_repository.histories[0]["requires_reverification"] is True
