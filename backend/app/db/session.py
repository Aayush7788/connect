from collections.abc import Generator
from functools import lru_cache
from time import perf_counter

from fastapi import Depends
from sqlalchemy import Engine, create_engine, event, text
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import Settings, get_settings
from app.core.logging import add_database_duration


def get_database_url(settings: Settings | None = None) -> str:
    resolved_settings = settings or get_settings()
    if resolved_settings.database_url is None:
        raise RuntimeError("DATABASE_URL is required for database access.")
    return resolved_settings.database_url.get_secret_value()


@lru_cache
def create_database_engine_from_url(database_url: str) -> Engine:
    engine = create_engine(
        database_url,
        pool_pre_ping=True,
        future=True,
    )
    event.listen(engine, "before_cursor_execute", _before_cursor_execute)
    event.listen(engine, "after_cursor_execute", _after_cursor_execute)
    return engine


def _before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    context.connect_request_started = perf_counter()


def _after_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    started = getattr(context, "connect_request_started", None)
    if started is not None:
        add_database_duration((perf_counter() - started) * 1000)


def create_database_engine(settings: Settings | None = None) -> Engine:
    return create_database_engine_from_url(get_database_url(settings))


def create_session_factory(settings: Settings | None = None) -> sessionmaker[Session]:
    return sessionmaker(
        bind=create_database_engine(settings),
        autoflush=False,
        expire_on_commit=False,
        future=True,
    )


def get_db_session(
    settings: Settings = Depends(get_settings),
) -> Generator[Session]:
    session_factory = create_session_factory(settings)
    with session_factory() as session:
        yield session


def check_database_connection(settings: Settings | None = None) -> bool:
    engine = create_database_engine(settings)
    try:
        with engine.connect() as connection:
            connection.execute(text("select 1"))
        return True
    finally:
        engine.dispose()
