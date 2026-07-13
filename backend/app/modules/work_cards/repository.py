from dataclasses import dataclass
from pathlib import PurePosixPath
from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import MediaAsset
from app.db.models.identity import User
from app.db.models.marketplace import WorkCard, WorkCardProductType
from app.db.models.profile import Profile
from app.db.models.taxonomy import Category, CategoryAlias, CategorySuggestion


@dataclass
class OwnerWorkCardContext:
    user: User
    profile: Profile


@dataclass
class WorkCardBundle:
    context: OwnerWorkCardContext
    card: WorkCard
    product_types: list[WorkCardProductType]
    media: list[MediaAsset]
    categories: dict[UUID, Category]


class WorkCardRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def get_owner_context(
        self,
        user_id: UUID,
        *,
        for_update: bool = False,
    ) -> OwnerWorkCardContext | None:
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
        return OwnerWorkCardContext(user=user, profile=profile)

    def list_owned_bundles(self, user_id: UUID) -> list[WorkCardBundle]:
        context = self.get_owner_context(user_id)
        if context is None:
            return []
        cards = list(
            self.session.scalars(
                select(WorkCard)
                .where(
                    WorkCard.profile_id == context.profile.id,
                    WorkCard.status != "deleted",
                    WorkCard.deleted_at.is_(None),
                )
                .order_by(WorkCard.updated_at.desc(), WorkCard.created_at.desc())
            )
        )
        return self._hydrate(context, cards)

    def get_owned_bundle(
        self,
        *,
        user_id: UUID,
        work_card_id: UUID,
        for_update: bool = False,
        include_deleted: bool = False,
    ) -> WorkCardBundle | None:
        context = self.get_owner_context(user_id, for_update=for_update)
        if context is None:
            return None
        statement = select(WorkCard).where(
            WorkCard.id == work_card_id,
            WorkCard.profile_id == context.profile.id,
        )
        if not include_deleted:
            statement = statement.where(
                WorkCard.status != "deleted",
                WorkCard.deleted_at.is_(None),
            )
        if for_update:
            statement = statement.with_for_update()
        card = self.session.scalar(statement)
        if card is None:
            return None
        return self._hydrate(context, [card])[0]

    def get_by_creation_key(
        self,
        *,
        profile_id: UUID,
        idempotency_key: str,
    ) -> WorkCard | None:
        return self.session.scalar(
            select(WorkCard).where(
                WorkCard.profile_id == profile_id,
                WorkCard.creation_idempotency_key == idempotency_key,
            )
        )

    def hydrate_card(
        self,
        *,
        context: OwnerWorkCardContext,
        card: WorkCard,
    ) -> WorkCardBundle:
        return self._hydrate(context, [card])[0]

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
        work_card_id: UUID,
        category_ids: list[UUID],
        custom_values: list[str],
    ) -> None:
        self.session.execute(
            delete(WorkCardProductType).where(
                WorkCardProductType.work_card_id == work_card_id
            )
        )
        self.session.add_all(
            [
                WorkCardProductType(
                    work_card_id=work_card_id,
                    product_type_category_id=category_id,
                )
                for category_id in dict.fromkeys(category_ids)
            ]
            + [
                WorkCardProductType(
                    work_card_id=work_card_id,
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
        work_card_id: UUID,
        suggestions: dict[str, list[tuple[str, str]]],
    ) -> None:
        self.session.execute(
            delete(CategorySuggestion).where(
                CategorySuggestion.source_entity_type == "work_card",
                CategorySuggestion.source_entity_id == work_card_id,
                CategorySuggestion.status == "pending",
            )
        )
        rows: list[CategorySuggestion] = []
        for category_type, values in suggestions.items():
            rows.extend(
                CategorySuggestion(
                    submitted_by_user_id=user_id,
                    profile_id=profile_id,
                    source_entity_type="work_card",
                    source_entity_id=work_card_id,
                    category_type=category_type,
                    raw_text=raw_text,
                    normalized_text=normalized_text,
                    status="pending",
                )
                for raw_text, normalized_text in values
            )
        self.session.add_all(rows)

    def ready_public_photo_count(self, work_card_id: UUID) -> int:
        return int(
            self.session.scalar(
                select(func.count(MediaAsset.id)).where(
                    MediaAsset.entity_type == "work_card",
                    MediaAsset.entity_id == work_card_id,
                    MediaAsset.media_kind == "image",
                    MediaAsset.document_type == "work_photo",
                    MediaAsset.visibility == "public",
                    MediaAsset.upload_status == "ready",
                    MediaAsset.deleted_at.is_(None),
                )
            )
            or 0
        )

    def set_search_vector(self, card: WorkCard, search_text: str) -> None:
        card.search_vector = func.to_tsvector("simple", search_text)

    def add(self, card: WorkCard) -> None:
        self.session.add(card)

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
        context: OwnerWorkCardContext,
        cards: list[WorkCard],
    ) -> list[WorkCardBundle]:
        if not cards:
            return []
        card_ids = {card.id for card in cards}
        product_types = list(
            self.session.scalars(
                select(WorkCardProductType)
                .where(WorkCardProductType.work_card_id.in_(card_ids))
                .order_by(WorkCardProductType.created_at, WorkCardProductType.id)
            )
        )
        media = list(
            self.session.scalars(
                select(MediaAsset)
                .where(
                    MediaAsset.entity_type == "work_card",
                    MediaAsset.entity_id.in_(card_ids),
                    MediaAsset.media_kind == "image",
                    MediaAsset.visibility == "public",
                    MediaAsset.deleted_at.is_(None),
                )
                .order_by(MediaAsset.sort_order, MediaAsset.created_at)
            )
        )
        category_ids = {
            category_id
            for card in cards
            for category_id in (card.work_category_id, card.work_name_category_id)
            if category_id is not None
        }
        category_ids.update(
            product.product_type_category_id
            for product in product_types
            if product.product_type_category_id is not None
        )
        categories = self.get_categories(category_ids)
        products_by_card: dict[UUID, list[WorkCardProductType]] = {
            card_id: [] for card_id in card_ids
        }
        for product in product_types:
            products_by_card[product.work_card_id].append(product)
        media_by_card: dict[UUID, list[MediaAsset]] = {
            card_id: [] for card_id in card_ids
        }
        for asset in media:
            media_by_card[asset.entity_id].append(asset)
        return [
            WorkCardBundle(
                context=context,
                card=card,
                product_types=products_by_card[card.id],
                media=media_by_card[card.id],
                categories=categories,
            )
            for card in cards
        ]
