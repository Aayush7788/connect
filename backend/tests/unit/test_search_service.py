from datetime import datetime, timezone
from uuid import uuid4

import pytest

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError
from app.modules.search.repository import SearchRepositoryPage
from app.modules.search.schemas import SearchResultResponse
from app.modules.search.service import SearchService


class FakeSearchLog:
    def __init__(self) -> None:
        self.id = uuid4()


class FakeSearchRepository:
    def __init__(self, *, result_count: int = 1) -> None:
        self.result_count = result_count
        self.criteria = None
        self.offset = None
        self.limit = None
        self.log_payload = None
        self.commits = 0
        self.rollbacks = 0

    def search(self, *, criteria, offset, limit):
        self.criteria = criteria
        self.offset = offset
        self.limit = limit
        items = []
        if offset < self.result_count:
            items.append(
                SearchResultResponse(
                    result_type="work_card",
                    id=uuid4(),
                    profile_id=uuid4(),
                    title="Flat hemming",
                    subtitle="Surat Hemming Works",
                    category="Stitching",
                    product_types=["Dupatta"],
                    locality="Ring Road",
                    experience_years=8,
                    is_verified=True,
                    photo_count=3,
                    last_activity_at=datetime.now(timezone.utc),
                )
            )
        return SearchRepositoryPage(items=items, result_count=self.result_count)

    def create_log(self, **payload):
        self.log_payload = payload
        return FakeSearchLog()

    def commit(self):
        self.commits += 1

    def rollback(self):
        self.rollbacks += 1


def current_user() -> CurrentUser:
    return CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )


def search(service: SearchService, **overrides):
    payload = {
        "current_user": current_user(),
        "target": "job_worker",
        "query": "  Flat   Hemming  ",
        "business_mode": None,
        "category_id": None,
        "product_type_id": None,
        "locality": " Ring Road ",
        "min_experience_years": 3,
        "max_experience_years": 10,
        "verified_only": True,
        "sort": "best",
        "cursor": None,
        "limit": 20,
    }
    payload.update(overrides)
    return service.search(**payload)


def test_search_normalizes_filters_and_logs_the_executed_query() -> None:
    repository = FakeSearchRepository()
    response = search(SearchService(repository))

    assert response.result_count == 1
    assert repository.criteria.normalized_query == "flat hemming"
    assert repository.criteria.normalized_locality == "ring road"
    assert repository.log_payload["query"] == "Flat Hemming"
    assert repository.log_payload["normalized_query"] == "flat hemming"
    assert repository.log_payload["target_persona"] == "job_worker"
    assert repository.log_payload["result_count"] == 1
    assert repository.commits == 1
    assert repository.rollbacks == 0


def test_business_search_defaults_to_work_needed_posts() -> None:
    repository = FakeSearchRepository(result_count=0)
    search(
        SearchService(repository),
        target="business",
        query=None,
        locality=None,
        min_experience_years=None,
        max_experience_years=None,
        verified_only=False,
    )

    assert repository.criteria.business_mode == "work_needed_posts"


def test_cursor_is_bound_to_the_same_query_and_filters() -> None:
    repository = FakeSearchRepository(result_count=2)
    service = SearchService(repository)
    first_page = search(service, limit=1)

    assert first_page.next_cursor is not None
    second_page = search(service, cursor=first_page.next_cursor, limit=1)
    assert second_page.result_count == 2
    assert repository.offset == 1

    with pytest.raises(ApiError) as error:
        search(service, query="Embroidery", cursor=first_page.next_cursor, limit=1)

    assert error.value.field_errors["cursor"]


def test_business_search_rejects_experience_filters() -> None:
    repository = FakeSearchRepository()

    with pytest.raises(ApiError) as error:
        search(
            SearchService(repository),
            target="business",
            min_experience_years=2,
            max_experience_years=None,
        )

    assert error.value.field_errors["experience"]


def test_search_repository_uses_fuzzy_only_after_primary_has_no_results() -> None:
    class FallbackRepository:
        def __init__(self):
            self.calls = []

        def _execute(self, *, criteria, offset, limit, fuzzy):
            self.calls.append(fuzzy)
            count = 1 if fuzzy else 0
            return SearchRepositoryPage(items=[], result_count=count)

    from app.modules.search.repository import SearchCriteria, SearchRepository

    repository = FallbackRepository()
    criteria = SearchCriteria(
        target="job_worker",
        normalized_query="flat heming",
        business_mode=None,
        category_id=None,
        product_type_id=None,
        normalized_locality=None,
        min_experience_years=None,
        max_experience_years=None,
        verified_only=False,
        sort="best",
    )

    page = SearchRepository.search(
        repository,
        criteria=criteria,
        offset=0,
        limit=20,
    )

    assert page.result_count == 1
    assert repository.calls == [False, True]
