"""seed business categories

Revision ID: 20260712_0009
Revises: 20260712_0008
Create Date: 2026-07-12 19:30:00.000000
"""

from collections.abc import Sequence

from alembic import op


revision: str = "20260712_0009"
down_revision: str | None = "20260712_0008"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute(
        """
        insert into categories (
          category_type,
          parent_id,
          name,
          slug,
          normalized_name,
          sort_order,
          metadata
        )
        values
          ('business_category', null, 'Manufacturing', 'manufacturing', 'manufacturing', 10, '{}'::jsonb),
          ('business_category', null, 'Wholesale', 'wholesale', 'wholesale', 20, '{}'::jsonb),
          ('business_category', null, 'Trading', 'trading', 'trading', 30, '{}'::jsonb),
          ('business_category', null, 'Retail', 'retail', 'retail', 40, '{}'::jsonb),
          ('business_category', null, 'Process house', 'process-house', 'process house', 50, '{}'::jsonb),
          ('business_category', null, 'Textile brand', 'textile-brand', 'textile brand', 60, '{}'::jsonb),
          ('business_category', null, 'Other textile business', 'other-textile-business', 'other textile business', 70, '{}'::jsonb)
        on conflict (category_type, slug) do nothing
        """
    )


def downgrade() -> None:
    op.execute(
        """
        delete from categories
        where category_type = 'business_category'
          and slug in (
            'manufacturing',
            'wholesale',
            'trading',
            'retail',
            'process-house',
            'textile-brand',
            'other-textile-business'
          )
        """
    )
