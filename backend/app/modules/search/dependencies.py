import logging
from concurrent.futures import Future, ThreadPoolExecutor
from threading import BoundedSemaphore

from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.models.cross_cutting import SearchLog
from app.db.session import create_session_factory, get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.search.repository import SearchRepository
from app.modules.search.service import SearchLogPayload, SearchService


logger = logging.getLogger(__name__)
_log_executor = ThreadPoolExecutor(max_workers=1, thread_name_prefix="search-log")
_log_slots = BoundedSemaphore(1000)


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


def persist_search_log(payload: SearchLogPayload) -> None:
    try:
        session_factory = create_session_factory()
        with session_factory.begin() as session:
            session.add(
                SearchLog(
                    id=payload.id,
                    user_id=payload.user_id,
                    query=payload.query,
                    normalized_query=payload.normalized_query,
                    target_persona=payload.target_persona,
                    filters_json=payload.filters_json,
                    result_count=payload.result_count,
                )
            )
    except Exception:
        logger.warning("Unable to persist deferred search log", exc_info=True)


def enqueue_search_log(payload: SearchLogPayload) -> None:
    if not _log_slots.acquire(blocking=False):
        logger.warning("Search log queue is full; dropping analytics event")
        return
    future = _log_executor.submit(persist_search_log, payload)
    future.add_done_callback(_release_log_slot)


def _release_log_slot(future: Future[None]) -> None:
    _log_slots.release()
