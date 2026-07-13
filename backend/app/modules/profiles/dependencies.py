from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.profiles.repository import ProfileRepository
from app.modules.profiles.service import ProfileService


def get_profile_service(
    session: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> ProfileService:
    storage = SupabaseStorageGateway(settings)
    return ProfileService(
        ProfileRepository(session),
        public_media_url=lambda path: storage.public_url(
            bucket=settings.supabase_public_media_bucket,
            path=path,
        ),
    )
