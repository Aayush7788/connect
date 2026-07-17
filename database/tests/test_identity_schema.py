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


def test_identity_models_are_registered_in_metadata() -> None:
    expected_tables = {
        "users",
        "user_settings",
        "user_devices",
        "admin_users",
        "admin_audit_logs",
        "app_settings",
    }

    assert expected_tables <= set(Base.metadata.tables)


def test_identity_migration_renders_required_tables_and_constraints() -> None:
    migration_sql = render_offline_sql()

    assert "CREATE TABLE users" in migration_sql
    assert "CREATE TABLE admin_audit_logs" in migration_sql
    assert "CREATE TABLE app_settings" in migration_sql
    assert "account_status in ('active', 'suspended', 'terminated')" in migration_sql
    assert (
        "role is null or role in ('business', 'job_worker', 'skilled_worker')"
        in migration_sql
    )
    assert "CREATE UNIQUE INDEX uq_users_active_mobile" in migration_sql
    assert "account_status <> 'terminated' and deleted_at is null" in migration_sql
    assert "ALTER TABLE user_devices ALTER COLUMN fcm_token DROP NOT NULL" in (
        migration_sql
    )
    assert "fcm_token is not null and status = 'active'" in migration_sql
    assert (
        "ALTER TABLE admin_audit_logs ALTER COLUMN actor_admin_user_id SET NOT NULL"
        in migration_sql
    )


def test_identity_migration_enables_rls_and_seeds_launch_mode() -> None:
    migration_sql = render_offline_sql()

    for table_name in (
        "users",
        "user_settings",
        "user_devices",
        "admin_users",
        "admin_audit_logs",
        "app_settings",
    ):
        assert (
            f"alter table public.{table_name} enable row level security"
            in migration_sql
        )

    assert "'contact_reveal_mode'" in migration_sql
    assert "'\"free_unlimited\"'::jsonb" in migration_sql
