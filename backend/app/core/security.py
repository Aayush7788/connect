from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.auth_context import CurrentUser
from app.core.config import Settings, get_settings
from app.core.errors import ApiError, ErrorCode
from app.db.session import get_db_session


bearer_scheme = HTTPBearer(auto_error=False)


def require_bearer_token(
    credentials: HTTPAuthorizationCredentials | None,
) -> str:
    if credentials is None or not credentials.credentials:
        raise ApiError(
            status_code=401,
            code=ErrorCode.UNAUTHORIZED,
            message="Please login again.",
        )
    return credentials.credentials


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    settings: Settings = Depends(get_settings),
    session: Session = Depends(get_db_session),
) -> CurrentUser:
    from app.integrations.supabase_auth import SupabasePythonAuthGateway
    from app.modules.auth.repository import AuthRepository
    from app.modules.auth.service import AuthService

    access_token = require_bearer_token(credentials)
    auth_service = AuthService(
        repository=AuthRepository(session),
        auth_gateway=SupabasePythonAuthGateway(settings),
    )
    return await auth_service.get_current_user_from_token(access_token)


async def get_active_user(
    user: CurrentUser = Depends(get_current_user),
) -> CurrentUser:
    if user.account_status == "suspended":
        raise ApiError(
            status_code=403,
            code=ErrorCode.ACCOUNT_SUSPENDED,
            message="Your account is suspended. Please contact support.",
        )
    if user.account_status == "terminated":
        raise ApiError(
            status_code=401,
            code=ErrorCode.UNAUTHORIZED,
            message="Please login again.",
        )
    return user


async def get_current_admin() -> CurrentUser:
    raise ApiError(
        status_code=403,
        code=ErrorCode.FORBIDDEN,
        message="You do not have permission to do this.",
    )
