from datetime import datetime, timezone
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.db.models.cross_cutting import ContactActionEvent, Notification, Report
from app.db.models.cross_cutting import SavedItem, ShareEvent
from app.db.models.identity import User, UserDevice, UserSetting
from app.db.models.profile import Profile
from app.db.session import create_database_engine
from app.modules.engagement.repository import EngagementRepository
from app.modules.engagement.schemas import ContactActionRequest
from app.modules.engagement.schemas import CreateReportRequest, CreateShareLinkRequest
from app.modules.engagement.schemas import RegisterDeviceTokenRequest, SaveItemRequest
from app.modules.engagement.schemas import UpdateSettingsRequest
from app.modules.engagement.service import EngagementService


pytestmark = pytest.mark.skipif(
    Settings().database_url is None,
    reason="DATABASE_URL is required for PostgreSQL integration tests.",
)


def test_engagement_flows_persist_and_remain_owner_scoped() -> None:
    engine = create_database_engine()
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection, expire_on_commit=False)
    try:
        owner_id = uuid4()
        viewer_id = uuid4()
        profile_id = uuid4()
        notification_id = uuid4()
        now = datetime.now(timezone.utc)
        session.add_all(
            [
                User(
                    id=owner_id,
                    auth_user_id=uuid4(),
                    display_name="Engagement Owner",
                    primary_mobile=f"+916{str(owner_id.int)[-9:]}",
                    account_status="active",
                    role="business",
                    role_confirmed_at=now,
                    profile_completed_at=now,
                ),
                User(
                    id=viewer_id,
                    auth_user_id=uuid4(),
                    display_name="Engagement Viewer",
                    primary_mobile=f"+915{str(viewer_id.int)[-9:]}",
                    account_status="active",
                    role="job_worker",
                    role_confirmed_at=now,
                    profile_completed_at=now,
                ),
            ]
        )
        session.flush()
        session.add(
            Profile(
                id=profile_id,
                owner_user_id=owner_id,
                role="business",
                public_name="Engagement Textile Business",
                owner_name="Engagement Owner",
                full_address="Ring Road, Surat",
                locality="Ring Road",
                normalized_locality="ring road",
                city="Surat",
                state="Gujarat",
                pincode="395002",
                visibility_status="public",
                verification_status="unverified",
                completion_score=100,
                completion_flags={"profile_details": True},
                photo_count=3,
                is_verified=False,
                reverification_required=False,
                ranking_score=Decimal("3"),
                last_activity_at=now,
            )
        )
        session.add(
            Notification(
                id=notification_id,
                user_id=viewer_id,
                notification_type="verification_status",
                title="Profile approved",
                message="Your profile is now verified.",
                priority="normal",
            )
        )
        session.flush()

        service = EngagementService(
            EngagementRepository(session),
            share_base_url="https://connect.example",
        )
        current_user = CurrentUser(
            user_id=viewer_id,
            auth_user_id=uuid4(),
            mobile="+915000000000",
            role="job_worker",
            account_status="active",
        )
        save_request = SaveItemRequest(target_type="profile", target_id=profile_id)
        first_saved = service.save_item(
            current_user=current_user,
            payload=save_request,
        )
        second_saved = service.save_item(
            current_user=current_user,
            payload=save_request,
        )
        for _ in range(2):
            service.report(
                current_user=current_user,
                payload=CreateReportRequest(
                    reported_entity_type="profile",
                    reported_entity_id=profile_id,
                    reason="wrong_contact",
                ),
            )
        service.log_contact_action(
            current_user=current_user,
            payload=ContactActionRequest(
                profile_id=profile_id,
                action_type="address",
            ),
            ip_address="127.0.0.1",
            device_id="engagement-device",
            user_agent="flutter-test",
        )
        share = service.share_link(
            current_user=current_user,
            payload=CreateShareLinkRequest(
                target_type="profile",
                target_id=profile_id,
                channel="native_other",
            ),
            ip_address="127.0.0.1",
            device_id="engagement-device",
            user_agent="flutter-test",
        )
        service.register_device(
            current_user=current_user,
            payload=RegisterDeviceTokenRequest(
                fcm_token=f"fcm-{viewer_id}",
                platform="android",
                device_id=f"device-{viewer_id}",
                app_version="1.0.0",
            ),
        )
        marked = service.mark_notification_read(
            current_user=current_user,
            notification_id=notification_id,
        )
        settings = service.update_settings(
            current_user=current_user,
            payload=UpdateSettingsRequest(push_notifications_enabled=False),
        )
        loaded_settings = service.settings(current_user=current_user)

        assert first_saved.id == second_saved.id
        assert first_saved.profile_role == "business"
        assert share.url == f"https://connect.example/profiles/{profile_id}"
        assert marked.read_at is not None
        assert settings.push_notifications_enabled is False
        assert loaded_settings.push_notifications_enabled is False
        assert (
            session.scalar(
                select(func.count(SavedItem.id)).where(SavedItem.user_id == viewer_id)
            )
            == 1
        )
        assert (
            session.scalar(
                select(func.count(Report.id)).where(
                    Report.reporter_user_id == viewer_id
                )
            )
            == 2
        )
        assert (
            session.scalar(
                select(func.count(ContactActionEvent.id)).where(
                    ContactActionEvent.actor_user_id == viewer_id
                )
            )
            == 1
        )
        assert (
            session.scalar(
                select(func.count(ShareEvent.id)).where(ShareEvent.user_id == viewer_id)
            )
            == 1
        )
        assert (
            session.scalar(
                select(func.count(UserDevice.id)).where(UserDevice.user_id == viewer_id)
            )
            == 1
        )
        assert (
            session.scalar(
                select(func.count(UserSetting.id)).where(
                    UserSetting.user_id == viewer_id
                )
            )
            == 1
        )
    finally:
        session.close()
        transaction.rollback()
        connection.close()
        engine.dispose()
