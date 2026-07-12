from datetime import datetime, timezone
from uuid import uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.main import create_app
from app.modules.auth.dependencies import get_active_current_user
from app.modules.media.dependencies import get_media_service
from app.modules.media.schemas import MediaAssetResponse, UploadDetails
from app.modules.media.schemas import UploadIntentResponse


class FakeMediaService:
    def __init__(self) -> None:
        self.media_id = uuid4()
        self.cancelled = False
        self.deleted = False

    def media(self, status="pending_upload") -> MediaAssetResponse:
        return MediaAssetResponse(
            id=self.media_id,
            media_kind="image",
            visibility="public",
            upload_status=status,
            sort_order=0,
            document_type="shop_photo",
        )

    def intent(self) -> UploadIntentResponse:
        return UploadIntentResponse(
            media_asset=self.media(),
            upload=UploadDetails(
                url="https://storage.test/signed",
                headers={"content-type": "image/png"},
                expires_at=datetime.now(timezone.utc),
            ),
        )

    def create_upload_intent(self, *, current_user, payload):
        return self.intent()

    def complete_upload(self, *, current_user, media_asset_id):
        return self.media("ready")

    def retry_upload(self, *, current_user, media_asset_id):
        return self.intent()

    def cancel_upload(self, *, current_user, media_asset_id):
        self.cancelled = True

    def delete_media(self, *, current_user, media_asset_id):
        self.deleted = True


def make_client() -> tuple[TestClient, FakeMediaService]:
    app = create_app(Settings(app_env="test"))
    user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    service = FakeMediaService()
    app.dependency_overrides[get_active_current_user] = lambda: user
    app.dependency_overrides[get_media_service] = lambda: service
    return TestClient(app), service


def test_media_lifecycle_routes_are_wired() -> None:
    client, service = make_client()
    payload = {
        "entity_type": "profile",
        "entity_id": str(uuid4()),
        "media_kind": "image",
        "visibility": "public",
        "document_type": "shop_photo",
        "filename": "shop.png",
        "mime_type": "image/png",
        "byte_size": 1024,
    }

    created = client.post("/v1/media/upload-intent", json=payload)
    completed = client.post(f"/v1/media/{service.media_id}/complete")
    retried = client.post(f"/v1/media/{service.media_id}/retry")
    cancelled = client.post(f"/v1/media/{service.media_id}/cancel")
    deleted = client.delete(f"/v1/media/{service.media_id}")

    assert created.status_code == 201
    assert created.json()["upload"]["http_method"] == "PUT"
    assert completed.json()["upload_status"] == "ready"
    assert retried.status_code == 200
    assert cancelled.status_code == 204
    assert deleted.status_code == 204
    assert service.cancelled is True
    assert service.deleted is True


def test_upload_intent_rejects_unknown_fields() -> None:
    client, _ = make_client()

    response = client.post(
        "/v1/media/upload-intent",
        json={
            "entity_type": "profile",
            "entity_id": str(uuid4()),
            "media_kind": "image",
            "visibility": "public",
            "filename": "shop.png",
            "mime_type": "image/png",
            "byte_size": 1024,
            "storage_path": "user-controlled/path.png",
        },
    )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_failed"
