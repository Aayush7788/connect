from dataclasses import dataclass
from datetime import datetime, timezone
from collections.abc import Callable
from typing import Any
from uuid import UUID

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.modules.auth.schemas import ProfileSummaryResponse
from app.modules.auth.service import normalize_mobile
from app.modules.profiles.repository import OwnerProfileBundle
from app.modules.profiles.repository import ProfileRepository
from app.modules.profiles.schemas import OwnerMediaResponse, OwnerProfileResponse
from app.modules.profiles.schemas import ProfileUpdateRequest


COMMON_FIELDS = {
    "owner_name",
    "alternate_contact_number",
    "full_address",
    "address_line1",
    "address_line2",
    "locality",
    "city",
    "state",
    "pincode",
}
ROLE_FIELDS = {
    "business": {
        "business_name",
        "business_category_id",
        "manufacture_sell_details",
        "product_notes",
        "product_type_ids",
        "custom_product_types",
    },
    "job_worker": {
        "workshop_name",
        "has_workshop",
        "work_summary",
        "profile_experience_years",
    },
    "skilled_worker": {
        "primary_skill_category_id",
        "skill_mastery",
        "experience_years",
        "bio",
    },
}
SENSITIVE_FIELDS = {
    "alternate_contact_number",
    "full_address",
    "address_line1",
    "address_line2",
    "locality",
    "city",
    "state",
    "pincode",
    "business_name",
    "workshop_name",
    "has_workshop",
}


@dataclass(frozen=True)
class CompletionResult:
    score: int
    flags: dict[str, bool]

    @property
    def missing_fields(self) -> list[str]:
        return [field for field, complete in self.flags.items() if not complete]

    @property
    def is_complete(self) -> bool:
        return self.score == 100 and not self.missing_fields


def has_text(value: str | None) -> bool:
    return bool(value and value.strip())


def json_value(value: Any) -> Any:
    if isinstance(value, UUID):
        return str(value)
    if isinstance(value, list):
        return [json_value(item) for item in value]
    return value


