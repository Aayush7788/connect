from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.core.auth_context import CurrentUser
from app.core.config import Settings, get_settings
from app.core.security import bearer_scheme, require_bearer_token
from app.db.session import get_db_session
from app.integrations.supabase_auth import SupabasePythonAuthGateway
from app.modules.auth.repository import AuthRepository
from app.modules.auth.service import AuthService


def get_auth_gateway(
    settings: Settings = Depends(get_settings),
) -> SupabasePythonAuthGateway:
    return SupabasePythonAuthGateway(settings)


def get_auth_service(
    session: Session = Depends(get_db_session),
    auth_gateway=Depends(get_auth_gateway),
) -> AuthService:
    return AuthService(
        repository=AuthRepository(session),
        auth_gateway=auth_gateway,
    )


async def get_current_user_from_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    auth_service: AuthService = Depends(get_auth_service),
) -> CurrentUser:
    access_token = require_bearer_token(credentials)
    return await auth_service.get_current_user_from_token(access_token)


async def get_current_access_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    return require_bearer_token(credentials)
