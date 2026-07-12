from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


EntityType = Literal["profile", "work_card", "work_needed_post", "verification_case"]
MediaKind = Literal["image", "document"]
MediaVisibility = Literal["public", "private_admin_only"]
DocumentType = Literal[
    "identity_proof",
    "masked_aadhaar",
    "gst_proof",
    "shop_photo",
    "workplace_photo",
    "work_photo",
    "other",
]


class UploadIntentRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    entity_type: EntityType
    entity_id: UUID
    media_kind: MediaKind
    visibility: MediaVisibility
    document_type: DocumentType | None = None
    filename: str = Field(min_length=1, max_length=255)
    mime_type: str = Field(min_length=1, max_length=100)
    byte_size: int = Field(gt=0)

    @field_validator("filename", "mime_type")
    @classmethod
    def strip_text(cls, value: str) -> str:
        return value.strip()

    @field_validator("filename")
    @classmethod
    def reject_control_characters(cls, value: str) -> str:
        if any(ord(character) < 32 for character in value):
            raise ValueError("Filename contains invalid characters.")
        return value

    @model_validator(mode="after")
    def validate_media_shape(self) -> "UploadIntentRequest":
        if self.media_kind == "image" and not self.mime_type.startswith("image/"):
            raise ValueError("Image media requires an image MIME type.")
        if self.media_kind == "document" and self.visibility != "private_admin_only":
            raise ValueError("Document media must be private.")
        return self


class MediaAssetResponse(BaseModel):
    id: UUID
    media_kind: MediaKind
    visibility: MediaVisibility
    upload_status: str
    url: str | None = None
    thumbnail_url: str | None = None
    sort_order: int
    document_type: str | None = None
    safe_display_name: str | None = None


class UploadDetails(BaseModel):
    method: Literal["signed_url"] = "signed_url"
    http_method: Literal["PUT"] = "PUT"
    form_field: Literal["file"] = "file"
    url: str
    headers: dict[str, str] = Field(default_factory=dict)
    expires_at: datetime


class UploadIntentResponse(BaseModel):
    media_asset: MediaAssetResponse
    upload: UploadDetails
