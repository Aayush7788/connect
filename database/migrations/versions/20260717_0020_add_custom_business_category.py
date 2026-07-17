"""Add custom business category text.

Revision ID: 20260717_0020
Revises: 20260717_0019
Create Date: 2026-07-17
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = "20260717_0020"
down_revision: str | None = "20260717_0019"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "business_profiles",
        sa.Column("custom_business_category", sa.Text(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("business_profiles", "custom_business_category")
