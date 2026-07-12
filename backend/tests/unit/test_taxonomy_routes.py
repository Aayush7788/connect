from types import SimpleNamespace
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient

from app.core.auth_context import CurrentUser
from app.core.config import Settings
from app.core.errors import ApiError, ErrorCode
from app.main import create_app
from app.modules.auth.dependencies import get_active_current_user
from app.modules.taxonomy.dependencies import get_taxonomy_repository


class FakeTaxonomyRepository:
    def __init__(self) -> None:
        self.category_id = uuid4()

    def list_categories(self, *, category_type, parent_id):
        return [
            SimpleNamespace(
                id=self.category_id,
                parent_id=parent_id,
                category_type=category_type,
                name="Manufacturing",
            )
        ]


def test_list_categories_returns_authenticated_form_options() -> None:
    app = create_app(Settings(app_env="test"))
    current_user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    repository = FakeTaxonomyRepository()
    app.dependency_overrides[get_active_current_user] = lambda: current_user
    app.dependency_overrides[get_taxonomy_repository] = lambda: repository
    client = TestClient(app)

    response = client.get("/v1/taxonomy/categories?category_type=business_category")

    assert response.status_code == 200
    assert response.json()["items"] == [
        {
            "id": str(repository.category_id),
            "parent_id": None,
            "category_type": "business_category",
            "name": "Manufacturing",
        }
    ]


@pytest.mark.asyncio
async def test_active_user_dependency_blocks_suspended_account() -> None:
    current_user = CurrentUser(
        user_id=uuid4(),
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="suspended",
    )

    with pytest.raises(ApiError) as exc_info:
        await get_active_current_user(current_user)

    assert exc_info.value.code == ErrorCode.ACCOUNT_SUSPENDED
