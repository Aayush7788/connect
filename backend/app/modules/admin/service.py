import base64
import csv
from datetime import datetime, timedelta, timezone
from io import StringIO
from uuid import UUID, uuid4

from sqlalchemy import func

from app.core.auth_context import CurrentAdmin
from app.core.errors import ApiError, ErrorCode
from app.db.models.cross_cutting import Notification
from app.db.models.identity import AdminAuditLog
from app.db.models.profile import BusinessProfile, JobWorkerProfile, Profile
from app.db.models.profile import SkilledWorkerProfile
from app.integrations.supabase_storage import MediaStorageGateway
from app.integrations.supabase_storage import StorageProviderError
from app.modules.admin.repository import AdminRepository, VerificationBundle
from app.modules.admin.schemas import AdminAnalyticsSummaryResponse
from app.modules.admin.schemas import AdminDecisionRequest, AdminPrivateDocumentResponse
from app.modules.admin.schemas import AdminProfileResponse, AdminProfilesResponse
from app.modules.admin.schemas import AdminReportResponse, AdminReportsResponse
from app.modules.admin.schemas import AdminSeedProfileRequest
from app.modules.admin.schemas import AdminUserResponse
from app.modules.admin.schemas import AdminVerificationCaseResponse
from app.modules.admin.schemas import AdminVerificationCasesResponse
from app.modules.admin.schemas import AdminVerificationCheckResponse
from app.modules.admin.schemas import CreateExportRequest, ExportJobResponse
from app.modules.auth.schemas import ProfileSummaryResponse
from app.modules.auth.session_cache import auth_context_cache


