from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import Any, Callable, Literal, cast
from uuid import UUID, uuid4

from sqlalchemy import Float, and_, case, func, literal
from sqlalchemy import or_, select
from sqlalchemy.orm import Session, aliased

from app.db.models.cross_cutting import MediaAsset, SearchLog
from app.db.models.identity import User
from app.db.models.marketplace import WorkCard, WorkCardProductType
from app.db.models.marketplace import WorkNeededPost, WorkNeededPostProductType
from app.db.models.profile import BusinessProfile, BusinessProfileProductType
from app.db.models.profile import SkilledWorkerProfileSkill
from app.db.models.profile import JobWorkerProfile, Profile, SkilledWorkerProfile
from app.db.models.taxonomy import Category
from app.modules.media.schemas import MediaAssetResponse, MediaKind, MediaVisibility
from app.modules.search.schemas import SearchResultResponse


SearchTarget = Literal["business", "job_worker", "skilled_worker"]
BusinessMode = Literal["work_needed_posts", "profiles"]
JobWorkerMode = Literal["work_cards", "profiles"]
SortMode = Literal["best", "verified_first", "nearby", "most_photos", "recent"]


@dataclass(frozen=True)
class SearchCriteria:
    target: SearchTarget
    normalized_query: str
    business_mode: BusinessMode | None
    category_id: UUID | None
    product_type_id: UUID | None
    normalized_locality: str | None
    min_experience_years: int | None
    max_experience_years: int | None
    verified_only: bool
    sort: SortMode
    job_worker_mode: JobWorkerMode | None = None


@dataclass(frozen=True)
class SearchRepositoryPage:
    items: list[SearchResultResponse]
    result_count: int


