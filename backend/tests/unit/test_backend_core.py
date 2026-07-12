from typing import Annotated

import pytest
from fastapi import Depends, Query
from fastapi.testclient import TestClient

from app.core.config import Settings
from app.core.errors import ApiError, ErrorCode
from app.core.pagination import PaginationParams, pagination_params
from app.core.security import get_current_user
from app.main import create_app


def test_health_endpoint_returns_request_id_header_and_body() -> None:
    client = TestClient(create_app(Settings(app_env="test")))

    response = client.get("/health", headers={"X-Request-ID": "req_test"})

    assert response.status_code == 200
    assert response.headers["X-Request-ID"] == "req_test"
    assert response.json()["status"] == "ok"
    assert response.json()["request_id"] == "req_test"


def test_versioned_health_endpoint_works() -> None:
    client = TestClient(create_app(Settings(app_env="test")))

    response = client.get("/v1/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_missing_route_uses_contract_error_envelope() -> None:
    client = TestClient(create_app(Settings(app_env="test")))

    response = client.get("/missing")
    body = response.json()

    assert response.status_code == 404
    assert set(body) == {"error"}
    assert body["error"]["code"] == ErrorCode.NOT_FOUND
    assert body["error"]["message"] == "Not found."
    assert body["error"]["request_id"].startswith("req_")
    assert response.headers["X-Request-ID"] == body["error"]["request_id"]


def test_validation_errors_use_contract_error_envelope() -> None:
    app = create_app(Settings(app_env="test"))

    @app.get("/test-validation")
    async def test_validation(limit: Annotated[int, Query(ge=1)]) -> dict[str, int]:
        return {"limit": limit}

    client = TestClient(app)

    response = client.get("/test-validation?limit=0")
    body = response.json()

    assert response.status_code == 422
    assert body["error"]["code"] == ErrorCode.VALIDATION_FAILED
    assert body["error"]["message"] == "Please check the highlighted fields."
    assert "query.limit" in body["error"]["field_errors"]
    assert body["error"]["request_id"].startswith("req_")


def test_api_error_uses_contract_error_envelope() -> None:
    app = create_app(Settings(app_env="test"))

    @app.get("/test-api-error")
    async def test_api_error() -> None:
        raise ApiError(
            status_code=403,
            code=ErrorCode.FORBIDDEN,
            message="You do not have permission to do this.",
        )

    client = TestClient(app)

    response = client.get("/test-api-error")
    body = response.json()

    assert response.status_code == 403
    assert body["error"]["code"] == ErrorCode.FORBIDDEN
    assert body["error"]["message"] == "You do not have permission to do this."
    assert body["error"]["request_id"].startswith("req_")


def test_pagination_dependency_validates_limits() -> None:
    app = create_app(Settings(app_env="test"))

    @app.get("/test-pagination")
    async def test_pagination(
        pagination: Annotated[PaginationParams, Depends(pagination_params)],
    ) -> dict[str, int | str | None]:
        return pagination.model_dump()

    client = TestClient(app)

    ok_response = client.get("/test-pagination?cursor=abc&limit=50")
    invalid_response = client.get("/test-pagination?limit=51")

    assert ok_response.status_code == 200
    assert ok_response.json() == {"cursor": "abc", "limit": 50}
    assert invalid_response.status_code == 422
    assert invalid_response.json()["error"]["code"] == ErrorCode.VALIDATION_FAILED


@pytest.mark.asyncio
async def test_auth_dependency_requires_bearer_token() -> None:
    with pytest.raises(ApiError) as exc_info:
        await get_current_user(credentials=None)

    assert exc_info.value.status_code == 401
    assert exc_info.value.code == ErrorCode.UNAUTHORIZED
