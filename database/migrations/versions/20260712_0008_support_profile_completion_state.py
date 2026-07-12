"""support profile completion state

Revision ID: 20260712_0008
Revises: 20260711_0007
Create Date: 2026-07-12 16:30:00.000000
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "20260712_0008"
down_revision: str | None = "20260711_0007"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "profiles",
        sa.Column(
            "reverification_required",
            sa.Boolean(),
            server_default=sa.text("false"),
            nullable=False,
        ),
    )
    op.create_check_constraint(
        op.f("ck_profiles_reverification_requires_unverified_profile"),
        "profiles",
        "reverification_required = false or "
        "(is_verified = false and verification_status <> 'verified')",
    )
    op.drop_constraint(
        op.f("ck_skilled_worker_profiles_experience_years_non_negative"),
        "skilled_worker_profiles",
        type_="check",
    )
    op.alter_column(
        "skilled_worker_profiles",
        "experience_years",
        existing_type=sa.Integer(),
        nullable=True,
        existing_server_default=sa.text("0"),
        server_default=None,
    )
    op.create_check_constraint(
        op.f("ck_skilled_worker_profiles_experience_years_non_negative"),
        "skilled_worker_profiles",
        "experience_years is null or experience_years >= 0",
    )


def downgrade() -> None:
    op.execute(
        "update skilled_worker_profiles set experience_years = 0 "
        "where experience_years is null"
    )
    op.drop_constraint(
        op.f("ck_skilled_worker_profiles_experience_years_non_negative"),
        "skilled_worker_profiles",
        type_="check",
    )
    op.alter_column(
        "skilled_worker_profiles",
        "experience_years",
        existing_type=sa.Integer(),
        nullable=False,
        server_default=sa.text("0"),
    )
    op.create_check_constraint(
        op.f("ck_skilled_worker_profiles_experience_years_non_negative"),
        "skilled_worker_profiles",
        "experience_years >= 0",
    )
    op.drop_constraint(
        op.f("ck_profiles_reverification_requires_unverified_profile"),
        "profiles",
        type_="check",
    )
    op.drop_column("profiles", "reverification_required")
