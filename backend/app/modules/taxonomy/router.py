from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.taxonomy.dependencies import get_taxonomy_repository
from app.modules.taxonomy.repository import TaxonomyRepository
from app.modules.taxonomy.schemas import CategoryListResponse, CategoryResponse
from app.modules.taxonomy.schemas import CategoryType


router = APIRouter(prefix="/taxonomy", tags=["Taxonomy"])


@router.get("/categories", response_model=CategoryListResponse)
def list_categories(
    category_type: Annotated[CategoryType, Query()],
    parent_id: UUID | None = None,
    current_user: CurrentUser = Depends(get_active_current_user),
    repository: TaxonomyRepository = Depends(get_taxonomy_repository),
) -> CategoryListResponse:
    del current_user
    return CategoryListResponse(
        items=[
            CategoryResponse.model_validate(category, from_attributes=True)
            for category in repository.list_categories(
                category_type=category_type,
                parent_id=parent_id,
            )
        ]
    )
