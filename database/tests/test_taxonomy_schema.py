import subprocess
import sys
from pathlib import Path

import app.db.models  # noqa: F401
from app.db.base import Base


REPO_ROOT = Path(__file__).resolve().parents[2]
ALEMBIC_INI = REPO_ROOT / "database" / "alembic.ini"
SEED_FILE = REPO_ROOT / "database" / "seeds" / "001_initial_taxonomy.sql"


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


def test_taxonomy_models_are_registered_in_metadata() -> None:
    expected_tables = {
        "categories",
        "category_aliases",
        "category_suggestions",
        "business_subtypes",
    }

    assert expected_tables <= set(Base.metadata.tables)


def test_taxonomy_migration_renders_required_tables_constraints_and_indexes() -> None:
    migration_sql = render_offline_sql()

    assert "CREATE TABLE categories" in migration_sql
    assert "CREATE TABLE category_aliases" in migration_sql
    assert "CREATE TABLE category_suggestions" in migration_sql
    assert "CREATE TABLE business_subtypes" in migration_sql
    assert (
        "category_type in ('business_category', 'work_category', 'work_name', 'product_type', 'skill')"
        in migration_sql
    )
    assert "CREATE INDEX idx_categories_type_parent" in migration_sql
    assert "CREATE INDEX idx_category_aliases_normalized" in migration_sql
    assert "CREATE INDEX idx_category_suggestions_source" in migration_sql
    assert "CREATE INDEX idx_business_subtypes_active_sort" in migration_sql


def test_taxonomy_migration_enables_rls() -> None:
    migration_sql = render_offline_sql()

    for table_name in (
        "categories",
        "category_aliases",
        "category_suggestions",
        "business_subtypes",
    ):
        assert (
            f"alter table public.{table_name} enable row level security"
            in migration_sql
        )


def test_taxonomy_seed_data_contains_mvp_terms() -> None:
    combined_seed_text = (
        render_offline_sql() + "\n" + SEED_FILE.read_text(encoding="utf-8")
    )

    for expected_term in (
        "flat-hemming",
        "embroidery",
        "digital-print",
        "zari-work",
        "dupatta",
        "saree",
        "fabric",
        "manufacturer",
        "wholesaler",
        "trader",
    ):
        assert expected_term in combined_seed_text


def test_category_suggestions_profile_reference_has_fk_after_profile_schema() -> None:
    category_suggestions = Base.metadata.tables["category_suggestions"]
    profile_id = category_suggestions.columns["profile_id"]

    assert "profile_id" in category_suggestions.columns
    assert len(profile_id.foreign_keys) == 1
    assert next(iter(profile_id.foreign_keys)).target_fullname == "profiles.id"
