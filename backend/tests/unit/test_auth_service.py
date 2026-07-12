from types import SimpleNamespace
from uuid import UUID, uuid4

import pytest

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.integrations.supabase_auth import SupabaseAuthUser, SupabaseVerifiedSession
from app.modules.auth.schemas import BasicAccountRequest
from app.modules.auth.schemas import DeviceInfo
from app.modules.auth.schemas import OtpRequest
from app.modules.auth.schemas import OtpVerifyRequest
from app.modules.auth.service import AuthService, normalize_mobile


class FakeGateway:
    def __init__(self) -> None:
        self.auth_user_id = uuid4()
        self.requested_phone: str | None = None
        self.logged_out_token: str | None = None

    async def request_otp(self, *, phone: str) -> None:
        self.requested_phone = phone

    async def verify_otp(self, *, phone: str, otp: str) -> SupabaseVerifiedSession:
        return SupabaseVerifiedSession(
            auth_user_id=self.auth_user_id,
            phone=phone,
            access_token="access-token",
            refresh_token="refresh-token",
        )

    async def get_user(self, *, access_token: str) -> SupabaseAuthUser:
        return SupabaseAuthUser(
            auth_user_id=self.auth_user_id,
            phone="+919999999999",
        )

    async def logout(self, *, access_token: str) -> None:
        self.logged_out_token = access_token


class FakeRepository:
    def __init__(self) -> None:
        self.users_by_auth: dict[UUID, SimpleNamespace] = {}
        self.users_by_mobile: dict[str, SimpleNamespace] = {}
        self.devices: list[tuple[UUID, DeviceInfo | None]] = []
        self.commits = 0
        self.profile = None
        self.unread_count = 0

    def get_user_by_auth_user_id(self, auth_user_id: UUID):
        return self.users_by_auth.get(auth_user_id)

    def get_user_by_mobile(self, mobile: str):
        return self.users_by_mobile.get(mobile)

    def create_user_after_otp(self, *, auth_user_id: UUID, mobile: str):
        user = SimpleNamespace(
            id=uuid4(),
            auth_user_id=auth_user_id,
            display_name="",
            primary_mobile=mobile,
            account_status="active",
            role=None,
            accepted_terms_version=None,
            accepted_privacy_version=None,
        )
        self.users_by_auth[auth_user_id] = user
        self.users_by_mobile[mobile] = user
        return user

    def attach_auth_user_id(self, *, user, auth_user_id: UUID) -> None:
        user.auth_user_id = auth_user_id
        self.users_by_auth[auth_user_id] = user

    def mark_login(self, user) -> None:
        user.last_login_marked = True

    def update_basic_account(
        self,
        *,
        user,
        display_name: str,
        accepted_terms_version: str,
        accepted_privacy_version: str,
    ) -> None:
        user.display_name = display_name
        user.accepted_terms_version = accepted_terms_version
        user.accepted_privacy_version = accepted_privacy_version

    def upsert_device(self, *, user, device: DeviceInfo | None) -> None:
        self.devices.append((user.id, device))

    def get_profile_for_user(self, user_id: UUID):
        return self.profile

    def unread_notification_count(self, user_id: UUID) -> int:
        return self.unread_count

    def commit(self) -> None:
        self.commits += 1


def make_service() -> tuple[AuthService, FakeRepository, FakeGateway]:
    repository = FakeRepository()
    gateway = FakeGateway()
    service = AuthService(repository=repository, auth_gateway=gateway)
    return service, repository, gateway


def test_normalize_mobile_accepts_indian_local_and_e164_numbers() -> None:
    assert normalize_mobile("99999 99999") == "+919999999999"
    assert normalize_mobile("+91-99999-99999") == "+919999999999"


def test_normalize_mobile_rejects_invalid_mobile() -> None:
    with pytest.raises(ApiError) as exc_info:
        normalize_mobile("123")

    assert exc_info.value.status_code == 422
    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED


@pytest.mark.asyncio
async def test_request_otp_returns_generic_response_without_account_lookup() -> None:
    service, repository, gateway = make_service()

    response = await service.request_otp(OtpRequest(mobile="9999999999"))

    assert gateway.requested_phone == "+919999999999"
    assert response.message == "OTP sent"
    assert response.otp_request_id
    assert not repository.users_by_auth


@pytest.mark.asyncio
async def test_verify_otp_creates_app_user_only_after_success_and_captures_device() -> (
    None
):
    service, repository, gateway = make_service()
    request = OtpVerifyRequest(
        mobile="9999999999",
        otp="123456",
        otp_request_id=uuid4(),
        device=DeviceInfo(device_id="install-1", app_version="1.0.0"),
    )

    response = await service.verify_otp(request)

    assert response.access_token == "access-token"
    assert response.refresh_token == "refresh-token"
    assert response.next_state == "complete_basic_account"
    assert response.user.primary_mobile == "+919999999999"
    assert gateway.auth_user_id in repository.users_by_auth
    assert repository.devices[0][1] == request.device
    assert repository.commits == 1


@pytest.mark.asyncio
async def test_complete_basic_account_moves_user_to_role_selection() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    current_user = CurrentUser(
        user_id=user.id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role=None,
        account_status="active",
    )

    response = await service.complete_basic_account(
        current_user=current_user,
        payload=BasicAccountRequest(
            display_name="Aayush",
            accepted_terms_version="2026-07-10",
            accepted_privacy_version="2026-07-10",
        ),
    )

    assert response.next_state == "role_selection_required"
    assert response.user.display_name == "Aayush"
    assert response.allowed_actions == ["select_role", "logout"]


@pytest.mark.asyncio
async def test_suspended_user_gets_blocked_state_and_cannot_complete_account() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    user.account_status = "suspended"
    current_user = CurrentUser(
        user_id=user.id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role=None,
        account_status="suspended",
    )

    me_response = await service.get_me(current_user)
    assert me_response.next_state == "account_blocked"
    assert me_response.allowed_actions == ["logout", "contact_support"]

    with pytest.raises(ApiError) as exc_info:
        await service.complete_basic_account(
            current_user=current_user,
            payload=BasicAccountRequest(
                display_name="Blocked",
                accepted_terms_version="2026-07-10",
                accepted_privacy_version="2026-07-10",
            ),
        )

    assert exc_info.value.code == ErrorCode.ACCOUNT_SUSPENDED


@pytest.mark.asyncio
async def test_logout_delegates_current_access_token_to_provider() -> None:
    service, _, gateway = make_service()

    await service.logout("access-token")

    assert gateway.logged_out_token == "access-token"
