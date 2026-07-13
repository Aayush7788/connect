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
from app.db.models.marketplace import WorkCard
from app.modules.media.schemas import MediaAssetResponse, MediaKind, MediaVisibility
from app.modules.profiles.service import CompletionResult, ProfileService
from app.modules.work_cards.repository import OwnerWorkCardContext
from app.modules.work_cards.repository import WorkCardBundle, WorkCardRepository
from app.modules.work_cards.schemas import WorkCardListResponse, WorkCardResponse
from app.modules.work_cards.schemas import WorkCardStatus, WorkCardUpsertRequest


def normalize_search_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value).casefold()
    return " ".join(normalized.split())


def has_text(value: str | None) -> bool:
    return bool(value and value.strip())


class WorkCardService:
    def __init__(
        self,
        *,
        repository: WorkCardRepository,
        profile_service: ProfileService,
        public_media_url: Callable[[str], str] | None = None,
    ) -> None:
        self.repository = repository
        self.profile_service = profile_service
        self.public_media_url = public_media_url

    def list_owner_work_cards(
        self,
        current_user: CurrentUser,
    ) -> WorkCardListResponse:
        context = self._get_context(current_user.user_id)
        self._ensure_job_worker(current_user, context)
        return WorkCardListResponse(
            items=[
                self._response(bundle)
                for bundle in self.repository.list_owned_bundles(current_user.user_id)
            ]
        )

    def create_work_card(
        self,
        *,
        current_user: CurrentUser,
        payload: WorkCardUpsertRequest,
        idempotency_key: str | None,
    ) -> WorkCardResponse:
        context = self._get_context(current_user.user_id, for_update=True)
        self._ensure_job_worker(current_user, context)
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
                    self.repository.hydrate_card(context=context, card=existing)
                )

        card = WorkCard(
            profile_id=context.profile.id,
            title="Untitled work",
            status="draft",
            creation_idempotency_key=key,
            creation_request_hash=request_hash,
        )
        self.repository.add(card)
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
                self.repository.hydrate_card(
                    context=retry_context,
                    card=existing,
                )
            )

        bundle = self.repository.hydrate_card(context=context, card=card)
        bundle = self._apply_payload(bundle, payload)
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self._refresh_profile(bundle)
        self.repository.commit()
        return self._get_response(current_user.user_id, card.id, include_deleted=True)

    def update_work_card(
        self,
        *,
        current_user: CurrentUser,
        work_card_id: UUID,
        payload: WorkCardUpsertRequest,
    ) -> WorkCardResponse:
        if not payload.model_fields_set:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={"body": "At least one work field is required."},
            )
        bundle = self._get_bundle(
            current_user=current_user,
            work_card_id=work_card_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_card_mutable(bundle.card)
        bundle = self._apply_payload(bundle, payload)
        bundle.card.photo_count = self.repository.ready_public_photo_count(
            bundle.card.id
        )
        if bundle.card.status in {"published", "hidden_by_user"}:
            self._ensure_publishable(bundle)
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self._refresh_profile(bundle)
        self.repository.commit()
        return self._get_response(current_user.user_id, work_card_id)

    def publish_work_card(
        self,
        *,
        current_user: CurrentUser,
        work_card_id: UUID,
    ) -> WorkCardResponse:
        bundle = self._get_bundle(
            current_user=current_user,
            work_card_id=work_card_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_card_mutable(bundle.card)
        if bundle.card.status == "published":
            return self._response(bundle)
        if bundle.card.status != "draft":
            raise self._invalid_state("Use Show to publish a hidden work card again.")
        bundle.card.photo_count = self.repository.ready_public_photo_count(
            bundle.card.id
        )
        self._ensure_publishable(bundle)
        bundle.card.status = "published"
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self._refresh_profile(bundle)
        self.repository.commit()
        return self._get_response(current_user.user_id, work_card_id)

    def hide_work_card(
        self,
        *,
        current_user: CurrentUser,
        work_card_id: UUID,
    ) -> WorkCardResponse:
        bundle = self._get_bundle(
            current_user=current_user,
            work_card_id=work_card_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_card_mutable(bundle.card)
        if bundle.card.status == "hidden_by_user":
            return self._response(bundle)
        if bundle.card.status != "published":
            raise self._invalid_state("Only published work can be hidden.")
        bundle.card.status = "hidden_by_user"
        bundle.card.last_activity_at = datetime.now(timezone.utc)
        bundle.context.profile.last_activity_at = bundle.card.last_activity_at
        self.repository.flush()
        self._refresh_profile(bundle)
        self.repository.commit()
        return self._get_response(current_user.user_id, work_card_id)

    def show_work_card(
        self,
        *,
        current_user: CurrentUser,
        work_card_id: UUID,
    ) -> WorkCardResponse:
        bundle = self._get_bundle(
            current_user=current_user,
            work_card_id=work_card_id,
            for_update=True,
        )
        self._ensure_profile_mutable(bundle.context)
        self._ensure_card_mutable(bundle.card)
        if bundle.card.status == "published":
            return self._response(bundle)
        if bundle.card.status != "hidden_by_user":
            raise self._invalid_state("Only hidden work can be shown.")
        bundle.card.photo_count = self.repository.ready_public_photo_count(
            bundle.card.id
        )
        self._ensure_publishable(bundle)
        bundle.card.status = "published"
        self._refresh_materialized_fields(bundle)
        self.repository.flush()
        self._refresh_profile(bundle)
        self.repository.commit()
        return self._get_response(current_user.user_id, work_card_id)

    def delete_work_card(
        self,
        *,
        current_user: CurrentUser,
        work_card_id: UUID,
    ) -> None:
        bundle = self._get_bundle(
            current_user=current_user,
            work_card_id=work_card_id,
            for_update=True,
            include_deleted=True,
        )
        self._ensure_profile_mutable(bundle.context)
        if bundle.card.status == "deleted":
            return
        self._ensure_card_mutable(bundle.card)
        now = datetime.now(timezone.utc)
        bundle.card.status = "deleted"
        bundle.card.deleted_at = now
        bundle.card.last_activity_at = now
        bundle.context.profile.last_activity_at = now
        self.repository.flush()
        self._refresh_profile(bundle)
        self.repository.commit()

    def _apply_payload(
        self,
        bundle: WorkCardBundle,
        payload: WorkCardUpsertRequest,
    ) -> WorkCardBundle:
        self._validate_payload_categories(payload)
        card = bundle.card
        fields = payload.model_fields_set
        if "category_id" in fields:
            card.work_category_id = payload.category_id
            if payload.category_id is not None:
                card.custom_work_category_text = None
        if "custom_category_text" in fields:
            card.custom_work_category_text = payload.custom_category_text
            if payload.custom_category_text is not None:
                card.work_category_id = None
        if "work_name_id" in fields:
            card.work_name_category_id = payload.work_name_id
            if payload.work_name_id is not None:
                card.custom_work_name = None
        if "custom_work_name" in fields:
            card.custom_work_name = payload.custom_work_name
            if payload.custom_work_name is not None:
                card.work_name_category_id = None
        if "description" in fields:
            card.description = payload.description
        if "experience_years" in fields:
            card.experience_years = payload.experience_years

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
                work_card_id=card.id,
                category_ids=category_ids or [],
                custom_values=custom_values or [],
            )

        self.repository.flush()
        bundle = self.repository.hydrate_card(context=bundle.context, card=card)
        self._validate_category_relationship(bundle)
        card.title = self._work_name(bundle) or "Untitled work"
        self._sync_suggestions(bundle)
        return bundle

    def _validate_payload_categories(self, payload: WorkCardUpsertRequest) -> None:
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

    def _validate_category_relationship(self, bundle: WorkCardBundle) -> None:
        card = bundle.card
        if card.work_category_id is None or card.work_name_category_id is None:
            return
        category = bundle.categories.get(card.work_category_id)
        work_name = bundle.categories.get(card.work_name_category_id)
        if category is None or work_name is None or work_name.parent_id != category.id:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={
                    "work_name_id": "Select a work name from the chosen category."
                },
            )

    def _ensure_publishable(self, bundle: WorkCardBundle) -> None:
        card = bundle.card
        errors: dict[str, str] = {}
        category = (
            bundle.categories.get(card.work_category_id)
            if card.work_category_id is not None
            else None
        )
        work_name = (
            bundle.categories.get(card.work_name_category_id)
            if card.work_name_category_id is not None
            else None
        )
        if (category is None or not category.is_active) and not has_text(
            card.custom_work_category_text
        ):
            errors["category_id"] = "Select or enter a work category."
        elif category is not None and category.category_type != "work_category":
            errors["category_id"] = "Select a valid work category."
        if (work_name is None or not work_name.is_active) and not has_text(
            card.custom_work_name
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
        if not has_text(card.description):
            errors["description"] = "Please describe this work."
        if card.photo_count < 3:
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
                    else "Complete the required work details first."
                ),
                details={"missing_fields": sorted(errors)},
                field_errors=errors,
            )

    def _sync_suggestions(self, bundle: WorkCardBundle) -> None:
        card = bundle.card
        suggestions: dict[str, list[tuple[str, str]]] = {
            "work_category": [],
            "work_name": [],
            "product_type": [],
        }
        if has_text(card.custom_work_category_text):
            raw = card.custom_work_category_text or ""
            suggestions["work_category"].append((raw, normalize_search_text(raw)))
        if has_text(card.custom_work_name):
            raw = card.custom_work_name or ""
            suggestions["work_name"].append((raw, normalize_search_text(raw)))
        for product in bundle.product_types:
            if has_text(product.custom_product_type_text):
                raw = product.custom_product_type_text or ""
                suggestions["product_type"].append((raw, normalize_search_text(raw)))
        self.repository.sync_pending_suggestions(
            user_id=bundle.context.user.id,
            profile_id=bundle.context.profile.id,
            work_card_id=card.id,
            suggestions=suggestions,
        )

    def _refresh_materialized_fields(self, bundle: WorkCardBundle) -> None:
        card = bundle.card
        card.photo_count = self.repository.ready_public_photo_count(card.id)
        category_ids = {
            category_id
            for category_id in (
                card.work_category_id,
                card.work_name_category_id,
                *(product.product_type_category_id for product in bundle.product_types),
            )
            if category_id is not None
        }
        values = [
            bundle.context.profile.public_name,
            card.title,
            self._category_name(bundle),
            card.custom_work_category_text,
            self._work_name(bundle),
            card.custom_work_name,
            card.description,
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
        card.search_text = search_text
        self.repository.set_search_vector(card, search_text)
        score = Decimal(card.photo_count)
        if has_text(card.description):
            score += Decimal("1")
        if card.experience_years is not None:
            score += Decimal("0.5")
        card.ranking_score = score
        now = datetime.now(timezone.utc)
        card.last_activity_at = now
        bundle.context.profile.last_activity_at = now

    def _refresh_profile(self, bundle: WorkCardBundle) -> CompletionResult:
        completion = self.profile_service.refresh_completion(bundle.context.profile.id)
        profile = bundle.context.profile
        if not completion.is_complete and profile.visibility_status == "public":
            profile.visibility_status = "draft"
        elif (
            completion.is_complete
            and profile.visibility_status == "draft"
            and bundle.context.user.profile_completed_at is not None
        ):
            profile.visibility_status = "public"
        return completion

    def _get_context(
        self,
        user_id: UUID,
        *,
        for_update: bool = False,
    ) -> OwnerWorkCardContext:
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
        work_card_id: UUID,
        for_update: bool = False,
        include_deleted: bool = False,
    ) -> WorkCardBundle:
        context = self._get_context(current_user.user_id)
        self._ensure_job_worker(current_user, context)
        bundle = self.repository.get_owned_bundle(
            user_id=current_user.user_id,
            work_card_id=work_card_id,
            for_update=for_update,
            include_deleted=include_deleted,
        )
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Work card not found.",
            )
        return bundle

    def _get_response(
        self,
        user_id: UUID,
        work_card_id: UUID,
        *,
        include_deleted: bool = False,
    ) -> WorkCardResponse:
        bundle = self.repository.get_owned_bundle(
            user_id=user_id,
            work_card_id=work_card_id,
            include_deleted=include_deleted,
        )
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Work card not found.",
            )
        return self._response(bundle)

    def _response(self, bundle: WorkCardBundle) -> WorkCardResponse:
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
        return WorkCardResponse(
            id=bundle.card.id,
            profile_id=bundle.card.profile_id,
            status=cast(WorkCardStatus, bundle.card.status),
            title=bundle.card.title,
            category_id=bundle.card.work_category_id,
            category_name=self._category_name(bundle),
            custom_category_text=bundle.card.custom_work_category_text,
            work_name_id=bundle.card.work_name_category_id,
            work_name=self._work_name(bundle),
            custom_work_name=bundle.card.custom_work_name,
            product_type_ids=mapped_product_ids,
            custom_product_texts=custom_products,
            product_types=self._product_names(bundle),
            description=bundle.card.description,
            experience_years=bundle.card.experience_years,
            photo_count=bundle.card.photo_count,
            photos=photos,
            last_activity_at=bundle.card.last_activity_at,
            created_at=bundle.card.created_at,
            updated_at=bundle.card.updated_at,
        )

    def _category_name(self, bundle: WorkCardBundle) -> str | None:
        category = (
            bundle.categories.get(bundle.card.work_category_id)
            if bundle.card.work_category_id is not None
            else None
        )
        return (
            category.name
            if category is not None
            else bundle.card.custom_work_category_text
        )

    def _work_name(self, bundle: WorkCardBundle) -> str | None:
        category = (
            bundle.categories.get(bundle.card.work_name_category_id)
            if bundle.card.work_name_category_id is not None
            else None
        )
        return category.name if category is not None else bundle.card.custom_work_name

    def _product_names(self, bundle: WorkCardBundle) -> list[str]:
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
    def _ensure_job_worker(
        current_user: CurrentUser,
        context: OwnerWorkCardContext,
    ) -> None:
        if current_user.role != "job_worker" or context.profile.role != "job_worker":
            raise ApiError(
                status_code=403,
                code=ErrorCode.FORBIDDEN,
                message="Only job workers can manage work cards.",
            )

    @staticmethod
    def _ensure_profile_mutable(context: OwnerWorkCardContext) -> None:
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
                message="This profile cannot manage work cards.",
            )

    @staticmethod
    def _ensure_card_mutable(card: WorkCard) -> None:
        if card.status in {"removed_by_admin", "deleted"}:
            raise ApiError(
                status_code=409,
                code=ErrorCode.FORBIDDEN,
                message="This work cannot be changed.",
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
    def _request_hash(payload: WorkCardUpsertRequest) -> str:
        serialized = json.dumps(
            payload.model_dump(mode="json", exclude_unset=True),
            sort_keys=True,
            separators=(",", ":"),
        )
        return hashlib.sha256(serialized.encode("utf-8")).hexdigest()

    @staticmethod
    def _ensure_same_idempotent_request(
        card: WorkCard,
        request_hash: str | None,
    ) -> None:
        if card.creation_request_hash != request_hash:
            raise ApiError(
                status_code=409,
                code=ErrorCode.VALIDATION_FAILED,
                message="This request key was already used with different details.",
                field_errors={
                    "Idempotency-Key": "Use a new key for different work details."
                },
            )

    @staticmethod
    def _invalid_state(message: str) -> ApiError:
        return ApiError(
            status_code=409,
            code=ErrorCode.VALIDATION_FAILED,
            message=message,
        )
