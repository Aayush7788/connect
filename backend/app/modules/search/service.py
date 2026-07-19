import base64
from dataclasses import dataclass
import hashlib
import json
import re
import unicodedata
from typing import Any
from uuid import UUID, uuid4

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.modules.search.repository import SearchCriteria, SearchRepository
from app.modules.search.schemas import BusinessSearchMode, JobWorkerSearchMode
from app.modules.search.schemas import SearchResponse
from app.modules.search.schemas import SearchSort, SearchTarget


def normalize_search_text(value: str | None) -> str:
    normalized = unicodedata.normalize("NFKC", value or "").casefold()
    return " ".join(re.sub(r"[^\w]+", " ", normalized, flags=re.UNICODE).split())


@dataclass(frozen=True)
class SearchLogPayload:
    id: UUID
    user_id: UUID
    query: str | None
    normalized_query: str | None
    target_persona: SearchTarget
    filters_json: dict[str, Any]
    result_count: int


class SearchService:
    def __init__(self, repository: SearchRepository) -> None:
        self.repository = repository
        self.deferred_log: SearchLogPayload | None = None

    def search(
        self,
        *,
        current_user: CurrentUser,
        target: SearchTarget,
        query: str | None,
        business_mode: BusinessSearchMode | None,
        category_id: UUID | None,
        product_type_id: UUID | None,
        locality: str | None,
        min_experience_years: int | None,
        max_experience_years: int | None,
        verified_only: bool,
        sort: SearchSort,
        cursor: str | None,
        limit: int,
        job_worker_mode: JobWorkerSearchMode | None = None,
        defer_log: bool = False,
    ) -> SearchResponse:
        resolved_business_mode = self._business_mode(target, business_mode)
        resolved_job_worker_mode = self._job_worker_mode(target, job_worker_mode)
        self._validate_experience(
            target=target,
            minimum=min_experience_years,
            maximum=max_experience_years,
        )
        cleaned_query = " ".join((query or "").split()) or None
        normalized_query = normalize_search_text(cleaned_query)
        normalized_locality = normalize_search_text(locality) or None
        filters = {
            "business_mode": resolved_business_mode,
            "job_worker_mode": resolved_job_worker_mode,
            "category_id": str(category_id) if category_id else None,
            "product_type_id": str(product_type_id) if product_type_id else None,
            "locality": locality,
            "normalized_locality": normalized_locality,
            "min_experience_years": min_experience_years,
            "max_experience_years": max_experience_years,
            "verified_only": verified_only,
            "sort": sort,
        }
        fingerprint = self._fingerprint(
            target=target,
            normalized_query=normalized_query,
            filters=filters,
        )
        offset = self._decode_cursor(cursor, fingerprint=fingerprint)
        criteria = SearchCriteria(
            target=target,
            normalized_query=normalized_query,
            business_mode=resolved_business_mode,
            job_worker_mode=resolved_job_worker_mode,
            category_id=category_id,
            product_type_id=product_type_id,
            normalized_locality=normalized_locality,
            min_experience_years=min_experience_years,
            max_experience_years=max_experience_years,
            verified_only=verified_only,
            sort=sort,
        )
        try:
            page = self.repository.search(
                criteria=criteria,
                offset=offset,
                limit=limit,
            )
            log_payload = SearchLogPayload(
                id=uuid4(),
                user_id=current_user.user_id,
                query=cleaned_query,
                normalized_query=normalized_query or None,
                target_persona=target,
                filters_json=filters,
                result_count=page.result_count,
            )
            if defer_log:
                self.deferred_log = log_payload
                search_log_id = log_payload.id
            else:
                search_log = self.repository.create_log(
                    log_id=log_payload.id,
                    user_id=log_payload.user_id,
                    query=log_payload.query,
                    normalized_query=log_payload.normalized_query,
                    target_persona=log_payload.target_persona,
                    filters_json=log_payload.filters_json,
                    result_count=log_payload.result_count,
                )
                self.repository.commit()
                search_log_id = search_log.id
        except Exception:
            self.repository.rollback()
            raise

        next_offset = offset + len(page.items)
        next_cursor = None
        if next_offset < page.result_count:
            next_cursor = self._encode_cursor(
                offset=next_offset,
                fingerprint=fingerprint,
            )
        return SearchResponse(
            items=page.items,
            result_count=page.result_count,
            next_cursor=next_cursor,
            search_log_id=search_log_id,
        )

    @staticmethod
    def _business_mode(
        target: SearchTarget,
        business_mode: BusinessSearchMode | None,
    ) -> BusinessSearchMode | None:
        if target == "business":
            return business_mode or "work_needed_posts"
        if business_mode is not None:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={
                    "business_mode": "Business mode is only valid for business search."
                },
            )
        return None

    @staticmethod
    def _job_worker_mode(
        target: SearchTarget,
        job_worker_mode: JobWorkerSearchMode | None,
    ) -> JobWorkerSearchMode | None:
        if target == "job_worker":
            return job_worker_mode or "work_cards"
        if job_worker_mode is not None:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={
                    "job_worker_mode": (
                        "Job-worker mode is only valid for job-worker search."
                    )
                },
            )
        return None

    @staticmethod
    def _validate_experience(
        *,
        target: SearchTarget,
        minimum: int | None,
        maximum: int | None,
    ) -> None:
        if target == "business" and (minimum is not None or maximum is not None):
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={
                    "experience": "Experience is not available for business search."
                },
            )
        if minimum is not None and maximum is not None and minimum > maximum:
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please check the highlighted fields.",
                field_errors={"min_experience_years": "Minimum cannot exceed maximum."},
            )

    @staticmethod
    def _fingerprint(
        *,
        target: SearchTarget,
        normalized_query: str,
        filters: dict[str, Any],
    ) -> str:
        payload = json.dumps(
            {
                "target": target,
                "q": normalized_query,
                "filters": filters,
            },
            sort_keys=True,
            separators=(",", ":"),
        )
        return hashlib.sha256(payload.encode("utf-8")).hexdigest()[:24]

    @staticmethod
    def _encode_cursor(*, offset: int, fingerprint: str) -> str:
        payload = json.dumps(
            {"v": 1, "offset": offset, "fingerprint": fingerprint},
            separators=(",", ":"),
        ).encode("utf-8")
        return base64.urlsafe_b64encode(payload).decode("ascii").rstrip("=")

    @staticmethod
    def _decode_cursor(cursor: str | None, *, fingerprint: str) -> int:
        if cursor is None:
            return 0
        try:
            padded = cursor + "=" * (-len(cursor) % 4)
            payload = json.loads(base64.urlsafe_b64decode(padded).decode("utf-8"))
            if (
                payload.get("v") != 1
                or payload.get("fingerprint") != fingerprint
                or not isinstance(payload.get("offset"), int)
                or payload["offset"] < 0
            ):
                raise ValueError
            return payload["offset"]
        except (ValueError, TypeError, json.JSONDecodeError, UnicodeDecodeError):
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please refresh the search results.",
                field_errors={"cursor": "This search cursor is invalid or expired."},
            ) from None
