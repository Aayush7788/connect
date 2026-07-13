from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.search.repository import SearchRepository
from app.modules.search.service import SearchService


def get_search_service(
    session: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> SearchService:
    storage = SupabaseStorageGateway(settings)
    return SearchService(
        SearchRepository(
            session,
            public_media_url=lambda path: storage.public_url(
                bucket=settings.supabase_public_media_bucket,
                path=path,
            ),
        )
    )
