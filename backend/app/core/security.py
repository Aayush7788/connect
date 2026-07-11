from dataclasses import dataclass
from typing import Literal
from uuid import UUID

from app.core.errors import ApiError, ErrorCode


UserRole = Literal["business", "job_worker", "skilled_worker"]
AccountStatus = Literal["active", "suspended", "terminated"]


@dataclass(frozen=True)
class CurrentUser:
    user_id: UUID
    mobile: str
    role: UserRole | None
    account_status: AccountStatus


async def get_current_user() -> CurrentUser:
    raise ApiError(
        status_code=401,
        code=ErrorCode.UNAUTHORIZED,
        message="Please login again.",
    )


async def get_active_user() -> CurrentUser:
    user = await get_current_user()
    if user.account_status == "suspended":
        raise ApiError(
            status_code=403,
            code=ErrorCode.ACCOUNT_SUSPENDED,
            message="Your account is suspended. Please contact support.",
        )
    if user.account_status == "terminated":
        raise ApiError(
            status_code=401,
            code=ErrorCode.UNAUTHORIZED,
            message="Please login again.",
        )
    return user


async def get_current_admin() -> CurrentUser:
    raise ApiError(
        status_code=403,
        code=ErrorCode.FORBIDDEN,
        message="You do not have permission to do this.",
    )
