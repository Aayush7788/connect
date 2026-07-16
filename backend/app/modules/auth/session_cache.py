from collections import OrderedDict
from dataclasses import dataclass
from datetime import datetime, timezone
from threading import Lock
from time import monotonic
from uuid import UUID

from app.core.auth_context import CurrentUser


@dataclass(frozen=True)
class CachedAuthContext:
    current_user: CurrentUser
    auth_user_id: UUID
    token_expires_at: datetime
    cache_expires_at: float


class AuthContextCache:
    def __init__(self, *, maximum_entries: int = 10_000) -> None:
        self.maximum_entries = maximum_entries
        self._entries: OrderedDict[UUID, CachedAuthContext] = OrderedDict()
        self._lock = Lock()

    def get(
        self,
        *,
        session_id: UUID,
        auth_user_id: UUID,
    ) -> CurrentUser | None:
        with self._lock:
            entry = self._entries.get(session_id)
            if entry is None:
                return None
            if (
                entry.auth_user_id != auth_user_id
                or entry.cache_expires_at <= monotonic()
                or entry.token_expires_at <= datetime.now(timezone.utc)
            ):
                self._entries.pop(session_id, None)
                return None
            self._entries.move_to_end(session_id)
            return entry.current_user

    def put(
        self,
        *,
        current_user: CurrentUser,
        token_expires_at: datetime,
        ttl_seconds: int,
    ) -> None:
        session_id = current_user.session_id
        if session_id is None or ttl_seconds <= 0:
            return
        with self._lock:
            self._entries[session_id] = CachedAuthContext(
                current_user=current_user,
                auth_user_id=current_user.auth_user_id,
                token_expires_at=token_expires_at,
                cache_expires_at=monotonic() + ttl_seconds,
            )
            self._entries.move_to_end(session_id)
            while len(self._entries) > self.maximum_entries:
                self._entries.popitem(last=False)

    def invalidate_session(self, session_id: UUID) -> None:
        with self._lock:
            self._entries.pop(session_id, None)

    def invalidate_user(self, user_id: UUID) -> None:
        with self._lock:
            session_ids = [
                session_id
                for session_id, entry in self._entries.items()
                if entry.current_user.user_id == user_id
            ]
            for session_id in session_ids:
                self._entries.pop(session_id, None)

    def clear(self) -> None:
        with self._lock:
            self._entries.clear()


auth_context_cache = AuthContextCache()
