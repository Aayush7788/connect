from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.work_needed_posts.repository import WorkNeededPostRepository
from app.modules.work_needed_posts.service import WorkNeededPostService


def get_work_needed_post_service(
    session: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> WorkNeededPostService:
    storage = SupabaseStorageGateway(settings)
    return WorkNeededPostService(
        repository=WorkNeededPostRepository(session),
        public_media_url=lambda path: storage.public_url(
            bucket=settings.supabase_public_media_bucket,
            path=path,
        ),
    )
