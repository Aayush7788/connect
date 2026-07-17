from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, model_validator


class VerificationSubmitRequest(BaseModel):
    consent_version: str | None = Field(default=None, max_length=80)
    consent_accepted: bool = False

    @model_validator(mode="after")
    def validate_consent(self) -> "VerificationSubmitRequest":
        if self.consent_accepted and not self.consent_version:
            raise ValueError("Consent version is required when consent is accepted.")
        return self


class SafeVerificationDocument(BaseModel):
    media_asset_id: UUID
    document_type: str
    status: str
    safe_display_name: str


class VerificationCheckResponse(BaseModel):
    check_type: str
    status: str
    notes_to_user: str | None = None


class VerificationSummaryResponse(BaseModel):
    verification_status: str
    is_verified: bool
    reverification_required: bool = False
    active_case_id: UUID | None = None
    case_status: str | None = None
    notes_to_user: str | None = None
    submitted_at: datetime | None = None
    checks: list[VerificationCheckResponse] = Field(default_factory=list)
    safe_documents: list[SafeVerificationDocument] = Field(default_factory=list)
