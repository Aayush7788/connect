from datetime import datetime, timezone
from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.core.auth_context import CurrentAdmin, CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.integrations.supabase_storage import SignedDownload
from app.modules.admin.repository import VerificationBundle
from app.modules.admin.schemas import AdminDecisionRequest, CreateExportRequest
from app.modules.admin.service import AdminService


class FakeStorage:
    def __init__(self) -> None:
        self.uploads = []

    def create_signed_download(self, *, bucket, path, expires_in_seconds=900):
        return SignedDownload(url=f"https://private.test/{path}")

    def upload(self, **values):
        self.uploads.append(values)


class FakeAdminRepository:
    def __init__(self) -> None:
        profile = SimpleNamespace(
            id=uuid4(),
            owner_user_id=uuid4(),
            role="business",
            public_name="Connect Textiles",
            visibility_status="public",
            completion_score=100,
            completion_flags={},
            verification_status="pending",
            is_verified=False,
            reverification_required=False,
            full_address="Ring Road, Surat",
            is_admin_seeded=False,
            claim_status=None,
        )
        owner = SimpleNamespace(
            id=profile.owner_user_id,
            primary_mobile="+919999999999",
            account_status="active",
        )
        case = SimpleNamespace(
            id=uuid4(),
            profile_id=profile.id,
            status="pending_review",
            case_reason="initial_verification",
            submitted_at=datetime.now(timezone.utc),
            reviewed_at=None,
            reviewed_by_admin_user_id=None,
            notes_to_user=None,
            internal_notes=None,
            resubmission_count=0,
        )
        checks = [
            SimpleNamespace(
                check_type=check_type,
                status="pending",
                notes_to_user=None,
                internal_notes=None,
                reviewed_by_admin_user_id=None,
                reviewed_at=None,
            )
            for check_type in (
                "profile_details",
                "mobile",
                "shop_or_workplace_photos",
                "identity_proof",
                "gst_proof",
                "admin_final_review",
            )
        ]
        self.bundle = VerificationBundle(case, profile, owner, checks, [])
        self.notifications = []
        self.audits = []
        self.commits = 0

    def verification_bundle(self, case_id, *, for_update=False):
        return self.bundle if case_id == self.bundle.case.id else None

    def add_notification(self, notification):
        self.notifications.append(notification)

    def add_audit(self, audit):
        self.audits.append(audit)

    def commit(self):
        self.commits += 1

    def export_rows(self, dataset):
        return ["id", "status"], [(uuid4(), "verified")]


def make_service():
    repository = FakeAdminRepository()
    user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919888888888",
        role="business",
        account_status="active",
    )
    admin = CurrentAdmin(
        admin_user_id=uuid4(),
        user=user,
        role="super_admin",
        display_name="Aayush",
    )
    storage = FakeStorage()
    return (
        AdminService(
            repository=repository,
            storage=storage,
            private_bucket="verification-private",
        ),
        repository,
        storage,
        admin,
    )


def test_admin_approval_sets_blue_tick_and_audits() -> None:
    service, repository, _, admin = make_service()

    response = service.approve_verification(
        admin=admin,
        case_id=repository.bundle.case.id,
        payload=AdminDecisionRequest(notes="Checked manually"),
        ip_address="127.0.0.1",
        user_agent="pytest",
    )

    assert response.status == "approved"
    assert repository.bundle.profile.is_verified is True
    assert repository.bundle.profile.verification_status == "verified"
    assert repository.notifications[0].notification_type == "verification_approved"
    assert repository.audits[0].action == "verification.approve"
    assert all(check.status == "approved" for check in repository.bundle.checks)


def test_request_changes_requires_owner_visible_message() -> None:
    service, repository, _, admin = make_service()

    with pytest.raises(ApiError) as exc_info:
        service.request_verification_changes(
            admin=admin,
            case_id=repository.bundle.case.id,
            payload=AdminDecisionRequest(),
            ip_address=None,
            user_agent=None,
        )

    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED


def test_csv_export_is_private_signed_and_audited() -> None:
    service, repository, storage, admin = make_service()

    response = service.create_export(
        admin=admin,
        payload=CreateExportRequest(dataset="profiles"),
        ip_address=None,
        user_agent="pytest",
    )

    assert response.status == "ready"
    assert response.download_url.startswith("https://private.test/admin-exports/")
    assert storage.uploads[0]["mime_type"] == "text/csv"
    assert repository.audits[0].action == "export.create"
