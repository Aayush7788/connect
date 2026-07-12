from dataclasses import dataclass
from typing import Protocol
from uuid import UUID

from anyio import to_thread

from app.core.config import Settings
from app.core.errors import ApiError, ErrorCode


@dataclass(frozen=True)
class SupabaseVerifiedSession:
    auth_user_id: UUID
    phone: str
    access_token: str
    refresh_token: str


@dataclass(frozen=True)
class SupabaseAuthUser:
    auth_user_id: UUID
    phone: str


class SupabaseAuthGateway(Protocol):
    async def request_otp(self, *, phone: str) -> None: ...

    async def verify_otp(self, *, phone: str, otp: str) -> SupabaseVerifiedSession: ...

    async def get_user(self, *, access_token: str) -> SupabaseAuthUser: ...

    async def logout(self, *, access_token: str) -> None: ...


class SupabasePythonAuthGateway:
    def __init__(self, settings: Settings) -> None:
        if settings.supabase_url is None or settings.supabase_anon_key is None:
            raise ApiError(
                status_code=503,
                code=ErrorCode.PROVIDER_UNAVAILABLE,
                message="Login is temporarily unavailable.",
            )
        self.supabase_url = settings.supabase_url
        self.supabase_key = settings.supabase_anon_key.get_secret_value()

    def _client(self):
        from supabase import create_client

        return create_client(self.supabase_url, self.supabase_key)

    async def request_otp(self, *, phone: str) -> None:
        def request() -> None:
            self._client().auth.sign_in_with_otp({"phone": phone})

        await to_thread.run_sync(request)

    async def verify_otp(self, *, phone: str, otp: str) -> SupabaseVerifiedSession:
        def verify():
            return self._client().auth.verify_otp(
                {
                    "phone": phone,
                    "token": otp,
                    "type": "sms",
                }
            )

        response = await to_thread.run_sync(verify)
        session = getattr(response, "session", None)
        user = getattr(response, "user", None)
        if session is None or user is None:
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Incorrect OTP.",
            )

        return SupabaseVerifiedSession(
            auth_user_id=UUID(str(user.id)),
            phone=str(getattr(user, "phone", None) or phone),
            access_token=str(session.access_token),
            refresh_token=str(session.refresh_token),
        )

    async def get_user(self, *, access_token: str) -> SupabaseAuthUser:
        def get_user():
            return self._client().auth.get_user(jwt=access_token)

        response = await to_thread.run_sync(get_user)
        user = getattr(response, "user", None)
        if user is None:
            raise ApiError(
                status_code=401,
                code=ErrorCode.UNAUTHORIZED,
                message="Please login again.",
            )

        return SupabaseAuthUser(
            auth_user_id=UUID(str(user.id)),
            phone=str(getattr(user, "phone", "") or ""),
        )

    async def logout(self, *, access_token: str) -> None:
        def sign_out() -> None:
            self._client().auth.admin.sign_out(access_token, "local")

        await to_thread.run_sync(sign_out)
