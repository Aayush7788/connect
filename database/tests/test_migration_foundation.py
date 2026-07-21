import subprocess
import sys
from pathlib import Path

from alembic.config import Config
from alembic.script import ScriptDirectory


REPO_ROOT = Path(__file__).resolve().parents[2]
ALEMBIC_INI = REPO_ROOT / "database" / "alembic.ini"
FIRST_MIGRATION = (
    REPO_ROOT
    / "database"
    / "migrations"
    / "versions"
    / "20260711_0001_enable_required_extensions.py"
)


def test_alembic_has_single_head() -> None:
    config = Config(str(ALEMBIC_INI))
    script = ScriptDirectory.from_config(config)

    assert script.get_heads() == ["20260721_0023"]


def test_first_migration_enables_required_extensions() -> None:
    migration_sql = FIRST_MIGRATION.read_text(encoding="utf-8")

    assert 'CREATE EXTENSION IF NOT EXISTS "pgcrypto"' in migration_sql
    assert 'CREATE EXTENSION IF NOT EXISTS "pg_trgm"' in migration_sql


def test_alembic_can_render_offline_sql() -> None:
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

    assert 'CREATE EXTENSION IF NOT EXISTS "pgcrypto"' in result.stdout
    assert 'CREATE EXTENSION IF NOT EXISTS "pg_trgm"' in result.stdout
