import logging
from concurrent.futures import Future, ThreadPoolExecutor
from threading import BoundedSemaphore

from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.db.session import create_session_factory, get_db_session
from app.integrations.supabase_storage import SupabaseStorageGateway
from app.modules.profiles.repository import ProfileRepository
from app.modules.profiles.service import ContactRevealPayload, ProfileService


logger = logging.getLogger(__name__)
_reveal_executor = ThreadPoolExecutor(max_workers=1, thread_name_prefix="reveal-log")
_reveal_slots = BoundedSemaphore(1000)


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


def persist_contact_reveal(payload: ContactRevealPayload) -> None:
    try:
        with create_session_factory()() as session:
            repository = ProfileRepository(session)
            repository.record_contact_reveal(
                viewer_user_id=payload.viewer_user_id,
                profile_id=payload.profile_id,
                source_type=payload.source_type,
                source_id=payload.source_id,
                ip_address=payload.ip_address,
                device_id=payload.device_id,
                user_agent=payload.user_agent,
            )
            repository.commit()
    except Exception:
        logger.warning("Unable to persist deferred contact reveal", exc_info=True)


def enqueue_contact_reveal(payload: ContactRevealPayload) -> None:
    if not _reveal_slots.acquire(blocking=False):
        logger.warning("Contact reveal queue is full; dropping analytics event")
        return
    future = _reveal_executor.submit(persist_contact_reveal, payload)
    future.add_done_callback(_release_reveal_slot)


def _release_reveal_slot(future: Future[None]) -> None:
    _reveal_slots.release()
