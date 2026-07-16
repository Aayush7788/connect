from datetime import datetime, timezone
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy.orm import Session

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.db.models.cross_cutting import SearchLog
from app.db.models.identity import User
from app.db.models.marketplace import WorkCard, WorkCardProductType
from app.db.models.profile import JobWorkerProfile, Profile
from app.db.session import create_database_engine
from app.modules.search.repository import SearchCriteria, SearchRepository
from app.modules.search.service import SearchService


pytestmark = pytest.mark.skipif(
    Settings().database_url is None,
    reason="DATABASE_URL is required for PostgreSQL integration tests.",
)


def test_flat_hemming_work_card_is_searchable_without_private_fields() -> None:
    engine = create_database_engine()
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection, expire_on_commit=False)
    try:
        user_id = uuid4()
        profile_id = uuid4()
        card_id = uuid4()
        now = datetime.now(timezone.utc)
        session.add(
            User(
                id=user_id,
                auth_user_id=uuid4(),
                display_name="Search Test Owner",
                primary_mobile=f"+919{str(user_id.int)[-9:]}",
                account_status="active",
                role="job_worker",
                role_confirmed_at=now,
                profile_completed_at=now,
            )
        )
        session.flush()
        session.add(
            Profile(
                id=profile_id,
                owner_user_id=user_id,
                role="job_worker",
                public_name="Rollback Hemming Workshop",
                owner_name="Search Test Owner",
                full_address="Private test address that must never be returned",
                locality="Ring Road",
                normalized_locality="ring road",
                city="Surat",
                state="Gujarat",
                pincode="395002",
                visibility_status="public",
                verification_status="unverified",
                completion_score=100,
                completion_flags={"published_work_card": True},
                photo_count=3,
                is_verified=False,
                reverification_required=False,
                ranking_score=Decimal("5"),
                search_text="rollback hemming workshop ring road surat",
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
                search_text="flat hemming stitching dupatta pico ring road",
                search_vector="'flat':1 'hemming':2 'stitching':3 'dupatta':4",
                last_activity_at=now,
            )
        )
        session.add(
            WorkCardProductType(
                work_card_id=card_id,
                custom_product_type_text="Dupatta",
            )
        )
        session.flush()

        response = SearchService(SearchRepository(session)).search(
            current_user=CurrentUser(
                user_id=user_id,
                auth_user_id=uuid4(),
                mobile="+919999999999",
                role="job_worker",
                account_status="active",
            ),
            target="job_worker",
            query="Flat Hemming",
            business_mode=None,
            category_id=None,
            product_type_id=None,
            locality=None,
            min_experience_years=None,
            max_experience_years=None,
            verified_only=False,
            sort="best",
            cursor=None,
            limit=20,
        )

        match = next(item for item in response.items if item.id == card_id)
        payload = match.model_dump()
        search_log = session.get(SearchLog, response.search_log_id)
        assert match.title == "Flat hemming"
        assert match.profile_id == profile_id
        assert match.product_types == ["Dupatta"]
        assert "full_address" not in payload
        assert "alternate_contact_number" not in payload
        assert search_log is not None
        assert search_log.query == "Flat Hemming"
        assert search_log.normalized_query == "flat hemming"
        assert search_log.target_persona == "job_worker"
        assert search_log.result_count >= 1
        assert search_log.filters_json["sort"] == "best"
    finally:
        session.rollback()
        session.close()
        if transaction.is_active:
            transaction.rollback()
        connection.close()
        engine.dispose()


@pytest.mark.parametrize(
    ("target", "business_mode", "query", "sort"),
    [
        ("job_worker", None, "unlikely flat heming typo", "verified_first"),
        ("business", "work_needed_posts", None, "most_photos"),
        ("business", "profiles", None, "nearby"),
        ("skilled_worker", None, None, "recent"),
    ],
)
def test_all_search_modes_execute_on_postgresql(
    target,
    business_mode,
    query,
    sort,
) -> None:
    engine = create_database_engine()
    with Session(bind=engine, expire_on_commit=False) as session:
        page = SearchRepository(session).search(
            criteria=SearchCriteria(
                target=target,
                normalized_query=query or "",
                business_mode=business_mode,
                category_id=None,
                product_type_id=None,
                normalized_locality="ring road" if sort == "nearby" else None,
                min_experience_years=None,
                max_experience_years=None,
                verified_only=False,
                sort=sort,
            ),
            offset=0,
            limit=5,
        )

        assert page.result_count >= 0
    engine.dispose()


def test_empty_later_search_page_keeps_total_result_count() -> None:
    engine = create_database_engine()
    with Session(bind=engine, expire_on_commit=False) as session:
        repository = SearchRepository(session)
        criteria = SearchCriteria(
            target="job_worker",
            normalized_query="",
            business_mode=None,
            category_id=None,
            product_type_id=None,
            normalized_locality=None,
            min_experience_years=None,
            max_experience_years=None,
            verified_only=False,
            sort="best",
        )
        first_page = repository.search(criteria=criteria, offset=0, limit=1)
        later_page = repository.search(
            criteria=criteria,
            offset=first_page.result_count + 1,
            limit=1,
        )

        assert later_page.items == []
        assert later_page.result_count == first_page.result_count
    engine.dispose()
