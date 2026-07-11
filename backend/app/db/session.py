from sqlalchemy import Engine, create_engine, text

from app.core.config import Settings, get_settings


def get_database_url(settings: Settings | None = None) -> str:
    resolved_settings = settings or get_settings()
    if resolved_settings.database_url is None:
        raise RuntimeError("DATABASE_URL is required for database access.")
    return resolved_settings.database_url.get_secret_value()


def create_database_engine(settings: Settings | None = None) -> Engine:
    return create_engine(
        get_database_url(settings),
        pool_pre_ping=True,
        future=True,
    )


def check_database_connection(settings: Settings | None = None) -> bool:
    engine = create_database_engine(settings)
    try:
        with engine.connect() as connection:
            connection.execute(text("select 1"))
        return True
    finally:
        engine.dispose()
