from dataclasses import dataclass
from datetime import datetime, timezone
from functools import lru_cache
from typing import Protocol
from uuid import UUID

from anyio import to_thread
import jwt
from jwt import InvalidTokenError, PyJWKClient

from app.core.config import Settings
from app.core.errors import ApiError, ErrorCode


@dataclass(frozen=True)
class SupabaseVerifiedSession:
    auth_user_id: UUID
    phone: str
    access_token: str
    refresh_token: str
    session_id: UUID
    expires_at: datetime


@dataclass(frozen=True)
class SupabaseAuthUser:
    auth_user_id: UUID
    phone: str


@dataclass(frozen=True)
class SupabaseAccessTokenClaims:
    auth_user_id: UUID
    session_id: UUID
    expires_at: datetime


class SupabaseAuthGateway(Protocol):
    async def request_otp(self, *, phone: str) -> None: ...

    async def verify_otp(self, *, phone: str, otp: str) -> SupabaseVerifiedSession: ...

    async def get_user(self, *, access_token: str) -> SupabaseAuthUser: ...

    async def verify_access_token(
        self, *, access_token: str
    ) -> SupabaseAccessTokenClaims: ...

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
        self.jwt_issuer = f"{self.supabase_url.rstrip('/')}/auth/v1"
        self.jwks_url = f"{self.jwt_issuer}/.well-known/jwks.json"
        self.jwks_cache_seconds = settings.supabase_jwks_cache_seconds
        self.jwt_leeway_seconds = settings.supabase_jwt_leeway_seconds

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

        claims = await self.verify_access_token(access_token=str(session.access_token))
        return SupabaseVerifiedSession(
            auth_user_id=UUID(str(user.id)),
            phone=str(getattr(user, "phone", None) or phone),
            access_token=str(session.access_token),
            refresh_token=str(session.refresh_token),
            session_id=claims.session_id,
            expires_at=claims.expires_at,
        )

    async def verify_access_token(
        self, *, access_token: str
    ) -> SupabaseAccessTokenClaims:
        def verify() -> SupabaseAccessTokenClaims:
            try:
                signing_key = _jwks_client(
                    self.jwks_url,
                    self.jwks_cache_seconds,
                ).get_signing_key_from_jwt(access_token)
                payload = jwt.decode(
                    access_token,
                    signing_key.key,
                    algorithms=["ES256", "RS256"],
                    audience="authenticated",
                    issuer=self.jwt_issuer,
                    leeway=self.jwt_leeway_seconds,
                    options={
                        "require": ["aud", "exp", "iat", "iss", "session_id", "sub"]
                    },
                )
                return SupabaseAccessTokenClaims(
                    auth_user_id=UUID(str(payload["sub"])),
                    session_id=UUID(str(payload["session_id"])),
                    expires_at=datetime.fromtimestamp(
                        int(payload["exp"]),
                        tz=timezone.utc,
                    ),
                )
            except (InvalidTokenError, KeyError, TypeError, ValueError) as error:
                raise ApiError(
                    status_code=401,
                    code=ErrorCode.UNAUTHORIZED,
                    message="Please login again.",
                ) from error

        return await to_thread.run_sync(verify)

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


@lru_cache(maxsize=8)
def _jwks_client(jwks_url: str, cache_seconds: int) -> PyJWKClient:
    return PyJWKClient(
        jwks_url,
        cache_keys=True,
        lifespan=cache_seconds,
    )
