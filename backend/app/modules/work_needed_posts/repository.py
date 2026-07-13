from dataclasses import dataclass
from pathlib import PurePosixPath
from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import MediaAsset
from app.db.models.identity import User
from app.db.models.marketplace import WorkNeededPost, WorkNeededPostProductType
from app.db.models.profile import Profile
from app.db.models.taxonomy import Category, CategoryAlias, CategorySuggestion


@dataclass
class OwnerWorkNeededContext:
    user: User
    profile: Profile


@dataclass
class WorkNeededPostBundle:
    context: OwnerWorkNeededContext
    post: WorkNeededPost
    product_types: list[WorkNeededPostProductType]
    media: list[MediaAsset]
    categories: dict[UUID, Category]


class WorkNeededPostRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def get_owner_context(
        self,
        user_id: UUID,
        *,
        for_update: bool = False,
    ) -> OwnerWorkNeededContext | None:
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
        return OwnerWorkNeededContext(user=user, profile=profile)

    def list_owned_bundles(self, user_id: UUID) -> list[WorkNeededPostBundle]:
        context = self.get_owner_context(user_id)
        if context is None:
            return []
        posts = list(
            self.session.scalars(
                select(WorkNeededPost)
                .where(
                    WorkNeededPost.profile_id == context.profile.id,
                    WorkNeededPost.status != "deleted",
                    WorkNeededPost.deleted_at.is_(None),
                )
                .order_by(
                    WorkNeededPost.updated_at.desc(),
                    WorkNeededPost.created_at.desc(),
                )
            )
        )
        return self._hydrate(context, posts)

    def get_owned_bundle(
        self,
        *,
        user_id: UUID,
        post_id: UUID,
        for_update: bool = False,
        include_deleted: bool = False,
    ) -> WorkNeededPostBundle | None:
        context = self.get_owner_context(user_id, for_update=for_update)
        if context is None:
            return None
        statement = select(WorkNeededPost).where(
            WorkNeededPost.id == post_id,
            WorkNeededPost.profile_id == context.profile.id,
        )
        if not include_deleted:
            statement = statement.where(
                WorkNeededPost.status != "deleted",
                WorkNeededPost.deleted_at.is_(None),
            )
        if for_update:
            statement = statement.with_for_update()
        post = self.session.scalar(statement)
        if post is None:
            return None
        return self._hydrate(context, [post])[0]

    def get_by_creation_key(
        self,
        *,
        profile_id: UUID,
        idempotency_key: str,
    ) -> WorkNeededPost | None:
        return self.session.scalar(
            select(WorkNeededPost).where(
                WorkNeededPost.profile_id == profile_id,
                WorkNeededPost.creation_idempotency_key == idempotency_key,
            )
        )

    def hydrate_post(
        self,
        *,
        context: OwnerWorkNeededContext,
        post: WorkNeededPost,
    ) -> WorkNeededPostBundle:
        return self._hydrate(context, [post])[0]

    def get_active_categories(self, category_ids: set[UUID]) -> dict[UUID, Category]:
        if not category_ids:
            return {}
        return {
            category.id: category
            for category in self.session.scalars(
                select(Category).where(
                    Category.id.in_(category_ids),
                    Category.is_active.is_(True),
                )
            )
        }

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

    def replace_product_types(
        self,
        *,
        post_id: UUID,
        category_ids: list[UUID],
        custom_values: list[str],
    ) -> None:
        self.session.execute(
            delete(WorkNeededPostProductType).where(
                WorkNeededPostProductType.work_needed_post_id == post_id
            )
        )
        self.session.add_all(
            [
                WorkNeededPostProductType(
                    work_needed_post_id=post_id,
                    product_type_category_id=category_id,
                )
                for category_id in dict.fromkeys(category_ids)
            ]
            + [
                WorkNeededPostProductType(
                    work_needed_post_id=post_id,
                    custom_product_type_text=value,
                )
                for value in custom_values
            ]
        )

    def sync_pending_suggestions(
        self,
        *,
        user_id: UUID,
        profile_id: UUID,
        post_id: UUID,
        suggestions: dict[str, list[tuple[str, str]]],
    ) -> None:
        self.session.execute(
            delete(CategorySuggestion).where(
                CategorySuggestion.source_entity_type == "work_needed_post",
                CategorySuggestion.source_entity_id == post_id,
                CategorySuggestion.status == "pending",
            )
        )
        rows: list[CategorySuggestion] = []
        for category_type, values in suggestions.items():
            rows.extend(
                CategorySuggestion(
                    submitted_by_user_id=user_id,
                    profile_id=profile_id,
                    source_entity_type="work_needed_post",
                    source_entity_id=post_id,
                    category_type=category_type,
                    raw_text=raw_text,
                    normalized_text=normalized_text,
                    status="pending",
                )
                for raw_text, normalized_text in values
            )
        self.session.add_all(rows)

    def ready_public_photo_count(self, post_id: UUID) -> int:
        return int(
            self.session.scalar(
                select(func.count(MediaAsset.id)).where(
                    MediaAsset.entity_type == "work_needed_post",
                    MediaAsset.entity_id == post_id,
                    MediaAsset.media_kind == "image",
                    MediaAsset.document_type == "work_photo",
                    MediaAsset.visibility == "public",
                    MediaAsset.upload_status == "ready",
                    MediaAsset.deleted_at.is_(None),
                )
            )
            or 0
        )

    def set_search_vector(self, post: WorkNeededPost, search_text: str) -> None:
        post.search_vector = func.to_tsvector("simple", search_text)

    def add(self, post: WorkNeededPost) -> None:
        self.session.add(post)

    def flush(self) -> None:
        self.session.flush()

    def commit(self) -> None:
        self.session.commit()

    def rollback(self) -> None:
        self.session.rollback()

    @staticmethod
    def safe_media_name(media: MediaAsset) -> str:
        return PurePosixPath(media.original_path).name

    def _hydrate(
        self,
        context: OwnerWorkNeededContext,
        posts: list[WorkNeededPost],
    ) -> list[WorkNeededPostBundle]:
        if not posts:
            return []
        post_ids = {post.id for post in posts}
        product_types = list(
            self.session.scalars(
                select(WorkNeededPostProductType)
                .where(
                    WorkNeededPostProductType.work_needed_post_id.in_(post_ids)
                )
                .order_by(
                    WorkNeededPostProductType.created_at,
                    WorkNeededPostProductType.id,
                )
            )
        )
        media = list(
            self.session.scalars(
                select(MediaAsset)
                .where(
                    MediaAsset.entity_type == "work_needed_post",
                    MediaAsset.entity_id.in_(post_ids),
                    MediaAsset.media_kind == "image",
                    MediaAsset.visibility == "public",
                    MediaAsset.deleted_at.is_(None),
                )
                .order_by(MediaAsset.sort_order, MediaAsset.created_at)
            )
        )
        category_ids = {
            category_id
            for post in posts
            for category_id in (post.work_category_id, post.work_name_category_id)
            if category_id is not None
        }
        category_ids.update(
            product.product_type_category_id
            for product in product_types
            if product.product_type_category_id is not None
        )
        categories = self.get_categories(category_ids)
        products_by_post: dict[UUID, list[WorkNeededPostProductType]] = {
            post_id: [] for post_id in post_ids
        }
        for product in product_types:
            products_by_post[product.work_needed_post_id].append(product)
        media_by_post: dict[UUID, list[MediaAsset]] = {
            post_id: [] for post_id in post_ids
        }
        for asset in media:
            media_by_post[asset.entity_id].append(asset)
        return [
            WorkNeededPostBundle(
                context=context,
                post=post,
                product_types=products_by_post[post.id],
                media=media_by_post[post.id],
                categories=categories,
            )
            for post in posts
        ]
