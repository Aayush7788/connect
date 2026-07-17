from datetime import datetime
from typing import Any, Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.modules.auth.schemas import ProfileSummaryResponse


class AdminUserResponse(BaseModel):
    id: UUID
    display_name: str | None = None
    mobile: str
    role: Literal["super_admin"] = "super_admin"


class AdminDecisionRequest(BaseModel):
    notes: str | None = Field(default=None, max_length=2000)

    @field_validator("notes")
    @classmethod
    def clean_notes(cls, value: str | None) -> str | None:
        if value is None:
            return None
        return value.strip() or None


class AdminVerificationCheckResponse(BaseModel):
    check_type: str
    status: str
    notes_to_user: str | None = None
    internal_notes: str | None = None


class AdminPrivateDocumentResponse(BaseModel):
    media_asset_id: UUID
    document_type: str
    safe_display_name: str
    access_url: str
    expires_at: datetime


class AdminVerificationCaseResponse(BaseModel):
    id: UUID
    status: str
    case_reason: str
    profile: ProfileSummaryResponse
    owner_mobile: str | None = None
    full_address: str | None = None
    submitted_at: datetime | None = None
    reviewed_at: datetime | None = None
    notes_to_user: str | None = None
    internal_notes: str | None = None
    resubmission_count: int = 0
    checks: list[AdminVerificationCheckResponse] = Field(default_factory=list)
    private_document_access: list[AdminPrivateDocumentResponse] = Field(
        default_factory=list
    )


class AdminVerificationCasesResponse(BaseModel):
    items: list[AdminVerificationCaseResponse]
    next_cursor: str | None = None


class AdminProfileResponse(BaseModel):
    profile: ProfileSummaryResponse
    owner_user_id: UUID | None = None
    owner_mobile: str | None = None
    is_admin_seeded: bool
    claim_status: str | None = None
    account_status: str | None = None
    full_address: str | None = None


class AdminProfilesResponse(BaseModel):
    items: list[AdminProfileResponse]
    next_cursor: str | None = None


class AdminSeedProfileRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    role: Literal["business", "job_worker", "skilled_worker"]
    display_name: str = Field(min_length=1, max_length=200)
    profile_data: dict[str, Any] = Field(default_factory=dict)
    make_public: bool = False

    @field_validator("display_name")
    @classmethod
    def clean_display_name(cls, value: str) -> str:
        return value.strip()


class AdminReportResponse(BaseModel):
    id: UUID | None = None
    reported_entity_type: str
    reported_entity_id: UUID
    reason: str
    status: str | None = None
    message: str | None = None
    report_count: int = 1
    latest_reported_at: datetime


class AdminReportsResponse(BaseModel):
    items: list[AdminReportResponse]
    next_cursor: str | None = None


class AdminSearchTermResponse(BaseModel):
    term: str
    count: int


class AdminAnalyticsSummaryResponse(BaseModel):
    total_profiles: int
    verified_profiles: int
    pending_verifications: int
    submitted_reports: int
    profile_views: int
    contact_actions: dict[str, int]
    top_search_terms: list[AdminSearchTermResponse]


class CreateExportRequest(BaseModel):
    dataset: Literal[
        "profiles",
        "verification_cases",
        "reports",
        "search_summary",
        "contact_summary",
    ]
    filters: dict[str, Any] = Field(default_factory=dict)


class ExportJobResponse(BaseModel):
    id: UUID
    status: Literal["ready"] = "ready"
    download_url: str
    expires_at: datetime
