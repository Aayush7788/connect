from datetime import datetime
from typing import Annotated, Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, StringConstraints
from pydantic import field_validator, model_validator

from app.modules.media.schemas import MediaAssetResponse


WorkCardStatus = Literal[
    "draft",
    "published",
    "hidden_by_user",
    "removed_by_admin",
    "deleted",
]


class WorkCardUpsertRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    category_id: UUID | None = None
    custom_category_text: str | None = Field(default=None, max_length=160)
    work_name_id: UUID | None = None
    custom_work_name: str | None = Field(default=None, max_length=160)
    product_type_ids: list[UUID] | None = Field(default=None, max_length=20)
    custom_product_texts: (
        list[Annotated[str, StringConstraints(max_length=160)]] | None
    ) = Field(default=None, max_length=20)
    description: str | None = Field(default=None, max_length=2000)
    experience_years: int | None = Field(default=None, ge=0, le=100)

    @field_validator(
        "custom_category_text",
        "custom_work_name",
        "description",
    )
    @classmethod
    def strip_optional_text(cls, value: str | None) -> str | None:
        if value is None:
            return None
        cleaned = " ".join(value.split())
        return cleaned or None

    @field_validator("product_type_ids")
    @classmethod
    def deduplicate_product_ids(cls, values: list[UUID] | None) -> list[UUID] | None:
        if values is None:
            return None
        return list(dict.fromkeys(values))

    @field_validator("custom_product_texts")
    @classmethod
    def normalize_custom_products(cls, values: list[str] | None) -> list[str] | None:
        if values is None:
            return None
        normalized: list[str] = []
        seen: set[str] = set()
        for value in values:
            cleaned = " ".join(value.split())
            key = cleaned.casefold()
            if cleaned and key not in seen:
                normalized.append(cleaned)
                seen.add(key)
        return normalized

    @model_validator(mode="after")
    def validate_mapped_or_custom_fields(self) -> "WorkCardUpsertRequest":
        if self.category_id is not None and self.custom_category_text is not None:
            raise ValueError("Choose a category or enter a custom category, not both.")
        if self.work_name_id is not None and self.custom_work_name is not None:
            raise ValueError(
                "Choose a work name or enter a custom work name, not both."
            )
        return self


class WorkCardResponse(BaseModel):
    id: UUID
    profile_id: UUID
    status: WorkCardStatus
    title: str
    category_id: UUID | None = None
    category_name: str | None = None
    custom_category_text: str | None = None
    work_name_id: UUID | None = None
    work_name: str | None = None
    custom_work_name: str | None = None
    product_type_ids: list[UUID] = Field(default_factory=list)
    custom_product_texts: list[str] = Field(default_factory=list)
    product_types: list[str] = Field(default_factory=list)
    description: str | None = None
    experience_years: int | None = None
    photo_count: int
    photos: list[MediaAssetResponse] = Field(default_factory=list)
    last_activity_at: datetime | None = None
    created_at: datetime
    updated_at: datetime


class WorkCardListResponse(BaseModel):
    items: list[WorkCardResponse] = Field(default_factory=list)
