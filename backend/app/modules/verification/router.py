from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.verification.dependencies import get_verification_service
from app.modules.verification.schemas import VerificationSubmitRequest
from app.modules.verification.schemas import VerificationSummaryResponse
from app.modules.verification.service import VerificationService


router = APIRouter(prefix="/me/verification", tags=["Verification"])
CurrentUserDependency = Annotated[CurrentUser, Depends(get_active_current_user)]
ServiceDependency = Annotated[VerificationService, Depends(get_verification_service)]


@router.get("", response_model=VerificationSummaryResponse)
def get_verification(
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> VerificationSummaryResponse:
    return service.get_summary(current_user)


@router.post("/prepare", response_model=VerificationSummaryResponse)
def prepare_verification(
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> VerificationSummaryResponse:
    return service.prepare(current_user)


@router.post("/submit", response_model=VerificationSummaryResponse)
def submit_verification(
    payload: VerificationSubmitRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> VerificationSummaryResponse:
    return service.submit(current_user=current_user, payload=payload)


@router.post("/resubmit", response_model=VerificationSummaryResponse)
def resubmit_verification(
    payload: VerificationSubmitRequest,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> VerificationSummaryResponse:
    return service.resubmit(current_user=current_user, payload=payload)


@router.get("/cases/{case_id}", response_model=VerificationSummaryResponse)
def get_verification_case(
    case_id: UUID,
    current_user: CurrentUserDependency,
    service: ServiceDependency,
) -> VerificationSummaryResponse:
    return service.get_case(current_user=current_user, case_id=case_id)
