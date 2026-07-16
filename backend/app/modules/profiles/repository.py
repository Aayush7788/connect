from dataclasses import dataclass
from pathlib import PurePosixPath
from uuid import UUID

from sqlalchemy import and_, delete, func, or_, select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.orm import Session, aliased

from app.db.models.cross_cutting import ContactReveal, MediaAsset
from app.db.models.identity import User
from app.db.models.marketplace import WorkCard, WorkCardProductType
from app.db.models.marketplace import WorkNeededPost, WorkNeededPostProductType
from app.db.models.profile import BusinessProfile, BusinessProfileProductType
from app.db.models.profile import JobWorkerProfile, Profile, ProfileChangeHistory
from app.db.models.profile import SkilledWorkerProfile
from app.db.models.taxonomy import Category, CategoryAlias, CategorySuggestion


@dataclass
class CompletionEvidence:
    public_photo_count: int
    required_profile_photo_count: int
    business_product_type_count: int
    published_valid_work_card_count: int


@dataclass
class OwnerProfileBundle:
    user: User
    profile: Profile
    role_profile: BusinessProfile | JobWorkerProfile | SkilledWorkerProfile
    product_types: list[BusinessProfileProductType]
    media: list[MediaAsset]


@dataclass
class PublicWorkCardBundle:
    card: WorkCard
    product_types: list[WorkCardProductType]
    media: list[MediaAsset]
    categories: dict[UUID, Category]


@dataclass
class PublicWorkNeededPostBundle:
    post: WorkNeededPost
    product_types: list[WorkNeededPostProductType]
    media: list[MediaAsset]
    categories: dict[UUID, Category]


@dataclass
class PublicProfileBundle:
    user: User | None
    profile: Profile
    role_profile: BusinessProfile | JobWorkerProfile | SkilledWorkerProfile
    product_types: list[BusinessProfileProductType]
    media: list[MediaAsset]
    categories: dict[UUID, Category]
    work_cards: list[PublicWorkCardBundle]
    work_needed_posts: list[PublicWorkNeededPostBundle]


class ProfileRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def get_owner_bundle(
        self,
        user_id: UUID,
        *,
        for_update: bool = False,
    ) -> OwnerProfileBundle | None:
        statement = (
            select(
                User,
                Profile,
                BusinessProfile,
                JobWorkerProfile,
                SkilledWorkerProfile,
            )
            .join(Profile, Profile.owner_user_id == User.id)
            .outerjoin(BusinessProfile, BusinessProfile.profile_id == Profile.id)
            .outerjoin(JobWorkerProfile, JobWorkerProfile.profile_id == Profile.id)
            .outerjoin(
                SkilledWorkerProfile,
                SkilledWorkerProfile.profile_id == Profile.id,
            )
            .where(
                User.id == user_id,
                User.deleted_at.is_(None),
                Profile.deleted_at.is_(None),
            )
        )
        if for_update:
            statement = statement.with_for_update(of=(User, Profile))
        row = self.session.execute(statement).one_or_none()
        if row is None:
            return None
        user, profile, business, job_worker, skilled_worker = row
        role_profile = self._joined_role_profile(
            profile,
            business=business,
            job_worker=job_worker,
            skilled_worker=skilled_worker,
        )
        if role_profile is None:
            return None
        product_types = (
            self.list_business_product_types(profile.id)
            if profile.role == "business"
            else []
        )
        media = list(
            self.session.scalars(
                select(MediaAsset)
                .where(
                    MediaAsset.entity_type == "profile",
                    MediaAsset.entity_id == profile.id,
                    MediaAsset.visibility == "public",
                    MediaAsset.deleted_at.is_(None),
                )
                .order_by(MediaAsset.sort_order, MediaAsset.created_at)
            )
        )
        return OwnerProfileBundle(
            user=user,
            profile=profile,
            role_profile=role_profile,
            product_types=product_types,
            media=media,
        )

    def get_bundle_by_profile_id(
        self,
        profile_id: UUID,
        *,
        for_update: bool = False,
    ) -> OwnerProfileBundle | None:
        owner_user_id = self.session.scalar(
            select(Profile.owner_user_id).where(
                Profile.id == profile_id,
                Profile.deleted_at.is_(None),
            )
        )
        if owner_user_id is None:
            return None
        return self.get_owner_bundle(owner_user_id, for_update=for_update)

    def get_public_bundle(self, profile_id: UUID) -> PublicProfileBundle | None:
        row = self.session.execute(
            select(
                Profile,
                User,
                BusinessProfile,
                JobWorkerProfile,
                SkilledWorkerProfile,
            )
            .outerjoin(User, User.id == Profile.owner_user_id)
            .outerjoin(BusinessProfile, BusinessProfile.profile_id == Profile.id)
            .outerjoin(JobWorkerProfile, JobWorkerProfile.profile_id == Profile.id)
            .outerjoin(
                SkilledWorkerProfile,
                SkilledWorkerProfile.profile_id == Profile.id,
            )
            .where(
                Profile.id == profile_id,
                Profile.deleted_at.is_(None),
                Profile.visibility_status.in_(("public", "hidden_by_user")),
                or_(
                    Profile.owner_user_id.is_(None),
                    and_(
                        User.account_status == "active",
                        User.deleted_at.is_(None),
                    ),
                ),
            )
        ).one_or_none()
        if row is None:
            return None
        profile, user, business, job_worker, skilled_worker = row
        role_profile = self._joined_role_profile(
            profile,
            business=business,
            job_worker=job_worker,
            skilled_worker=skilled_worker,
        )
        if role_profile is None:
            return None
        profile_media, related_media = self._public_profile_media(profile)
        product_types = (
            self.list_business_product_types(profile.id)
            if profile.role == "business"
            else []
        )
        category_ids = {
            item.product_type_category_id
            for item in product_types
            if item.product_type_category_id is not None
        }
        if profile.role == "business" and role_profile.business_category_id:
            category_ids.add(role_profile.business_category_id)
        if profile.role == "skilled_worker" and role_profile.primary_skill_category_id:
            category_ids.add(role_profile.primary_skill_category_id)
        return PublicProfileBundle(
            user=user,
            profile=profile,
            role_profile=role_profile,
            product_types=product_types,
            media=profile_media,
            categories=self.get_categories(category_ids),
            work_cards=(
                self._public_work_cards(profile.id, media=related_media)
                if profile.role == "job_worker"
                else []
            ),
            work_needed_posts=(
                self._public_work_needed_posts(profile.id, media=related_media)
                if profile.role == "business"
                else []
            ),
        )

    def record_contact_reveal(
        self,
        *,
        viewer_user_id: UUID,
        profile_id: UUID,
        source_type: str | None,
        source_id: UUID | None,
        ip_address: str | None,
        device_id: str | None,
        user_agent: str | None,
    ) -> None:
        statement = pg_insert(ContactReveal).values(
            viewer_user_id=viewer_user_id,
            revealed_profile_id=profile_id,
            source_type=source_type,
            source_id=source_id,
            reveal_mode="free_unlimited",
            ip_address=ip_address,
            device_id=device_id,
            user_agent=user_agent,
        )
        self.session.execute(
            statement.on_conflict_do_update(
                index_elements=[
                    ContactReveal.viewer_user_id,
                    ContactReveal.revealed_profile_id,
                ],
                set_={
                    "last_revealed_at": func.now(),
                    "reveal_count": ContactReveal.reveal_count + 1,
                    "source_type": statement.excluded.source_type,
                    "source_id": statement.excluded.source_id,
                    "ip_address": statement.excluded.ip_address,
                    "device_id": statement.excluded.device_id,
                    "user_agent": statement.excluded.user_agent,
                },
            )
        )

    @staticmethod
    def _joined_role_profile(
        profile: Profile,
        *,
        business: BusinessProfile | None,
        job_worker: JobWorkerProfile | None,
        skilled_worker: SkilledWorkerProfile | None,
    ) -> BusinessProfile | JobWorkerProfile | SkilledWorkerProfile | None:
        return {
            "business": business,
            "job_worker": job_worker,
            "skilled_worker": skilled_worker,
        }[profile.role]

    def list_business_product_types(
        self,
        profile_id: UUID,
    ) -> list[BusinessProfileProductType]:
        return list(
            self.session.scalars(
                select(BusinessProfileProductType)
                .where(BusinessProfileProductType.profile_id == profile_id)
                .order_by(BusinessProfileProductType.created_at)
            )
        )

    def replace_business_product_types(
        self,
        *,
        profile_id: UUID,
        category_ids: list[UUID],
        custom_values: list[str],
    ) -> None:
        self.session.execute(
            delete(BusinessProfileProductType).where(
                BusinessProfileProductType.profile_id == profile_id
            )
        )
        self.session.add_all(
            [
                BusinessProfileProductType(
                    profile_id=profile_id,
                    product_type_category_id=category_id,
                )
                for category_id in dict.fromkeys(category_ids)
            ]
            + [
                BusinessProfileProductType(
                    profile_id=profile_id,
                    custom_product_type_text=value,
                )
                for value in custom_values
            ]
        )

    def create_product_type_suggestions(
        self,
        *,
        user_id: UUID,
        profile_id: UUID,
        values: list[str],
    ) -> None:
        normalized_values = {value.casefold(): value for value in values}
        if not normalized_values:
            return
        existing = set(
            self.session.scalars(
                select(CategorySuggestion.normalized_text).where(
                    CategorySuggestion.profile_id == profile_id,
                    CategorySuggestion.source_entity_type == "profile",
                    CategorySuggestion.category_type == "product_type",
                    CategorySuggestion.normalized_text.in_(set(normalized_values)),
                    CategorySuggestion.status == "pending",
                )
            )
        )
        self.session.add_all(
            [
                CategorySuggestion(
                    submitted_by_user_id=user_id,
                    profile_id=profile_id,
                    source_entity_type="profile",
                    source_entity_id=profile_id,
                    category_type="product_type",
                    raw_text=raw_text,
                    normalized_text=normalized_text,
                    status="pending",
                )
                for normalized_text, raw_text in normalized_values.items()
                if normalized_text not in existing
            ]
        )

    def category_ids_are_valid(
        self,
        category_ids: set[UUID],
        *,
        allowed_types: set[str],
    ) -> bool:
        if not category_ids:
            return True
        count = self.session.scalar(
            select(func.count(Category.id)).where(
                Category.id.in_(category_ids),
                Category.category_type.in_(allowed_types),
                Category.is_active.is_(True),
            )
        )
        return int(count or 0) == len(category_ids)

    def get_categories(self, category_ids: set[UUID]) -> dict[UUID, Category]:
        if not category_ids:
            return {}
        return {
            category.id: category
            for category in self.session.scalars(
                select(Category).where(Category.id.in_(category_ids))
            )
        }

    def category_aliases(self, category_ids: set[UUID]) -> list[str]:
        if not category_ids:
            return []
        return list(
            self.session.scalars(
                select(CategoryAlias.normalized_alias).where(
                    CategoryAlias.category_id.in_(category_ids),
                    CategoryAlias.is_active.is_(True),
                )
            )
        )

    def set_search_vector(self, profile: Profile, search_text: str) -> None:
        profile.search_vector = func.to_tsvector("simple", search_text)

    def _public_work_cards(
        self,
        profile_id: UUID,
        *,
        media: dict[UUID, list[MediaAsset]],
    ) -> list[PublicWorkCardBundle]:
        selected_ids = (
            select(WorkCard.id)
            .where(
                WorkCard.profile_id == profile_id,
                WorkCard.status == "published",
                WorkCard.deleted_at.is_(None),
            )
            .order_by(WorkCard.ranking_score.desc(), WorkCard.updated_at.desc())
            .limit(50)
            .subquery()
        )
        work_category = aliased(Category)
        work_name = aliased(Category)
        product_category = aliased(Category)
        rows = self.session.execute(
            select(
                WorkCard,
                WorkCardProductType,
                work_category,
                work_name,
                product_category,
            )
            .join(selected_ids, selected_ids.c.id == WorkCard.id)
            .outerjoin(
                WorkCardProductType,
                WorkCardProductType.work_card_id == WorkCard.id,
            )
            .outerjoin(work_category, work_category.id == WorkCard.work_category_id)
            .outerjoin(work_name, work_name.id == WorkCard.work_name_category_id)
            .outerjoin(
                product_category,
                product_category.id
                == WorkCardProductType.product_type_category_id,
            )
            .order_by(
                WorkCard.ranking_score.desc(),
                WorkCard.updated_at.desc(),
                WorkCardProductType.created_at,
            )
        ).all()
        if not rows:
            return []
        cards: dict[UUID, WorkCard] = {}
        products_by_card: dict[UUID, list[WorkCardProductType]] = {}
        categories: dict[UUID, Category] = {}
        for card, product, category, name, product_type in rows:
            cards.setdefault(card.id, card)
            if product is not None:
                products_by_card.setdefault(card.id, []).append(product)
            for value in (category, name, product_type):
                if value is not None:
                    categories[value.id] = value
        return [
            PublicWorkCardBundle(
                card=card,
                product_types=products_by_card.get(card.id, []),
                media=media.get(card.id, []),
                categories=categories,
            )
            for card in cards.values()
        ]

    def _public_work_needed_posts(
        self,
        profile_id: UUID,
        *,
        media: dict[UUID, list[MediaAsset]],
    ) -> list[PublicWorkNeededPostBundle]:
        selected_ids = (
            select(WorkNeededPost.id)
            .where(
                WorkNeededPost.profile_id == profile_id,
                WorkNeededPost.status == "active",
                WorkNeededPost.deleted_at.is_(None),
            )
            .order_by(
                WorkNeededPost.ranking_score.desc(),
                WorkNeededPost.updated_at.desc(),
            )
            .limit(50)
            .subquery()
        )
        work_category = aliased(Category)
        work_name = aliased(Category)
        product_category = aliased(Category)
        rows = self.session.execute(
            select(
                WorkNeededPost,
                WorkNeededPostProductType,
                work_category,
                work_name,
                product_category,
            )
            .join(selected_ids, selected_ids.c.id == WorkNeededPost.id)
            .outerjoin(
                WorkNeededPostProductType,
                WorkNeededPostProductType.work_needed_post_id
                == WorkNeededPost.id,
            )
            .outerjoin(
                work_category,
                work_category.id == WorkNeededPost.work_category_id,
            )
            .outerjoin(
                work_name,
                work_name.id == WorkNeededPost.work_name_category_id,
            )
            .outerjoin(
                product_category,
                product_category.id
                == WorkNeededPostProductType.product_type_category_id,
            )
            .order_by(
                WorkNeededPost.ranking_score.desc(),
                WorkNeededPost.updated_at.desc(),
                WorkNeededPostProductType.created_at,
            )
        ).all()
        if not rows:
            return []
        posts: dict[UUID, WorkNeededPost] = {}
        products_by_post: dict[UUID, list[WorkNeededPostProductType]] = {}
        categories: dict[UUID, Category] = {}
        for post, product, category, name, product_type in rows:
            posts.setdefault(post.id, post)
            if product is not None:
                products_by_post.setdefault(post.id, []).append(product)
            for value in (category, name, product_type):
                if value is not None:
                    categories[value.id] = value
        return [
            PublicWorkNeededPostBundle(
                post=post,
                product_types=products_by_post.get(post.id, []),
                media=media.get(post.id, []),
                categories=categories,
            )
            for post in posts.values()
        ]

    def _public_profile_media(
        self,
        profile: Profile,
    ) -> tuple[list[MediaAsset], dict[UUID, list[MediaAsset]]]:
        conditions = [
            and_(
                MediaAsset.entity_type == "profile",
                MediaAsset.entity_id == profile.id,
            )
        ]
        related_type: str | None = None
        if profile.role == "job_worker":
            related_type = "work_card"
            related_ids = (
                select(WorkCard.id)
                .where(
                    WorkCard.profile_id == profile.id,
                    WorkCard.status == "published",
                    WorkCard.deleted_at.is_(None),
                )
                .order_by(
                    WorkCard.ranking_score.desc(),
                    WorkCard.updated_at.desc(),
                )
                .limit(50)
            )
            conditions.append(
                and_(
                    MediaAsset.entity_type == related_type,
                    MediaAsset.entity_id.in_(related_ids),
                )
            )
        elif profile.role == "business":
            related_type = "work_needed_post"
            related_ids = (
                select(WorkNeededPost.id)
                .where(
                    WorkNeededPost.profile_id == profile.id,
                    WorkNeededPost.status == "active",
                    WorkNeededPost.deleted_at.is_(None),
                )
                .order_by(
                    WorkNeededPost.ranking_score.desc(),
                    WorkNeededPost.updated_at.desc(),
                )
                .limit(50)
            )
            conditions.append(
                and_(
                    MediaAsset.entity_type == related_type,
                    MediaAsset.entity_id.in_(related_ids),
                )
            )
        rows = self.session.scalars(
            select(MediaAsset)
            .where(
                or_(*conditions),
                MediaAsset.media_kind == "image",
                MediaAsset.visibility == "public",
                MediaAsset.upload_status == "ready",
                MediaAsset.deleted_at.is_(None),
            )
            .order_by(
                MediaAsset.entity_type,
                MediaAsset.entity_id,
                MediaAsset.sort_order,
                MediaAsset.created_at,
            )
        )
        profile_media: list[MediaAsset] = []
        related_media: dict[UUID, list[MediaAsset]] = {}
        for media_asset in rows:
            if media_asset.entity_type == "profile":
                profile_media.append(media_asset)
            elif media_asset.entity_type == related_type:
                related_media.setdefault(media_asset.entity_id, []).append(media_asset)
        return profile_media, related_media

    def _public_media(
        self, entity_type: str, entity_ids: list[UUID]
    ) -> dict[UUID, list[MediaAsset]]:
        if not entity_ids:
            return {}
        grouped: dict[UUID, list[MediaAsset]] = {}
        rows = self.session.scalars(
            select(MediaAsset)
            .where(
                MediaAsset.entity_type == entity_type,
                MediaAsset.entity_id.in_(entity_ids),
                MediaAsset.media_kind == "image",
                MediaAsset.visibility == "public",
                MediaAsset.upload_status == "ready",
                MediaAsset.deleted_at.is_(None),
            )
            .order_by(
                MediaAsset.entity_id, MediaAsset.sort_order, MediaAsset.created_at
            )
        )
        for media in rows:
            grouped.setdefault(media.entity_id, []).append(media)
        return grouped

    def completion_evidence(self, profile: Profile) -> CompletionEvidence:
        public_photo_count = int(
            self.session.scalar(
                select(func.count(MediaAsset.id)).where(
                    MediaAsset.entity_type == "profile",
                    MediaAsset.entity_id == profile.id,
                    MediaAsset.media_kind == "image",
                    MediaAsset.visibility == "public",
                    MediaAsset.upload_status == "ready",
                    MediaAsset.deleted_at.is_(None),
                )
            )
            or 0
        )
        required_document_type = {
            "business": "shop_photo",
            "job_worker": "workplace_photo",
        }.get(profile.role)
        required_profile_photo_count = 0
        if required_document_type is not None:
            required_profile_photo_count = int(
                self.session.scalar(
                    select(func.count(MediaAsset.id)).where(
                        MediaAsset.entity_type == "profile",
                        MediaAsset.entity_id == profile.id,
                        MediaAsset.media_kind == "image",
                        MediaAsset.document_type == required_document_type,
                        MediaAsset.visibility == "public",
                        MediaAsset.upload_status == "ready",
                        MediaAsset.deleted_at.is_(None),
                    )
                )
                or 0
            )
        business_product_type_count = 0
        if profile.role == "business":
            business_product_type_count = int(
                self.session.scalar(
                    select(func.count(BusinessProfileProductType.id)).where(
                        BusinessProfileProductType.profile_id == profile.id
                    )
                )
                or 0
            )
        published_valid_work_card_count = 0
        if profile.role == "job_worker":
            has_product_type = (
                select(WorkCardProductType.id)
                .where(WorkCardProductType.work_card_id == WorkCard.id)
                .exists()
            )
            published_valid_work_card_count = int(
                self.session.scalar(
                    select(func.count(WorkCard.id)).where(
                        WorkCard.profile_id == profile.id,
                        WorkCard.status == "published",
                        WorkCard.deleted_at.is_(None),
                        WorkCard.photo_count >= 3,
                        or_(
                            WorkCard.work_category_id.is_not(None),
                            func.nullif(
                                func.btrim(WorkCard.custom_work_category_text), ""
                            ).is_not(None),
                        ),
                        or_(
                            WorkCard.work_name_category_id.is_not(None),
                            func.nullif(
                                func.btrim(WorkCard.custom_work_name), ""
                            ).is_not(None),
                        ),
                        has_product_type,
                    )
                )
                or 0
            )
        return CompletionEvidence(
            public_photo_count=public_photo_count,
            required_profile_photo_count=required_profile_photo_count,
            business_product_type_count=business_product_type_count,
            published_valid_work_card_count=published_valid_work_card_count,
        )

    def add_change_history(
        self,
        *,
        profile_id: UUID,
        user_id: UUID,
        before: dict,
        after: dict,
        requires_reverification: bool,
    ) -> None:
        self.session.add(
            ProfileChangeHistory(
                profile_id=profile_id,
                changed_by_user_id=user_id,
                changed_fields={key: True for key in after},
                before_json=before,
                after_json=after,
                requires_reverification=requires_reverification,
            )
        )

    @staticmethod
    def safe_media_name(media: MediaAsset) -> str:
        return PurePosixPath(media.original_path).name

    def flush(self) -> None:
        self.session.flush()

    def commit(self) -> None:
        self.session.commit()

    def rollback(self) -> None:
        self.session.rollback()
