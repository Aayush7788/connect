from uuid import UUID, uuid4

from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.modules.auth.dependencies import get_auth_service
from app.modules.auth.schemas import AuthSessionResponse
from app.modules.auth.schemas import MeResponse
from app.modules.auth.schemas import OtpRequestResponse
from app.modules.auth.schemas import UserResponse
from app.main import create_app


class FakeAuthService:
    def __init__(self) -> None:
        self.current_user = CurrentUser(
            user_id=uuid4(),
            auth_user_id=uuid4(),
            mobile="+919999999999",
            role=None,
            account_status="active",
        )
        self.me_response = MeResponse(
            user=UserResponse(
                id=self.current_user.user_id,
                display_name="Aayush",
                primary_mobile=self.current_user.mobile,
                account_status="active",
                role=None,
            ),
            next_state="role_selection_required",
            unread_notification_count=0,
            allowed_actions=["select_role", "logout"],
        )
        self.logged_out_token: str | None = None

    async def request_otp(self, payload) -> OtpRequestResponse:
        return OtpRequestResponse(
            otp_request_id=UUID("00000000-0000-0000-0000-000000000001"),
            message="OTP sent",
        )

    async def verify_otp(self, payload) -> AuthSessionResponse:
        return AuthSessionResponse(
            access_token="access-token",
            refresh_token="refresh-token",
            next_state="complete_basic_account",
            user=self.me_response.user,
        )

    async def complete_basic_account(self, *, current_user, payload) -> MeResponse:
        return self.me_response

    async def confirm_role(self, *, current_user, payload) -> MeResponse:
        self.me_response.user.role = payload.role
        self.me_response.next_state = "home"
        self.me_response.allowed_actions = ["search", "view_profile", "logout"]
        return self.me_response

    async def get_current_user_from_token(self, access_token: str) -> CurrentUser:
        return self.current_user

    async def get_me(self, current_user: CurrentUser) -> MeResponse:
        return self.me_response

    async def logout(self, access_token: str) -> None:
        self.logged_out_token = access_token


def client_with_fake_auth(fake_auth_service: FakeAuthService) -> TestClient:
    app = create_app(Settings(app_env="test"))
    app.dependency_overrides[get_auth_service] = lambda: fake_auth_service
    return TestClient(app)


def test_request_otp_endpoint_returns_generic_response() -> None:
    client = client_with_fake_auth(FakeAuthService())

    response = client.post("/v1/auth/otp/request", json={"mobile": "+919999999999"})

    assert response.status_code == 200
    assert response.json() == {
        "otp_request_id": "00000000-0000-0000-0000-000000000001",
        "message": "OTP sent",
    }


def test_verify_otp_endpoint_returns_session_and_next_state() -> None:
    client = client_with_fake_auth(FakeAuthService())

    response = client.post(
        "/v1/auth/otp/verify",
        json={
            "mobile": "+919999999999",
            "otp": "123456",
            "otp_request_id": "00000000-0000-0000-0000-000000000001",
            "device": {"device_id": "install-1", "platform": "android"},
        },
    )

    assert response.status_code == 200
    assert response.json()["access_token"] == "access-token"
    assert response.json()["refresh_token"] == "refresh-token"
    assert response.json()["next_state"] == "complete_basic_account"


def test_get_me_requires_bearer_token() -> None:
    client = client_with_fake_auth(FakeAuthService())

    response = client.get("/v1/me")

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "unauthorized"


def test_get_me_returns_onboarding_state_for_verified_session() -> None:
    client = client_with_fake_auth(FakeAuthService())

    response = client.get("/v1/me", headers={"Authorization": "Bearer access-token"})

    assert response.status_code == 200
    assert response.json()["next_state"] == "role_selection_required"
    assert response.json()["allowed_actions"] == ["select_role", "logout"]


def test_confirm_role_endpoint_returns_home_state() -> None:
    client = client_with_fake_auth(FakeAuthService())

    response = client.post(
        "/v1/auth/role/confirm",
        headers={"Authorization": "Bearer access-token"},
        json={"role": "job_worker"},
    )

    assert response.status_code == 200
    assert response.json()["next_state"] == "home"
    assert response.json()["user"]["role"] == "job_worker"


def test_logout_uses_current_bearer_token() -> None:
    fake_auth_service = FakeAuthService()
    client = client_with_fake_auth(fake_auth_service)

    response = client.post(
        "/v1/auth/logout",
        headers={"Authorization": "Bearer access-token"},
    )

    assert response.status_code == 204
    assert fake_auth_service.logged_out_token == "access-token"
