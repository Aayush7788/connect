import contextvars
import logging
import sys
from dataclasses import dataclass
from collections.abc import Awaitable, Callable
from time import perf_counter
from uuid import uuid4

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware


REQUEST_ID_HEADER = "X-Request-ID"
_request_id_ctx: contextvars.ContextVar[str | None] = contextvars.ContextVar(
    "request_id",
    default=None,
)


@dataclass
class RequestPerformance:
    auth_ms: float = 0
    database_ms: float = 0
    database_queries: int = 0


_request_performance_ctx: contextvars.ContextVar[RequestPerformance | None] = (
    contextvars.ContextVar("request_performance", default=None)
)


class RequestIdFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        record.request_id = get_request_id() or "-"
        return True


def get_request_id() -> str | None:
    return _request_id_ctx.get()


def new_request_id() -> str:
    return f"req_{uuid4().hex}"


def get_request_performance() -> RequestPerformance | None:
    return _request_performance_ctx.get()


def add_auth_duration(duration_ms: float) -> None:
    performance = get_request_performance()
    if performance is not None:
        performance.auth_ms += duration_ms


def add_database_duration(duration_ms: float) -> None:
    performance = get_request_performance()
    if performance is not None:
        performance.database_ms += duration_ms
        performance.database_queries += 1


def configure_logging(log_level: str) -> None:
    level = getattr(logging, log_level.upper(), logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.addFilter(RequestIdFilter())
    handler.setFormatter(
        logging.Formatter(
            "%(asctime)s %(levelname)s %(name)s [%(request_id)s] %(message)s"
        )
    )

    root_logger = logging.getLogger()
    root_logger.handlers.clear()
    root_logger.addHandler(handler)
    root_logger.setLevel(level)


class RequestIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        request_id = request.headers.get(REQUEST_ID_HEADER)
        if not request_id or len(request_id) > 128:
            request_id = new_request_id()

        request.state.request_id = request_id
        token = _request_id_ctx.set(request_id)
        performance = RequestPerformance()
        performance_token = _request_performance_ctx.set(performance)
        started = perf_counter()
        try:
            response = await call_next(request)
        finally:
            total_ms = (perf_counter() - started) * 1000
            _request_performance_ctx.reset(performance_token)
            _request_id_ctx.reset(token)

        response.headers[REQUEST_ID_HEADER] = request_id
        response.headers["X-Response-Time-Ms"] = f"{total_ms:.1f}"
        response.headers["Server-Timing"] = (
            f"total;dur={total_ms:.1f}, "
            f"auth;dur={performance.auth_ms:.1f}, "
            f'db;dur={performance.database_ms:.1f};desc="'
            f'{performance.database_queries} queries"'
        )
        if total_ms >= 750:
            logging.getLogger("app.performance").warning(
                "slow request method=%s path=%s total_ms=%.1f auth_ms=%.1f "
                "db_ms=%.1f db_queries=%d",
                request.method,
                request.url.path,
                total_ms,
                performance.auth_ms,
                performance.database_ms,
                performance.database_queries,
            )
        return response
