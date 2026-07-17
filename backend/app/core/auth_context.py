from dataclasses import dataclass
from typing import Literal
from uuid import UUID


UserRole = Literal["business", "job_worker", "skilled_worker"]
AccountStatus = Literal["active", "suspended", "terminated"]


@dataclass(frozen=True)
class CurrentUser:
    user_id: UUID
    auth_user_id: UUID
    mobile: str
    role: UserRole | None
    account_status: AccountStatus
    session_id: UUID | None = None


@dataclass(frozen=True)
class CurrentAdmin:
    admin_user_id: UUID
    user: CurrentUser
    role: str
    display_name: str | None = None
