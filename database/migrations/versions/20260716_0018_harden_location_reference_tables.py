"""harden backend-only location reference tables

Revision ID: 20260716_0018
Revises: 20260716_0017
"""

from collections.abc import Sequence

from alembic import op


revision: str = "20260716_0018"
down_revision: str | None = "20260716_0017"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


TABLES = (
    "location_states",
    "location_districts",
    "postal_codes",
    "postal_areas",
)
SEQUENCES = (
    "location_states_id_seq",
    "location_districts_id_seq",
    "postal_areas_id_seq",
)


def upgrade() -> None:
    for role in ("anon", "authenticated"):
        op.execute(
            f"""
            do $$
            begin
              if exists (select 1 from pg_roles where rolname = '{role}') then
                revoke all on {", ".join("public." + table for table in TABLES)}
                from {role};
                revoke all on {", ".join("public." + sequence for sequence in SEQUENCES)}
                from {role};
              end if;
            end $$;
            """
        )


def downgrade() -> None:
    pass
