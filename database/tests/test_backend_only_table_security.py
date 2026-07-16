from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
MIGRATION_PATH = (
    REPO_ROOT
    / "database"
    / "migrations"
    / "versions"
    / "20260716_0016_harden_backend_only_tables.py"
)


def migration_sql() -> str:
    return MIGRATION_PATH.read_text(encoding="utf-8").lower()


def test_backend_only_tables_enable_rls_without_frontend_policies() -> None:
    sql = migration_sql()

    for table_name in ("alembic_version", "user_auth_sessions"):
        assert f'"{table_name}"' in sql

    assert "enable row level security" in sql
    assert "create policy" not in sql


def test_backend_only_tables_revoke_all_api_role_privileges() -> None:
    sql = migration_sql()

    assert "public.alembic_version" in sql
    assert "public.user_auth_sessions" in sql
    assert "from public, anon, authenticated" in sql


def test_future_postgres_tables_and_sequences_default_to_backend_only() -> None:
    sql = migration_sql()

    assert "alter default privileges for role postgres in schema public" in sql
    assert "revoke all on tables from public, anon, authenticated" in sql
    assert "revoke all on sequences from public, anon, authenticated" in sql
