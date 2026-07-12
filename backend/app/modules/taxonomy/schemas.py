from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field


CategoryType = Literal[
    "business_category",
    "work_category",
    "work_name",
    "product_type",
    "skill",
]


class CategoryResponse(BaseModel):
    id: UUID
    parent_id: UUID | None = None
    category_type: CategoryType
    name: str


class CategoryListResponse(BaseModel):
    items: list[CategoryResponse] = Field(default_factory=list)
