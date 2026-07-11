from collections.abc import Mapping
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.config import Settings
from app.core.logging import get_request_id, new_request_id


class ErrorCode:
    VALIDATION_FAILED = "validation_failed"
    UNAUTHORIZED = "unauthorized"
    FORBIDDEN = "forbidden"
    NOT_FOUND = "not_found"
    ACCOUNT_SUSPENDED = "account_suspended"
    PROFILE_INCOMPLETE = "profile_incomplete"
    MINIMUM_PHOTOS_REQUIRED = "minimum_photos_required"
    VERIFICATION_PENDING_LOCKED = "verification_pending_locked"
    UPLOAD_NOT_READY = "upload_not_ready"
    APP_UPDATE_REQUIRED = "app_update_required"
    PROVIDER_UNAVAILABLE = "provider_unavailable"
    INTERNAL_ERROR = "internal_error"


class ApiError(Exception):
    def __init__(
        self,
        *,
        status_code: int,
        code: str,
        message: str,
        details: Mapping[str, Any] | None = None,
        field_errors: Mapping[str, str] | None = None,
    ) -> None:
        self.status_code = status_code
        self.code = code
        self.message = message
        self.details = dict(details or {})
        self.field_errors = dict(field_errors or {})


def build_error_content(
    *,
    code: str,
    message: str,
    request_id: str,
    details: Mapping[str, Any] | None = None,
    field_errors: Mapping[str, str] | None = None,
) -> dict[str, Any]:
    error: dict[str, Any] = {
        "code": code,
        "message": message,
        "request_id": request_id,
    }
    if details:
        error["details"] = dict(details)
    if field_errors:
        error["field_errors"] = dict(field_errors)
    return {"error": error}


def request_id_for(request: Request) -> str:
    return (
        getattr(request.state, "request_id", None)
        or get_request_id()
        or new_request_id()
    )


def validation_field_name(error_location: tuple[Any, ...]) -> str:
    return ".".join(str(part) for part in error_location if part != "body")


def register_exception_handlers(app: FastAPI, settings: Settings) -> None:
    @app.exception_handler(ApiError)
    async def api_error_handler(request: Request, exc: ApiError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content=build_error_content(
                code=exc.code,
                message=exc.message,
                details=exc.details,
                field_errors=exc.field_errors,
                request_id=request_id_for(request),
            ),
        )

    @app.exception_handler(RequestValidationError)
    async def validation_error_handler(
        request: Request,
        exc: RequestValidationError,
    ) -> JSONResponse:
        field_errors = {
            validation_field_name(tuple(error.get("loc", ()))): str(
                error.get("msg", "Invalid value")
            )
            for error in exc.errors()
        }
        return JSONResponse(
            status_code=422,
            content=build_error_content(
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors=field_errors,
                request_id=request_id_for(request),
            ),
        )

    @app.exception_handler(StarletteHTTPException)
    async def http_error_handler(
        request: Request,
        exc: StarletteHTTPException,
    ) -> JSONResponse:
        code = ErrorCode.INTERNAL_ERROR
        message = "Something went wrong."
        if exc.status_code == 401:
            code = ErrorCode.UNAUTHORIZED
            message = "Please login again."
        elif exc.status_code == 403:
            code = ErrorCode.FORBIDDEN
            message = "You do not have permission to do this."
        elif exc.status_code == 404:
            code = ErrorCode.NOT_FOUND
            message = "Not found."

        return JSONResponse(
            status_code=exc.status_code,
            content=build_error_content(
                code=code,
                message=message,
                request_id=request_id_for(request),
            ),
        )

    @app.exception_handler(Exception)
    async def unhandled_error_handler(request: Request, exc: Exception) -> JSONResponse:
        details: dict[str, Any] = {}
        if settings.enable_debug_errors:
            details["exception"] = exc.__class__.__name__
            details["message"] = str(exc)
        return JSONResponse(
            status_code=500,
            content=build_error_content(
                code=ErrorCode.INTERNAL_ERROR,
                message="Something went wrong.",
                details=details,
                request_id=request_id_for(request),
            ),
        )
