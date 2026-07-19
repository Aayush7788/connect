from dataclasses import dataclass
from datetime import datetime, timezone
from collections.abc import Callable
from decimal import Decimal
import re
from typing import Any, cast
import unicodedata
from uuid import UUID

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.db.models.profile import BusinessProfile, JobWorkerProfile
from app.db.models.profile import SkilledWorkerProfile
from app.modules.auth.schemas import ProfileSummaryResponse
from app.modules.auth.service import normalize_mobile
from app.modules.profiles.repository import OwnerProfileBundle
from app.modules.profiles.repository import PublicProfileBundle
from app.modules.profiles.repository import PublicWorkCardBundle
from app.modules.profiles.repository import PublicWorkNeededPostBundle
from app.modules.profiles.repository import ProfileRepository
from app.modules.media.schemas import MediaAssetResponse, MediaKind, MediaVisibility
from app.modules.locations.schemas import AddressValidationRequest
from app.modules.locations.schemas import AddressValidationResponse
from app.modules.locations.service import LocationService
from app.modules.profiles.schemas import OwnerMediaResponse, OwnerProfileResponse
from app.modules.profiles.schemas import ProfileUpdateRequest
from app.modules.profiles.schemas import PublicAddressResponse, PublicContactResponse
from app.modules.profiles.schemas import PublicProfileDetailResponse
from app.modules.work_cards.schemas import WorkCardResponse, WorkCardStatus
from app.modules.work_needed_posts.schemas import WorkNeededPostResponse
from app.modules.work_needed_posts.schemas import WorkNeededPostStatus


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
    "state_id",
    "district_id",
}
ROLE_FIELDS = {
    "business": {
        "business_name",
        "business_category_id",
        "custom_business_category",
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
        "skill_category_ids",
        "custom_skills",
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
    "state_id",
    "district_id",
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


@dataclass(frozen=True)
class ContactRevealPayload:
    viewer_user_id: UUID
    profile_id: UUID
    source_type: str | None
    source_id: UUID | None
    ip_address: str | None
    device_id: str | None
    user_agent: str | None


def has_text(value: str | None) -> bool:
    return bool(value and value.strip())


def normalize_search_text(value: str | None) -> str:
    normalized = unicodedata.normalize("NFKC", value or "").casefold()
    return " ".join(re.sub(r"[^\w]+", " ", normalized, flags=re.UNICODE).split())


def json_value(value: Any) -> Any:
    if isinstance(value, UUID):
        return str(value)
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, list):
        return [json_value(item) for item in value]
    return value


class ProfileService:
    def __init__(
        self,
        repository: ProfileRepository,
        public_media_url: Callable[[str], str] | None = None,
        location_service: LocationService | None = None,
    ) -> None:
        self.repository = repository
        self.public_media_url = public_media_url
        self.location_service = location_service
        self.deferred_reveal: ContactRevealPayload | None = None

    def get_owner_profile(self, current_user: CurrentUser) -> OwnerProfileResponse:
        bundle = self._get_bundle(current_user.user_id)
        self._ensure_active(bundle.user.account_status)
        completion = (
            CompletionResult(
                score=bundle.profile.completion_score,
                flags={
                    key: bool(value)
                    for key, value in bundle.profile.completion_flags.items()
                },
            )
            if bundle.profile.completion_flags
            else self._calculate_completion(bundle)
        )
        return self._response(bundle, completion)

    def get_public_profile(
        self,
        *,
        current_user: CurrentUser,
        profile_id: UUID,
        source_type: str | None,
        source_id: UUID | None,
        ip_address: str | None,
        device_id: str | None,
        user_agent: str | None,
        defer_reveal: bool = False,
    ) -> PublicProfileDetailResponse:
        bundle = self.repository.get_public_bundle(profile_id)
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Profile not found.",
            )
        response = self._public_response(bundle)
        reveal = ContactRevealPayload(
            viewer_user_id=current_user.user_id,
            profile_id=profile_id,
            source_type=source_type,
            source_id=source_id,
            ip_address=ip_address,
            device_id=device_id,
            user_agent=user_agent,
        )
        if defer_reveal:
            self.deferred_reveal = reveal
            return response
        try:
            self.repository.record_contact_reveal(
                viewer_user_id=reveal.viewer_user_id,
                profile_id=reveal.profile_id,
                source_type=reveal.source_type,
                source_id=reveal.source_id,
                ip_address=reveal.ip_address,
                device_id=reveal.device_id,
                user_agent=reveal.user_agent,
            )
            self.repository.commit()
        except Exception:
            self.repository.rollback()
            raise
        return response

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
        self._refresh_search_projection(bundle, completion)
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
        location_validation = self._validate_location_update(bundle, payload)
        self._apply_common_fields(bundle, payload, before, after)
        self._apply_location_validation(
            bundle,
            payload,
            location_validation,
            before,
            after,
        )
        self._apply_role_fields(bundle, payload, before, after)
        if not after:
            return self._response(
                bundle,
                CompletionResult(
                    score=bundle.profile.completion_score,
                    flags={
                        key: bool(value)
                        for key, value in bundle.profile.completion_flags.items()
                    },
                ),
            )
        self.repository.flush()
        refreshed = self._get_bundle(current_user.user_id, for_update=True)
        completion = self._calculate_completion(refreshed)
        refreshed.profile.completion_score = completion.score
        refreshed.profile.completion_flags = completion.flags
        refreshed.profile.photo_count = self.repository.completion_evidence(
            refreshed.profile
        ).public_photo_count
        self._refresh_search_projection(refreshed, completion)

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
        self._refresh_search_projection(bundle, completion)
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
        self._refresh_search_projection(bundle, completion)
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
        if "skill_category_ids" in payload.model_fields_set:
            skill_ids = set(payload.skill_category_ids or [])
            if not self.repository.category_ids_are_valid(
                skill_ids, allowed_types={"skill", "work_name"}
            ):
                field_errors["skill_category_ids"] = "Select valid skills."

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
            if field == "locality":
                bundle.profile.normalized_locality = (
                    normalize_search_text(value) or None
                )

    def _validate_location_update(
        self,
        bundle: OwnerProfileBundle,
        payload: ProfileUpdateRequest,
    ) -> AddressValidationResponse | None:
        location_fields = {
            "state_id",
            "district_id",
            "state",
            "city",
            "locality",
            "pincode",
            "address_line1",
            "full_address",
        }
        if not (payload.model_fields_set & location_fields):
            return None
        state_id = payload.state_id or getattr(bundle.profile, "state_id", None)
        district_id = payload.district_id or getattr(
            bundle.profile, "district_id", None
        )
        pincode = payload.pincode or bundle.profile.pincode
        area = payload.locality if "locality" in payload.model_fields_set else bundle.profile.locality
        if not state_id or not district_id or not pincode or self.location_service is None:
            return None
        result = self.location_service.validate(
            AddressValidationRequest(
                state_id=state_id,
                district_id=district_id,
                pincode=pincode,
                area=area,
            )
        )
        if result.status == "invalid":
            field_errors: dict[str, str] = {"pincode": result.message}
            if not result.state_matches:
                field_errors["state_id"] = "Select the state linked to this PIN code."
            if not result.district_matches:
                field_errors["district_id"] = (
                    "Select the city/district linked to this PIN code."
                )
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted address fields.",
                field_errors=field_errors,
            )
        return result

    def _apply_location_validation(
        self,
        bundle: OwnerProfileBundle,
        payload: ProfileUpdateRequest,
        result: AddressValidationResponse | None,
        before: dict[str, Any],
        after: dict[str, Any],
    ) -> None:
        if result is not None:
            state = result.canonical_state
            district = result.canonical_district
            self._set_changed(
                bundle.profile, "state_id", state.id if state else None, before, after
            )
            self._set_changed(
                bundle.profile,
                "district_id",
                district.id if district else None,
                before,
                after,
            )
            self._set_changed(
                bundle.profile, "state", state.name if state else None, before, after
            )
            self._set_changed(
                bundle.profile,
                "city",
                district.name if district else None,
                before,
                after,
            )
            self._set_changed(
                bundle.profile,
                "location_validation_status",
                result.status,
                before,
                after,
            )
            self._set_changed(
                bundle.profile,
                "location_validated_at",
                datetime.now(timezone.utc),
                before,
                after,
            )
        elif payload.model_fields_set & {
            "state_id",
            "district_id",
            "state",
            "city",
            "locality",
            "pincode",
        }:
            self._set_changed(
                bundle.profile,
                "location_validation_status",
                "unvalidated",
                before,
                after,
            )
            self._set_changed(
                bundle.profile,
                "location_validated_at",
                None,
                before,
                after,
            )
        if payload.model_fields_set & {
            "address_line1",
            "locality",
            "city",
            "state",
            "pincode",
            "state_id",
            "district_id",
        }:
            parts = [
                bundle.profile.address_line1,
                bundle.profile.locality,
                bundle.profile.city,
                bundle.profile.state,
                bundle.profile.pincode,
            ]
            full_address = ", ".join(part for part in parts if has_text(part)) or None
            self._set_changed(
                bundle.profile, "full_address", full_address, before, after
            )

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
                "custom_business_category",
                "manufacture_sell_details",
                "product_notes",
            ):
                if field in payload.model_fields_set:
                    value = getattr(payload, field)
                    if field in {"business_name", "manufacture_sell_details"}:
                        value = value or ""
                    self._set_changed(role_profile, field, value, before, after)
            if (
                "custom_business_category" in payload.model_fields_set
                and payload.custom_business_category
            ):
                self.repository.create_business_category_suggestion(
                    user_id=bundle.user.id,
                    profile_id=bundle.profile.id,
                    value=payload.custom_business_category,
                )
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
            for field in ("skill_mastery", "experience_years", "bio"):
                if field in payload.model_fields_set:
                    value = getattr(payload, field)
                    if field == "skill_mastery":
                        value = value or ""
                    self._set_changed(
                        role_profile,
                        field,
                        value,
                        before,
                        after,
                    )
            skill_fields = {"skill_category_ids", "custom_skills"}
            has_skill_update = bool(skill_fields & payload.model_fields_set)
            has_legacy_update = (
                "primary_skill_category_id" in payload.model_fields_set
                and not has_skill_update
            )
            if has_skill_update or has_legacy_update:
                existing_ids = [
                    item.skill_category_id
                    for item in bundle.skills
                    if item.skill_category_id is not None
                ]
                existing_custom = [
                    item.custom_skill_text
                    for item in bundle.skills
                    if item.custom_skill_text
                ]
                if has_legacy_update:
                    category_ids = (
                        [payload.primary_skill_category_id]
                        if payload.primary_skill_category_id is not None
                        else []
                    )
                    custom_values = []
                else:
                    category_ids = (
                        payload.skill_category_ids
                        if "skill_category_ids" in payload.model_fields_set
                        else existing_ids
                    )
                    custom_values = (
                        payload.custom_skills
                        if "custom_skills" in payload.model_fields_set
                        else existing_custom
                    )
                before["skills"] = {
                    "category_ids": json_value(existing_ids),
                    "custom_values": existing_custom,
                }
                after["skills"] = {
                    "category_ids": json_value(category_ids or []),
                    "custom_values": custom_values or [],
                }
                if before["skills"] == after["skills"]:
                    before.pop("skills")
                    after.pop("skills")
                else:
                    self.repository.create_skill_suggestions(
                        user_id=bundle.user.id,
                        profile_id=bundle.profile.id,
                        values=custom_values or [],
                    )
                    self.repository.replace_skilled_worker_skills(
                        profile_id=bundle.profile.id,
                        category_ids=category_ids or [],
                        custom_values=custom_values or [],
                    )
                    self._set_changed(
                        role_profile,
                        "primary_skill_category_id",
                        (category_ids or [None])[0],
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
            "location_check": getattr(
                profile, "location_validation_status", "valid"
            )
            in {"valid", "warning"},
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
                "skills": bool(bundle.skills)
                or role_profile.primary_skill_category_id is not None,
                "skill_mastery": has_text(role_profile.skill_mastery),
                "experience": role_profile.experience_years is not None,
            }
        complete_count = sum(flags.values())
        score = int((complete_count * 100) / len(flags))
        if complete_count == len(flags):
            score = 100
        return CompletionResult(score=score, flags=flags)

    def _refresh_search_projection(
        self,
        bundle: OwnerProfileBundle,
        completion: CompletionResult,
    ) -> None:
        profile = bundle.profile
        role_profile = bundle.role_profile
        category_ids: set[UUID] = set()
        values = [
            profile.public_name,
            profile.owner_name,
            profile.locality,
            profile.city,
            profile.state,
        ]
        if profile.role == "business":
            business_profile = cast(BusinessProfile, role_profile)
            if business_profile.business_category_id is not None:
                category_ids.add(business_profile.business_category_id)
            category_ids.update(
                item.product_type_category_id
                for item in bundle.product_types
                if item.product_type_category_id is not None
            )
            values.extend(
                [
                    business_profile.business_name,
                    business_profile.custom_business_category,
                    business_profile.manufacture_sell_details,
                    business_profile.product_notes,
                    *(
                        item.custom_product_type_text
                        for item in bundle.product_types
                        if item.custom_product_type_text
                    ),
                ]
            )
        elif profile.role == "job_worker":
            job_worker_profile = cast(JobWorkerProfile, role_profile)
            values.extend(
                [
                    job_worker_profile.workshop_name,
                    job_worker_profile.work_summary,
                ]
            )
        else:
            skilled_worker_profile = cast(SkilledWorkerProfile, role_profile)
            skill_category_ids = {
                item.skill_category_id
                for item in bundle.skills
                if item.skill_category_id is not None
            }
            if (
                not skill_category_ids
                and skilled_worker_profile.primary_skill_category_id is not None
            ):
                skill_category_ids.add(skilled_worker_profile.primary_skill_category_id)
            category_ids.update(skill_category_ids)
            values.extend(
                [
                    skilled_worker_profile.skill_mastery,
                    skilled_worker_profile.bio,
                    *(
                        item.custom_skill_text
                        for item in bundle.skills
                        if item.custom_skill_text
                    ),
                ]
            )
        categories = self.repository.get_categories(category_ids)
        values.extend(category.name for category in categories.values())
        values.extend(self.repository.category_aliases(category_ids))
        normalized_values: list[str] = []
        seen: set[str] = set()
        for value in values:
            normalized = normalize_search_text(value)
            if normalized and normalized not in seen:
                normalized_values.append(normalized)
                seen.add(normalized)
        search_text = " ".join(normalized_values)
        profile.search_text = search_text
        self.repository.set_search_vector(profile, search_text)
        profile.ranking_score = Decimal(profile.photo_count) + (
            Decimal(completion.score) / Decimal("20")
        )

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
                "state_id": getattr(profile, "state_id", None),
                "district_id": getattr(profile, "district_id", None),
                "location_validation_status": getattr(
                    profile, "location_validation_status", "unvalidated"
                ),
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
                    thumbnail_url=(
                        self.public_media_url(media.thumbnail_path)
                        if self.public_media_url is not None
                        and media.visibility == "public"
                        and media.upload_status == "ready"
                        and media.thumbnail_path
                        else None
                    ),
                )
                for media in bundle.media
            ],
        )

    def _public_response(
        self, bundle: PublicProfileBundle
    ) -> PublicProfileDetailResponse:
        profile = bundle.profile
        mobile = profile.alternate_contact_number or (
            bundle.user.primary_mobile if bundle.user is not None else None
        )
        return PublicProfileDetailResponse(
            profile=ProfileSummaryResponse(
                id=profile.id,
                role=profile.role,
                display_name=profile.public_name,
                visibility_status=profile.visibility_status,
                completion_score=profile.completion_score,
                completion_flags={},
                verification_status=profile.verification_status,
                is_verified=profile.is_verified,
                reverification_required=profile.reverification_required,
            ),
            role_specific=self._public_role_data(bundle),
            contact=PublicContactResponse(
                mobile=mobile,
                whatsapp_number=mobile,
            ),
            address=PublicAddressResponse(
                locality=profile.locality,
                city=profile.city,
                state=profile.state,
                pincode=profile.pincode,
                full_address=profile.full_address,
            ),
            media=[self._public_media_response(media) for media in bundle.media],
            work_cards=[
                self._public_work_card_response(item) for item in bundle.work_cards
            ],
            work_needed_posts=[
                self._public_work_needed_response(item)
                for item in bundle.work_needed_posts
            ],
            similar_profiles=[],
        )

    def _public_role_data(self, bundle: PublicProfileBundle) -> dict[str, Any]:
        profile = bundle.profile
        role_profile = bundle.role_profile
        if profile.role == "business":
            category = bundle.categories.get(role_profile.business_category_id)
            return {
                "owner_name": profile.owner_name,
                "business_name": role_profile.business_name,
                "business_category": (
                    role_profile.custom_business_category
                    or (category.name if category else None)
                ),
                "manufacture_sell_details": role_profile.manufacture_sell_details,
                "product_notes": role_profile.product_notes,
                "product_types": [
                    (
                        bundle.categories[item.product_type_category_id].name
                        if item.product_type_category_id in bundle.categories
                        else item.custom_product_type_text
                    )
                    for item in bundle.product_types
                    if item.product_type_category_id in bundle.categories
                    or has_text(item.custom_product_type_text)
                ],
            }
        if profile.role == "job_worker":
            return {
                "owner_name": profile.owner_name,
                "workshop_name": role_profile.workshop_name,
                "work_summary": role_profile.work_summary,
                "profile_experience_years": role_profile.profile_experience_years,
            }
        skills = [
            (
                bundle.categories[item.skill_category_id].name
                if item.skill_category_id in bundle.categories
                else item.custom_skill_text
            )
            for item in bundle.skills
            if item.skill_category_id in bundle.categories
            or has_text(item.custom_skill_text)
        ]
        if not skills:
            legacy_skill = bundle.categories.get(role_profile.primary_skill_category_id)
            if legacy_skill is not None:
                skills.append(legacy_skill.name)
        return {
            "owner_name": profile.owner_name,
            "primary_skill": skills[0] if skills else None,
            "skills": skills,
            "skill_mastery": role_profile.skill_mastery,
            "experience_years": role_profile.experience_years,
            "bio": role_profile.bio,
        }

    def _public_work_card_response(
        self, bundle: PublicWorkCardBundle
    ) -> WorkCardResponse:
        card = bundle.card
        return WorkCardResponse(
            id=card.id,
            profile_id=card.profile_id,
            status=cast(WorkCardStatus, card.status),
            title=card.title,
            category_id=card.work_category_id,
            category_name=self._category_or_custom(
                bundle.categories,
                card.work_category_id,
                card.custom_work_category_text,
            ),
            custom_category_text=card.custom_work_category_text,
            work_name_id=card.work_name_category_id,
            work_name=self._category_or_custom(
                bundle.categories,
                card.work_name_category_id,
                card.custom_work_name,
            ),
            custom_work_name=card.custom_work_name,
            product_type_ids=[
                item.product_type_category_id
                for item in bundle.product_types
                if item.product_type_category_id is not None
            ],
            custom_product_texts=[
                item.custom_product_type_text
                for item in bundle.product_types
                if item.custom_product_type_text is not None
            ],
            product_types=self._product_names(bundle.product_types, bundle.categories),
            description=card.description,
            experience_years=card.experience_years,
            photo_count=card.photo_count,
            photos=[self._public_media_response(media) for media in bundle.media],
            last_activity_at=card.last_activity_at,
            created_at=card.created_at,
            updated_at=card.updated_at,
        )

    def _public_work_needed_response(
        self, bundle: PublicWorkNeededPostBundle
    ) -> WorkNeededPostResponse:
        post = bundle.post
        return WorkNeededPostResponse(
            id=post.id,
            profile_id=post.profile_id,
            status=cast(WorkNeededPostStatus, post.status),
            title=post.title,
            category_id=post.work_category_id,
            category_name=self._category_or_custom(
                bundle.categories,
                post.work_category_id,
                post.custom_work_category_text,
            ),
            custom_category_text=post.custom_work_category_text,
            work_name_id=post.work_name_category_id,
            work_name=self._category_or_custom(
                bundle.categories,
                post.work_name_category_id,
                post.custom_work_name,
            ),
            custom_work_name=post.custom_work_name,
            product_type_ids=[
                item.product_type_category_id
                for item in bundle.product_types
                if item.product_type_category_id is not None
            ],
            custom_product_texts=[
                item.custom_product_type_text
                for item in bundle.product_types
                if item.custom_product_type_text is not None
            ],
            product_types=self._product_names(bundle.product_types, bundle.categories),
            description=post.description,
            photo_count=post.photo_count,
            photos=[self._public_media_response(media) for media in bundle.media],
            last_activity_at=post.last_activity_at,
            closed_at=post.closed_at,
            created_at=post.created_at,
            updated_at=post.updated_at,
        )

    def _public_media_response(self, media: Any) -> MediaAssetResponse:
        return MediaAssetResponse(
            id=media.id,
            media_kind=cast(MediaKind, media.media_kind),
            visibility=cast(MediaVisibility, media.visibility),
            upload_status=media.upload_status,
            url=(
                self.public_media_url(media.original_path)
                if self.public_media_url is not None
                else None
            ),
            thumbnail_url=(
                self.public_media_url(media.thumbnail_path)
                if self.public_media_url is not None and media.thumbnail_path
                else None
            ),
            sort_order=media.sort_order,
            document_type=media.document_type,
            safe_display_name=self.repository.safe_media_name(media),
        )

    @staticmethod
    def _category_or_custom(
        categories: dict[UUID, Any],
        category_id: UUID | None,
        custom_text: str | None,
    ) -> str | None:
        category = categories.get(category_id)
        return category.name if category is not None else custom_text

    @staticmethod
    def _product_names(products: list[Any], categories: dict[UUID, Any]) -> list[str]:
        return [
            (
                categories[item.product_type_category_id].name
                if item.product_type_category_id in categories
                else item.custom_product_type_text
            )
            for item in products
            if item.product_type_category_id in categories
            or has_text(item.custom_product_type_text)
        ]

    def _role_data(self, bundle: OwnerProfileBundle) -> dict[str, Any]:
        role_profile = bundle.role_profile
        if bundle.profile.role == "business":
            return {
                "business_name": role_profile.business_name,
                "business_category_id": role_profile.business_category_id,
                "custom_business_category": role_profile.custom_business_category,
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
        category_ids = {
            item.skill_category_id
            for item in bundle.skills
            if item.skill_category_id is not None
        }
        categories = self.repository.get_categories(category_ids)
        skills = [
            (
                categories[item.skill_category_id].name
                if item.skill_category_id in categories
                else item.custom_skill_text
            )
            for item in bundle.skills
            if item.skill_category_id in categories or has_text(item.custom_skill_text)
        ]
        if not skills and role_profile.primary_skill_category_id is not None:
            legacy = self.repository.get_categories(
                {role_profile.primary_skill_category_id}
            ).get(role_profile.primary_skill_category_id)
            if legacy is not None:
                skills.append(legacy.name)
        return {
            "primary_skill_category_id": role_profile.primary_skill_category_id,
            "skill_category_ids": [
                item.skill_category_id
                for item in bundle.skills
                if item.skill_category_id is not None
            ],
            "custom_skills": [
                item.custom_skill_text
                for item in bundle.skills
                if item.custom_skill_text
            ],
            "skills": skills,
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
