from datetime import datetime, timezone
from uuid import UUID, uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.main import create_app
from app.modules.auth.dependencies import get_active_current_user
from app.modules.work_cards.dependencies import get_work_card_service
from app.modules.work_cards.schemas import WorkCardListResponse, WorkCardResponse


class FakeWorkCardService:
    def __init__(self) -> None:
        self.work_card_id = uuid4()
        self.status = "draft"
        self.idempotency_key: str | None = None
        self.deleted = False

    def response(self) -> WorkCardResponse:
        now = datetime.now(timezone.utc)
        return WorkCardResponse(
            id=self.work_card_id,
            profile_id=uuid4(),
            status=self.status,
            title="Flat hemming",
            custom_category_text="Stitching",
            custom_work_name="Flat hemming",
            custom_product_texts=["Dupatta"],
            product_types=["Dupatta"],
            description="Clean flat hemming for dupattas.",
            photo_count=3,
            created_at=now,
            updated_at=now,
        )

    def list_owner_work_cards(self, current_user):
        return WorkCardListResponse(items=[self.response()])

    def create_work_card(self, *, current_user, payload, idempotency_key):
        self.idempotency_key = idempotency_key
        return self.response()

    def update_work_card(self, *, current_user, work_card_id, payload):
        return self.response()

    def publish_work_card(self, *, current_user, work_card_id):
        self.status = "published"
        return self.response()

    def hide_work_card(self, *, current_user, work_card_id):
        self.status = "hidden_by_user"
        return self.response()

    def show_work_card(self, *, current_user, work_card_id):
        self.status = "published"
        return self.response()

    def delete_work_card(self, *, current_user, work_card_id):
        self.deleted = True


def make_client() -> tuple[TestClient, FakeWorkCardService, UUID]:
    app = create_app(Settings(app_env="test"))
    user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="job_worker",
        account_status="active",
    )
    service = FakeWorkCardService()
    app.dependency_overrides[get_active_current_user] = lambda: user
    app.dependency_overrides[get_work_card_service] = lambda: service
    return TestClient(app), service, service.work_card_id


def test_work_card_lifecycle_routes_are_wired() -> None:
    client, service, work_card_id = make_client()
    payload = {
        "custom_category_text": "Stitching",
        "custom_work_name": "Flat hemming",
        "custom_product_texts": ["Dupatta"],
        "description": "Clean flat hemming for dupattas.",
    }

    listed = client.get("/v1/me/work-cards")
    created = client.post(
        "/v1/me/work-cards",
        headers={"Idempotency-Key": "create-flat-hemming"},
        json=payload,
    )
    updated = client.patch(f"/v1/me/work-cards/{work_card_id}", json=payload)
    published = client.post(f"/v1/me/work-cards/{work_card_id}/publish")
    hidden = client.post(f"/v1/me/work-cards/{work_card_id}/hide")
    shown = client.post(f"/v1/me/work-cards/{work_card_id}/show")
    deleted = client.delete(f"/v1/me/work-cards/{work_card_id}")

    assert listed.status_code == 200
    assert created.status_code == 201
    assert service.idempotency_key == "create-flat-hemming"
    assert updated.status_code == 200
    assert published.json()["status"] == "published"
    assert hidden.json()["status"] == "hidden_by_user"
    assert shown.json()["status"] == "published"
    assert deleted.status_code == 204
    assert service.deleted is True


def test_work_card_request_rejects_unknown_fields() -> None:
    client, _, _ = make_client()

    response = client.post(
        "/v1/me/work-cards",
        json={"title": "Client-controlled title"},
    )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_failed"
