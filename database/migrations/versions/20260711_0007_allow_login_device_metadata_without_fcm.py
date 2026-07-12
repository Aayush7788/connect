"""allow login device metadata without fcm

Revision ID: 20260711_0007
Revises: 20260711_0006
Create Date: 2026-07-12 10:45:00.000000
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "20260711_0007"
down_revision: str | None = "20260711_0006"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.drop_index("uq_user_devices_active_fcm_token", table_name="user_devices")
    op.alter_column(
        "user_devices",
        "fcm_token",
        existing_type=sa.Text(),
        nullable=True,
    )
    op.create_index(
        "uq_user_devices_active_fcm_token",
        "user_devices",
        ["fcm_token"],
        unique=True,
        postgresql_where=sa.text("fcm_token is not null and status = 'active'"),
    )


def downgrade() -> None:
    op.drop_index(
        "uq_user_devices_active_fcm_token",
        table_name="user_devices",
        postgresql_where=sa.text("fcm_token is not null and status = 'active'"),
    )
    op.alter_column(
        "user_devices",
        "fcm_token",
        existing_type=sa.Text(),
        nullable=False,
    )
    op.create_index(
        "uq_user_devices_active_fcm_token",
        "user_devices",
        ["fcm_token"],
        unique=True,
        postgresql_where=sa.text("status = 'active'"),
    )