class AdminService:
    def __init__(
        self,
        *,
        repository: AdminRepository,
        storage: MediaStorageGateway,
        private_bucket: str,
    ) -> None:
        self.repository = repository
        self.storage = storage
        self.private_bucket = private_bucket

    @staticmethod
    def me(admin: CurrentAdmin) -> AdminUserResponse:
        return AdminUserResponse(
            id=admin.admin_user_id,
            display_name=admin.display_name,
            mobile=admin.user.mobile,
        )

    def list_verification_cases(
        self,
        *,
        status: str | None,
        cursor: str | None,
        limit: int,
    ) -> AdminVerificationCasesResponse:
        offset = self._decode_cursor(cursor)
        rows = self.repository.verification_rows(
            status=status,
            offset=offset,
            limit=limit + 1,
        )
        has_more = len(rows) > limit
        items = [
            self._verification_response(
                VerificationBundle(case, profile, owner, [], []),
                include_documents=False,
            )
            for case, profile, owner in rows[:limit]
        ]
        return AdminVerificationCasesResponse(
            items=items,
            next_cursor=self._encode_cursor(offset + limit) if has_more else None,
        )

    def get_verification_case(
        self,
        *,
        admin: CurrentAdmin,
        case_id: UUID,
        ip_address: str | None,
        user_agent: str | None,
    ) -> AdminVerificationCaseResponse:
        bundle = self._verification_bundle(case_id)
        response = self._verification_response(bundle, include_documents=True)
        if bundle.documents:
            self._audit(
                admin=admin,
                action="verification.private_documents_accessed",
                entity_type="verification_case",
                entity_id=case_id,
                before=None,
                after={"document_count": len(bundle.documents)},
                ip_address=ip_address,
                user_agent=user_agent,
            )
            self.repository.commit()
        return response

    def approve_verification(
        self,
        *,
        admin: CurrentAdmin,
        case_id: UUID,
        payload: AdminDecisionRequest,
        ip_address: str | None,
        user_agent: str | None,
    ) -> AdminVerificationCaseResponse:
        bundle = self._pending_bundle(case_id)
        before = self._verification_snapshot(bundle)
        now = datetime.now(timezone.utc)
        for check in bundle.checks:
            if check.status != "not_required":
                check.status = "approved"
            check.reviewed_by_admin_user_id = admin.admin_user_id
            check.reviewed_at = now
            check.internal_notes = payload.notes
        bundle.case.status = "approved"
        bundle.case.internal_notes = payload.notes
        bundle.case.notes_to_user = None
        bundle.case.reviewed_by_admin_user_id = admin.admin_user_id
        bundle.case.reviewed_at = now
        bundle.profile.verification_status = "verified"
        bundle.profile.is_verified = True
        bundle.profile.reverification_required = False
        self._notify(
            bundle,
            notification_type="verification_approved",
            title="Profile verified",
            message="Your profile is approved and now shows a blue tick.",
        )
        self._audit_decision(
            admin, "verification.approve", bundle, before, ip_address, user_agent
        )
        self.repository.commit()
        return self._verification_response(bundle, include_documents=False)

    def request_verification_changes(
        self,
        *,
        admin: CurrentAdmin,
        case_id: UUID,
        payload: AdminDecisionRequest,
        ip_address: str | None,
        user_agent: str | None,
    ) -> AdminVerificationCaseResponse:
        notes = self._required_notes(payload)
        bundle = self._pending_bundle(case_id)
        before = self._verification_snapshot(bundle)
        now = datetime.now(timezone.utc)
        for check in bundle.checks:
            if check.check_type == "admin_final_review":
                check.status = "changes_requested"
                check.notes_to_user = notes
                check.reviewed_by_admin_user_id = admin.admin_user_id
                check.reviewed_at = now
        bundle.case.status = "changes_requested"
        bundle.case.notes_to_user = notes
        bundle.case.internal_notes = payload.notes
        bundle.case.reviewed_by_admin_user_id = admin.admin_user_id
        bundle.case.reviewed_at = now
        bundle.profile.verification_status = "changes_requested"
        bundle.profile.is_verified = False
        self._notify(
            bundle,
            notification_type="verification_changes_requested",
            title="Verification changes requested",
            message=notes,
        )
        self._audit_decision(
            admin,
            "verification.request_changes",
            bundle,
            before,
            ip_address,
            user_agent,
        )
        self.repository.commit()
        return self._verification_response(bundle, include_documents=False)

    def reject_verification(
        self,
        *,
        admin: CurrentAdmin,
        case_id: UUID,
        payload: AdminDecisionRequest,
        ip_address: str | None,
        user_agent: str | None,
    ) -> AdminVerificationCaseResponse:
        notes = self._required_notes(payload)
        bundle = self._pending_bundle(case_id)
        before = self._verification_snapshot(bundle)
        now = datetime.now(timezone.utc)
        for check in bundle.checks:
            if check.check_type == "admin_final_review":
                check.status = "rejected"
                check.notes_to_user = notes
                check.reviewed_by_admin_user_id = admin.admin_user_id
                check.reviewed_at = now
        bundle.case.status = "rejected"
        bundle.case.notes_to_user = notes
        bundle.case.internal_notes = payload.notes
        bundle.case.reviewed_by_admin_user_id = admin.admin_user_id
        bundle.case.reviewed_at = now
        bundle.profile.verification_status = "rejected"
        bundle.profile.is_verified = False
        self._notify(
            bundle,
            notification_type="verification_rejected",
            title="Verification not approved",
            message=notes,
        )
        self._audit_decision(
            admin, "verification.reject", bundle, before, ip_address, user_agent
        )
        self.repository.commit()
        return self._verification_response(bundle, include_documents=False)

    def list_profiles(
        self,
        *,
        role: str | None,
        verification_status: str | None,
        is_admin_seeded: bool | None,
        cursor: str | None,
        limit: int,
    ) -> AdminProfilesResponse:
        offset = self._decode_cursor(cursor)
        rows = self.repository.profile_rows(
            role=role,
            verification_status=verification_status,
            is_admin_seeded=is_admin_seeded,
            offset=offset,
            limit=limit + 1,
        )
        has_more = len(rows) > limit
        return AdminProfilesResponse(
            items=[
                self._admin_profile(profile, owner) for profile, owner in rows[:limit]
            ],
            next_cursor=self._encode_cursor(offset + limit) if has_more else None,
        )

    def create_seed_profile(
        self,
        *,
        admin: CurrentAdmin,
        payload: AdminSeedProfileRequest,
        ip_address: str | None,
        user_agent: str | None,
    ) -> AdminProfileResponse:
        data = self._clean_seed_data(payload.profile_data)
        profile = Profile(
            owner_user_id=None,
            role=payload.role,
            public_name=payload.display_name,
            owner_name=data.get("owner_name"),
            alternate_contact_number=data.get("alternate_contact_number"),
            full_address=data.get("full_address"),
            address_line1=data.get("address_line1"),
            address_line2=data.get("address_line2"),
            locality=data.get("locality"),
            normalized_locality=self._normalize(data.get("locality")),
            city=data.get("city"),
            state=data.get("state"),
            pincode=data.get("pincode"),
            visibility_status="public" if payload.make_public else "draft",
            completion_score=70 if payload.make_public else 0,
            completion_flags={"admin_seeded": True},
            is_admin_seeded=True,
            created_by_admin_user_id=admin.admin_user_id,
            claim_status="unclaimed",
            search_text=self._seed_search_text(payload.display_name, data),
            last_activity_at=datetime.now(timezone.utc),
        )
        profile.search_vector = func.to_tsvector("simple", profile.search_text)
        if payload.role == "business":
            role_profile = BusinessProfile(
                profile_id=profile.id,
                business_name=data.get("business_name") or payload.display_name,
                manufacture_sell_details=data.get("manufacture_sell_details") or "",
                product_notes=data.get("product_notes"),
            )
        elif payload.role == "job_worker":
            role_profile = JobWorkerProfile(
                profile_id=profile.id,
                workshop_name=data.get("workshop_name") or payload.display_name,
                has_workshop=bool(data.get("has_workshop", True)),
                work_summary=data.get("work_summary"),
                profile_experience_years=data.get("experience_years"),
            )
        else:
            role_profile = SkilledWorkerProfile(
                profile_id=profile.id,
                skill_mastery=data.get("skill_mastery") or "Skilled textile work",
                experience_years=data.get("experience_years"),
                bio=data.get("bio"),
            )
        self.repository.add_seed_profile(profile, role_profile)
        self.repository.flush()
        self._audit(
            admin=admin,
            action="profile.seed_create",
            entity_type="profile",
            entity_id=profile.id,
            before=None,
            after={
                "role": profile.role,
                "public_name": profile.public_name,
                "visibility_status": profile.visibility_status,
                "is_admin_seeded": True,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )
        self.repository.commit()
        return self._admin_profile(profile, None)

    def suspend_profile(
        self,
        *,
        admin: CurrentAdmin,
        profile_id: UUID,
        payload: AdminDecisionRequest,
        ip_address: str | None,
        user_agent: str | None,
    ) -> AdminProfileResponse:
        row = self._profile_row(profile_id, for_update=True)
        profile, owner = row
        before = self._profile_snapshot(profile, owner)
        profile.visibility_status = "suspended_by_admin"
        if owner is not None:
            owner.account_status = "suspended"
            auth_context_cache.invalidate_user(owner.id)
        self._audit(
            admin=admin,
            action="profile.suspend",
            entity_type="profile",
            entity_id=profile.id,
            before=before,
            after={**self._profile_snapshot(profile, owner), "notes": payload.notes},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        self.repository.commit()
        return self._admin_profile(profile, owner)

    def unsuspend_profile(
        self,
        *,
        admin: CurrentAdmin,
        profile_id: UUID,
        ip_address: str | None,
        user_agent: str | None,
    ) -> AdminProfileResponse:
        profile, owner = self._profile_row(profile_id, for_update=True)
        before = self._profile_snapshot(profile, owner)
        can_publish = profile.completion_score == 100 or (
            profile.is_admin_seeded and profile.completion_score > 0
        )
        profile.visibility_status = "public" if can_publish else "draft"
        if owner is not None:
            owner.account_status = "active"
            auth_context_cache.invalidate_user(owner.id)
        self._audit(
            admin=admin,
            action="profile.unsuspend",
            entity_type="profile",
            entity_id=profile.id,
            before=before,
            after=self._profile_snapshot(profile, owner),
            ip_address=ip_address,
            user_agent=user_agent,
        )
        self.repository.commit()
        return self._admin_profile(profile, owner)

    def list_reports(
        self,
        *,
        status: str | None,
        grouped: bool,
        cursor: str | None,
        limit: int,
    ) -> AdminReportsResponse:
        offset = self._decode_cursor(cursor)
        rows = self.repository.report_rows(
            status=status,
            grouped=grouped,
            offset=offset,
            limit=limit + 1,
        )
        has_more = len(rows) > limit
        if grouped:
            items = [
                AdminReportResponse(
                    reported_entity_type=row[0],
                    reported_entity_id=row[1],
                    reason=row[2],
                    report_count=int(row[3]),
                    latest_reported_at=row[4],
                )
                for row in rows[:limit]
            ]
        else:
            items = [
                AdminReportResponse(
                    id=report.id,
                    reported_entity_type=report.reported_entity_type,
                    reported_entity_id=report.reported_entity_id,
                    reason=report.reason,
                    status=report.status,
                    message=report.message,
                    latest_reported_at=report.created_at,
                )
                for report in rows[:limit]
            ]
        return AdminReportsResponse(
            items=items,
            next_cursor=self._encode_cursor(offset + limit) if has_more else None,
        )

    def analytics(self) -> AdminAnalyticsSummaryResponse:
        return AdminAnalyticsSummaryResponse.model_validate(self.repository.analytics())

    def create_export(
        self,
        *,
        admin: CurrentAdmin,
        payload: CreateExportRequest,
        ip_address: str | None,
        user_agent: str | None,
    ) -> ExportJobResponse:
        headers, rows = self.repository.export_rows(payload.dataset)
        stream = StringIO(newline="")
        writer = csv.writer(stream)
        writer.writerow(headers)
        writer.writerows(rows)
        export_id = uuid4()
        path = f"admin-exports/{admin.admin_user_id}/{export_id}.csv"
        try:
            self.storage.upload(
                bucket=self.private_bucket,
                path=path,
                content=stream.getvalue().encode("utf-8-sig"),
                mime_type="text/csv",
            )
            signed = self.storage.create_signed_download(
                bucket=self.private_bucket,
                path=path,
            )
        except StorageProviderError as error:
            raise ApiError(
                status_code=503,
                code=ErrorCode.PROVIDER_UNAVAILABLE,
                message="Export is temporarily unavailable.",
            ) from error
        expires_at = datetime.now(timezone.utc) + timedelta(
            seconds=signed.expires_in_seconds
        )
        self._audit(
            admin=admin,
            action="export.create",
            entity_type="admin_export",
            entity_id=export_id,
            before=None,
            after={"dataset": payload.dataset, "row_count": len(rows)},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        self.repository.commit()
        return ExportJobResponse(
            id=export_id,
            download_url=signed.url,
            expires_at=expires_at,
        )

    def _verification_response(
        self,
        bundle: VerificationBundle,
        *,
        include_documents: bool,
    ) -> AdminVerificationCaseResponse:
        documents = []
        if include_documents:
            try:
                for document in bundle.documents:
                    signed = self.storage.create_signed_download(
                        bucket=self.private_bucket,
                        path=document.original_path,
                    )
                    documents.append(
                        AdminPrivateDocumentResponse(
                            media_asset_id=document.id,
                            document_type=document.document_type or "other",
                            safe_display_name=(document.document_type or "document")
                            .replace("_", " ")
                            .title(),
                            access_url=signed.url,
                            expires_at=datetime.now(timezone.utc)
                            + timedelta(seconds=signed.expires_in_seconds),
                        )
                    )
            except StorageProviderError as error:
                raise ApiError(
                    status_code=503,
                    code=ErrorCode.PROVIDER_UNAVAILABLE,
                    message="Verification documents are temporarily unavailable.",
                ) from error
        return AdminVerificationCaseResponse(
            id=bundle.case.id,
            status=bundle.case.status,
            case_reason=bundle.case.case_reason,
            profile=self._profile_summary(bundle.profile),
            owner_mobile=bundle.owner.primary_mobile if bundle.owner else None,
            full_address=bundle.profile.full_address,
            submitted_at=bundle.case.submitted_at,
            reviewed_at=bundle.case.reviewed_at,
            notes_to_user=bundle.case.notes_to_user,
            internal_notes=bundle.case.internal_notes,
            resubmission_count=bundle.case.resubmission_count,
            checks=[
                AdminVerificationCheckResponse(
                    check_type=check.check_type,
                    status=check.status,
                    notes_to_user=check.notes_to_user,
                    internal_notes=check.internal_notes,
                )
                for check in bundle.checks
            ],
            private_document_access=documents,
        )

    def _pending_bundle(self, case_id: UUID) -> VerificationBundle:
        bundle = self._verification_bundle(case_id, for_update=True)
        if bundle.case.status != "pending_review":
            raise ApiError(
                status_code=409,
                code=ErrorCode.VALIDATION_FAILED,
                message="This verification case is no longer pending review.",
            )
        return bundle

    def _verification_bundle(
        self,
        case_id: UUID,
        *,
        for_update: bool = False,
    ) -> VerificationBundle:
        bundle = self.repository.verification_bundle(case_id, for_update=for_update)
        if bundle is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Verification case not found.",
            )
        return bundle

    def _profile_row(self, profile_id: UUID, *, for_update: bool):
        row = self.repository.profile_with_owner(profile_id, for_update=for_update)
        if row is None:
            raise ApiError(
                status_code=404,
                code=ErrorCode.NOT_FOUND,
                message="Profile not found.",
            )
        return row

    def _notify(
        self,
        bundle: VerificationBundle,
        *,
        notification_type: str,
        title: str,
        message: str,
    ) -> None:
        if bundle.profile.owner_user_id is None:
            return
        self.repository.add_notification(
            Notification(
                user_id=bundle.profile.owner_user_id,
                notification_type=notification_type,
                title=title,
                message=message,
                data_json={"verification_case_id": str(bundle.case.id)},
                priority="normal",
                push_status="not_sent",
            )
        )

    def _audit_decision(
        self,
        admin: CurrentAdmin,
        action: str,
        bundle: VerificationBundle,
        before: dict,
        ip_address: str | None,
        user_agent: str | None,
    ) -> None:
        self._audit(
            admin=admin,
            action=action,
            entity_type="verification_case",
            entity_id=bundle.case.id,
            before=before,
            after=self._verification_snapshot(bundle),
            ip_address=ip_address,
            user_agent=user_agent,
        )

    def _audit(
        self,
        *,
        admin: CurrentAdmin,
        action: str,
        entity_type: str,
        entity_id: UUID,
        before: dict | None,
        after: dict | None,
        ip_address: str | None,
        user_agent: str | None,
    ) -> None:
        self.repository.add_audit(
            AdminAuditLog(
                actor_admin_user_id=admin.admin_user_id,
                action=action,
                entity_type=entity_type,
                entity_id=entity_id,
                before_json=before,
                after_json=after,
                ip_address=ip_address,
                user_agent=user_agent,
            )
        )

    @staticmethod
    def _profile_summary(profile: Profile) -> ProfileSummaryResponse:
        return ProfileSummaryResponse(
            id=profile.id,
            role=profile.role,
            display_name=profile.public_name,
            visibility_status=profile.visibility_status,
            completion_score=profile.completion_score,
            completion_flags=profile.completion_flags,
            verification_status=profile.verification_status,
            is_verified=profile.is_verified,
            reverification_required=profile.reverification_required,
        )

    def _admin_profile(self, profile: Profile, owner) -> AdminProfileResponse:
        return AdminProfileResponse(
            profile=self._profile_summary(profile),
            owner_user_id=profile.owner_user_id,
            owner_mobile=owner.primary_mobile if owner else None,
            is_admin_seeded=profile.is_admin_seeded,
            claim_status=profile.claim_status,
            account_status=owner.account_status if owner else None,
            full_address=profile.full_address,
        )

    @staticmethod
    def _verification_snapshot(bundle: VerificationBundle) -> dict:
        return {
            "case_status": bundle.case.status,
            "profile_verification_status": bundle.profile.verification_status,
            "is_verified": bundle.profile.is_verified,
            "checks": {check.check_type: check.status for check in bundle.checks},
        }

    @staticmethod
    def _profile_snapshot(profile: Profile, owner) -> dict:
        return {
            "visibility_status": profile.visibility_status,
            "account_status": owner.account_status if owner else None,
        }

    @staticmethod
    def _required_notes(payload: AdminDecisionRequest) -> str:
        if payload.notes is None:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Tell the user what needs to change.",
                field_errors={"notes": "A message is required."},
            )
        return payload.notes

    @staticmethod
    def _clean_seed_data(values: dict) -> dict:
        allowed = {
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
            "has_workshop",
            "work_summary",
            "skill_mastery",
            "experience_years",
            "bio",
        }
        return {key: value for key, value in values.items() if key in allowed}

    @staticmethod
    def _seed_search_text(display_name: str, data: dict) -> str:
        parts = [display_name]
        parts.extend(str(value) for value in data.values() if value not in (None, ""))
        return " ".join(parts).casefold()

    @staticmethod
    def _normalize(value) -> str | None:
        return str(value).strip().casefold() if value else None

    @staticmethod
    def _encode_cursor(offset: int) -> str:
        return base64.urlsafe_b64encode(str(offset).encode()).decode().rstrip("=")

    @staticmethod
    def _decode_cursor(cursor: str | None) -> int:
        if cursor is None:
            return 0
        try:
            value = int(
                base64.urlsafe_b64decode(cursor + "=" * (-len(cursor) % 4)).decode()
            )
            if value < 0:
                raise ValueError
            return value
        except (ValueError, UnicodeDecodeError) as error:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="This cursor is invalid or expired.",
            ) from error
