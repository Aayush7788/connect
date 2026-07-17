from datetime import datetime, timezone
from uuid import UUID

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.db.models.cross_cutting import Notification, VerificationCase
from app.db.models.cross_cutting import VerificationCheck
from app.modules.verification.repository import VerificationRepository
from app.modules.verification.schemas import SafeVerificationDocument
from app.modules.verification.schemas import VerificationCheckResponse
from app.modules.verification.schemas import VerificationSubmitRequest
from app.modules.verification.schemas import VerificationSummaryResponse


CHECK_TYPES = (
    "profile_details",
    "mobile",
    "shop_or_workplace_photos",
    "identity_proof",
    "gst_proof",
    "admin_final_review",
)


class VerificationService:
    def __init__(self, repository: VerificationRepository) -> None:
        self.repository = repository

    def get_summary(self, current_user: CurrentUser) -> VerificationSummaryResponse:
        profile = self._owner_profile(current_user.user_id)
        case = self.repository.active_case(profile.id) or self.repository.latest_case(
            profile.id
        )
        return self._response(profile, case)

    def get_case(
        self,
        *,
        current_user: CurrentUser,
        case_id: UUID,
    ) -> VerificationSummaryResponse:
        profile = self._owner_profile(current_user.user_id)
        case = self.repository.case_for_owner(case_id, current_user.user_id)
        if case is None or case.profile_id != profile.id:
            raise self._not_found()
        return self._response(profile, case)

    def prepare(self, current_user: CurrentUser) -> VerificationSummaryResponse:
        profile = self._owner_profile(current_user.user_id, for_update=True)
        self._ensure_complete(profile)
        case = self.repository.active_case(profile.id, for_update=True)
        if case is not None:
            if case.status == "pending_review":
                raise ApiError(
                    status_code=409,
                    code=ErrorCode.VERIFICATION_PENDING_LOCKED,
                    message="Verification is already pending review.",
                )
            return self._response(profile, case)
        case = self._create_draft(profile.id, current_user.user_id)
        self.repository.commit()
        return self._response(profile, case)

    def submit(
        self,
        *,
        current_user: CurrentUser,
        payload: VerificationSubmitRequest,
    ) -> VerificationSummaryResponse:
        profile = self._owner_profile(current_user.user_id, for_update=True)
        self._ensure_complete(profile)
        case = self.repository.active_case(profile.id, for_update=True)
        if case is None:
            case = self._create_draft(profile.id, current_user.user_id)
        if case.status == "pending_review":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VERIFICATION_PENDING_LOCKED,
                message="Verification is already pending review.",
            )
        if case.status == "changes_requested":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VALIDATION_FAILED,
                message="Use resubmit after making the requested changes.",
            )
        self._submit_case(profile, case, payload)
        self.repository.commit()
        return self._response(profile, case)

    def resubmit(
        self,
        *,
        current_user: CurrentUser,
        payload: VerificationSubmitRequest,
    ) -> VerificationSummaryResponse:
        profile = self._owner_profile(current_user.user_id, for_update=True)
        self._ensure_complete(profile)
        case = self.repository.active_case(profile.id, for_update=True)
        if case is None or case.status != "changes_requested":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VALIDATION_FAILED,
                message="There is no verification case ready to resubmit.",
            )
        case.resubmission_count += 1
        self._submit_case(profile, case, payload)
        self.repository.commit()
        return self._response(profile, case)

    def _create_draft(self, profile_id: UUID, user_id: UUID) -> VerificationCase:
        profile = self.repository.owner_profile(user_id)
        case = VerificationCase(
            profile_id=profile_id,
            submitted_by_user_id=user_id,
            case_reason=(
                "reverification"
                if profile is not None and profile.reverification_required
                else "initial_verification"
            ),
            status="draft",
        )
        self.repository.add_case(case)
        self.repository.flush()
        self.repository.add_checks(
            [
                VerificationCheck(
                    verification_case_id=case.id,
                    check_type=check_type,
                    status="pending",
                )
                for check_type in CHECK_TYPES
            ]
        )
        self.repository.flush()
        return case

    def _submit_case(self, profile, case, payload: VerificationSubmitRequest) -> None:
        documents = self.repository.private_documents(case.id)
        if documents and not payload.consent_accepted:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Accept verification document consent before submitting.",
            )
        now = datetime.now(timezone.utc)
        case.status = "pending_review"
        case.notes_to_user = None
        case.internal_notes = None
        case.submitted_at = now
        case.reviewed_at = None
        case.reviewed_by_admin_user_id = None
        case.consent_version = payload.consent_version if documents else None
        case.consent_accepted_at = now if documents else None
        document_types = {document.document_type for document in documents}
        checks = self.repository.checks(case.id)
        for check in checks:
            check.reviewed_by_admin_user_id = None
            check.reviewed_at = None
            check.notes_to_user = None
            check.internal_notes = None
            if check.check_type == "identity_proof":
                check.status = (
                    "pending"
                    if document_types.intersection({"identity_proof", "masked_aadhaar"})
                    else "not_required"
                )
            elif check.check_type == "gst_proof":
                check.status = (
                    "pending" if "gst_proof" in document_types else "not_required"
                )
            else:
                check.status = "pending"
        profile.verification_status = "pending"
        profile.is_verified = False
        self.repository.add_notification(
            Notification(
                user_id=profile.owner_user_id,
                notification_type="verification_submitted",
                title="Verification submitted",
                message="Your profile is waiting for admin review.",
                data_json={"verification_case_id": str(case.id)},
                priority="normal",
                push_status="not_sent",
            )
        )

    def _response(
        self, profile, case: VerificationCase | None
    ) -> VerificationSummaryResponse:
        checks = self.repository.checks(case.id) if case is not None else []
        documents = (
            self.repository.private_documents(case.id) if case is not None else []
        )
        check_status = {check.check_type: check.status for check in checks}
        return VerificationSummaryResponse(
            verification_status=profile.verification_status,
            is_verified=profile.is_verified,
            reverification_required=profile.reverification_required,
            active_case_id=case.id if case is not None else None,
            case_status=case.status if case is not None else None,
            notes_to_user=case.notes_to_user if case is not None else None,
            submitted_at=case.submitted_at if case is not None else None,
            checks=[
                VerificationCheckResponse(
                    check_type=check.check_type,
                    status=check.status,
                    notes_to_user=check.notes_to_user,
                )
                for check in checks
            ],
            safe_documents=[
                SafeVerificationDocument(
                    media_asset_id=document.id,
                    document_type=document.document_type or "other",
                    status=check_status.get(
                        "identity_proof"
                        if document.document_type == "masked_aadhaar"
                        else document.document_type or "",
                        "uploaded",
                    ),
                    safe_display_name=(document.document_type or "document")
                    .replace("_", " ")
                    .title(),
                )
                for document in documents
            ],
        )

    def _owner_profile(self, user_id: UUID, *, for_update: bool = False):
        profile = self.repository.owner_profile(user_id, for_update=for_update)
        if profile is None:
            raise self._not_found()
        return profile

    @staticmethod
    def _ensure_complete(profile) -> None:
        if profile.completion_score != 100:
            raise ApiError(
                status_code=409,
                code=ErrorCode.PROFILE_INCOMPLETE,
                message="Complete the required profile fields first.",
            )

    @staticmethod
    def _not_found() -> ApiError:
        return ApiError(
            status_code=404,
            code=ErrorCode.NOT_FOUND,
            message="Verification case not found.",
        )
