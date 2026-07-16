from fastapi import APIRouter, Depends, Query

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.locations.dependencies import get_location_service
from app.modules.locations.schemas import AddressValidationRequest
from app.modules.locations.schemas import AddressValidationResponse
from app.modules.locations.schemas import LocationOptionList
from app.modules.locations.service import LocationService


router = APIRouter(prefix="/locations", tags=["Locations"])


@router.get("/states", response_model=LocationOptionList)
def list_states(
    q: str | None = Query(default=None, max_length=80),
    limit: int = Query(default=50, ge=1, le=100),
    _: CurrentUser = Depends(get_active_current_user),
    service: LocationService = Depends(get_location_service),
) -> LocationOptionList:
    return service.states(q, limit)


@router.get("/districts", response_model=LocationOptionList)
def list_districts(
    state_id: int = Query(gt=0),
    q: str | None = Query(default=None, max_length=80),
    limit: int = Query(default=100, ge=1, le=200),
    _: CurrentUser = Depends(get_active_current_user),
    service: LocationService = Depends(get_location_service),
) -> LocationOptionList:
    return service.districts(state_id=state_id, query=q, limit=limit)


@router.post("/validate-address", response_model=AddressValidationResponse)
def validate_address(
    payload: AddressValidationRequest,
    _: CurrentUser = Depends(get_active_current_user),
    service: LocationService = Depends(get_location_service),
) -> AddressValidationResponse:
    return service.validate(payload)

