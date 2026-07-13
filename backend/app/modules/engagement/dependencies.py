from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.engagement.repository import EngagementRepository
from app.modules.engagement.service import EngagementService


def get_engagement_service(
    session: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> EngagementService:
    storage = SupabaseStorageGateway(settings)
    return EngagementService(
        EngagementRepository(
            session,
            public_media_url=lambda path: storage.public_url(
                bucket=settings.supabase_public_media_bucket,
                path=path,
            ),
        ),
        share_base_url=settings.share_base_url,
    )
