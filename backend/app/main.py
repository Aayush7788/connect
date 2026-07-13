from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from app.core.config import Settings, get_settings
from app.core.errors import register_exception_handlers
from app.core.logging import RequestIdMiddleware, configure_logging, get_request_id
from app.modules.auth.router import router as auth_router
from app.modules.me.router import router as me_router
from app.modules.media.router import router as media_router
from app.modules.profiles.router import router as profiles_router
from app.modules.search.router import router as search_router
from app.modules.taxonomy.router import router as taxonomy_router
from app.modules.work_cards.router import router as work_cards_router
from app.modules.work_needed_posts.router import router as work_needed_posts_router


class HealthResponse(BaseModel):
    status: str
    app: str
    environment: str
    request_id: str | None


def create_app(settings: Settings | None = None) -> FastAPI:
    resolved_settings = settings or get_settings()
    configure_logging(resolved_settings.log_level)

    app = FastAPI(
        title=resolved_settings.app_name,
        version="0.1.0",
    )
    app.state.settings = resolved_settings

    app.add_middleware(RequestIdMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=resolved_settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    register_exception_handlers(app, resolved_settings)

    @app.get("/health", response_model=HealthResponse, tags=["health"])
    async def health() -> HealthResponse:
        return HealthResponse(
            status="ok",
            app=resolved_settings.app_name,
            environment=resolved_settings.app_env,
            request_id=get_request_id(),
        )

    @app.get(
        f"{resolved_settings.api_v1_prefix}/health",
        response_model=HealthResponse,
        tags=["health"],
    )
    async def versioned_health() -> HealthResponse:
        return HealthResponse(
            status="ok",
            app=resolved_settings.app_name,
            environment=resolved_settings.app_env,
            request_id=get_request_id(),
        )

    app.include_router(auth_router, prefix=resolved_settings.api_v1_prefix)
    app.include_router(me_router, prefix=resolved_settings.api_v1_prefix)
    app.include_router(media_router, prefix=resolved_settings.api_v1_prefix)
    app.include_router(profiles_router, prefix=resolved_settings.api_v1_prefix)
    app.include_router(search_router, prefix=resolved_settings.api_v1_prefix)
    app.include_router(taxonomy_router, prefix=resolved_settings.api_v1_prefix)
    app.include_router(work_cards_router, prefix=resolved_settings.api_v1_prefix)
    app.include_router(
        work_needed_posts_router,
        prefix=resolved_settings.api_v1_prefix,
    )

    return app


app = create_app()
