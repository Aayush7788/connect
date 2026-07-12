from fastapi import APIRouter, Depends

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_current_user_from_token
from app.modules.profiles.dependencies import get_profile_service
from app.modules.profiles.schemas import OwnerProfileResponse, ProfileUpdateRequest
from app.modules.profiles.service import ProfileService


router = APIRouter(prefix="/me/profile", tags=["Me"])


@router.get("", response_model=OwnerProfileResponse)
def get_my_profile(
    current_user: CurrentUser = Depends(get_current_user_from_token),
    profile_service: ProfileService = Depends(get_profile_service),
) -> OwnerProfileResponse:
    return profile_service.get_owner_profile(current_user)


@router.patch("", response_model=OwnerProfileResponse)
def update_my_profile(
    payload: ProfileUpdateRequest,
    current_user: CurrentUser = Depends(get_current_user_from_token),
    profile_service: ProfileService = Depends(get_profile_service),
) -> OwnerProfileResponse:
    return profile_service.update_owner_profile(
        current_user=current_user,
        payload=payload,
    )


@router.post("/complete", response_model=OwnerProfileResponse)
def complete_my_profile(
    current_user: CurrentUser = Depends(get_current_user_from_token),
    profile_service: ProfileService = Depends(get_profile_service),
) -> OwnerProfileResponse:
    return profile_service.complete_owner_profile(current_user)


@router.post("/hide", response_model=OwnerProfileResponse)
def hide_my_profile(
    current_user: CurrentUser = Depends(get_current_user_from_token),
    profile_service: ProfileService = Depends(get_profile_service),
) -> OwnerProfileResponse:
    return profile_service.hide_owner_profile(current_user)


@router.post("/show", response_model=OwnerProfileResponse)
def show_my_profile(
    current_user: CurrentUser = Depends(get_current_user_from_token),
    profile_service: ProfileService = Depends(get_profile_service),
) -> OwnerProfileResponse:
    return profile_service.show_owner_profile(current_user)
