from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
MIGRATION = (
    REPO_ROOT
    / "database"
    / "migrations"
    / "versions"
    / "20260713_0014_align_engagement_event_constraints.py"
)


def test_engagement_event_constraints_match_api_values() -> None:
    migration = MIGRATION.read_text(encoding="utf-8")

    assert "'call', 'whatsapp', 'address', 'show_contact'" in migration
    assert "'copy_link', 'whatsapp', 'sms', 'x', 'email', 'linkedin'" in migration
    assert "'native_other', 'system_share'" in migration
