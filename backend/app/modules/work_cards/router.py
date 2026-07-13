from uuid import UUID

from fastapi import APIRouter, Depends, Header, Response, status

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.work_cards.dependencies import get_work_card_service
from app.modules.work_cards.schemas import WorkCardListResponse, WorkCardResponse
from app.modules.work_cards.schemas import WorkCardUpsertRequest
from app.modules.work_cards.service import WorkCardService


router = APIRouter(prefix="/me/work-cards", tags=["WorkCards"])


@router.get("", response_model=WorkCardListResponse)
def list_my_work_cards(
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkCardService = Depends(get_work_card_service),
) -> WorkCardListResponse:
    return service.list_owner_work_cards(current_user)


@router.post(
    "",
    response_model=WorkCardResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_work_card(
    payload: WorkCardUpsertRequest,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkCardService = Depends(get_work_card_service),
) -> WorkCardResponse:
    return service.create_work_card(
        current_user=current_user,
        payload=payload,
        idempotency_key=idempotency_key,
    )


@router.patch("/{work_card_id}", response_model=WorkCardResponse)
def update_work_card(
    work_card_id: UUID,
    payload: WorkCardUpsertRequest,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkCardService = Depends(get_work_card_service),
) -> WorkCardResponse:
    return service.update_work_card(
        current_user=current_user,
        work_card_id=work_card_id,
        payload=payload,
    )


@router.post("/{work_card_id}/publish", response_model=WorkCardResponse)
def publish_work_card(
    work_card_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkCardService = Depends(get_work_card_service),
) -> WorkCardResponse:
    return service.publish_work_card(
        current_user=current_user,
        work_card_id=work_card_id,
    )


@router.post("/{work_card_id}/hide", response_model=WorkCardResponse)
def hide_work_card(
    work_card_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkCardService = Depends(get_work_card_service),
) -> WorkCardResponse:
    return service.hide_work_card(
        current_user=current_user,
        work_card_id=work_card_id,
    )


@router.post("/{work_card_id}/show", response_model=WorkCardResponse)
def show_work_card(
    work_card_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkCardService = Depends(get_work_card_service),
) -> WorkCardResponse:
    return service.show_work_card(
        current_user=current_user,
        work_card_id=work_card_id,
    )


@router.delete(
    "/{work_card_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_work_card(
    work_card_id: UUID,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: WorkCardService = Depends(get_work_card_service),
) -> Response:
    service.delete_work_card(
        current_user=current_user,
        work_card_id=work_card_id,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
