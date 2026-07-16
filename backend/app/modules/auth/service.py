import re
import logging
from datetime import datetime, timezone
from uuid import uuid4

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.integrations.supabase_auth import SupabaseAuthGateway
from app.modules.auth.repository import AuthRepository
from app.modules.auth.schemas import AuthSessionResponse
from app.modules.auth.schemas import BasicAccountRequest
from app.modules.auth.schemas import MeResponse
from app.modules.auth.schemas import OtpRequest
from app.modules.auth.schemas import OtpRequestResponse
from app.modules.auth.schemas import OtpVerifyRequest
from app.modules.auth.schemas import ProfileSummaryResponse
from app.modules.auth.schemas import RoleConfirmRequest
from app.modules.auth.schemas import UserResponse
from app.modules.auth.session_cache import auth_context_cache


PHONE_DIGITS_RE = re.compile(r"\D+")
logger = logging.getLogger(__name__)


def normalize_mobile(mobile: str) -> str:
    digits = PHONE_DIGITS_RE.sub("", mobile)
    if len(digits) == 10:
        digits = "91" + digits
    if len(digits) == 12 and digits.startswith("91"):
        return f"+{digits}"
    if mobile.strip().startswith("+") and 8 <= len(digits) <= 15:
        return f"+{digits}"
    raise ApiError(
        status_code=422,
        code=ErrorCode.VALIDATION_FAILED,
        message="Please check the highlighted fields.",
        field_errors={"mobile": "Please enter a valid mobile number."},
    )


