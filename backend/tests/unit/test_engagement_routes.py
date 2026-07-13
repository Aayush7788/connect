from datetime import datetime, timezone
from uuid import uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.main import create_app
from app.modules.auth.dependencies import get_active_current_user
from app.modules.engagement.dependencies import get_engagement_service
from app.modules.engagement.schemas import NotificationResponse, NotificationsResponse
from app.modules.engagement.schemas import ReportResponse, SavedItemResponse
from app.modules.engagement.schemas import SavedItemsResponse, ShareLinkResponse
from app.modules.engagement.schemas import UserSettingsResponse
from app.modules.search.schemas import SearchResultResponse


class FakeEngagementService:
    def __init__(self) -> None:
        self.user_id = uuid4()
        self.profile_id = uuid4()
        self.saved_id = uuid4()
        self.notification_id = uuid4()
        self.calls: list[tuple[str, object]] = []

    def _saved(self) -> SavedItemResponse:
        return SavedItemResponse(
            id=self.saved_id,
            target_type="profile",
            target_id=self.profile_id,
            profile_role="job_worker",
            card=SearchResultResponse(
                result_type="profile",
                id=self.profile_id,
                profile_id=self.profile_id,
                title="Surat Hemming Works",
                is_verified=True,
                photo_count=3,
            ),
        )

    def save_item(self, **kwargs) -> SavedItemResponse:
        self.calls.append(("save", kwargs["payload"]))
        return self._saved()

    def list_saved(self, **kwargs) -> SavedItemsResponse:
        self.calls.append(("list_saved", kwargs))
        return SavedItemsResponse(items=[self._saved()])

    def remove_saved(self, **kwargs) -> None:
        self.calls.append(("remove", kwargs["saved_item_id"]))

    def report(self, **kwargs) -> ReportResponse:
        self.calls.append(("report", kwargs["payload"]))
        return ReportResponse(id=uuid4(), status="submitted")

    def notifications(self, **kwargs) -> NotificationsResponse:
        self.calls.append(("notifications", kwargs))
        return NotificationsResponse(
            items=[
                NotificationResponse(
                    id=self.notification_id,
                    title="Profile approved",
                    message="Your profile is now verified.",
                    created_at=datetime.now(timezone.utc),
                )
            ]
        )

    def mark_notification_read(self, **kwargs) -> NotificationResponse:
        self.calls.append(("mark_read", kwargs["notification_id"]))
        return NotificationResponse(
            id=self.notification_id,
            title="Profile approved",
            message="Your profile is now verified.",
            created_at=datetime.now(timezone.utc),
            read_at=datetime.now(timezone.utc),
        )

    def register_device(self, **kwargs) -> None:
        self.calls.append(("device", kwargs["payload"]))

    def update_settings(self, **kwargs) -> UserSettingsResponse:
        self.calls.append(("settings", kwargs["payload"]))
        return UserSettingsResponse(
            push_notifications_enabled=False,
            hidden_from_search=True,
        )

    def settings(self, **kwargs) -> UserSettingsResponse:
        self.calls.append(("get_settings", kwargs))
        return UserSettingsResponse(
            push_notifications_enabled=False,
            hidden_from_search=True,
        )

    def log_contact_action(self, **kwargs) -> None:
        self.calls.append(("contact", kwargs["payload"]))

    def share_link(self, **kwargs) -> ShareLinkResponse:
        self.calls.append(("share", kwargs["payload"]))
        return ShareLinkResponse(
            url=f"https://connect.example/profiles/{self.profile_id}",
            share_text="View Surat Hemming Works on Connect",
        )


def make_client() -> tuple[TestClient, FakeEngagementService]:
    app = create_app(Settings(app_env="test"))
    service = FakeEngagementService()
    user = CurrentUser(
        user_id=service.user_id,
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    app.dependency_overrides[get_active_current_user] = lambda: user
    app.dependency_overrides[get_engagement_service] = lambda: service
    return TestClient(app), service


def test_saved_item_routes_are_idempotent_and_privacy_safe() -> None:
    client, service = make_client()

    created = client.post(
        "/v1/me/saved-items",
        json={"target_type": "profile", "target_id": str(service.profile_id)},
    )
    listed = client.get("/v1/me/saved-items")
    removed = client.delete(f"/v1/me/saved-items/{service.saved_id}")

    assert created.status_code == 200
    assert created.json()["profile_role"] == "job_worker"
    assert "mobile" not in created.json()["card"]
    assert "full_address" not in created.json()["card"]
    assert listed.status_code == 200
    assert listed.json()["items"][0]["card"]["title"] == "Surat Hemming Works"
    assert removed.status_code == 204


def test_report_contact_and_share_routes_accept_contract_values() -> None:
    client, service = make_client()

    report = client.post(
        "/v1/reports",
        json={
            "reported_entity_type": "profile",
            "reported_entity_id": str(service.profile_id),
            "reason": "wrong_contact",
        },
    )
    contact = client.post(
        "/v1/contact-actions",
        json={"profile_id": str(service.profile_id), "action_type": "address"},
    )
    share = client.post(
        "/v1/share-links",
        json={
            "target_type": "profile",
            "target_id": str(service.profile_id),
            "channel": "native_other",
        },
    )

    assert report.status_code == 201
    assert report.json()["status"] == "submitted"
    assert contact.status_code == 202
    assert share.status_code == 200
    assert share.json()["url"].startswith("https://")


def test_notification_device_and_settings_routes_are_owner_scoped() -> None:
    client, service = make_client()

    listed = client.get("/v1/me/notifications")
    marked = client.post(f"/v1/me/notifications/{service.notification_id}/read")
    device = client.post(
        "/v1/me/device-tokens",
        json={"fcm_token": "test-token", "platform": "android"},
    )
    settings = client.patch(
        "/v1/me/settings",
        json={"push_notifications_enabled": False, "hidden_from_search": True},
    )
    loaded_settings = client.get("/v1/me/settings")

    assert listed.status_code == 200
    assert listed.json()["items"][0]["title"] == "Profile approved"
    assert marked.status_code == 200
    assert marked.json()["read_at"] is not None
    assert device.status_code == 204
    assert settings.status_code == 200
    assert settings.json() == {
        "push_notifications_enabled": False,
        "hidden_from_search": True,
    }
    assert loaded_settings.status_code == 200
    assert loaded_settings.json()["push_notifications_enabled"] is False


def test_settings_reject_empty_update() -> None:
    client, _ = make_client()

    response = client.patch("/v1/me/settings", json={})

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_failed"
