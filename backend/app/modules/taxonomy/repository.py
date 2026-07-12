from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.taxonomy import Category


class TaxonomyRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def list_categories(
        self,
        *,
        category_type: str,
        parent_id: UUID | None,
    ) -> list[Category]:
        statement = select(Category).where(
            Category.category_type == category_type,
            Category.is_active.is_(True),
        )
        if parent_id is not None:
            statement = statement.where(Category.parent_id == parent_id)
        return list(
            self.session.scalars(statement.order_by(Category.sort_order, Category.name))
        )