class AuthService:
    def __init__(
        self,
        *,
        repository: AuthRepository,
        auth_gateway: SupabaseAuthGateway,
        auth_context_cache_seconds: int = 15,
    ) -> None:
        self.repository = repository
        self.auth_gateway = auth_gateway
        self.auth_context_cache_seconds = auth_context_cache_seconds

    async def request_otp(self, payload: OtpRequest) -> OtpRequestResponse:
        mobile = normalize_mobile(payload.mobile)
        await self.auth_gateway.request_otp(phone=mobile)
        return OtpRequestResponse(
            otp_request_id=uuid4(),
            message="OTP sent",
        )

    async def verify_otp(self, payload: OtpVerifyRequest) -> AuthSessionResponse:
        mobile = normalize_mobile(payload.mobile)
        verified_session = await self.auth_gateway.verify_otp(
            phone=mobile,
            otp=payload.otp,
        )
        verified_mobile = normalize_mobile(verified_session.phone or mobile)
        user = self.repository.get_user_by_auth_user_id(
            verified_session.auth_user_id
        ) or self.repository.get_user_by_mobile(verified_mobile)

        if user is None:
            user = self.repository.create_user_after_otp(
                auth_user_id=verified_session.auth_user_id,
                mobile=verified_mobile,
            )
        elif user.auth_user_id is None:
            self.repository.attach_auth_user_id(
                user=user,
                auth_user_id=verified_session.auth_user_id,
            )

        self.repository.mark_login(user)
        self.repository.upsert_device(user=user, device=payload.device)
        auth_session = self.repository.register_auth_session(
            user=user,
            session_id=verified_session.session_id,
            expires_at=verified_session.expires_at,
            device=payload.device,
        )
        if auth_session.user_id != user.id or auth_session.status == "revoked":
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )
        self.repository.commit()

        return AuthSessionResponse(
            access_token=verified_session.access_token,
            refresh_token=verified_session.refresh_token,
            next_state=self.next_state_for_user(user),
            user=self.user_response(user),
        )

    async def complete_basic_account(
        self,
        *,
        current_user: CurrentUser,
        payload: BasicAccountRequest,
    ) -> MeResponse:
        user = self.repository.get_user_by_auth_user_id(current_user.auth_user_id)
        if user is None:
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )
        self.ensure_user_can_use_account_endpoints(user.account_status)
        self.repository.update_basic_account(
            user=user,
            display_name=payload.display_name.strip(),
            accepted_terms_version=payload.accepted_terms_version,
            accepted_privacy_version=payload.accepted_privacy_version,
        )
        self.repository.commit()
        return self.me_response_for_user(user)

    async def confirm_role(
        self,
        *,
        current_user: CurrentUser,
        payload: RoleConfirmRequest,
    ) -> MeResponse:
        user = self.repository.get_user_by_auth_user_id(current_user.auth_user_id)
        if user is None:
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )
        self.ensure_user_can_use_account_endpoints(user.account_status)

        if user.role is not None and user.role != payload.role:
            raise ApiError(
                status_code=403,
                code=ErrorCode.FORBIDDEN,
                message="Role is already selected.",
            )

        profile = self.repository.get_profile_for_user(user.id)
        if user.role is None:
            user.role = payload.role
            user.role_confirmed_at = datetime.now(timezone.utc)

        if profile is None:
            self.repository.create_profile_shell(user=user, role=payload.role)

        self.repository.commit()
        if current_user.session_id is not None:
            auth_context_cache.invalidate_session(current_user.session_id)
        return self.me_response_for_user(user)

    async def get_current_user_from_token(self, access_token: str) -> CurrentUser:
        claims = await self.auth_gateway.verify_access_token(access_token=access_token)
        cached_user = auth_context_cache.get(
            session_id=claims.session_id,
            auth_user_id=claims.auth_user_id,
        )
        if cached_user is not None:
            return cached_user
        user, auth_session = self.repository.get_user_and_auth_session(
            auth_user_id=claims.auth_user_id,
            session_id=claims.session_id,
        )
        if user is None:
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
        )
        if auth_session is None:
            auth_session = self.repository.register_auth_session(
                user=user,
                session_id=claims.session_id,
                expires_at=claims.expires_at,
                device=None,
            )
            if auth_session.user_id != user.id or auth_session.status != "active":
                raise ApiError(
                    status_code=401,
                    code=ErrorCode.UNAUTHORIZED,
                    message="Please login again.",
                )
            self.repository.commit()
        elif auth_session.status != "active":
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )
        else:
            expiry_extended = self.repository.extend_auth_session_expiry(
                auth_session,
                claims.expires_at,
            )
            if expiry_extended:
                self.repository.commit()
            elif auth_session.expires_at <= datetime.now(timezone.utc):
                raise ApiError(
                    status_code=401,
                    code=ErrorCode.UNAUTHORIZED,
                    message="Please login again.",
                )

        current_user = CurrentUser(
            user_id=user.id,
            auth_user_id=user.auth_user_id,
            mobile=user.primary_mobile,
            role=user.role,
            account_status=user.account_status,
            session_id=claims.session_id,
        )
        auth_context_cache.put(
            current_user=current_user,
            token_expires_at=claims.expires_at,
            ttl_seconds=self.auth_context_cache_seconds,
        )
        return current_user

    async def get_me(self, current_user: CurrentUser) -> MeResponse:
        snapshot = self.repository.get_me_snapshot(current_user.user_id)
        if snapshot is None:
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )
        user, profile, unread_count = snapshot
        return self._build_me_response(
            user=user,
            profile=profile,
            unread_count=unread_count,
        )

    async def logout(self, *, current_user: CurrentUser, access_token: str) -> None:
        if current_user.session_id is not None:
            auth_context_cache.invalidate_session(current_user.session_id)
            self.repository.revoke_auth_session(
                user_id=current_user.user_id,
                session_id=current_user.session_id,
            )
            self.repository.commit()
        try:
            await self.auth_gateway.logout(access_token=access_token)
        except Exception:
            logger.warning("Supabase session logout failed after local revocation")

    def me_response_for_user(self, user) -> MeResponse:
        profile = self.repository.get_profile_for_user(user.id)
        return self._build_me_response(
            user=user,
            profile=profile,
            unread_count=self.repository.unread_notification_count(user.id),
        )

    def _build_me_response(self, *, user, profile, unread_count: int) -> MeResponse:
        next_state = self.next_state_for_user(user)
        return MeResponse(
            user=self.user_response(user),
            next_state=next_state,
            profile=self.profile_response(profile),
            unread_notification_count=unread_count,
            allowed_actions=self.allowed_actions_for_state(next_state),
        )

    @staticmethod
    def user_response(user) -> UserResponse:
        return UserResponse(
            id=user.id,
            display_name=user.display_name,
            primary_mobile=user.primary_mobile,
            account_status=user.account_status,
            role=user.role,
        )

    @staticmethod
    def profile_response(profile) -> ProfileSummaryResponse | None:
        if profile is None:
            return None
        return ProfileSummaryResponse(
            id=profile.id,
            role=profile.role,
            display_name=profile.public_name,
            visibility_status=profile.visibility_status,
            completion_score=profile.completion_score,
            completion_flags=profile.completion_flags,
            verification_status=profile.verification_status,
            is_verified=profile.is_verified,
            reverification_required=getattr(profile, "reverification_required", False),
        )

    @staticmethod
    def next_state_for_user(user) -> str:
        if user.account_status == "suspended":
            return "account_blocked"
        if user.account_status == "terminated":
            return "account_blocked"
        if (
            not user.display_name
            or not user.accepted_terms_version
            or not user.accepted_privacy_version
        ):
            return "complete_basic_account"
        if user.role is None:
            return "role_selection_required"
        return "home"

    @staticmethod
    def allowed_actions_for_state(next_state: str) -> list[str]:
        if next_state == "account_blocked":
            return ["logout", "contact_support"]
        if next_state == "complete_basic_account":
            return ["complete_basic_account", "logout"]
        if next_state == "role_selection_required":
            return ["select_role", "logout"]
        return ["search", "view_profile", "logout"]

    @staticmethod
    def ensure_user_can_use_account_endpoints(account_status: str) -> None:
        if account_status == "suspended":
            raise ApiError(
                status_code=403,
                code=ErrorCode.ACCOUNT_SUSPENDED,
                message="Your account is suspended. Please contact support.",
            )
        if account_status == "terminated":
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )
