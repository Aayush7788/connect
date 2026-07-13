from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.core.auth_context import CurrentUser
from app.modules.auth.dependencies import get_active_current_user
from app.modules.search.dependencies import get_search_service
from app.modules.search.schemas import BusinessSearchMode, SearchResponse
from app.modules.search.schemas import SearchSort, SearchTarget
from app.modules.search.service import SearchService


router = APIRouter(prefix="/search", tags=["Search"])


@router.get("", response_model=SearchResponse)
def search_marketplace(
    target: SearchTarget,
    q: Annotated[str | None, Query(max_length=200)] = None,
    business_mode: BusinessSearchMode | None = None,
    category_id: UUID | None = None,
    product_type_id: UUID | None = None,
    locality: Annotated[str | None, Query(max_length=160)] = None,
    min_experience_years: Annotated[int | None, Query(ge=0, le=100)] = None,
    max_experience_years: Annotated[int | None, Query(ge=0, le=100)] = None,
    verified_only: bool = False,
    sort: SearchSort = "best",
    cursor: Annotated[str | None, Query(max_length=500)] = None,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    current_user: CurrentUser = Depends(get_active_current_user),
    service: SearchService = Depends(get_search_service),
) -> SearchResponse:
    return service.search(
        current_user=current_user,
        target=target,
        query=q,
        business_mode=business_mode,
        category_id=category_id,
        product_type_id=product_type_id,
        locality=locality,
        min_experience_years=min_experience_years,
        max_experience_years=max_experience_years,
        verified_only=verified_only,
        sort=sort,
        cursor=cursor,
        limit=limit,
    )
