import subprocess
import sys
from pathlib import Path

import app.db.models  # noqa: F401
from app.db.base import Base


REPO_ROOT = Path(__file__).resolve().parents[2]
ALEMBIC_INI = REPO_ROOT / "database" / "alembic.ini"


def render_offline_sql() -> str:
    result = subprocess.run(
        [
            sys.executable,
            "-m",
            "alembic",
            "-c",
            str(ALEMBIC_INI),
            "upgrade",
            "head",
            "--sql",
        ],
        cwd=REPO_ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout


def test_marketplace_models_are_registered_in_metadata() -> None:
    expected_tables = {
        "work_cards",
        "work_card_product_types",
        "work_needed_posts",
        "work_needed_post_product_types",
    }

    assert expected_tables <= set(Base.metadata.tables)


def test_content_tables_are_role_scoped_with_extension_table_fks() -> None:
    work_card_profile_id = Base.metadata.tables["work_cards"].columns["profile_id"]
    work_needed_profile_id = Base.metadata.tables["work_needed_posts"].columns[
        "profile_id"
    ]

    assert (
        next(iter(work_card_profile_id.foreign_keys)).target_fullname
        == "job_worker_profiles.profile_id"
    )
    assert (
        next(iter(work_needed_profile_id.foreign_keys)).target_fullname
        == "business_profiles.profile_id"
    )


def test_marketplace_migration_renders_required_tables_constraints_and_indexes() -> (
    None
):
    migration_sql = render_offline_sql()

    for table_name in (
        "work_cards",
        "work_card_product_types",
        "work_needed_posts",
        "work_needed_post_product_types",
    ):
        assert f"CREATE TABLE {table_name}" in migration_sql

    assert (
        "status in ('draft', 'published', 'hidden_by_user', "
        "'removed_by_admin', 'deleted')"
    ) in migration_sql
    assert (
        "status in ('draft', 'active', 'paused', 'closed_by_user', "
        "'removed_by_admin', 'deleted')"
    ) in migration_sql
    assert "DEFAULT 'draft'" in migration_sql
    assert "photo_count >= 3" in migration_sql
    assert "nullif(btrim(description), '') is not null" in migration_sql
    assert "nullif(btrim(title), '') is not null" in migration_sql
    assert "closed_at is null or status in" in migration_sql
    assert "CREATE INDEX idx_work_cards_profile_status" in migration_sql
    assert "CREATE INDEX idx_work_cards_category_status" in migration_sql
    assert "CREATE INDEX idx_work_cards_search_vector" in migration_sql
    assert "CREATE INDEX idx_work_cards_search_text_trgm" in migration_sql
    assert "CREATE INDEX idx_work_needed_posts_profile_status" in migration_sql
    assert "CREATE INDEX idx_work_needed_posts_category_status" in migration_sql
    assert "CREATE INDEX idx_work_needed_posts_search_vector" in migration_sql
    assert "CREATE INDEX idx_work_needed_posts_search_text_trgm" in migration_sql
    assert "CREATE INDEX idx_work_card_product_types_category" in migration_sql
    assert "CREATE INDEX idx_work_needed_post_product_types_category" in migration_sql
    assert "CREATE UNIQUE INDEX uq_work_cards_creation_idempotency" in migration_sql
    assert (
        "CREATE UNIQUE INDEX uq_work_needed_posts_creation_idempotency"
        in migration_sql
    )


def test_work_card_creation_idempotency_fields_are_constrained() -> None:
    work_cards = Base.metadata.tables["work_cards"]

    assert "creation_idempotency_key" in work_cards.columns
    assert "creation_request_hash" in work_cards.columns

    migration_sql = render_offline_sql()
    assert "creation_idempotency_key is not null" in migration_sql
    assert "creation_request_hash is not null" in migration_sql


def test_work_needed_post_creation_idempotency_fields_are_constrained() -> None:
    posts = Base.metadata.tables["work_needed_posts"]

    assert "creation_idempotency_key" in posts.columns
    assert "creation_request_hash" in posts.columns

    migration_sql = render_offline_sql()
    assert "uq_work_needed_posts_creation_idempotency" in migration_sql
    assert "ck_work_needed_posts_idempotency_fields_together" in migration_sql
    assert (
        "set status = 'draft', closed_at = null" in migration_sql
        and "nullif(btrim(description), '') is null" in migration_sql
    )


def test_product_type_rows_require_mapped_or_non_blank_custom_text() -> None:
    migration_sql = render_offline_sql()

    assert (
        "product_type_category_id is not null or "
        "nullif(btrim(custom_product_type_text), '') is not null"
    ) in migration_sql
    assert "CREATE UNIQUE INDEX uq_work_card_product_types_mapped" in migration_sql
    assert "CREATE UNIQUE INDEX uq_work_card_product_types_custom" in migration_sql
    assert (
        "CREATE UNIQUE INDEX uq_work_needed_post_product_types_mapped" in migration_sql
    )
    assert (
        "CREATE UNIQUE INDEX uq_work_needed_post_product_types_custom" in migration_sql
    )


def test_marketplace_migration_enables_rls_and_updated_at_triggers() -> None:
    migration_sql = render_offline_sql()

    for table_name in (
        "work_cards",
        "work_card_product_types",
        "work_needed_posts",
        "work_needed_post_product_types",
    ):
        assert (
            f"alter table public.{table_name} enable row level security"
            in migration_sql
        )

    for table_name in (
        "work_cards",
        "work_needed_posts",
    ):
        assert f"create trigger trg_{table_name}_set_updated_at" in migration_sql


def test_marketplace_schema_keeps_media_out_until_media_phase() -> None:
    marketplace_tables = {
        "work_cards",
        "work_card_product_types",
        "work_needed_posts",
        "work_needed_post_product_types",
    }

    for table_name in marketplace_tables:
        assert "media_asset_id" not in Base.metadata.tables[table_name].columns