class SearchRepository:
    def __init__(
        self,
        session: Session,
        public_media_url: Callable[[str], str] | None = None,
    ) -> None:
        self.session = session
        self.public_media_url = public_media_url

    def search(
        self,
        *,
        criteria: SearchCriteria,
        offset: int,
        limit: int,
    ) -> SearchRepositoryPage:
        primary = self._execute(
            criteria=criteria,
            offset=offset,
            limit=limit,
            fuzzy=False,
        )
        if primary.result_count > 0 or not criteria.normalized_query:
            return primary
        return self._execute(
            criteria=criteria,
            offset=offset,
            limit=limit,
            fuzzy=True,
        )

    def create_log(
        self,
        *,
        log_id: UUID | None = None,
        user_id: UUID,
        query: str | None,
        normalized_query: str | None,
        target_persona: SearchTarget,
        filters_json: dict[str, Any],
        result_count: int,
    ) -> SearchLog:
        search_log = SearchLog(
            id=log_id or uuid4(),
            user_id=user_id,
            query=query,
            normalized_query=normalized_query,
            target_persona=target_persona,
            filters_json=filters_json,
            result_count=result_count,
        )
        self.session.add(search_log)
        return search_log

    def commit(self) -> None:
        self.session.commit()

    def rollback(self) -> None:
        self.session.rollback()

    def _execute(
        self,
        *,
        criteria: SearchCriteria,
        offset: int,
        limit: int,
        fuzzy: bool,
    ) -> SearchRepositoryPage:
        if criteria.target == "job_worker" and criteria.job_worker_mode == "profiles":
            statement = self._job_worker_profile_statement(criteria, fuzzy=fuzzy)
        elif criteria.target == "job_worker":
            statement = self._work_card_statement(criteria, fuzzy=fuzzy)
        elif criteria.target == "business" and criteria.business_mode == "profiles":
            statement = self._business_profile_statement(criteria, fuzzy=fuzzy)
        elif criteria.target == "business":
            statement = self._work_needed_post_statement(criteria, fuzzy=fuzzy)
        else:
            statement = self._skilled_worker_statement(criteria, fuzzy=fuzzy)

        statement = statement.add_columns(func.count().over().label("_result_count"))
        rows = list(
            self.session.execute(statement.offset(offset).limit(limit)).mappings()
        )
        if rows:
            result_count = int(rows[0]["_result_count"])
        elif offset > 0:
            result_count = int(
                self.session.scalar(
                    select(func.count()).select_from(
                        statement.order_by(None).subquery()
                    )
                )
                or 0
            )
        else:
            result_count = 0
        product_types = self._product_types(rows)
        skills = self._skills(rows)
        photos = self._photos(rows)
        items = [
            SearchResultResponse(
                result_type=row["result_type"],
                id=row["id"],
                profile_id=row["profile_id"],
                title=row["title"],
                subtitle=row["subtitle"],
                category=row["category"],
                skills=skills.get(
                    (row["result_type"], row["id"]),
                    [row["category"]]
                    if criteria.target == "skilled_worker" and row["category"]
                    else [],
                ),
                product_types=product_types.get((row["result_type"], row["id"]), []),
                description=row["description"],
                locality=row["locality"],
                experience_years=row["experience_years"],
                is_verified=bool(row["is_verified"]),
                photo_count=int(row["photo_count"] or 0),
                photos=photos.get((row["result_type"], row["id"]), []),
                last_activity_at=row["last_activity_at"],
            )
            for row in rows
        ]
        return SearchRepositoryPage(items=items, result_count=result_count)

    def _work_card_statement(self, criteria: SearchCriteria, *, fuzzy: bool):
        work_category = aliased(Category)
        work_name = aliased(Category)
        experience = func.coalesce(
            WorkCard.experience_years,
            JobWorkerProfile.profile_experience_years,
        )
        relevance, match_condition = self._text_match(
            WorkCard.search_text,
            WorkCard.search_vector,
            criteria.normalized_query,
            fuzzy=fuzzy,
        )
        locality_match = self._locality_match(Profile, criteria.normalized_locality)
        statement = (
            select(
                literal("work_card").label("result_type"),
                WorkCard.id.label("id"),
                WorkCard.profile_id.label("profile_id"),
                WorkCard.title.label("title"),
                Profile.public_name.label("subtitle"),
                func.coalesce(
                    work_name.name,
                    WorkCard.custom_work_name,
                    work_category.name,
                    WorkCard.custom_work_category_text,
                ).label("category"),
                WorkCard.description.label("description"),
                Profile.locality.label("locality"),
                experience.label("experience_years"),
                Profile.is_verified.label("is_verified"),
                WorkCard.photo_count.label("photo_count"),
                WorkCard.last_activity_at.label("last_activity_at"),
                relevance.label("relevance"),
                locality_match.label("locality_match"),
                WorkCard.ranking_score.label("ranking_score"),
                WorkCard.created_at.label("created_at"),
            )
            .join(Profile, Profile.id == WorkCard.profile_id)
            .join(JobWorkerProfile, JobWorkerProfile.profile_id == Profile.id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .outerjoin(work_category, work_category.id == WorkCard.work_category_id)
            .outerjoin(work_name, work_name.id == WorkCard.work_name_category_id)
            .where(
                WorkCard.status == "published",
                WorkCard.deleted_at.is_(None),
                *self._public_profile_conditions(Profile, User, "job_worker"),
                match_condition,
            )
        )
        if criteria.category_id is not None:
            statement = statement.where(
                or_(
                    WorkCard.work_category_id == criteria.category_id,
                    WorkCard.work_name_category_id == criteria.category_id,
                )
            )
        if criteria.product_type_id is not None:
            statement = statement.where(
                select(WorkCardProductType.id)
                .where(
                    WorkCardProductType.work_card_id == WorkCard.id,
                    WorkCardProductType.product_type_category_id
                    == criteria.product_type_id,
                )
                .exists()
            )
        statement = self._common_filters(
            statement,
            criteria=criteria,
            profile=Profile,
            experience=experience,
        )
        return statement.order_by(
            *self._sort_expressions(
                criteria.sort,
                relevance=relevance,
                verified=Profile.is_verified,
                locality_match=locality_match,
                photo_count=WorkCard.photo_count,
                ranking_score=WorkCard.ranking_score,
                activity_at=func.coalesce(
                    WorkCard.last_activity_at, WorkCard.created_at
                ),
                entity_id=WorkCard.id,
            )
        )

    def _job_worker_profile_statement(
        self,
        criteria: SearchCriteria,
        *,
        fuzzy: bool,
    ):
        profile_relevance, profile_match = self._text_match(
            Profile.search_text,
            Profile.search_vector,
            criteria.normalized_query,
            fuzzy=fuzzy,
        )
        _, work_card_match = self._text_match(
            WorkCard.search_text,
            WorkCard.search_vector,
            criteria.normalized_query,
            fuzzy=fuzzy,
        )
        matching_work_card = (
            select(WorkCard.id)
            .where(
                WorkCard.profile_id == Profile.id,
                WorkCard.status == "published",
                WorkCard.deleted_at.is_(None),
                work_card_match,
            )
            .exists()
        )
        relevance = func.greatest(
            profile_relevance,
            case((matching_work_card, 0.9), else_=0.0),
        )
        match_condition = or_(profile_match, matching_work_card)
        locality_match = self._locality_match(Profile, criteria.normalized_locality)
        experience = JobWorkerProfile.profile_experience_years
        statement = (
            select(
                literal("profile").label("result_type"),
                Profile.id.label("id"),
                Profile.id.label("profile_id"),
                Profile.public_name.label("title"),
                JobWorkerProfile.work_summary.label("subtitle"),
                literal(None).label("category"),
                JobWorkerProfile.workshop_name.label("description"),
                Profile.locality.label("locality"),
                experience.label("experience_years"),
                Profile.is_verified.label("is_verified"),
                Profile.photo_count.label("photo_count"),
                Profile.last_activity_at.label("last_activity_at"),
                relevance.label("relevance"),
                locality_match.label("locality_match"),
                Profile.ranking_score.label("ranking_score"),
                Profile.created_at.label("created_at"),
            )
            .join(JobWorkerProfile, JobWorkerProfile.profile_id == Profile.id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .where(
                *self._public_profile_conditions(Profile, User, "job_worker"),
                match_condition,
            )
        )
        if criteria.category_id is not None:
            statement = statement.where(
                select(WorkCard.id)
                .where(
                    WorkCard.profile_id == Profile.id,
                    WorkCard.status == "published",
                    WorkCard.deleted_at.is_(None),
                    or_(
                        WorkCard.work_category_id == criteria.category_id,
                        WorkCard.work_name_category_id == criteria.category_id,
                    ),
                )
                .exists()
            )
        if criteria.product_type_id is not None:
            statement = statement.where(
                select(WorkCardProductType.id)
                .join(WorkCard, WorkCard.id == WorkCardProductType.work_card_id)
                .where(
                    WorkCard.profile_id == Profile.id,
                    WorkCard.status == "published",
                    WorkCard.deleted_at.is_(None),
                    WorkCardProductType.product_type_category_id
                    == criteria.product_type_id,
                )
                .exists()
            )
        statement = self._common_filters(
            statement,
            criteria=criteria,
            profile=Profile,
            experience=experience,
        )
        return statement.order_by(
            *self._sort_expressions(
                criteria.sort,
                relevance=relevance,
                verified=Profile.is_verified,
                locality_match=locality_match,
                photo_count=Profile.photo_count,
                ranking_score=Profile.ranking_score,
                activity_at=func.coalesce(Profile.last_activity_at, Profile.created_at),
                entity_id=Profile.id,
            )
        )

    def _work_needed_post_statement(
        self,
        criteria: SearchCriteria,
        *,
        fuzzy: bool,
    ):
        work_category = aliased(Category)
        work_name = aliased(Category)
        relevance, match_condition = self._text_match(
            WorkNeededPost.search_text,
            WorkNeededPost.search_vector,
            criteria.normalized_query,
            fuzzy=fuzzy,
        )
        locality_match = self._locality_match(Profile, criteria.normalized_locality)
        statement = (
            select(
                literal("work_needed_post").label("result_type"),
                WorkNeededPost.id.label("id"),
                WorkNeededPost.profile_id.label("profile_id"),
                WorkNeededPost.title.label("title"),
                Profile.public_name.label("subtitle"),
                func.coalesce(
                    work_name.name,
                    WorkNeededPost.custom_work_name,
                    work_category.name,
                    WorkNeededPost.custom_work_category_text,
                ).label("category"),
                WorkNeededPost.description.label("description"),
                Profile.locality.label("locality"),
                literal(None).label("experience_years"),
                Profile.is_verified.label("is_verified"),
                WorkNeededPost.photo_count.label("photo_count"),
                WorkNeededPost.last_activity_at.label("last_activity_at"),
                relevance.label("relevance"),
                locality_match.label("locality_match"),
                WorkNeededPost.ranking_score.label("ranking_score"),
                WorkNeededPost.created_at.label("created_at"),
            )
            .join(Profile, Profile.id == WorkNeededPost.profile_id)
            .join(BusinessProfile, BusinessProfile.profile_id == Profile.id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .outerjoin(
                work_category,
                work_category.id == WorkNeededPost.work_category_id,
            )
            .outerjoin(work_name, work_name.id == WorkNeededPost.work_name_category_id)
            .where(
                WorkNeededPost.status == "active",
                WorkNeededPost.deleted_at.is_(None),
                *self._public_profile_conditions(Profile, User, "business"),
                match_condition,
            )
        )
        if criteria.category_id is not None:
            statement = statement.where(
                or_(
                    WorkNeededPost.work_category_id == criteria.category_id,
                    WorkNeededPost.work_name_category_id == criteria.category_id,
                )
            )
        if criteria.product_type_id is not None:
            statement = statement.where(
                select(WorkNeededPostProductType.id)
                .where(
                    WorkNeededPostProductType.work_needed_post_id == WorkNeededPost.id,
                    WorkNeededPostProductType.product_type_category_id
                    == criteria.product_type_id,
                )
                .exists()
            )
        statement = self._common_filters(
            statement,
            criteria=criteria,
            profile=Profile,
            experience=None,
        )
        return statement.order_by(
            *self._sort_expressions(
                criteria.sort,
                relevance=relevance,
                verified=Profile.is_verified,
                locality_match=locality_match,
                photo_count=WorkNeededPost.photo_count,
                ranking_score=WorkNeededPost.ranking_score,
                activity_at=func.coalesce(
                    WorkNeededPost.last_activity_at,
                    WorkNeededPost.created_at,
                ),
                entity_id=WorkNeededPost.id,
            )
        )

    def _business_profile_statement(
        self,
        criteria: SearchCriteria,
        *,
        fuzzy: bool,
    ):
        business_category = aliased(Category)
        relevance, match_condition = self._text_match(
            Profile.search_text,
            Profile.search_vector,
            criteria.normalized_query,
            fuzzy=fuzzy,
        )
        locality_match = self._locality_match(Profile, criteria.normalized_locality)
        statement = (
            select(
                literal("profile").label("result_type"),
                Profile.id.label("id"),
                Profile.id.label("profile_id"),
                Profile.public_name.label("title"),
                BusinessProfile.manufacture_sell_details.label("subtitle"),
                business_category.name.label("category"),
                BusinessProfile.product_notes.label("description"),
                Profile.locality.label("locality"),
                literal(None).label("experience_years"),
                Profile.is_verified.label("is_verified"),
                Profile.photo_count.label("photo_count"),
                Profile.last_activity_at.label("last_activity_at"),
                relevance.label("relevance"),
                locality_match.label("locality_match"),
                Profile.ranking_score.label("ranking_score"),
                Profile.created_at.label("created_at"),
            )
            .join(BusinessProfile, BusinessProfile.profile_id == Profile.id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .outerjoin(
                business_category,
                business_category.id == BusinessProfile.business_category_id,
            )
            .where(
                *self._public_profile_conditions(Profile, User, "business"),
                match_condition,
            )
        )
        if criteria.category_id is not None:
            statement = statement.where(
                BusinessProfile.business_category_id == criteria.category_id
            )
        if criteria.product_type_id is not None:
            statement = statement.where(
                select(BusinessProfileProductType.id)
                .where(
                    BusinessProfileProductType.profile_id == Profile.id,
                    BusinessProfileProductType.product_type_category_id
                    == criteria.product_type_id,
                )
                .exists()
            )
        statement = self._common_filters(
            statement,
            criteria=criteria,
            profile=Profile,
            experience=None,
        )
        return statement.order_by(
            *self._sort_expressions(
                criteria.sort,
                relevance=relevance,
                verified=Profile.is_verified,
                locality_match=locality_match,
                photo_count=Profile.photo_count,
                ranking_score=Profile.ranking_score,
                activity_at=func.coalesce(Profile.last_activity_at, Profile.created_at),
                entity_id=Profile.id,
            )
        )

    def _skilled_worker_statement(
        self,
        criteria: SearchCriteria,
        *,
        fuzzy: bool,
    ):
        skill = aliased(Category)
        relevance, match_condition = self._text_match(
            Profile.search_text,
            Profile.search_vector,
            criteria.normalized_query,
            fuzzy=fuzzy,
        )
        locality_match = self._locality_match(Profile, criteria.normalized_locality)
        statement = (
            select(
                literal("profile").label("result_type"),
                Profile.id.label("id"),
                Profile.id.label("profile_id"),
                Profile.public_name.label("title"),
                SkilledWorkerProfile.skill_mastery.label("subtitle"),
                skill.name.label("category"),
                SkilledWorkerProfile.bio.label("description"),
                Profile.locality.label("locality"),
                SkilledWorkerProfile.experience_years.label("experience_years"),
                Profile.is_verified.label("is_verified"),
                Profile.photo_count.label("photo_count"),
                Profile.last_activity_at.label("last_activity_at"),
                relevance.label("relevance"),
                locality_match.label("locality_match"),
                Profile.ranking_score.label("ranking_score"),
                Profile.created_at.label("created_at"),
            )
            .join(SkilledWorkerProfile, SkilledWorkerProfile.profile_id == Profile.id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .outerjoin(
                skill, skill.id == SkilledWorkerProfile.primary_skill_category_id
            )
            .where(
                *self._public_profile_conditions(Profile, User, "skilled_worker"),
                match_condition,
            )
        )
        if criteria.category_id is not None:
            statement = statement.where(
                or_(
                    select(SkilledWorkerProfileSkill.id)
                    .where(
                        SkilledWorkerProfileSkill.profile_id == Profile.id,
                        SkilledWorkerProfileSkill.skill_category_id
                        == criteria.category_id,
                    )
                    .exists(),
                    SkilledWorkerProfile.primary_skill_category_id
                    == criteria.category_id,
                )
            )
        statement = self._common_filters(
            statement,
            criteria=criteria,
            profile=Profile,
            experience=SkilledWorkerProfile.experience_years,
        )
        return statement.order_by(
            *self._sort_expressions(
                criteria.sort,
                relevance=relevance,
                verified=Profile.is_verified,
                locality_match=locality_match,
                photo_count=Profile.photo_count,
                ranking_score=Profile.ranking_score,
                activity_at=func.coalesce(Profile.last_activity_at, Profile.created_at),
                entity_id=Profile.id,
            )
        )

    @staticmethod
    def _public_profile_conditions(profile, user, role: str):
        return (
            profile.role == role,
            profile.visibility_status == "public",
            profile.completion_score == 100,
            profile.deleted_at.is_(None),
            or_(
                profile.owner_user_id.is_(None),
                and_(user.account_status == "active", user.deleted_at.is_(None)),
            ),
        )

    @staticmethod
    def _text_match(search_text, search_vector, query: str, *, fuzzy: bool):
        if not query:
            return literal(0.0, type_=Float), literal(True)
        safe_text = func.coalesce(search_text, "")
        if fuzzy:
            return func.similarity(safe_text, query), safe_text.op("%")(query)
        ts_query = func.plainto_tsquery("simple", query)
        phrase_match = func.lower(safe_text).like(f"%{query}%")
        vector_match = search_vector.op("@@")(ts_query)
        relevance = func.greatest(
            func.ts_rank_cd(search_vector, ts_query),
            case((phrase_match, 1.0), else_=0.0),
        )
        return relevance, or_(phrase_match, vector_match)

    @staticmethod
    def _locality_match(profile, normalized_locality: str | None):
        if not normalized_locality:
            return literal(0)
        return case(
            (profile.normalized_locality == normalized_locality, 1),
            else_=0,
        )

    @staticmethod
    def _common_filters(statement, *, criteria, profile, experience):
        if criteria.normalized_locality is not None:
            statement = statement.where(
                profile.normalized_locality == criteria.normalized_locality
            )
        if criteria.verified_only:
            statement = statement.where(profile.is_verified.is_(True))
        if criteria.min_experience_years is not None and experience is not None:
            statement = statement.where(experience >= criteria.min_experience_years)
        if criteria.max_experience_years is not None and experience is not None:
            statement = statement.where(experience <= criteria.max_experience_years)
        return statement

    @staticmethod
    def _sort_expressions(
        sort: SortMode,
        *,
        relevance,
        verified,
        locality_match,
        photo_count,
        ranking_score,
        activity_at,
        entity_id,
    ):
        verified_order = verified.desc()
        relevance_order = relevance.desc()
        ranking_order = ranking_score.desc()
        activity_order = activity_at.desc()
        id_order = entity_id.desc()
        if sort == "verified_first":
            return (
                verified_order,
                relevance_order,
                ranking_order,
                activity_order,
                id_order,
            )
        if sort == "nearby":
            return (
                locality_match.desc(),
                relevance_order,
                verified_order,
                ranking_order,
                activity_order,
                id_order,
            )
        if sort == "most_photos":
            return (
                photo_count.desc(),
                relevance_order,
                verified_order,
                activity_order,
                id_order,
            )
        if sort == "recent":
            return (
                activity_order,
                relevance_order,
                verified_order,
                ranking_order,
                id_order,
            )
        return (
            relevance_order,
            verified_order,
            ranking_order,
            activity_order,
            id_order,
        )

    def _product_types(self, rows) -> dict[tuple[str, UUID], list[str]]:
        result: dict[tuple[str, UUID], list[str]] = {}
        grouped: dict[str, set[UUID]] = {}
        for row in rows:
            grouped.setdefault(row["result_type"], set()).add(row["id"])
        query_specs: dict[str, tuple[Any, Any]] = {
            "work_card": (
                WorkCardProductType,
                WorkCardProductType.work_card_id,
            ),
            "work_needed_post": (
                WorkNeededPostProductType,
                WorkNeededPostProductType.work_needed_post_id,
            ),
            "profile": (
                BusinessProfileProductType,
                BusinessProfileProductType.profile_id,
            ),
        }
        for result_type, entity_ids in grouped.items():
            if result_type not in query_specs:
                continue
            model, entity_column = query_specs[result_type]
            product_rows = self.session.execute(
                select(
                    entity_column.label("entity_id"),
                    func.coalesce(
                        Category.name,
                        model.custom_product_type_text,
                    ).label("name"),
                )
                .outerjoin(Category, Category.id == model.product_type_category_id)
                .where(entity_column.in_(entity_ids))
                .order_by(entity_column, model.created_at, model.id)
            )
            for entity_id, name in product_rows:
                if name:
                    result.setdefault((result_type, entity_id), []).append(name)
        return result

    def _skills(self, rows) -> dict[tuple[str, UUID], list[str]]:
        profile_ids = {row["id"] for row in rows if row["result_type"] == "profile"}
        if not profile_ids:
            return {}
        skill_rows = self.session.execute(
            select(
                SkilledWorkerProfileSkill.profile_id,
                func.coalesce(
                    Category.name,
                    SkilledWorkerProfileSkill.custom_skill_text,
                ).label("name"),
            )
            .outerjoin(
                Category,
                Category.id == SkilledWorkerProfileSkill.skill_category_id,
            )
            .where(SkilledWorkerProfileSkill.profile_id.in_(profile_ids))
            .order_by(
                SkilledWorkerProfileSkill.profile_id,
                SkilledWorkerProfileSkill.sort_order,
                SkilledWorkerProfileSkill.id,
            )
        )
        result: dict[tuple[str, UUID], list[str]] = {}
        for profile_id, name in skill_rows:
            if name:
                result.setdefault(("profile", profile_id), []).append(name)
        return result

    def _photos(self, rows) -> dict[tuple[str, UUID], list[MediaAssetResponse]]:
        grouped: dict[str, set[UUID]] = {}
        for row in rows:
            grouped.setdefault(row["result_type"], set()).add(row["id"])
        result: dict[tuple[str, UUID], list[MediaAssetResponse]] = {}
        for result_type, entity_ids in grouped.items():
            media_rows = self.session.scalars(
                select(MediaAsset)
                .where(
                    MediaAsset.entity_type == result_type,
                    MediaAsset.entity_id.in_(entity_ids),
                    MediaAsset.media_kind == "image",
                    MediaAsset.visibility == "public",
                    MediaAsset.upload_status == "ready",
                    MediaAsset.deleted_at.is_(None),
                )
                .order_by(
                    MediaAsset.entity_id,
                    MediaAsset.sort_order,
                    MediaAsset.created_at,
                )
            )
            for media in media_rows:
                result.setdefault((result_type, media.entity_id), []).append(
                    MediaAssetResponse(
                        id=media.id,
                        media_kind=cast(MediaKind, media.media_kind),
                        visibility=cast(MediaVisibility, media.visibility),
                        upload_status=media.upload_status,
                        url=(
                            self.public_media_url(media.original_path)
                            if self.public_media_url
                            else None
                        ),
                        thumbnail_url=(
                            self.public_media_url(media.thumbnail_path)
                            if self.public_media_url and media.thumbnail_path
                            else None
                        ),
                        sort_order=media.sort_order,
                        document_type=media.document_type,
                        safe_display_name=PurePosixPath(media.original_path).name,
                    )
                )
        return result
