from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request, status

from app.core.auth_context import CurrentAdmin
from app.modules.admin.dependencies import get_admin_service, get_current_admin
from app.modules.admin.schemas import AdminAnalyticsSummaryResponse
from app.modules.admin.schemas import AdminDecisionRequest, AdminProfileResponse
from app.modules.admin.schemas import AdminProfilesResponse, AdminReportsResponse
from app.modules.admin.schemas import AdminSeedProfileRequest
from app.modules.admin.schemas import AdminUserResponse
from app.modules.admin.schemas import AdminVerificationCaseResponse
from app.modules.admin.schemas import AdminVerificationCasesResponse
from app.modules.admin.schemas import CreateExportRequest, ExportJobResponse
from app.modules.admin.service import AdminService


router = APIRouter(prefix="/admin", tags=["Admin"])
AdminDependency = Annotated[CurrentAdmin, Depends(get_current_admin)]
ServiceDependency = Annotated[AdminService, Depends(get_admin_service)]


def _request_metadata(request: Request) -> tuple[str | None, str | None]:
    return (
        request.client.host if request.client else None,
        request.headers.get("user-agent"),
    )


@router.get("/me", response_model=AdminUserResponse)
def get_admin_me(
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminUserResponse:
    return service.me(admin)


@router.get("/verification-cases", response_model=AdminVerificationCasesResponse)
def list_verification_cases(
    admin: AdminDependency,
    service: ServiceDependency,
    case_status: Annotated[
        str | None,
        Query(
            alias="status",
            pattern="^(draft|pending_review|changes_requested|approved|rejected|cancelled)$",
        ),
    ] = None,
    cursor: str | None = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 25,
) -> AdminVerificationCasesResponse:
    return service.list_verification_cases(
        status=case_status,
        cursor=cursor,
        limit=limit,
    )


@router.get(
    "/verification-cases/{case_id}",
    response_model=AdminVerificationCaseResponse,
)
def get_verification_case(
    request: Request,
    case_id: UUID,
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminVerificationCaseResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.get_verification_case(
        admin=admin,
        case_id=case_id,
        ip_address=ip_address,
        user_agent=user_agent,
    )


@router.post(
    "/verification-cases/{case_id}/approve",
    response_model=AdminVerificationCaseResponse,
)
def approve_verification_case(
    request: Request,
    case_id: UUID,
    payload: AdminDecisionRequest,
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminVerificationCaseResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.approve_verification(
        admin=admin,
        case_id=case_id,
        payload=payload,
        ip_address=ip_address,
        user_agent=user_agent,
    )


@router.post(
    "/verification-cases/{case_id}/request-changes",
    response_model=AdminVerificationCaseResponse,
)
def request_verification_changes(
    request: Request,
    case_id: UUID,
    payload: AdminDecisionRequest,
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminVerificationCaseResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.request_verification_changes(
        admin=admin,
        case_id=case_id,
        payload=payload,
        ip_address=ip_address,
        user_agent=user_agent,
    )


@router.post(
    "/verification-cases/{case_id}/reject",
    response_model=AdminVerificationCaseResponse,
)
def reject_verification_case(
    request: Request,
    case_id: UUID,
    payload: AdminDecisionRequest,
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminVerificationCaseResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.reject_verification(
        admin=admin,
        case_id=case_id,
        payload=payload,
        ip_address=ip_address,
        user_agent=user_agent,
    )


@router.get("/profiles", response_model=AdminProfilesResponse)
def list_profiles(
    admin: AdminDependency,
    service: ServiceDependency,
    role: Annotated[
        str | None,
        Query(pattern="^(business|job_worker|skilled_worker)$"),
    ] = None,
    verification_status: Annotated[
        str | None,
        Query(pattern="^(unverified|pending|verified|changes_requested|rejected)$"),
    ] = None,
    is_admin_seeded: bool | None = None,
    cursor: str | None = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 25,
) -> AdminProfilesResponse:
    return service.list_profiles(
        role=role,
        verification_status=verification_status,
        is_admin_seeded=is_admin_seeded,
        cursor=cursor,
        limit=limit,
    )


@router.post(
    "/seed-profiles",
    response_model=AdminProfileResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_seed_profile(
    request: Request,
    payload: AdminSeedProfileRequest,
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminProfileResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.create_seed_profile(
        admin=admin,
        payload=payload,
        ip_address=ip_address,
        user_agent=user_agent,
    )


@router.post("/profiles/{profile_id}/suspend", response_model=AdminProfileResponse)
def suspend_profile(
    request: Request,
    profile_id: UUID,
    payload: AdminDecisionRequest,
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminProfileResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.suspend_profile(
        admin=admin,
        profile_id=profile_id,
        payload=payload,
        ip_address=ip_address,
        user_agent=user_agent,
    )


@router.post("/profiles/{profile_id}/unsuspend", response_model=AdminProfileResponse)
def unsuspend_profile(
    request: Request,
    profile_id: UUID,
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminProfileResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.unsuspend_profile(
        admin=admin,
        profile_id=profile_id,
        ip_address=ip_address,
        user_agent=user_agent,
    )


@router.get("/reports", response_model=AdminReportsResponse)
def list_reports(
    admin: AdminDependency,
    service: ServiceDependency,
    report_status: Annotated[
        str | None,
        Query(
            alias="status",
            pattern="^(submitted|in_review|resolved_no_action|action_taken|dismissed)$",
        ),
    ] = None,
    grouped: bool = True,
    cursor: str | None = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 25,
) -> AdminReportsResponse:
    return service.list_reports(
        status=report_status,
        grouped=grouped,
        cursor=cursor,
        limit=limit,
    )


@router.get("/analytics/summary", response_model=AdminAnalyticsSummaryResponse)
def analytics_summary(
    admin: AdminDependency,
    service: ServiceDependency,
) -> AdminAnalyticsSummaryResponse:
    return service.analytics()


@router.post(
    "/exports",
    response_model=ExportJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
def create_export(
    request: Request,
    payload: CreateExportRequest,
    admin: AdminDependency,
    service: ServiceDependency,
) -> ExportJobResponse:
    ip_address, user_agent = _request_metadata(request)
    return service.create_export(
        admin=admin,
        payload=payload,
        ip_address=ip_address,
        user_agent=user_agent,
    )
