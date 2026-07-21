"""Deactivate removed business-category options.

Revision ID: 20260721_0023
Revises: 20260720_0022
Create Date: 2026-07-21
"""

from collections.abc import Sequence

from alembic import op


revision: str = "20260721_0023"
down_revision: str | None = "20260720_0022"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute(
        """
        update categories
        set is_active = false,
            updated_at = now()
        where category_type = 'business_category'
          and slug in ('process-house', 'textile-brand')
        """
    )


def downgrade() -> None:
    op.execute(
        """
        update categories
        set is_active = true,
            updated_at = now()
        where category_type = 'business_category'
          and slug in ('process-house', 'textile-brand')
        """
    )
