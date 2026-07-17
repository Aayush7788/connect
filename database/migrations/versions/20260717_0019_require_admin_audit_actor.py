"""Require an actor for every admin audit record.

Revision ID: 20260717_0019
Revises: 20260716_0018
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "20260717_0019"
down_revision: str | None = "20260716_0018"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.alter_column(
        "admin_audit_logs",
        "actor_admin_user_id",
        existing_type=sa.UUID(),
        nullable=False,
    )


def downgrade() -> None:
    op.alter_column(
        "admin_audit_logs",
        "actor_admin_user_id",
        existing_type=sa.UUID(),
        nullable=True,
    )
