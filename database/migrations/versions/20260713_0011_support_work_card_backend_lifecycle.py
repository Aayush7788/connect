"""support work card backend lifecycle

Revision ID: 20260713_0011
Revises: 20260712_0010
Create Date: 2026-07-13 12:18:40.696012
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "20260713_0011"
down_revision: str | None = "20260712_0010"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "work_cards",
        sa.Column("creation_idempotency_key", sa.Text(), nullable=True),
    )
    op.add_column(
        "work_cards",
        sa.Column("creation_request_hash", sa.Text(), nullable=True),
    )
    op.create_check_constraint(
        op.f("ck_work_cards_idempotency_fields_together"),
        "work_cards",
        "(creation_idempotency_key is null and creation_request_hash is null) or "
        "(creation_idempotency_key is not null and creation_request_hash is not null)",
    )
    op.create_check_constraint(
        op.f("ck_work_cards_idempotency_key_length"),
        "work_cards",
        "creation_idempotency_key is null or "
        "char_length(creation_idempotency_key) between 1 and 128",
    )
    op.create_index(
        "uq_work_cards_creation_idempotency",
        "work_cards",
        ["profile_id", "creation_idempotency_key"],
        unique=True,
        postgresql_where=sa.text("creation_idempotency_key is not null"),
    )
    op.drop_constraint(
        op.f("ck_work_cards_publish_requires_required_fields"),
        "work_cards",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_work_cards_publish_requires_required_fields"),
        "work_cards",
        "status not in ('published', 'hidden_by_user') or "
        "(photo_count >= 3 and "
        "nullif(btrim(description), '') is not null and "
        "(work_category_id is not null or "
        "nullif(btrim(custom_work_category_text), '') is not null) and "
        "(work_name_category_id is not null or "
        "nullif(btrim(custom_work_name), '') is not null))",
    )


def downgrade() -> None:
    op.drop_constraint(
        op.f("ck_work_cards_publish_requires_required_fields"),
        "work_cards",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_work_cards_publish_requires_required_fields"),
        "work_cards",
        "status not in ('published', 'hidden_by_user') or "
        "(photo_count >= 3 and "
        "(work_category_id is not null or "
        "nullif(btrim(custom_work_category_text), '') is not null) and "
        "(work_name_category_id is not null or "
        "nullif(btrim(custom_work_name), '') is not null))",
    )
    op.drop_index(
        "uq_work_cards_creation_idempotency",
        table_name="work_cards",
        postgresql_where=sa.text("creation_idempotency_key is not null"),
    )
    op.drop_constraint(
        op.f("ck_work_cards_idempotency_key_length"),
        "work_cards",
        type_="check",
    )
    op.drop_constraint(
        op.f("ck_work_cards_idempotency_fields_together"),
        "work_cards",
        type_="check",
    )
    op.drop_column("work_cards", "creation_request_hash")
    op.drop_column("work_cards", "creation_idempotency_key")
