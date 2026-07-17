from datetime import datetime, timezone
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.auth_context import CurrentAdmin, CurrentUser
from app.core.config import Settings
from app.db.models.cross_cutting import Notification, VerificationCase
from app.db.models.identity import AdminAuditLog, AdminUser, User
from app.db.models.profile import Profile
from app.db.session import create_database_engine
from app.modules.admin.repository import AdminRepository
from app.modules.admin.schemas import AdminDecisionRequest
from app.modules.admin.service import AdminService
from app.modules.verification.repository import VerificationRepository
from app.modules.verification.schemas import VerificationSubmitRequest
from app.modules.verification.service import VerificationService


pytestmark = pytest.mark.skipif(
    Settings().database_url is None,
    reason="DATABASE_URL is required for PostgreSQL integration tests.",
)


class NoopStorage:
    pass


def test_verification_resubmission_approval_and_suspension_are_persisted() -> None:
    engine = create_database_engine()
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection, expire_on_commit=False)
    try:
        owner_id = uuid4()
        admin_user_id = uuid4()
        profile_id = uuid4()
        admin_id = uuid4()
        now = datetime.now(timezone.utc)
        owner_mobile = f"+914{str(owner_id.int)[-9:]}"
        admin_mobile = f"+913{str(admin_user_id.int)[-9:]}"
        session.add_all(
            [
                User(
                    id=owner_id,
                    auth_user_id=uuid4(),
                    display_name="Verification Owner",
                    primary_mobile=owner_mobile,
                    account_status="active",
                    role="business",
                    role_confirmed_at=now,
                    profile_completed_at=now,
                ),
                User(
                    id=admin_user_id,
                    auth_user_id=uuid4(),
                    display_name="Verification Admin",
                    primary_mobile=admin_mobile,
                    account_status="active",
                    role="business",
                    role_confirmed_at=now,
                ),
            ]
        )
        session.flush()
        session.add(
            AdminUser(
                id=admin_id,
                user_id=admin_user_id,
                display_name="Verification Admin",
                role="super_admin",
                status="active",
            )
        )
        session.add(
            Profile(
                id=profile_id,
                owner_user_id=owner_id,
                role="business",
                public_name="Verification Textile",
                owner_name="Verification Owner",
                full_address="Ring Road, Surat, Gujarat 395002",
                locality="Ring Road",
                normalized_locality="ring road",
                city="Surat",
                state="Gujarat",
                pincode="395002",
                visibility_status="public",
                verification_status="unverified",
                completion_score=100,
                completion_flags={"profile_details": True, "shop_photos": True},
                photo_count=3,
                is_verified=False,
                reverification_required=False,
                ranking_score=Decimal("2"),
                last_activity_at=now,
            )
        )
        session.flush()

        owner = CurrentUser(
            user_id=owner_id,
            auth_user_id=uuid4(),
            mobile=owner_mobile,
            role="business",
            account_status="active",
        )
        admin = CurrentAdmin(
            admin_user_id=admin_id,
            user=CurrentUser(
                user_id=admin_user_id,
                auth_user_id=uuid4(),
                mobile=admin_mobile,
                role="business",
                account_status="active",
            ),
            role="super_admin",
            display_name="Verification Admin",
        )
        verification = VerificationService(VerificationRepository(session))
        admin_service = AdminService(
            repository=AdminRepository(session),
            storage=NoopStorage(),
            private_bucket="verification-private",
        )

        submitted = verification.submit(
            current_user=owner,
            payload=VerificationSubmitRequest(),
        )
        changed = admin_service.request_verification_changes(
            admin=admin,
            case_id=submitted.active_case_id,
            payload=AdminDecisionRequest(notes="Add a clearer shop photo."),
            ip_address="127.0.0.1",
            user_agent="pytest",
        )
        resubmitted = verification.resubmit(
            current_user=owner,
            payload=VerificationSubmitRequest(),
        )
        approved = admin_service.approve_verification(
            admin=admin,
            case_id=resubmitted.active_case_id,
            payload=AdminDecisionRequest(notes="Profile evidence reviewed."),
            ip_address="127.0.0.1",
            user_agent="pytest",
        )
        suspended = admin_service.suspend_profile(
            admin=admin,
            profile_id=profile_id,
            payload=AdminDecisionRequest(notes="Moderation test."),
            ip_address="127.0.0.1",
            user_agent="pytest",
        )
        restored = admin_service.unsuspend_profile(
            admin=admin,
            profile_id=profile_id,
            ip_address="127.0.0.1",
            user_agent="pytest",
        )

        case = session.get(VerificationCase, submitted.active_case_id)
        assert changed.status == "changes_requested"
        assert resubmitted.active_case_id == submitted.active_case_id
        assert case is not None and case.resubmission_count == 1
        assert approved.profile.is_verified is True
        assert suspended.profile.visibility_status == "suspended_by_admin"
        assert restored.profile.visibility_status == "public"
        assert session.get(User, owner_id).account_status == "active"
        assert session.scalar(select(func.count(AdminAuditLog.id))) == 4
        assert session.scalar(select(func.count(Notification.id))) == 4
        assert (
            session.scalar(
                select(func.count(AdminAuditLog.id)).where(
                    AdminAuditLog.actor_admin_user_id.is_(None)
                )
            )
            == 0
        )
    finally:
        session.close()
        if transaction.is_active:
            transaction.rollback()
        connection.close()
        engine.dispose()
