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


def test_compact_location_models_are_registered() -> None:
    assert {
        "location_states",
        "location_districts",
        "postal_codes",
        "postal_areas",
    } <= set(Base.metadata.tables)


def test_location_schema_is_backend_only_and_profile_linked() -> None:
    sql = render_offline_sql().lower()

    for table in (
        "location_states",
        "location_districts",
        "postal_codes",
        "postal_areas",
    ):
        assert f"create table {table}" in sql
        assert f"alter table public.{table} enable row level security" in sql
        assert f"revoke all on public.{table} from public" in sql
        assert f"public.{table}" in sql
    assert "from anon" in sql
    assert "from authenticated" in sql
    assert "location_validation_status" in sql
    assert "fk_profiles_state_id_location_states" in sql
    assert "fk_profiles_district_id_location_districts" in sql
