from typing import Literal
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.auth.dependencies import get_current_user_from_token
from app.modules.profiles.dependencies import enqueue_contact_reveal
from app.modules.profiles.dependencies import get_profile_service
from app.modules.profiles.schemas import OwnerProfileResponse, ProfileUpdateRequest
from app.modules.profiles.schemas import PublicProfileDetailResponse
from app.modules.profiles.service import ProfileService


router = APIRouter(prefix="/me/profile", tags=["Me"])
public_router = APIRouter(prefix="/profiles", tags=["Profiles"])


@public_router.get("/{profile_id}", response_model=PublicProfileDetailResponse)
def get_public_profile(
    profile_id: UUID,
    request: Request,
    source_type: Literal["work_card", "work_needed_post", "profile"] | None = Query(
        default=None
    ),
    source_id: UUID | None = None,
    current_user: CurrentUser = Depends(get_active_current_user),
    profile_service: ProfileService = Depends(get_profile_service),
) -> PublicProfileDetailResponse:
    response = profile_service.get_public_profile(
        current_user=current_user,
        profile_id=profile_id,
        source_type=source_type,
        source_id=source_id,
        ip_address=request.client.host if request.client else None,
        device_id=request.headers.get("x-device-id"),
        user_agent=request.headers.get("user-agent"),
        defer_reveal=True,
    )
    deferred_reveal = getattr(profile_service, "deferred_reveal", None)
    if deferred_reveal is not None:
        enqueue_contact_reveal(deferred_reveal)
    return response


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
