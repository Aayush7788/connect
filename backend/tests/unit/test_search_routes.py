from datetime import datetime, timezone
from uuid import uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.main import create_app
from app.modules.auth.dependencies import get_active_current_user
from app.modules.search.dependencies import get_search_service
from app.modules.search.schemas import SearchResponse, SearchResultResponse


class FakeSearchService:
    def __init__(self) -> None:
        self.arguments = None

    def search(self, **arguments) -> SearchResponse:
        self.arguments = arguments
        return SearchResponse(
            items=[
                SearchResultResponse(
                    result_type="work_card",
                    id=uuid4(),
                    profile_id=uuid4(),
                    title="Flat hemming",
                    subtitle="Surat Hemming Works",
                    category="Stitching",
                    product_types=["Dupatta"],
                    description="Clean hemming for dupattas.",
                    locality="Ring Road",
                    experience_years=8,
                    is_verified=True,
                    photo_count=3,
                    last_activity_at=datetime.now(timezone.utc),
                )
            ],
            result_count=1,
            search_log_id=uuid4(),
        )


def make_client() -> tuple[TestClient, FakeSearchService]:
    app = create_app(Settings(app_env="test"))
    user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    service = FakeSearchService()
    app.dependency_overrides[get_active_current_user] = lambda: user
    app.dependency_overrides[get_search_service] = lambda: service
    return TestClient(app), service


def test_search_route_returns_privacy_safe_work_card_results() -> None:
    client, service = make_client()

    response = client.get(
        "/v1/search",
        params={
            "target": "job_worker",
            "q": "flat hemming",
            "locality": "Ring Road",
            "min_experience_years": 3,
            "verified_only": "true",
            "job_worker_mode": "profiles",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body["items"][0]["result_type"] == "work_card"
    assert body["items"][0]["title"] == "Flat hemming"
    assert "full_address" not in body["items"][0]
    assert "contact" not in body["items"][0]
    assert "mobile" not in body["items"][0]
    assert service.arguments["target"] == "job_worker"
    assert service.arguments["verified_only"] is True
    assert service.arguments["job_worker_mode"] == "profiles"


def test_search_route_rejects_invalid_target_and_limit() -> None:
    client, _ = make_client()

    invalid_target = client.get("/v1/search", params={"target": "all"})
    invalid_limit = client.get(
        "/v1/search",
        params={"target": "job_worker", "limit": 100},
    )

    assert invalid_target.status_code == 422
    assert invalid_limit.status_code == 422
    assert invalid_target.json()["error"]["code"] == "validation_failed"
