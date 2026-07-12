from uuid import UUID

from pydantic import BaseModel, Field

from app.core.auth_context import AccountStatus, UserRole


class DeviceInfo(BaseModel):
    device_id: str | None = None
    platform: str = "android"
    app_version: str | None = None
    fcm_token: str | None = None


class OtpRequest(BaseModel):
    mobile: str


class OtpRequestResponse(BaseModel):
    otp_request_id: UUID
    message: str


class OtpVerifyRequest(BaseModel):
    mobile: str
    otp: str
    otp_request_id: UUID
    device: DeviceInfo | None = None


class UserResponse(BaseModel):
    id: UUID
    display_name: str
    primary_mobile: str
    account_status: AccountStatus
    role: UserRole | None = None


class ProfileSummaryResponse(BaseModel):
    id: UUID
    role: UserRole
    display_name: str | None = None
    visibility_status: str
    completion_score: int = Field(ge=0, le=100)
    completion_flags: dict = Field(default_factory=dict)
    verification_status: str
    is_verified: bool
    reverification_required: bool = False


class MeResponse(BaseModel):
    user: UserResponse
    next_state: str
    profile: ProfileSummaryResponse | None = None
    unread_notification_count: int = 0
    allowed_actions: list[str] = Field(default_factory=list)


class AuthSessionResponse(BaseModel):
    access_token: str
    refresh_token: str
    next_state: str
    user: UserResponse


class BasicAccountRequest(BaseModel):
    display_name: str = Field(min_length=1)
    accepted_terms_version: str = Field(min_length=1)
    accepted_privacy_version: str = Field(min_length=1)
