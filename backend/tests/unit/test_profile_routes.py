from uuid import uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.modules.auth.dependencies import get_current_user_from_token
from app.modules.auth.schemas import ProfileSummaryResponse
from app.modules.profiles.dependencies import get_profile_service
from app.modules.profiles.schemas import OwnerProfileResponse
from app.modules.profiles.schemas import PublicAddressResponse, PublicContactResponse
from app.modules.profiles.schemas import PublicProfileDetailResponse
from app.main import create_app


class FakeProfileService:
    def __init__(self) -> None:
        self.visibility = "draft"
        self.updated_owner_name: str | None = None
        self.public_profile_arguments: dict | None = None

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

    def get_public_profile(self, **arguments):
        self.public_profile_arguments = arguments
        return PublicProfileDetailResponse(
            profile=self.response().profile,
            role_specific={"business_name": "Connect Textiles"},
            contact=PublicContactResponse(
                mobile="+919999999999",
                whatsapp_number="+919999999999",
            ),
            address=PublicAddressResponse(
                locality="Ring Road",
                city="Surat",
                full_address="Ring Road, Surat",
            ),
        )


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


def test_public_profile_detail_returns_contact_only_after_opening_profile() -> None:
    client, service = make_client()
    profile_id = uuid4()
    source_id = uuid4()

    response = client.get(
        f"/v1/profiles/{profile_id}",
        params={"source_type": "work_card", "source_id": str(source_id)},
        headers={"x-device-id": "android-test"},
    )

    assert response.status_code == 200
    assert response.json()["contact"]["mobile"] == "+919999999999"
    assert response.json()["role_specific"]["business_name"] == "Connect Textiles"
    assert service.public_profile_arguments is not None
    assert service.public_profile_arguments["profile_id"] == profile_id
    assert service.public_profile_arguments["source_type"] == "work_card"
    assert service.public_profile_arguments["source_id"] == source_id
    assert service.public_profile_arguments["device_id"] == "android-test"
