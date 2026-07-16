"""Add locally enforceable user auth sessions.

Revision ID: 20260716_0015
Revises: 20260713_0014
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql


revision: str = "20260716_0015"
down_revision: str | None = "20260713_0014"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "user_auth_sessions",
        sa.Column("session_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("device_id", sa.Text(), nullable=True),
        sa.Column("status", sa.Text(), server_default="active", nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column(
            "last_seen_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "status in ('active', 'revoked')",
            name=op.f("ck_user_auth_sessions_status_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_user_auth_sessions_user_id_users"),
        ),
        sa.PrimaryKeyConstraint(
            "session_id",
            name=op.f("pk_user_auth_sessions"),
        ),
    )
    op.create_index(
        "idx_user_auth_sessions_user_status",
        "user_auth_sessions",
        ["user_id", "status"],
    )
    op.create_index(
        "idx_user_auth_sessions_expires_at",
        "user_auth_sessions",
        ["expires_at"],
    )


def downgrade() -> None:
    op.drop_index(
        "idx_user_auth_sessions_expires_at",
        table_name="user_auth_sessions",
    )
    op.drop_index(
        "idx_user_auth_sessions_user_status",
        table_name="user_auth_sessions",
    )
    op.drop_table("user_auth_sessions")
