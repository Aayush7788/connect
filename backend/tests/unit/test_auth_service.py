from datetime import datetime, timedelta, timezone
from types import SimpleNamespace
from uuid import UUID, uuid4

import pytest

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.integrations.supabase_auth import SupabaseAccessTokenClaims
from app.integrations.supabase_auth import SupabaseAuthUser, SupabaseVerifiedSession
from app.modules.auth.schemas import BasicAccountRequest
from app.modules.auth.schemas import DeviceInfo
from app.modules.auth.schemas import OtpRequest
from app.modules.auth.schemas import OtpVerifyRequest
from app.modules.auth.schemas import RoleConfirmRequest
from app.modules.auth.service import AuthService, normalize_mobile
from app.modules.auth.session_cache import auth_context_cache


class FakeGateway:
    def __init__(self) -> None:
        self.auth_user_id = uuid4()
        self.session_id = uuid4()
        self.token_expires_at = datetime.now(timezone.utc) + timedelta(hours=1)
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
            session_id=self.session_id,
            expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
        )

    async def get_user(self, *, access_token: str) -> SupabaseAuthUser:
        return SupabaseAuthUser(
            auth_user_id=self.auth_user_id,
            phone="+919999999999",
        )

    async def verify_access_token(
        self, *, access_token: str
    ) -> SupabaseAccessTokenClaims:
        return SupabaseAccessTokenClaims(
            auth_user_id=self.auth_user_id,
            session_id=self.session_id,
            expires_at=self.token_expires_at,
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
        self.auth_sessions: dict[UUID, SimpleNamespace] = {}
        self.auth_session_lookups = 0

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

    def get_user_and_auth_session(self, *, auth_user_id: UUID, session_id: UUID):
        self.auth_session_lookups += 1
        return self.users_by_auth.get(auth_user_id), self.auth_sessions.get(session_id)

    def register_auth_session(
        self, *, user, session_id: UUID, expires_at: datetime, device: DeviceInfo | None
    ):
        session = self.auth_sessions.get(session_id)
        if session is None:
            session = SimpleNamespace(
                session_id=session_id,
                user_id=user.id,
                status="active",
                expires_at=expires_at,
                device_id=device.device_id if device else None,
            )
            self.auth_sessions[session_id] = session
        return session

    def revoke_auth_session(self, *, user_id: UUID, session_id: UUID) -> bool:
        session = self.auth_sessions.get(session_id)
        if session is None or session.user_id != user_id:
            return False
        session.status = "revoked"
        return True

    @staticmethod
    def extend_auth_session_expiry(session, expires_at: datetime) -> bool:
        if expires_at <= session.expires_at:
            return False
        session.expires_at = expires_at
        return True

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

    def create_profile_shell(self, *, user, role: str):
        self.profile = SimpleNamespace(
            id=uuid4(),
            role=role,
            public_name=user.display_name,
            visibility_status="draft",
            completion_score=0,
            completion_flags={},
            verification_status="unverified",
            is_verified=False,
        )
        return self.profile

    def unread_notification_count(self, user_id: UUID) -> int:
        return self.unread_count

    def get_me_snapshot(self, user_id: UUID):
        user = next(
            (
                candidate
                for candidate in self.users_by_auth.values()
                if candidate.id == user_id
            ),
            None,
        )
        if user is None:
            return None
        return user, self.profile, self.unread_count

    def commit(self) -> None:
        self.commits += 1


def make_service() -> tuple[AuthService, FakeRepository, FakeGateway]:
    auth_context_cache.clear()
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
    assert gateway.session_id in repository.auth_sessions
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
async def test_confirm_role_saves_role_and_creates_profile_shell() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    user.display_name = "Aayush"
    user.accepted_terms_version = "2026-07-10"
    user.accepted_privacy_version = "2026-07-10"
    current_user = CurrentUser(
        user_id=user.id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role=None,
        account_status="active",
    )

    response = await service.confirm_role(
        current_user=current_user,
        payload=RoleConfirmRequest(role="job_worker"),
    )

    assert user.role == "job_worker"
    assert user.role_confirmed_at is not None
    assert response.next_state == "home"
    assert response.profile is not None
    assert response.profile.role == "job_worker"


@pytest.mark.asyncio
async def test_confirm_role_is_idempotent_for_same_role() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    user.display_name = "Aayush"
    user.accepted_terms_version = "2026-07-10"
    user.accepted_privacy_version = "2026-07-10"
    user.role = "job_worker"
    repository.create_profile_shell(user=user, role="job_worker")
    current_user = CurrentUser(
        user_id=user.id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role="job_worker",
        account_status="active",
    )

    response = await service.confirm_role(
        current_user=current_user,
        payload=RoleConfirmRequest(role="job_worker"),
    )

    assert response.next_state == "home"
    assert response.profile is not None
    assert response.profile.role == "job_worker"


@pytest.mark.asyncio
async def test_confirm_role_rejects_different_existing_role() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    user.display_name = "Aayush"
    user.accepted_terms_version = "2026-07-10"
    user.accepted_privacy_version = "2026-07-10"
    user.role = "job_worker"
    current_user = CurrentUser(
        user_id=user.id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role="job_worker",
        account_status="active",
    )

    with pytest.raises(ApiError) as exc_info:
        await service.confirm_role(
            current_user=current_user,
            payload=RoleConfirmRequest(role="business"),
        )

    assert exc_info.value.code == ErrorCode.FORBIDDEN


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
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    repository.register_auth_session(
        user=user,
        session_id=gateway.session_id,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
        device=None,
    )
    current_user = CurrentUser(
        user_id=user.id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role=None,
        account_status="active",
        session_id=gateway.session_id,
    )

    await service.logout(current_user=current_user, access_token="access-token")

    assert gateway.logged_out_token == "access-token"
    assert repository.auth_sessions[gateway.session_id].status == "revoked"


@pytest.mark.asyncio
async def test_revoked_local_session_is_rejected_without_provider_lookup() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    session = repository.register_auth_session(
        user=user,
        session_id=gateway.session_id,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
        device=None,
    )
    session.status = "revoked"

    with pytest.raises(ApiError) as exc_info:
        await service.get_current_user_from_token("access-token")

    assert exc_info.value.code == ErrorCode.UNAUTHORIZED


@pytest.mark.asyncio
async def test_verified_auth_context_is_reused_for_a_short_period() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    repository.register_auth_session(
        user=user,
        session_id=gateway.session_id,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
        device=None,
    )

    first = await service.get_current_user_from_token("access-token")
    second = await service.get_current_user_from_token("access-token")

    assert first == second
    assert repository.auth_session_lookups == 1


@pytest.mark.asyncio
async def test_refreshed_access_token_extends_active_local_session() -> None:
    service, repository, gateway = make_service()
    user = repository.create_user_after_otp(
        auth_user_id=gateway.auth_user_id,
        mobile="+919999999999",
    )
    session = repository.register_auth_session(
        user=user,
        session_id=gateway.session_id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=1),
        device=None,
    )
    gateway.token_expires_at = datetime.now(timezone.utc) + timedelta(hours=1)

    current_user = await service.get_current_user_from_token("refreshed-token")

    assert current_user.user_id == user.id
    assert session.expires_at == gateway.token_expires_at
    assert repository.commits == 1
