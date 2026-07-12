from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.media.repository import MediaRepository
from app.modules.media.service import MediaService
from app.modules.profiles.repository import ProfileRepository


def get_media_service(
    session: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> MediaService:
    return MediaService(
        repository=MediaRepository(session),
        profile_repository=ProfileRepository(session),
        storage=SupabaseStorageGateway(settings),
        settings=settings,
    )