class ProfileService:
    def __init__(
        self,
        repository: ProfileRepository,
        public_media_url: Callable[[str], str] | None = None,
    ) -> None:
        self.repository = repository
        self.public_media_url = public_media_url

    def get_owner_profile(self, current_user: CurrentUser) -> OwnerProfileResponse:
        bundle = self._get_bundle(current_user.user_id)
        self._ensure_active(bundle.user.account_status)
        completion = self._calculate_completion(bundle)
        return self._response(bundle, completion)

    def refresh_completion(self, profile_id: UUID) -> CompletionResult:
        bundle = self.repository.get_bundle_by_profile_id(
            profile_id,
            for_update=False,
        )
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Profile not found.",
            )
        completion = self._calculate_completion(bundle)
        bundle.profile.completion_score = completion.score
        bundle.profile.completion_flags = completion.flags
        bundle.profile.photo_count = self.repository.completion_evidence(
            bundle.profile
        ).public_photo_count
        return completion

    def update_owner_profile(
        self,
        *,
        current_user: CurrentUser,
        payload: ProfileUpdateRequest,
    ) -> OwnerProfileResponse:
        bundle = self._get_bundle(current_user.user_id, for_update=True)
        self._ensure_active(bundle.user.account_status)
        if bundle.profile.verification_status == "pending":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VERIFICATION_PENDING_LOCKED,
                message="Profile editing is locked while verification is pending.",
            )
        self._validate_payload_for_role(bundle, payload)
        if (
            bundle.user.profile_completed_at is not None
            and "owner_name" in payload.model_fields_set
            and payload.owner_name != bundle.profile.owner_name
        ):
            raise ApiError(
                status_code=409,
                code=ErrorCode.FORBIDDEN,
                message="Owner name cannot be changed after profile completion.",
                field_errors={"owner_name": "This field is locked."},
            )

        before: dict[str, Any] = {}
        after: dict[str, Any] = {}
        self._apply_common_fields(bundle, payload, before, after)
        self._apply_role_fields(bundle, payload, before, after)
        self.repository.flush()
        refreshed = self._get_bundle(current_user.user_id, for_update=True)
        completion = self._calculate_completion(refreshed)
        refreshed.profile.completion_score = completion.score
        refreshed.profile.completion_flags = completion.flags
        refreshed.profile.photo_count = self.repository.completion_evidence(
            refreshed.profile
        ).public_photo_count

        if (
            refreshed.profile.visibility_status == "public"
            and not completion.is_complete
        ):
            refreshed.profile.visibility_status = "draft"

        changed_fields = set(after)
        requires_reverification = bool(
            changed_fields & SENSITIVE_FIELDS
            and (
                refreshed.profile.is_verified
                or refreshed.profile.verification_status == "verified"
            )
        )
        if requires_reverification:
            refreshed.profile.verification_status = "unverified"
            refreshed.profile.is_verified = False
            refreshed.profile.reverification_required = True

        if after:
            refreshed.profile.last_activity_at = datetime.now(timezone.utc)
            self.repository.add_change_history(
                profile_id=refreshed.profile.id,
                user_id=refreshed.user.id,
                before=before,
                after=after,
                requires_reverification=requires_reverification,
            )
        self.repository.commit()
        final_bundle = self._get_bundle(current_user.user_id)
        return self._response(final_bundle, self._calculate_completion(final_bundle))

    def complete_owner_profile(
        self,
        current_user: CurrentUser,
    ) -> OwnerProfileResponse:
        bundle = self._get_bundle(current_user.user_id, for_update=True)
        self._ensure_active(bundle.user.account_status)
        if bundle.profile.verification_status == "pending":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VERIFICATION_PENDING_LOCKED,
                message="Profile editing is locked while verification is pending.",
            )
        completion = self._calculate_completion(bundle)
        evidence = self.repository.completion_evidence(bundle.profile)
        bundle.profile.completion_score = completion.score
        bundle.profile.completion_flags = completion.flags
        bundle.profile.photo_count = evidence.public_photo_count
        if not completion.is_complete:
            self.repository.commit()
            raise ApiError(
                status_code=409,
                code=ErrorCode.PROFILE_INCOMPLETE,
                message="Complete the required profile fields first.",
                details={"missing_fields": completion.missing_fields},
                field_errors={
                    field: "Required to complete your profile."
                    for field in completion.missing_fields
                },
            )
        now = datetime.now(timezone.utc)
        if bundle.user.profile_completed_at is None:
            bundle.user.profile_completed_at = now
        if bundle.profile.visibility_status == "draft":
            bundle.profile.visibility_status = "public"
        bundle.profile.last_activity_at = now
        self.repository.commit()
        final_bundle = self._get_bundle(current_user.user_id)
        return self._response(final_bundle, completion)

    def hide_owner_profile(self, current_user: CurrentUser) -> OwnerProfileResponse:
        bundle = self._get_bundle(current_user.user_id, for_update=True)
        self._ensure_active(bundle.user.account_status)
        self._ensure_visibility_mutable(bundle.profile.visibility_status)
        bundle.profile.visibility_status = "hidden_by_user"
        bundle.profile.last_activity_at = datetime.now(timezone.utc)
        self.repository.commit()
        return self._response(bundle, self._calculate_completion(bundle))

    def show_owner_profile(self, current_user: CurrentUser) -> OwnerProfileResponse:
        bundle = self._get_bundle(current_user.user_id, for_update=True)
        self._ensure_active(bundle.user.account_status)
        self._ensure_visibility_mutable(bundle.profile.visibility_status)
        completion = self._calculate_completion(bundle)
        if not completion.is_complete:
            raise ApiError(
                status_code=409,
                code=ErrorCode.PROFILE_INCOMPLETE,
                message="Complete the required profile fields first.",
                details={"missing_fields": completion.missing_fields},
            )
        bundle.profile.visibility_status = "public"
        bundle.profile.completion_score = completion.score
        bundle.profile.completion_flags = completion.flags
        bundle.profile.last_activity_at = datetime.now(timezone.utc)
        self.repository.commit()
        return self._response(bundle, completion)

    def _validate_payload_for_role(
        self,
        bundle: OwnerProfileBundle,
        payload: ProfileUpdateRequest,
    ) -> None:
        allowed = COMMON_FIELDS | ROLE_FIELDS[bundle.profile.role]
        invalid_fields = payload.model_fields_set - allowed
        if invalid_fields:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={
                    field: f"This field is not valid for a {bundle.profile.role} profile."
                    for field in sorted(invalid_fields)
                },
            )
        field_errors: dict[str, str] = {}
        if (
            "business_category_id" in payload.model_fields_set
            and payload.business_category_id is not None
            and not self.repository.category_ids_are_valid(
                {payload.business_category_id}, allowed_types={"business_category"}
            )
        ):
            field_errors["business_category_id"] = "Select a valid business category."
        if "product_type_ids" in payload.model_fields_set:
            product_ids = set(payload.product_type_ids or [])
            if not self.repository.category_ids_are_valid(
                product_ids, allowed_types={"product_type"}
            ):
                field_errors["product_type_ids"] = "Select valid product types."
        if (
            "primary_skill_category_id" in payload.model_fields_set
            and payload.primary_skill_category_id is not None
            and not self.repository.category_ids_are_valid(
                {payload.primary_skill_category_id},
                allowed_types={"skill", "work_name"},
            )
        ):
            field_errors["primary_skill_category_id"] = "Select a valid skill."
        if field_errors:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors=field_errors,
            )

    def _apply_common_fields(
        self,
        bundle: OwnerProfileBundle,
        payload: ProfileUpdateRequest,
        before: dict[str, Any],
        after: dict[str, Any],
    ) -> None:
        for field in COMMON_FIELDS:
            if field not in payload.model_fields_set:
                continue
            value = getattr(payload, field)
            if field == "alternate_contact_number" and value is not None:
                try:
                    value = normalize_mobile(value)
                except ApiError as exc:
                    raise ApiError(
                        status_code=422,
                        code=ErrorCode.VALIDATION_FAILED,
                        message="Please check the highlighted fields.",
                        field_errors={
                            "alternate_contact_number": (
                                "Please enter a valid mobile number."
                            )
                        },
                    ) from exc
            self._set_changed(bundle.profile, field, value, before, after)

    def _apply_role_fields(
        self,
        bundle: OwnerProfileBundle,
        payload: ProfileUpdateRequest,
        before: dict[str, Any],
        after: dict[str, Any],
    ) -> None:
        role_profile = bundle.role_profile
        if bundle.profile.role == "business":
            for field in (
                "business_name",
                "business_category_id",
                "manufacture_sell_details",
                "product_notes",
            ):
                if field in payload.model_fields_set:
                    value = getattr(payload, field)
                    if field in {"business_name", "manufacture_sell_details"}:
                        value = value or ""
                    self._set_changed(role_profile, field, value, before, after)
            if "business_name" in payload.model_fields_set:
                self._set_changed(
                    bundle.profile,
                    "public_name",
                    payload.business_name,
                    before,
                    after,
                )
            if {
                "product_type_ids",
                "custom_product_types",
            } & payload.model_fields_set:
                existing_ids = [
                    item.product_type_category_id for item in bundle.product_types
                ]
                existing_custom = [
                    item.custom_product_type_text
                    for item in bundle.product_types
                    if item.custom_product_type_text
                ]
                category_ids = (
                    payload.product_type_ids
                    if "product_type_ids" in payload.model_fields_set
                    else [item for item in existing_ids if item is not None]
                )
                custom_values = (
                    payload.custom_product_types
                    if "custom_product_types" in payload.model_fields_set
                    else existing_custom
                )
                before["product_types"] = {
                    "category_ids": json_value([item for item in existing_ids if item]),
                    "custom_values": existing_custom,
                }
                after["product_types"] = {
                    "category_ids": json_value(category_ids or []),
                    "custom_values": custom_values or [],
                }
                if before["product_types"] == after["product_types"]:
                    before.pop("product_types")
                    after.pop("product_types")
                else:
                    existing_custom_keys = {
                        value.casefold() for value in existing_custom
                    }
                    self.repository.create_product_type_suggestions(
                        user_id=bundle.user.id,
                        profile_id=bundle.profile.id,
                        values=[
                            value
                            for value in custom_values or []
                            if value.casefold() not in existing_custom_keys
                        ],
                    )
                    self.repository.replace_business_product_types(
                        profile_id=bundle.profile.id,
                        category_ids=category_ids or [],
                        custom_values=custom_values or [],
                    )
        elif bundle.profile.role == "job_worker":
            for field in ROLE_FIELDS["job_worker"]:
                if field in payload.model_fields_set:
                    self._set_changed(
                        role_profile,
                        field,
                        getattr(payload, field),
                        before,
                        after,
                    )
            if {
                "workshop_name",
                "has_workshop",
                "owner_name",
            } & payload.model_fields_set:
                public_name = (
                    role_profile.workshop_name
                    if role_profile.has_workshop
                    and has_text(role_profile.workshop_name)
                    else bundle.profile.owner_name
                )
                self._set_changed(
                    bundle.profile, "public_name", public_name, before, after
                )
        else:
            for field in ROLE_FIELDS["skilled_worker"]:
                if field in payload.model_fields_set:
                    self._set_changed(
                        role_profile,
                        field,
                        getattr(payload, field),
                        before,
                        after,
                    )
            if "owner_name" in payload.model_fields_set:
                self._set_changed(
                    bundle.profile,
                    "public_name",
                    bundle.profile.owner_name,
                    before,
                    after,
                )

    def _calculate_completion(self, bundle: OwnerProfileBundle) -> CompletionResult:
        evidence = self.repository.completion_evidence(bundle.profile)
        profile = bundle.profile
        common = {
            "mobile": has_text(bundle.user.primary_mobile),
            "owner_name": has_text(profile.owner_name),
            "full_address": has_text(profile.full_address),
            "locality": has_text(profile.locality),
            "city": has_text(profile.city),
            "state": has_text(profile.state),
            "pincode": bool(profile.pincode and len(profile.pincode) == 6),
        }
        if profile.role == "business":
            role_profile = bundle.role_profile
            flags = common | {
                "business_name": has_text(role_profile.business_name),
                "business_category": role_profile.business_category_id is not None,
                "manufacture_sell_details": has_text(
                    role_profile.manufacture_sell_details
                ),
                "product_type": evidence.business_product_type_count > 0,
                "shop_photos": evidence.required_profile_photo_count >= 3,
            }
        elif profile.role == "job_worker":
            role_profile = bundle.role_profile
            flags = common | {
                "workshop_name": (
                    not role_profile.has_workshop
                    or has_text(role_profile.workshop_name)
                ),
                "workplace_photos": evidence.required_profile_photo_count >= 3,
                "published_work_card": evidence.published_valid_work_card_count > 0,
            }
        else:
            role_profile = bundle.role_profile
            flags = common | {
                "primary_skill": role_profile.primary_skill_category_id is not None,
                "skill_mastery": has_text(role_profile.skill_mastery),
                "experience": role_profile.experience_years is not None,
            }
        complete_count = sum(flags.values())
        score = int((complete_count * 100) / len(flags))
        if complete_count == len(flags):
            score = 100
        return CompletionResult(score=score, flags=flags)

    def _response(
        self,
        bundle: OwnerProfileBundle,
        completion: CompletionResult,
    ) -> OwnerProfileResponse:
        profile = bundle.profile
        allowed = COMMON_FIELDS | ROLE_FIELDS[profile.role]
        locked = {"mobile", "role"}
        if bundle.user.profile_completed_at is not None:
            locked.add("owner_name")
        if profile.verification_status == "pending":
            locked |= allowed
        editable = sorted(allowed - locked)
        role_data = self._role_data(bundle)
        role_data.update(
            {
                "owner_name": profile.owner_name,
                "alternate_contact_number": profile.alternate_contact_number,
                "full_address": profile.full_address,
                "address_line1": profile.address_line1,
                "address_line2": profile.address_line2,
                "locality": profile.locality,
                "city": profile.city,
                "state": profile.state,
                "pincode": profile.pincode,
            }
        )
        return OwnerProfileResponse(
            profile=ProfileSummaryResponse(
                id=profile.id,
                role=profile.role,
                display_name=profile.public_name,
                visibility_status=profile.visibility_status,
                completion_score=completion.score,
                completion_flags=completion.flags,
                verification_status=profile.verification_status,
                is_verified=profile.is_verified,
                reverification_required=profile.reverification_required,
            ),
            editable_fields=editable,
            locked_fields=sorted(locked),
            role_specific=role_data,
            media=[
                OwnerMediaResponse(
                    id=media.id,
                    media_kind=media.media_kind,
                    visibility=media.visibility,
                    upload_status=media.upload_status,
                    sort_order=media.sort_order,
                    document_type=media.document_type,
                    safe_display_name=self.repository.safe_media_name(media),
                    url=(
                        self.public_media_url(media.original_path)
                        if self.public_media_url is not None
                        and media.visibility == "public"
                        and media.upload_status == "ready"
                        else None
                    ),
                )
                for media in bundle.media
            ],
        )

    @staticmethod
    def _role_data(bundle: OwnerProfileBundle) -> dict[str, Any]:
        role_profile = bundle.role_profile
        if bundle.profile.role == "business":
            return {
                "business_name": role_profile.business_name,
                "business_category_id": role_profile.business_category_id,
                "manufacture_sell_details": role_profile.manufacture_sell_details,
                "product_notes": role_profile.product_notes,
                "product_types": [
                    {
                        "category_id": item.product_type_category_id,
                        "custom_text": item.custom_product_type_text,
                    }
                    for item in bundle.product_types
                ],
            }
        if bundle.profile.role == "job_worker":
            return {
                "workshop_name": role_profile.workshop_name,
                "has_workshop": role_profile.has_workshop,
                "work_summary": role_profile.work_summary,
                "profile_experience_years": role_profile.profile_experience_years,
            }
        return {
            "primary_skill_category_id": role_profile.primary_skill_category_id,
            "skill_mastery": role_profile.skill_mastery,
            "experience_years": role_profile.experience_years,
            "bio": role_profile.bio,
        }

    def _get_bundle(
        self,
        user_id: UUID,
        *,
        for_update: bool = False,
    ) -> OwnerProfileBundle:
        bundle = self.repository.get_owner_bundle(user_id, for_update=for_update)
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Profile not found.",
            )
        return bundle

    @staticmethod
    def _set_changed(
        target: Any,
        field: str,
        value: Any,
        before: dict[str, Any],
        after: dict[str, Any],
    ) -> None:
        current = getattr(target, field)
        if current == value:
            return
        before[field] = json_value(current)
        after[field] = json_value(value)
        setattr(target, field, value)

    @staticmethod
    def _ensure_active(account_status: str) -> None:
        if account_status == "suspended":
            raise ApiError(
                status_code=403,
                code=ErrorCode.ACCOUNT_SUSPENDED,
                message="Your account is suspended. Please contact support.",
            )
        if account_status == "terminated":
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )

    @staticmethod
    def _ensure_visibility_mutable(visibility_status: str) -> None:
        if visibility_status in {"suspended_by_admin", "deleted"}:
            raise ApiError(
                status_code=403,
                code=ErrorCode.FORBIDDEN,
                message="This profile visibility cannot be changed.",
            )
