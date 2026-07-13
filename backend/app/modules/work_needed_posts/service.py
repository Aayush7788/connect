import hashlib
import json
import unicodedata
from collections.abc import Callable
from datetime import datetime, timezone
from decimal import Decimal
from typing import cast
from uuid import UUID

from sqlalchemy.exc import IntegrityError

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.db.models.marketplace import WorkNeededPost
from app.modules.media.schemas import MediaAssetResponse, MediaKind, MediaVisibility
from app.modules.work_needed_posts.repository import OwnerWorkNeededContext
from app.modules.work_needed_posts.repository import WorkNeededPostBundle
from app.modules.work_needed_posts.repository import WorkNeededPostRepository
from app.modules.work_needed_posts.schemas import WorkNeededPostListResponse
from app.modules.work_needed_posts.schemas import WorkNeededPostResponse
from app.modules.work_needed_posts.schemas import WorkNeededPostStatus
from app.modules.work_needed_posts.schemas import WorkNeededPostUpsertRequest


def normalize_search_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value).casefold()
    return " ".join(normalized.split())


def has_text(value: str | None) -> bool:
    return bool(value and value.strip())


class WorkNeededPostService:
    def __init__(
        self,
        *,
        repository: WorkNeededPostRepository,
        public_media_url: Callable[[str], str] | None = None,
    ) -> None:
        self.repository = repository
        self.public_media_url = public_media_url

    def list_owner_posts(
        self,
        current_user: CurrentUser,
    ) -> WorkNeededPostListResponse:
        context = self._get_context(current_user.user_id)
        self._ensure_business(current_user, context)
        return WorkNeededPostListResponse(
            items=[
                self._response(bundle)
                for bundle in self.repository.list_owned_bundles(current_user.user_id)
            ]
        )

    def create_post(
        self,
        *,
        current_user: CurrentUser,
        payload: WorkNeededPostUpsertRequest,
        idempotency_key: str | None,
    ) -> WorkNeededPostResponse:
        context = self._get_context(current_user.user_id, for_update=True)
        self._ensure_business(current_user, context)
        self._ensure_profile_mutable(context)
        key = self._normalize_idempotency_key(idempotency_key)
        request_hash = self._request_hash(payload) if key is not None else None
        if key is not None:
            existing = self.repository.get_by_creation_key(
                profile_id=context.profile.id,
                idempotency_key=key,
            )
            if existing is not None:
                self._ensure_same_idempotent_request(existing, request_hash)
                return self._response(
                    self.repository.hydrate_post(context=context, post=existing)
                )

        post = WorkNeededPost(
            profile_id=context.profile.id,
            title="Untitled work needed",
            status="draft",
            creation_idempotency_key=key,
            creation_request_hash=request_hash,
        )
        self.repository.add(post)
        try:
            self.repository.flush()
        except IntegrityError:
            if key is None:
                raise
            self.repository.rollback()
            retry_context = self._get_context(current_user.user_id)
            existing = self.repository.get_by_creation_key(
                profile_id=retry_context.profile.id,
                idempotency_key=key,
            )
            if existing is None:
                raise
            self._ensure_same_idempotent_request(existing, request_hash)
            return self._response(
                self.repository.hydrate_post(
                    context=retry_context,
                    post=existing,
                )
            )

        bundle = self.repository.hydrate_post(context=context, post=post)
        bundle = self._apply_payload(bundle, payload)
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self.repository.commit()
        return self._get_response(current_user.user_id, post.id, include_deleted=True)

    def update_post(
        self,
        *,
        current_user: CurrentUser,
        post_id: UUID,
        payload: WorkNeededPostUpsertRequest,
    ) -> WorkNeededPostResponse:
        if not payload.model_fields_set:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={"body": "At least one post field is required."},
            )
        bundle = self._get_bundle(
            current_user=current_user,
            post_id=post_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_post_mutable(bundle.post)
        self._ensure_live_payload_keeps_required_fields(bundle, payload)
        bundle = self._apply_payload(bundle, payload)
        bundle.post.photo_count = self.repository.ready_public_photo_count(
            bundle.post.id
        )
        if bundle.post.status in {"active", "paused", "closed_by_user"}:
            self._ensure_publishable(bundle)
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self.repository.commit()
        return self._get_response(current_user.user_id, post_id)

    def publish_post(
        self,
        *,
        current_user: CurrentUser,
        post_id: UUID,
        idempotency_key: str | None,
    ) -> WorkNeededPostResponse:
        self._normalize_idempotency_key(idempotency_key)
        bundle = self._get_bundle(
            current_user=current_user,
            post_id=post_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_post_mutable(bundle.post)
        if bundle.post.status == "active":
            return self._response(bundle)
        if bundle.post.status != "draft":
            raise self._invalid_state("Only a draft post can be published.")
        bundle.post.photo_count = self.repository.ready_public_photo_count(
            bundle.post.id
        )
        self._ensure_publishable(bundle)
        bundle.post.status = "active"
        bundle.post.closed_at = None
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self.repository.commit()
        return self._get_response(current_user.user_id, post_id)

    def pause_post(
        self,
        *,
        current_user: CurrentUser,
        post_id: UUID,
    ) -> WorkNeededPostResponse:
        bundle = self._get_bundle(
            current_user=current_user,
            post_id=post_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_post_mutable(bundle.post)
        if bundle.post.status == "paused":
            return self._response(bundle)
        if bundle.post.status != "active":
            raise self._invalid_state("Only an active post can be paused.")
        bundle.post.status = "paused"
        self._touch(bundle)
        self.repository.flush()
        self.repository.commit()
        return self._get_response(current_user.user_id, post_id)

    def resume_post(
        self,
        *,
        current_user: CurrentUser,
        post_id: UUID,
    ) -> WorkNeededPostResponse:
        bundle = self._get_bundle(
            current_user=current_user,
            post_id=post_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_post_mutable(bundle.post)
        if bundle.post.status == "active":
            return self._response(bundle)
        if bundle.post.status != "paused":
            raise self._invalid_state("Only a paused post can be resumed.")
        bundle.post.photo_count = self.repository.ready_public_photo_count(
            bundle.post.id
        )
        self._ensure_publishable(bundle)
        bundle.post.status = "active"
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self.repository.commit()
        return self._get_response(current_user.user_id, post_id)

    def close_post(
        self,
        *,
        current_user: CurrentUser,
        post_id: UUID,
        idempotency_key: str | None,
    ) -> WorkNeededPostResponse:
        self._normalize_idempotency_key(idempotency_key)
        bundle = self._get_bundle(
            current_user=current_user,
            post_id=post_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_post_mutable(bundle.post)
        if bundle.post.status == "closed_by_user":
            return self._response(bundle)
        if bundle.post.status not in {"active", "paused"}:
            raise self._invalid_state("Only an active or paused post can be closed.")
        now = datetime.now(timezone.utc)
        bundle.post.status = "closed_by_user"
        bundle.post.closed_at = now
        bundle.post.last_activity_at = now
        bundle.context.profile.last_activity_at = now
        self.repository.flush()
        self.repository.commit()
        return self._get_response(current_user.user_id, post_id)

    def delete_post(
        self,
        *,
        current_user: CurrentUser,
        post_id: UUID,
    ) -> None:
        bundle = self._get_bundle(
            current_user=current_user,
            post_id=post_id,
            for_update=True,
            include_deleted=True,
        )
        self._ensure_profile_mutable(bundle.context)
        if bundle.post.status == "deleted":
            return
        self._ensure_post_mutable(bundle.post)
        now = datetime.now(timezone.utc)
        bundle.post.status = "deleted"
        bundle.post.deleted_at = now
        bundle.post.closed_at = bundle.post.closed_at or now
        bundle.post.last_activity_at = now
        bundle.context.profile.last_activity_at = now
        self.repository.flush()
        self.repository.commit()

    def _apply_payload(
        self,
        bundle: WorkNeededPostBundle,
        payload: WorkNeededPostUpsertRequest,
    ) -> WorkNeededPostBundle:
        self._validate_payload_categories(payload)
        post = bundle.post
        fields = payload.model_fields_set
        if "category_id" in fields:
            post.work_category_id = payload.category_id
            if payload.category_id is not None:
                post.custom_work_category_text = None
        if "custom_category_text" in fields:
            post.custom_work_category_text = payload.custom_category_text
            if payload.custom_category_text is not None:
                post.work_category_id = None
        if "work_name_id" in fields:
            post.work_name_category_id = payload.work_name_id
            if payload.work_name_id is not None:
                post.custom_work_name = None
        if "custom_work_name" in fields:
            post.custom_work_name = payload.custom_work_name
            if payload.custom_work_name is not None:
                post.work_name_category_id = None
        if "description" in fields:
            post.description = payload.description

        if {"product_type_ids", "custom_product_texts"} & fields:
            category_ids = (
                payload.product_type_ids
                if "product_type_ids" in fields
                else [
                    item.product_type_category_id
                    for item in bundle.product_types
                    if item.product_type_category_id is not None
                ]
            )
            custom_values = (
                payload.custom_product_texts
                if "custom_product_texts" in fields
                else [
                    item.custom_product_type_text
                    for item in bundle.product_types
                    if item.custom_product_type_text is not None
                ]
            )
            self._validate_product_types(category_ids or [])
            self.repository.replace_product_types(
                post_id=post.id,
                category_ids=category_ids or [],
                custom_values=custom_values or [],
            )

        self.repository.flush()
        bundle = self.repository.hydrate_post(context=bundle.context, post=post)
        self._validate_category_relationship(bundle)
        post.title = self._work_name(bundle) or "Untitled work needed"
        self._sync_suggestions(bundle)
        return bundle

    def _ensure_live_payload_keeps_required_fields(
        self,
        bundle: WorkNeededPostBundle,
        payload: WorkNeededPostUpsertRequest,
    ) -> None:
        if bundle.post.status not in {"active", "paused", "closed_by_user"}:
            return
        fields = payload.model_fields_set
        mapped_category = bundle.post.work_category_id
        custom_category = bundle.post.custom_work_category_text
        mapped_work = bundle.post.work_name_category_id
        custom_work = bundle.post.custom_work_name
        description = bundle.post.description
        mapped_products = [
            product.product_type_category_id
            for product in bundle.product_types
            if product.product_type_category_id is not None
        ]
        custom_products = [
            product.custom_product_type_text
            for product in bundle.product_types
            if product.custom_product_type_text is not None
        ]
        if "category_id" in fields:
            mapped_category = payload.category_id
            if mapped_category is not None:
                custom_category = None
        if "custom_category_text" in fields:
            custom_category = payload.custom_category_text
            if custom_category is not None:
                mapped_category = None
        if "work_name_id" in fields:
            mapped_work = payload.work_name_id
            if mapped_work is not None:
                custom_work = None
        if "custom_work_name" in fields:
            custom_work = payload.custom_work_name
            if custom_work is not None:
                mapped_work = None
        if "description" in fields:
            description = payload.description
        if "product_type_ids" in fields:
            mapped_products = payload.product_type_ids or []
        if "custom_product_texts" in fields:
            custom_products = payload.custom_product_texts or []
        errors: dict[str, str] = {}
        if mapped_category is None and not has_text(custom_category):
            errors["category_id"] = "Select or enter a work category."
        if mapped_work is None and not has_text(custom_work):
            errors["work_name_id"] = "Select or enter a work name."
        if not mapped_products and not any(has_text(value) for value in custom_products):
            errors["product_type_ids"] = "Select or enter at least one product type."
        if not has_text(description):
            errors["description"] = "Please describe the work you need."
        if errors:
            raise ApiError(
                status_code=409,
                code=ErrorCode.VALIDATION_FAILED,
                message="Complete the required post details first.",
                details={"missing_fields": sorted(errors)},
                field_errors=errors,
            )

    def _validate_payload_categories(
        self,
        payload: WorkNeededPostUpsertRequest,
    ) -> None:
        requested: dict[str, tuple[UUID, str]] = {}
        if payload.category_id is not None:
            requested["category_id"] = (payload.category_id, "work_category")
        if payload.work_name_id is not None:
            requested["work_name_id"] = (payload.work_name_id, "work_name")
        categories = self.repository.get_active_categories(
            {category_id for category_id, _ in requested.values()}
        )
        errors = {
            field: "Select a valid category."
            for field, (category_id, expected_type) in requested.items()
            if category_id not in categories
            or categories[category_id].category_type != expected_type
        }
        if errors:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors=errors,
            )

    def _validate_product_types(self, category_ids: list[UUID]) -> None:
        categories = self.repository.get_active_categories(set(category_ids))
        if len(categories) != len(set(category_ids)) or any(
            category.category_type != "product_type" for category in categories.values()
        ):
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={"product_type_ids": "Select valid product types."},
            )

    def _validate_category_relationship(self, bundle: WorkNeededPostBundle) -> None:
        post = bundle.post
        if post.work_category_id is None or post.work_name_category_id is None:
            return
        category = bundle.categories.get(post.work_category_id)
        work_name = bundle.categories.get(post.work_name_category_id)
        if category is None or work_name is None or work_name.parent_id != category.id:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={
                    "work_name_id": "Select a work name from the chosen category."
                },
            )

    def _ensure_publishable(self, bundle: WorkNeededPostBundle) -> None:
        post = bundle.post
        errors: dict[str, str] = {}
        category = (
            bundle.categories.get(post.work_category_id)
            if post.work_category_id is not None
            else None
        )
        work_name = (
            bundle.categories.get(post.work_name_category_id)
            if post.work_name_category_id is not None
            else None
        )
        if (category is None or not category.is_active) and not has_text(
            post.custom_work_category_text
        ):
            errors["category_id"] = "Select or enter a work category."
        elif category is not None and category.category_type != "work_category":
            errors["category_id"] = "Select a valid work category."
        if (work_name is None or not work_name.is_active) and not has_text(
            post.custom_work_name
        ):
            errors["work_name_id"] = "Select or enter a work name."
        elif work_name is not None and work_name.category_type != "work_name":
            errors["work_name_id"] = "Select a valid work name."
        if (
            category is not None
            and work_name is not None
            and work_name.parent_id != category.id
        ):
            errors["work_name_id"] = "Select a work name from the chosen category."
        invalid_product = any(
            product.product_type_category_id is not None
            and (
                product.product_type_category_id not in bundle.categories
                or not bundle.categories[product.product_type_category_id].is_active
                or bundle.categories[product.product_type_category_id].category_type
                != "product_type"
            )
            for product in bundle.product_types
        )
        if not bundle.product_types or invalid_product:
            errors["product_type_ids"] = "Select or enter at least one product type."
        if not has_text(post.description):
            errors["description"] = "Please describe the work you need."
        if post.photo_count < 3:
            errors["photos"] = "Minimum 3 photos required."
        if errors:
            code = (
                ErrorCode.MINIMUM_PHOTOS_REQUIRED
                if set(errors) == {"photos"}
                else ErrorCode.VALIDATION_FAILED
            )
            raise ApiError(
                status_code=409,
                code=code,
                message=(
                    "Minimum 3 photos required."
                    if code == ErrorCode.MINIMUM_PHOTOS_REQUIRED
                    else "Complete the required post details first."
                ),
                details={"missing_fields": sorted(errors)},
                field_errors=errors,
            )

    def _sync_suggestions(self, bundle: WorkNeededPostBundle) -> None:
        post = bundle.post
        suggestions: dict[str, list[tuple[str, str]]] = {
            "work_category": [],
            "work_name": [],
            "product_type": [],
        }
        if has_text(post.custom_work_category_text):
            raw = post.custom_work_category_text or ""
            suggestions["work_category"].append((raw, normalize_search_text(raw)))
        if has_text(post.custom_work_name):
            raw = post.custom_work_name or ""
            suggestions["work_name"].append((raw, normalize_search_text(raw)))
        for product in bundle.product_types:
            if has_text(product.custom_product_type_text):
                raw = product.custom_product_type_text or ""
                suggestions["product_type"].append((raw, normalize_search_text(raw)))
        self.repository.sync_pending_suggestions(
            user_id=bundle.context.user.id,
            profile_id=bundle.context.profile.id,
            post_id=post.id,
            suggestions=suggestions,
        )

    def _refresh_materialized_fields(self, bundle: WorkNeededPostBundle) -> None:
        post = bundle.post
        post.photo_count = self.repository.ready_public_photo_count(post.id)
        category_ids = {
            category_id
            for category_id in (
                post.work_category_id,
                post.work_name_category_id,
                *(product.product_type_category_id for product in bundle.product_types),
            )
            if category_id is not None
        }
        values = [
            bundle.context.profile.public_name,
            post.title,
            self._category_name(bundle),
            post.custom_work_category_text,
            self._work_name(bundle),
            post.custom_work_name,
            post.description,
            *self._product_names(bundle),
            *self.repository.category_aliases(category_ids),
        ]
        normalized_values: list[str] = []
        seen: set[str] = set()
        for value in values:
            if not has_text(value):
                continue
            normalized = normalize_search_text(value or "")
            if normalized and normalized not in seen:
                normalized_values.append(normalized)
                seen.add(normalized)
        search_text = " ".join(normalized_values)
        post.search_text = search_text
        self.repository.set_search_vector(post, search_text)
        post.ranking_score = Decimal(post.photo_count) + (
            Decimal("1") if has_text(post.description) else Decimal("0")
        )
        self._touch(bundle)

    @staticmethod
    def _touch(bundle: WorkNeededPostBundle) -> None:
        now = datetime.now(timezone.utc)
        bundle.post.last_activity_at = now
        bundle.context.profile.last_activity_at = now

    def _get_context(
        self,
        user_id: UUID,
        *,
        for_update: bool = False,
    ) -> OwnerWorkNeededContext:
        context = self.repository.get_owner_context(user_id, for_update=for_update)
        if context is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Profile not found.",
            )
        return context

    def _get_bundle(
        self,
        *,
        current_user: CurrentUser,
        post_id: UUID,
        for_update: bool = False,
        include_deleted: bool = False,
    ) -> WorkNeededPostBundle:
        context = self._get_context(current_user.user_id)
        self._ensure_business(current_user, context)
        bundle = self.repository.get_owned_bundle(
            user_id=current_user.user_id,
            post_id=post_id,
            for_update=for_update,
            include_deleted=include_deleted,
        )
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Work-needed post not found.",
            )
        return bundle

    def _get_response(
        self,
        user_id: UUID,
        post_id: UUID,
        *,
        include_deleted: bool = False,
    ) -> WorkNeededPostResponse:
        bundle = self.repository.get_owned_bundle(
            user_id=user_id,
            post_id=post_id,
            include_deleted=include_deleted,
        )
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Work-needed post not found.",
            )
        return self._response(bundle)

    def _response(self, bundle: WorkNeededPostBundle) -> WorkNeededPostResponse:
        mapped_product_ids = [
            product.product_type_category_id
            for product in bundle.product_types
            if product.product_type_category_id is not None
        ]
        custom_products = [
            product.custom_product_type_text
            for product in bundle.product_types
            if product.custom_product_type_text is not None
        ]
        photos = [
            MediaAssetResponse(
                id=media.id,
                media_kind=cast(MediaKind, media.media_kind),
                visibility=cast(MediaVisibility, media.visibility),
                upload_status=media.upload_status,
                url=(
                    self.public_media_url(media.original_path)
                    if media.upload_status == "ready" and self.public_media_url
                    else None
                ),
                thumbnail_url=(
                    self.public_media_url(media.thumbnail_path)
                    if media.upload_status == "ready"
                    and media.thumbnail_path
                    and self.public_media_url
                    else None
                ),
                sort_order=media.sort_order,
                document_type=media.document_type,
                safe_display_name=self.repository.safe_media_name(media),
            )
            for media in bundle.media
        ]
        return WorkNeededPostResponse(
            id=bundle.post.id,
            profile_id=bundle.post.profile_id,
            status=cast(WorkNeededPostStatus, bundle.post.status),
            title=bundle.post.title,
            category_id=bundle.post.work_category_id,
            category_name=self._category_name(bundle),
            custom_category_text=bundle.post.custom_work_category_text,
            work_name_id=bundle.post.work_name_category_id,
            work_name=self._work_name(bundle),
            custom_work_name=bundle.post.custom_work_name,
            product_type_ids=mapped_product_ids,
            custom_product_texts=custom_products,
            product_types=self._product_names(bundle),
            description=bundle.post.description,
            photo_count=bundle.post.photo_count,
            photos=photos,
            last_activity_at=bundle.post.last_activity_at,
            closed_at=bundle.post.closed_at,
            created_at=bundle.post.created_at,
            updated_at=bundle.post.updated_at,
        )

    def _category_name(self, bundle: WorkNeededPostBundle) -> str | None:
        category = (
            bundle.categories.get(bundle.post.work_category_id)
            if bundle.post.work_category_id is not None
            else None
        )
        return (
            category.name
            if category is not None
            else bundle.post.custom_work_category_text
        )

    def _work_name(self, bundle: WorkNeededPostBundle) -> str | None:
        category = (
            bundle.categories.get(bundle.post.work_name_category_id)
            if bundle.post.work_name_category_id is not None
            else None
        )
        return category.name if category is not None else bundle.post.custom_work_name

    def _product_names(self, bundle: WorkNeededPostBundle) -> list[str]:
        return [
            (
                bundle.categories[product.product_type_category_id].name
                if product.product_type_category_id in bundle.categories
                else product.custom_product_type_text or ""
            )
            for product in bundle.product_types
            if product.product_type_category_id in bundle.categories
            or has_text(product.custom_product_type_text)
        ]

    @staticmethod
    def _ensure_business(
        current_user: CurrentUser,
        context: OwnerWorkNeededContext,
    ) -> None:
        if current_user.role != "business" or context.profile.role != "business":
            raise ApiError(
                status_code=403,
                code=ErrorCode.FORBIDDEN,
                message="Only businesses can manage work-needed posts.",
            )

    @staticmethod
    def _ensure_profile_mutable(context: OwnerWorkNeededContext) -> None:
        if context.profile.verification_status == "pending":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VERIFICATION_PENDING_LOCKED,
                message="Profile editing is locked while verification is pending.",
            )
        if context.profile.visibility_status in {"suspended_by_admin", "deleted"}:
            raise ApiError(
                status_code=403,
                code=ErrorCode.FORBIDDEN,
                message="This profile cannot manage work-needed posts.",
            )

    @staticmethod
    def _ensure_post_mutable(post: WorkNeededPost) -> None:
        if post.status in {"removed_by_admin", "deleted"}:
            raise ApiError(
                status_code=409,
                code=ErrorCode.FORBIDDEN,
                message="This post cannot be changed.",
            )

    @staticmethod
    def _normalize_idempotency_key(value: str | None) -> str | None:
        if value is None:
            return None
        cleaned = value.strip()
        if not cleaned or len(cleaned) > 128:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={
                    "Idempotency-Key": "Use a value between 1 and 128 characters."
                },
            )
        return cleaned

    @staticmethod
    def _request_hash(payload: WorkNeededPostUpsertRequest) -> str:
        serialized = json.dumps(
            payload.model_dump(mode="json", exclude_unset=True),
            sort_keys=True,
            separators=(",", ":"),
        )
        return hashlib.sha256(serialized.encode("utf-8")).hexdigest()

    @staticmethod
    def _ensure_same_idempotent_request(
        post: WorkNeededPost,
        request_hash: str | None,
    ) -> None:
        if post.creation_request_hash != request_hash:
            raise ApiError(
                status_code=409,
                code=ErrorCode.VALIDATION_FAILED,
                message="This request key was already used with different details.",
                field_errors={
                    "Idempotency-Key": "Use a new key for different post details."
                },
            )

    @staticmethod
    def _invalid_state(message: str) -> ApiError:
        return ApiError(
            status_code=409,
            code=ErrorCode.VALIDATION_FAILED,
            message=message,
        )
