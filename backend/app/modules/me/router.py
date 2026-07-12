from fastapi import APIRouter, Depends

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_auth_service
from app.modules.auth.dependencies import get_current_user_from_token
from app.modules.auth.schemas import MeResponse
from app.modules.auth.service import AuthService


router = APIRouter(tags=["Me"])


@router.get("/me", response_model=MeResponse)
async def get_me(
    current_user: CurrentUser = Depends(get_current_user_from_token),
    auth_service: AuthService = Depends(get_auth_service),
) -> MeResponse:
    return await auth_service.get_me(current_user)
