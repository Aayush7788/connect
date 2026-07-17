from typing import Annotated

from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.auth_context import CurrentAdmin, CurrentUser
from app.core.config import Settings, get_settings
from app.core.errors import ApiError, ErrorCode
from app.db.session import get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.admin.repository import AdminRepository
from app.modules.admin.service import AdminService
from app.modules.auth.dependencies import get_active_current_user


async def get_current_admin(
    current_user: Annotated[CurrentUser, Depends(get_active_current_user)],
    session: Annotated[Session, Depends(get_db_session)],
) -> CurrentAdmin:
    admin = AdminRepository(session).admin_for_user(current_user.user_id)
    if admin is None:
        raise ApiError(
            status_code=403,
            code=ErrorCode.FORBIDDEN,
            message="You do not have permission to do this.",
        )
    return CurrentAdmin(
        admin_user_id=admin.id,
        user=current_user,
        role="super_admin",
        display_name=admin.display_name,
    )


def get_admin_service(
    session: Annotated[Session, Depends(get_db_session)],
    settings: Annotated[Settings, Depends(get_settings)],
) -> AdminService:
    return AdminService(
        repository=AdminRepository(session),
        storage=SupabaseStorageGateway(settings),
        private_bucket=settings.supabase_private_verification_bucket,
    )
