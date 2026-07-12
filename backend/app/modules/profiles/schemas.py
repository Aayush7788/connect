from typing import Annotated, Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, StringConstraints
from pydantic import field_validator, model_validator

from app.modules.auth.schemas import ProfileSummaryResponse


class ProfileUpdateRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    owner_name: str | None = Field(default=None, max_length=160)
    alternate_contact_number: str | None = Field(default=None, max_length=20)
    full_address: str | None = Field(default=None, max_length=500)
    address_line1: str | None = Field(default=None, max_length=250)
    address_line2: str | None = Field(default=None, max_length=250)
    locality: str | None = Field(default=None, max_length=160)
    city: str | None = Field(default=None, max_length=120)
    state: str | None = Field(default=None, max_length=120)
    pincode: str | None = Field(default=None, max_length=6)
    business_name: str | None = Field(default=None, max_length=200)
    business_category_id: UUID | None = None
    manufacture_sell_details: str | None = Field(default=None, max_length=2000)
    product_notes: str | None = Field(default=None, max_length=1000)
    product_type_ids: list[UUID] | None = Field(default=None, max_length=20)
    custom_product_types: (
        list[Annotated[str, StringConstraints(max_length=160)]] | None
    ) = Field(default=None, max_length=20)
    workshop_name: str | None = Field(default=None, max_length=200)
    has_workshop: bool | None = None
    work_summary: str | None = Field(default=None, max_length=2000)
    profile_experience_years: int | None = Field(default=None, ge=0, le=100)
    primary_skill_category_id: UUID | None = None
    skill_mastery: str | None = Field(default=None, max_length=1000)
    experience_years: int | None = Field(default=None, ge=0, le=100)
    bio: str | None = Field(default=None, max_length=2000)

    @field_validator(
        "owner_name",
        "alternate_contact_number",
        "full_address",
        "address_line1",
        "address_line2",
        "locality",
        "city",
        "state",
        "pincode",
        "business_name",
        "manufacture_sell_details",
        "product_notes",
        "workshop_name",
        "work_summary",
        "skill_mastery",
        "bio",
    )
    @classmethod
    def strip_text(cls, value: str | None) -> str | None:
        if value is None:
            return None
        stripped = value.strip()
        return stripped or None

    @field_validator("custom_product_types")
    @classmethod
    def normalize_custom_products(cls, values: list[str] | None) -> list[str] | None:
        if values is None:
            return None
        normalized: list[str] = []
        seen: set[str] = set()
        for value in values:
            cleaned = value.strip()
            key = cleaned.casefold()
            if cleaned and key not in seen:
                normalized.append(cleaned)
                seen.add(key)
        return normalized

    @field_validator("pincode")
    @classmethod
    def validate_pincode(cls, value: str | None) -> str | None:
        if value is not None and (len(value) != 6 or not value.isdigit()):
            raise ValueError("Pincode must contain 6 digits.")
        return value

    @model_validator(mode="after")
    def reject_empty_update(self) -> "ProfileUpdateRequest":
        if not self.model_fields_set:
            raise ValueError("At least one profile field is required.")
        return self


class OwnerMediaResponse(BaseModel):
    id: UUID
    media_kind: str
    visibility: str
    upload_status: str
    sort_order: int
    document_type: str | None = None
    safe_display_name: str | None = None


class OwnerProfileResponse(BaseModel):
    profile: ProfileSummaryResponse
    editable_fields: list[str] = Field(default_factory=list)
    locked_fields: list[str] = Field(default_factory=list)
    role_specific: dict[str, Any] = Field(default_factory=dict)
    media: list[OwnerMediaResponse] = Field(default_factory=list)
