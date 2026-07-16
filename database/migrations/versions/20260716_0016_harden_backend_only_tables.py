"""Harden backend-only tables against Supabase Data API access.

Revision ID: 20260716_0016
Revises: 20260716_0015
"""

from collections.abc import Sequence

from alembic import op


revision: str = "20260716_0016"
down_revision: str | None = "20260716_0015"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


BACKEND_ONLY_TABLES = (
    "alembic_version",
    "user_auth_sessions",
)


def upgrade() -> None:
    for table_name in BACKEND_ONLY_TABLES:
        op.execute(
            f"alter table public.{table_name} enable row level security"
        )

    op.execute(
        """
        revoke all on table
          public.alembic_version,
          public.user_auth_sessions
        from public, anon, authenticated
        """
    )

    op.execute(
        """
        alter default privileges for role postgres in schema public
          revoke all on tables from public, anon, authenticated
        """
    )
    op.execute(
        """
        alter default privileges for role postgres in schema public
          revoke all on sequences from public, anon, authenticated
        """
    )


def downgrade() -> None:
    pass
