from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import cast
from uuid import UUID

from sqlalchemy import delete, func, or_, select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import MediaAsset
from app.db.models.identity import User
from app.db.models.marketplace import WorkCard, WorkCardProductType
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
            select(User, Profile)
            .join(Profile, Profile.owner_user_id == User.id)
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
        user, profile = row
        role_profile = self._get_role_profile(profile)
        if role_profile is None:
            return None
        product_types = self.list_business_product_types(profile.id)
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

    def _get_role_profile(
        self,
        profile: Profile,
    ) -> BusinessProfile | JobWorkerProfile | SkilledWorkerProfile | None:
        model = {
            "business": BusinessProfile,
            "job_worker": JobWorkerProfile,
            "skilled_worker": SkilledWorkerProfile,
        }[profile.role]
        return cast(
            BusinessProfile | JobWorkerProfile | SkilledWorkerProfile | None,
            self.session.get(model, profile.id),
        )

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
