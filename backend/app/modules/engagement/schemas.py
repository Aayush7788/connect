from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field, model_validator

from app.modules.search.schemas import SearchResultResponse


SavedTargetType = Literal["profile", "work_card", "work_needed_post"]
ProfileRole = Literal["business", "job_worker", "skilled_worker"]
ReportReason = Literal[
    "wrong_contact",
    "wrong_category",
    "inappropriate_photo",
    "wrong_details",
    "fake_profile",
    "spam",
    "other",
]
ShareChannel = Literal[
    "copy_link",
    "whatsapp",
    "sms",
    "x",
    "email",
    "linkedin",
    "native_other",
]


class SaveItemRequest(BaseModel):
    target_type: SavedTargetType
    target_id: UUID


class SavedItemResponse(BaseModel):
    id: UUID
    target_type: SavedTargetType
    target_id: UUID
    profile_role: ProfileRole
    card: SearchResultResponse | None = None


class SavedItemsResponse(BaseModel):
    items: list[SavedItemResponse] = Field(default_factory=list)
    next_cursor: str | None = None


class CreateReportRequest(BaseModel):
    reported_entity_type: SavedTargetType
    reported_entity_id: UUID
    reason: ReportReason


class ReportResponse(BaseModel):
    id: UUID
    status: str


class NotificationResponse(BaseModel):
    id: UUID
    title: str
    message: str
    created_at: datetime
    read_at: datetime | None = None


class NotificationsResponse(BaseModel):
    items: list[NotificationResponse] = Field(default_factory=list)
    next_cursor: str | None = None


class RegisterDeviceTokenRequest(BaseModel):
    fcm_token: str = Field(min_length=1, max_length=4096)
    platform: Literal["android"]
    device_id: str | None = Field(default=None, min_length=1, max_length=500)
    app_version: str | None = Field(default=None, min_length=1, max_length=100)


class UpdateSettingsRequest(BaseModel):
    push_notifications_enabled: bool | None = None
    hidden_from_search: bool | None = None

    @model_validator(mode="after")
    def has_update(self) -> "UpdateSettingsRequest":
        if self.push_notifications_enabled is None and self.hidden_from_search is None:
            raise ValueError("At least one setting must be provided.")
        return self


class UserSettingsResponse(BaseModel):
    push_notifications_enabled: bool
    hidden_from_search: bool


class ContactActionRequest(BaseModel):
    profile_id: UUID
    action_type: Literal["call", "whatsapp", "address"]
    source_type: (
        Literal["search", "saved", "profile", "work_card", "work_needed_post"] | None
    ) = None
    source_id: UUID | None = None


class CreateShareLinkRequest(BaseModel):
    target_type: SavedTargetType
    target_id: UUID
    channel: ShareChannel | None = None


class ShareLinkResponse(BaseModel):
    url: str
    share_text: str
