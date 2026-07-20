from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.media.schemas import MediaAssetResponse


SearchTarget = Literal["business", "job_worker", "skilled_worker"]
BusinessSearchMode = Literal["work_needed_posts", "profiles"]
JobWorkerSearchMode = Literal["work_cards", "profiles"]
SearchSort = Literal["best", "verified_first", "nearby", "most_photos", "recent"]


class SearchResultResponse(BaseModel):
    result_type: Literal["profile", "work_card", "work_needed_post"]
    id: UUID
    profile_id: UUID
    title: str
    subtitle: str | None = None
    category: str | None = None
    skills: list[str] = Field(default_factory=list)
    product_types: list[str] = Field(default_factory=list)
    description: str | None = None
    locality: str | None = None
    experience_years: int | None = None
    is_verified: bool
    photo_count: int
    photos: list[MediaAssetResponse] = Field(default_factory=list)
    last_activity_at: datetime | None = None


class SearchResponse(BaseModel):
    items: list[SearchResultResponse] = Field(default_factory=list)
    result_count: int
    next_cursor: str | None = None
    search_log_id: UUID
