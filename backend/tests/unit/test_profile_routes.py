from uuid import uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.modules.auth.dependencies import get_current_user_from_token
from app.modules.auth.schemas import ProfileSummaryResponse
from app.modules.profiles.dependencies import get_profile_service
from app.modules.profiles.schemas import OwnerProfileResponse
from app.main import create_app


class FakeProfileService:
    def __init__(self) -> None:
        self.visibility = "draft"
        self.updated_owner_name: str | None = None

    def response(self) -> OwnerProfileResponse:
        return OwnerProfileResponse(
            profile=ProfileSummaryResponse(
                id=uuid4(),
                role="business",
                display_name="Connect Textiles",
                visibility_status=self.visibility,
                completion_score=75,
                completion_flags={"shop_photos": False},
                verification_status="unverified",
                is_verified=False,
                reverification_required=False,
            ),
            editable_fields=["business_name"],
            locked_fields=["mobile", "role"],
        )

    def get_owner_profile(self, current_user):
        return self.response()

    def update_owner_profile(self, *, current_user, payload):
        self.updated_owner_name = payload.owner_name
        return self.response()

    def complete_owner_profile(self, current_user):
        self.visibility = "public"
        return self.response()

    def hide_owner_profile(self, current_user):
        self.visibility = "hidden_by_user"
        return self.response()

    def show_owner_profile(self, current_user):
        self.visibility = "public"
        return self.response()


def make_client() -> tuple[TestClient, FakeProfileService]:
    app = create_app(Settings(app_env="test"))
    current_user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    service = FakeProfileService()
    app.dependency_overrides[get_current_user_from_token] = lambda: current_user
    app.dependency_overrides[get_profile_service] = lambda: service
    return TestClient(app), service


def test_owner_profile_routes_are_wired() -> None:
    client, service = make_client()

    get_response = client.get("/v1/me/profile")
    patch_response = client.patch(
        "/v1/me/profile",
        json={"owner_name": "Aayush"},
    )
    complete_response = client.post("/v1/me/profile/complete")
    hide_response = client.post("/v1/me/profile/hide")
    show_response = client.post("/v1/me/profile/show")

    assert get_response.status_code == 200
    assert patch_response.status_code == 200
    assert service.updated_owner_name == "Aayush"
    assert complete_response.json()["profile"]["visibility_status"] == "public"
    assert hide_response.json()["profile"]["visibility_status"] == "hidden_by_user"
    assert show_response.json()["profile"]["visibility_status"] == "public"


def test_profile_update_rejects_unknown_fields() -> None:
    client, _ = make_client()

    response = client.patch("/v1/me/profile", json={"role": "job_worker"})

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_failed"
