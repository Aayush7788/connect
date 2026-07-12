from fastapi import APIRouter, Depends, Response, status

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_auth_service
from app.modules.auth.dependencies import get_current_access_token
from app.modules.auth.dependencies import get_current_user_from_token
from app.modules.auth.schemas import AuthSessionResponse
from app.modules.auth.schemas import BasicAccountRequest
from app.modules.auth.schemas import MeResponse
from app.modules.auth.schemas import OtpRequest
from app.modules.auth.schemas import OtpRequestResponse
from app.modules.auth.schemas import OtpVerifyRequest
from app.modules.auth.service import AuthService


router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/otp/request", response_model=OtpRequestResponse)
async def request_otp(
    payload: OtpRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> OtpRequestResponse:
    return await auth_service.request_otp(payload)


@router.post("/otp/verify", response_model=AuthSessionResponse)
async def verify_otp(
    payload: OtpVerifyRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> AuthSessionResponse:
    return await auth_service.verify_otp(payload)


@router.post("/account", response_model=MeResponse)
async def complete_basic_account(
    payload: BasicAccountRequest,
    current_user: CurrentUser = Depends(get_current_user_from_token),
    auth_service: AuthService = Depends(get_auth_service),
) -> MeResponse:
    return await auth_service.complete_basic_account(
        current_user=current_user,
        payload=payload,
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    access_token: str = Depends(get_current_access_token),
    auth_service: AuthService = Depends(get_auth_service),
) -> Response:
    await auth_service.logout(access_token)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
