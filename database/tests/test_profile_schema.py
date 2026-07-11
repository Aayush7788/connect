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


def test_profile_models_are_registered_in_metadata() -> None:
    expected_tables = {
        "profiles",
        "business_profiles",
        "business_profile_product_types",
        "profile_business_subtypes",
        "job_worker_profiles",
        "skilled_worker_profiles",
        "profile_gst_details",
        "profile_change_history",
    }

    assert expected_tables <= set(Base.metadata.tables)


def test_profile_migration_renders_required_tables_constraints_and_indexes() -> None:
    migration_sql = render_offline_sql()

    for table_name in (
        "profiles",
        "business_profiles",
        "business_profile_product_types",
        "profile_business_subtypes",
        "job_worker_profiles",
        "skilled_worker_profiles",
        "profile_gst_details",
        "profile_change_history",
    ):
        assert f"CREATE TABLE {table_name}" in migration_sql

    assert "role in ('business', 'job_worker', 'skilled_worker')" in migration_sql
    assert (
        "visibility_status in ('draft', 'public', 'hidden_by_user', "
        "'suspended_by_admin', 'deleted')"
    ) in migration_sql
    assert (
        "verification_status in ('unverified', 'pending', 'verified', "
        "'changes_requested', 'rejected')"
    ) in migration_sql
    assert "completion_score between 0 and 100" in migration_sql
    assert "owner_user_id is not null or is_admin_seeded = true" in migration_sql
    assert "CREATE UNIQUE INDEX uq_profiles_owner_active" in migration_sql
    assert "owner_user_id is not null and deleted_at is null" in migration_sql
    assert "CREATE INDEX idx_profiles_role_visibility" in migration_sql
    assert "CREATE INDEX idx_profiles_location" in migration_sql
    assert "CREATE INDEX idx_profiles_ranking" in migration_sql
    assert "CREATE INDEX idx_profiles_search_vector" in migration_sql
    assert "CREATE INDEX idx_profiles_search_text_trgm" in migration_sql


def test_profile_migration_enables_rls_and_updated_at_triggers() -> None:
    migration_sql = render_offline_sql()

    for table_name in (
        "profiles",
        "business_profiles",
        "business_profile_product_types",
        "profile_business_subtypes",
        "job_worker_profiles",
        "skilled_worker_profiles",
        "profile_gst_details",
        "profile_change_history",
    ):
        assert (
            f"alter table public.{table_name} enable row level security"
            in migration_sql
        )

    for table_name in (
        "profiles",
        "business_profiles",
        "job_worker_profiles",
        "skilled_worker_profiles",
        "profile_gst_details",
    ):
        assert f"create trigger trg_{table_name}_set_updated_at" in migration_sql


def test_profile_schema_does_not_store_raw_identity_document_numbers() -> None:
    migration_sql = render_offline_sql().lower()

    assert "aadhaar" not in migration_sql
    assert "aadhar" not in migration_sql
    assert "pan" not in migration_sql


def test_gst_proof_media_reference_is_deferred_until_media_assets_schema() -> None:
    gst_table = Base.metadata.tables["profile_gst_details"]
    proof_media_asset_id = gst_table.columns["proof_media_asset_id"]

    assert not proof_media_asset_id.foreign_keys


def test_category_suggestions_profile_fk_is_added_by_profile_migration() -> None:
    migration_sql = render_offline_sql()

    assert "fk_category_suggestions_profile_id_profiles" in migration_sql
