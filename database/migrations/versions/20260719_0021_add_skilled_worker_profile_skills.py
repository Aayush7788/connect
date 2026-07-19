"""Add multiple skills to skilled-worker profiles.

Revision ID: 20260719_0021
Revises: 20260717_0020
Create Date: 2026-07-19
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = "20260719_0021"
down_revision: str | None = "20260717_0020"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "skilled_worker_profile_skills",
        sa.Column(
            "id",
            sa.UUID(),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("profile_id", sa.UUID(), nullable=False),
        sa.Column("skill_category_id", sa.UUID(), nullable=True),
        sa.Column("custom_skill_text", sa.Text(), nullable=True),
        sa.Column("sort_order", sa.SmallInteger(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "(skill_category_id is not null and custom_skill_text is null) or "
            "(skill_category_id is null and custom_skill_text is not null)",
            name=op.f("ck_skilled_worker_profile_skills_skill_or_custom_required"),
        ),
        sa.CheckConstraint(
            "custom_skill_text is null or btrim(custom_skill_text) <> ''",
            name=op.f("ck_skilled_worker_profile_skills_custom_skill_not_blank"),
        ),
        sa.ForeignKeyConstraint(
            ["profile_id"],
            ["skilled_worker_profiles.profile_id"],
            name=op.f(
                "fk_skilled_worker_profile_skills_profile_id_skilled_worker_profiles"
            ),
        ),
        sa.ForeignKeyConstraint(
            ["skill_category_id"],
            ["categories.id"],
            name=op.f("fk_skilled_worker_profile_skills_skill_category_id_categories"),
        ),
        sa.PrimaryKeyConstraint(
            "id",
            name=op.f("pk_skilled_worker_profile_skills"),
        ),
    )
    op.create_index(
        "idx_skilled_worker_profile_skills_category",
        "skilled_worker_profile_skills",
        ["skill_category_id", "profile_id"],
    )
    op.create_index(
        "idx_skilled_worker_profile_skills_profile",
        "skilled_worker_profile_skills",
        ["profile_id", "sort_order"],
    )
    op.create_index(
        "uq_skilled_worker_profile_skills_mapped",
        "skilled_worker_profile_skills",
        ["profile_id", "skill_category_id"],
        unique=True,
        postgresql_where=sa.text("skill_category_id is not null"),
    )
    op.execute(
        """
        insert into skilled_worker_profile_skills (
          profile_id,
          skill_category_id,
          sort_order
        )
        select profile_id, primary_skill_category_id, 0
        from skilled_worker_profiles
        where primary_skill_category_id is not null
        """
    )
    op.execute(
        "alter table public.skilled_worker_profile_skills enable row level security"
    )
    op.execute(
        "revoke all on table public.skilled_worker_profile_skills "
        "from public, anon, authenticated"
    )


def downgrade() -> None:
    op.drop_index(
        "uq_skilled_worker_profile_skills_mapped",
        table_name="skilled_worker_profile_skills",
    )
    op.drop_index(
        "idx_skilled_worker_profile_skills_profile",
        table_name="skilled_worker_profile_skills",
    )
    op.drop_index(
        "idx_skilled_worker_profile_skills_category",
        table_name="skilled_worker_profile_skills",
    )
    op.drop_table("skilled_worker_profile_skills")
