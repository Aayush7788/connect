from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.media.dependencies import get_media_service
from app.modules.media.schemas import MediaAssetResponse, UploadIntentRequest
from app.modules.media.schemas import UploadIntentResponse
from app.modules.media.service import MediaService


router = APIRouter(prefix="/media", tags=["Media"])


@router.post(
    "/upload-intent",
    response_model=UploadIntentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_upload_intent(
    payload: UploadIntentRequest,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: MediaService = Depends(get_media_service),
) -> UploadIntentResponse:
    return service.create_upload_intent(current_user=current_user, payload=payload)


@router.post("/{media_asset_id}/complete", response_model=MediaAssetResponse)
def complete_media_upload(
    media_asset_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: MediaService = Depends(get_media_service),
) -> MediaAssetResponse:
    return service.complete_upload(
        current_user=current_user,
        media_asset_id=media_asset_id,
    )


@router.post("/{media_asset_id}/retry", response_model=UploadIntentResponse)
def retry_media_upload(
    media_asset_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: MediaService = Depends(get_media_service),
) -> UploadIntentResponse:
    return service.retry_upload(
        current_user=current_user,
        media_asset_id=media_asset_id,
    )


@router.post(
    "/{media_asset_id}/cancel",
    status_code=status.HTTP_204_NO_CONTENT,
)
def cancel_media_upload(
    media_asset_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: MediaService = Depends(get_media_service),
) -> Response:
    service.cancel_upload(current_user=current_user, media_asset_id=media_asset_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete(
    "/{media_asset_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_media(
    media_asset_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: MediaService = Depends(get_media_service),
) -> Response:
    service.delete_media(current_user=current_user, media_asset_id=media_asset_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
