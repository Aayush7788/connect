from datetime import datetime, timezone
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.db.models.cross_cutting import ContactReveal, MediaAsset
from app.db.models.identity import User
from app.db.models.marketplace import WorkCard, WorkCardProductType
from app.db.models.profile import JobWorkerProfile, Profile
from app.db.session import create_database_engine
from app.modules.profiles.repository import ProfileRepository
from app.modules.profiles.service import ProfileService


pytestmark = pytest.mark.skipif(
    Settings().database_url is None,
    reason="DATABASE_URL is required for PostgreSQL integration tests.",
)


def test_profile_detail_returns_contact_and_upserts_one_reveal_row() -> None:
    engine = create_database_engine()
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection, expire_on_commit=False)
    try:
        owner_id = uuid4()
        viewer_id = uuid4()
        profile_id = uuid4()
        card_id = uuid4()
        now = datetime.now(timezone.utc)
        session.add_all(
            [
                User(
                    id=owner_id,
                    auth_user_id=uuid4(),
                    display_name="Profile Test Owner",
                    primary_mobile=f"+918{str(owner_id.int)[-9:]}",
                    account_status="active",
                    role="job_worker",
                    role_confirmed_at=now,
                    profile_completed_at=now,
                ),
                User(
                    id=viewer_id,
                    auth_user_id=uuid4(),
                    display_name="Profile Test Viewer",
                    primary_mobile=f"+917{str(viewer_id.int)[-9:]}",
                    account_status="active",
                    role="business",
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
                role="job_worker",
                public_name="Rollback Hemming Workshop",
                owner_name="Profile Test Owner",
                full_address="Ring Road, Surat",
                locality="Ring Road",
                normalized_locality="ring road",
                city="Surat",
                state="Gujarat",
                pincode="395002",
                visibility_status="public",
                verification_status="verified",
                completion_score=100,
                completion_flags={"published_work_card": True},
                photo_count=3,
                is_verified=True,
                reverification_required=False,
                ranking_score=Decimal("5"),
                last_activity_at=now,
            )
        )
        session.flush()
        session.add(
            JobWorkerProfile(
                profile_id=profile_id,
                workshop_name="Rollback Hemming Workshop",
                has_workshop=True,
                work_summary="Flat hemming job work",
                profile_experience_years=8,
            )
        )
        session.flush()
        session.add(
            WorkCard(
                id=card_id,
                profile_id=profile_id,
                custom_work_category_text="Stitching",
                custom_work_name="Flat hemming",
                title="Flat hemming",
                description="Clean flat hemming for dupattas",
                experience_years=8,
                status="published",
                photo_count=3,
                ranking_score=Decimal("4.5"),
                last_activity_at=now,
            )
        )
        session.add(
            WorkCardProductType(
                work_card_id=card_id,
                custom_product_type_text="Dupatta",
            )
        )
        session.add_all(
            [
                MediaAsset(
                    entity_type="work_card",
                    entity_id=card_id,
                    media_kind="image",
                    document_type="work_photo",
                    visibility="public",
                    upload_status="ready",
                    original_path=f"test/{card_id}/{index}.jpg",
                    sort_order=index,
                    uploaded_by_user_id=owner_id,
                )
                for index in range(3)
            ]
        )
        session.flush()

        service = ProfileService(
            ProfileRepository(session),
            public_media_url=lambda path: f"https://media.test/{path}",
        )
        current_user = CurrentUser(
            user_id=viewer_id,
            auth_user_id=uuid4(),
            mobile="+917000000000",
            role="business",
            account_status="active",
        )
        first = service.get_public_profile(
            current_user=current_user,
            profile_id=profile_id,
            source_type="work_card",
            source_id=card_id,
            ip_address="127.0.0.1",
            device_id="android-test",
            user_agent="flutter-test",
        )
        second = service.get_public_profile(
            current_user=current_user,
            profile_id=profile_id,
            source_type="work_card",
            source_id=card_id,
            ip_address="127.0.0.1",
            device_id="android-test",
            user_agent="flutter-test",
        )

        reveal = session.scalar(
            select(ContactReveal).where(
                ContactReveal.viewer_user_id == viewer_id,
                ContactReveal.revealed_profile_id == profile_id,
            )
        )
        reveal_rows = session.scalar(
            select(func.count(ContactReveal.id)).where(
                ContactReveal.viewer_user_id == viewer_id,
                ContactReveal.revealed_profile_id == profile_id,
            )
        )
        assert first.contact.mobile is not None
        assert first.address.full_address == "Ring Road, Surat"
        assert first.work_cards[0].title == "Flat hemming"
        assert first.work_cards[0].photos[0].url is not None
        assert second.profile.id == profile_id
        assert reveal_rows == 1
        assert reveal is not None
        assert reveal.reveal_count == 2
    finally:
        session.rollback()
        session.close()
        if transaction.is_active:
            transaction.rollback()
        connection.close()
        engine.dispose()
