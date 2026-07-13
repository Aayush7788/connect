from datetime import datetime, timezone
from uuid import UUID, uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.main import create_app
from app.modules.auth.dependencies import get_active_current_user
from app.modules.work_needed_posts.dependencies import get_work_needed_post_service
from app.modules.work_needed_posts.schemas import WorkNeededPostListResponse
from app.modules.work_needed_posts.schemas import WorkNeededPostResponse


class FakeWorkNeededPostService:
    def __init__(self) -> None:
        self.post_id = uuid4()
        self.status = "draft"
        self.creation_key: str | None = None
        self.publish_key: str | None = None
        self.close_key: str | None = None
        self.deleted = False

    def response(self) -> WorkNeededPostResponse:
        now = datetime.now(timezone.utc)
        return WorkNeededPostResponse(
            id=self.post_id,
            profile_id=uuid4(),
            status=self.status,
            title="Flat hemming",
            custom_category_text="Stitching",
            custom_work_name="Flat hemming",
            custom_product_texts=["Dupatta"],
            product_types=["Dupatta"],
            description="Need clean flat hemming for dupattas.",
            photo_count=3,
            created_at=now,
            updated_at=now,
        )

    def list_owner_posts(self, current_user):
        return WorkNeededPostListResponse(items=[self.response()])

    def create_post(self, *, current_user, payload, idempotency_key):
        self.creation_key = idempotency_key
        return self.response()

    def update_post(self, *, current_user, post_id, payload):
        return self.response()

    def publish_post(self, *, current_user, post_id, idempotency_key):
        self.publish_key = idempotency_key
        self.status = "active"
        return self.response()

    def pause_post(self, *, current_user, post_id):
        self.status = "paused"
        return self.response()

    def resume_post(self, *, current_user, post_id):
        self.status = "active"
        return self.response()

    def close_post(self, *, current_user, post_id, idempotency_key):
        self.close_key = idempotency_key
        self.status = "closed_by_user"
        return self.response()

    def delete_post(self, *, current_user, post_id):
        self.deleted = True


def make_client() -> tuple[TestClient, FakeWorkNeededPostService, UUID]:
    app = create_app(Settings(app_env="test"))
    user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    service = FakeWorkNeededPostService()
    app.dependency_overrides[get_active_current_user] = lambda: user
    app.dependency_overrides[get_work_needed_post_service] = lambda: service
    return TestClient(app), service, service.post_id


def test_work_needed_post_lifecycle_routes_are_wired() -> None:
    client, service, post_id = make_client()
    payload = {
        "custom_category_text": "Stitching",
        "custom_work_name": "Flat hemming",
        "custom_product_texts": ["Dupatta"],
        "description": "Need clean flat hemming for dupattas.",
    }

    listed = client.get("/v1/me/work-needed-posts")
    created = client.post(
        "/v1/me/work-needed-posts",
        headers={"Idempotency-Key": "create-flat-hemming-need"},
        json=payload,
    )
    updated = client.patch(f"/v1/me/work-needed-posts/{post_id}", json=payload)
    published = client.post(
        f"/v1/me/work-needed-posts/{post_id}/publish",
        headers={"Idempotency-Key": "publish-flat-hemming-need"},
    )
    paused = client.post(f"/v1/me/work-needed-posts/{post_id}/pause")
    resumed = client.post(f"/v1/me/work-needed-posts/{post_id}/resume")
    closed = client.post(
        f"/v1/me/work-needed-posts/{post_id}/close",
        headers={"Idempotency-Key": "close-flat-hemming-need"},
    )
    deleted = client.delete(f"/v1/me/work-needed-posts/{post_id}")

    assert listed.status_code == 200
    assert created.status_code == 201
    assert service.creation_key == "create-flat-hemming-need"
    assert updated.status_code == 200
    assert published.json()["status"] == "active"
    assert service.publish_key == "publish-flat-hemming-need"
    assert paused.json()["status"] == "paused"
    assert resumed.json()["status"] == "active"
    assert closed.json()["status"] == "closed_by_user"
    assert service.close_key == "close-flat-hemming-need"
    assert deleted.status_code == 204
    assert service.deleted is True


def test_work_needed_post_request_rejects_unknown_fields() -> None:
    client, _, _ = make_client()

    response = client.post(
        "/v1/me/work-needed-posts",
        json={"title": "Client-controlled title"},
    )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_failed"
