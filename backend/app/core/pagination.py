from typing import Annotated

from fastapi import Query
from pydantic import BaseModel, Field


DEFAULT_PAGE_LIMIT = 20
MAX_PAGE_LIMIT = 50


class PaginationParams(BaseModel):
    cursor: str | None = None
    limit: int = Field(default=DEFAULT_PAGE_LIMIT, ge=1, le=MAX_PAGE_LIMIT)


def pagination_params(
    cursor: Annotated[str | None, Query(min_length=1, max_length=500)] = None,
    limit: Annotated[int, Query(ge=1, le=MAX_PAGE_LIMIT)] = DEFAULT_PAGE_LIMIT,
) -> PaginationParams:
    return PaginationParams(cursor=cursor, limit=limit)
