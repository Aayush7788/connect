from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.profiles.repository import ProfileRepository
from app.modules.profiles.service import ProfileService
from app.modules.work_cards.repository import WorkCardRepository
from app.modules.work_cards.service import WorkCardService


def get_work_card_service(
    session: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> WorkCardService:
    storage = SupabaseStorageGateway(settings)
    return WorkCardService(
        repository=WorkCardRepository(session),
        profile_service=ProfileService(ProfileRepository(session)),
        public_media_url=lambda path: storage.public_url(
            bucket=settings.supabase_public_media_bucket,
            path=path,
        ),
    )
