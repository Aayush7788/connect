from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request, Response, status

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.engagement.dependencies import get_engagement_service
from app.modules.engagement.schemas import ContactActionRequest
from app.modules.engagement.schemas import CreateReportRequest, CreateShareLinkRequest
from app.modules.engagement.schemas import NotificationResponse, NotificationsResponse
from app.modules.engagement.schemas import RegisterDeviceTokenRequest
from app.modules.engagement.schemas import ReportResponse, SavedItemsResponse
from app.modules.engagement.schemas import SaveItemRequest, SavedItemResponse
from app.modules.engagement.schemas import ShareLinkResponse
from app.modules.engagement.schemas import UpdateSettingsRequest, UserSettingsResponse
from app.modules.engagement.service import EngagementService


router = APIRouter()
CurrentUserDependency = Annotated[CurrentUser, Depends(get_active_current_user)]
ServiceDependency = Annotated[EngagementService, Depends(get_engagement_service)]


@router.get("/me/saved-items", response_model=SavedItemsResponse, tags=["Saved"])
def list_saved_items(
    current_user: CurrentUserDependency,
    service: ServiceDependency,
    target_type: Annotated[
        str | None,
        Query(pattern="^(profile|work_card|work_needed_post)$"),
    ] = None,
    cursor: str | None = None,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
) -> SavedItemsResponse:
    return service.list_saved(
        current_user=current_user,
        target_type=target_type,
        cursor=cursor,
        limit=limit,
    )


@router.post("/me/saved-items", response_model=SavedItemResponse, tags=["Saved"])
def save_item(
    payload: SaveItemRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> SavedItemResponse:
    return service.save_item(current_user=current_user, payload=payload)


@router.delete(
    "/me/saved-items/{saved_item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["Saved"],
)
def remove_saved_item(
    saved_item_id: UUID,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> Response:
    service.remove_saved(current_user=current_user, saved_item_id=saved_item_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/reports",
    response_model=ReportResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Reports"],
)
def create_report(
    payload: CreateReportRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> ReportResponse:
    return service.report(current_user=current_user, payload=payload)


@router.get(
    "/me/notifications",
    response_model=NotificationsResponse,
    tags=["Notifications"],
)
def list_notifications(
    current_user: CurrentUserDependency,
    service: ServiceDependency,
    cursor: str | None = None,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
) -> NotificationsResponse:
    return service.notifications(
        current_user=current_user,
        cursor=cursor,
        limit=limit,
    )


@router.post(
    "/me/notifications/{notification_id}/read",
    response_model=NotificationResponse,
    tags=["Notifications"],
)
def mark_notification_read(
    notification_id: UUID,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> NotificationResponse:
    return service.mark_notification_read(
        current_user=current_user,
        notification_id=notification_id,
    )


@router.post(
    "/me/device-tokens",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["Notifications"],
)
def register_device_token(
    payload: RegisterDeviceTokenRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> Response:
    service.register_device(current_user=current_user, payload=payload)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.patch(
    "/me/settings",
    response_model=UserSettingsResponse,
    tags=["Settings"],
)
def update_settings(
    payload: UpdateSettingsRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> UserSettingsResponse:
    return service.update_settings(current_user=current_user, payload=payload)


@router.get(
    "/me/settings",
    response_model=UserSettingsResponse,
    tags=["Settings"],
)
def get_settings(
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> UserSettingsResponse:
    return service.settings(current_user=current_user)


@router.post(
    "/contact-actions",
    status_code=status.HTTP_202_ACCEPTED,
    tags=["Contact"],
)
def create_contact_action(
    request: Request,
    payload: ContactActionRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> Response:
    service.log_contact_action(
        current_user=current_user,
        payload=payload,
        ip_address=request.client.host if request.client else None,
        device_id=request.headers.get("x-device-id"),
        user_agent=request.headers.get("user-agent"),
    )
    return Response(status_code=status.HTTP_202_ACCEPTED)


@router.post(
    "/share-links",
    response_model=ShareLinkResponse,
    tags=["Share"],
)
def create_share_link(
    request: Request,
    payload: CreateShareLinkRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> ShareLinkResponse:
    return service.share_link(
        current_user=current_user,
        payload=payload,
        ip_address=request.client.host if request.client else None,
        device_id=request.headers.get("x-device-id"),
        user_agent=request.headers.get("user-agent"),
    )
