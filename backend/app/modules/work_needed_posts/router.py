from uuid import UUID

from fastapi import APIRouter, Depends, Header, Response, status

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.work_needed_posts.dependencies import get_work_needed_post_service
from app.modules.work_needed_posts.schemas import WorkNeededPostListResponse
from app.modules.work_needed_posts.schemas import WorkNeededPostResponse
from app.modules.work_needed_posts.schemas import WorkNeededPostUpsertRequest
from app.modules.work_needed_posts.service import WorkNeededPostService


router = APIRouter(prefix="/me/work-needed-posts", tags=["WorkNeededPosts"])


@router.get("", response_model=WorkNeededPostListResponse)
def list_my_work_needed_posts(
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> WorkNeededPostListResponse:
    return service.list_owner_posts(current_user)


@router.post(
    "",
    response_model=WorkNeededPostResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_work_needed_post(
    payload: WorkNeededPostUpsertRequest,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> WorkNeededPostResponse:
    return service.create_post(
        current_user=current_user,
        payload=payload,
        idempotency_key=idempotency_key,
    )


@router.patch("/{post_id}", response_model=WorkNeededPostResponse)
def update_work_needed_post(
    post_id: UUID,
    payload: WorkNeededPostUpsertRequest,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> WorkNeededPostResponse:
    return service.update_post(
        current_user=current_user,
        post_id=post_id,
        payload=payload,
    )


@router.post("/{post_id}/publish", response_model=WorkNeededPostResponse)
def publish_work_needed_post(
    post_id: UUID,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> WorkNeededPostResponse:
    return service.publish_post(
        current_user=current_user,
        post_id=post_id,
        idempotency_key=idempotency_key,
    )


@router.post("/{post_id}/pause", response_model=WorkNeededPostResponse)
def pause_work_needed_post(
    post_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> WorkNeededPostResponse:
    return service.pause_post(current_user=current_user, post_id=post_id)


@router.post("/{post_id}/resume", response_model=WorkNeededPostResponse)
def resume_work_needed_post(
    post_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> WorkNeededPostResponse:
    return service.resume_post(current_user=current_user, post_id=post_id)


@router.post("/{post_id}/close", response_model=WorkNeededPostResponse)
def close_work_needed_post(
    post_id: UUID,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> WorkNeededPostResponse:
    return service.close_post(
        current_user=current_user,
        post_id=post_id,
        idempotency_key=idempotency_key,
    )


@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_work_needed_post(
    post_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkNeededPostService = Depends(get_work_needed_post_service),
) -> Response:
    service.delete_post(current_user=current_user, post_id=post_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
