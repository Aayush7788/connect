import subprocess
import sys
from pathlib import Path

from sqlalchemy import UniqueConstraint

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


def test_cross_cutting_models_are_registered_in_metadata() -> None:
    expected_tables = {
        "media_assets",
        "verification_cases",
        "verification_checks",
        "verification_provider_checks",
        "saved_items",
        "reports",
        "notifications",
        "search_logs",
        "profile_view_events",
        "contact_action_events",
        "share_events",
        "contact_reveals",
        "user_contact_quotas",
        "subscription_plans",
        "user_subscriptions",
        "payment_transactions",
        "admin_access_grants",
    }

    assert expected_tables <= set(Base.metadata.tables)


def test_cross_cutting_migration_renders_required_tables_rls_and_triggers() -> None:
    migration_sql = render_offline_sql()
    tables_with_rls = (
        "media_assets",
        "verification_cases",
        "verification_checks",
        "verification_provider_checks",
        "saved_items",
        "reports",
        "notifications",
        "search_logs",
        "profile_view_events",
        "contact_action_events",
        "share_events",
        "contact_reveals",
        "user_contact_quotas",
        "subscription_plans",
        "user_subscriptions",
        "payment_transactions",
        "admin_access_grants",
    )
    tables_with_updated_at = (
        "media_assets",
        "verification_cases",
        "verification_checks",
        "reports",
        "contact_reveals",
        "user_contact_quotas",
        "subscription_plans",
        "user_subscriptions",
        "payment_transactions",
        "admin_access_grants",
    )

    for table_name in tables_with_rls:
        assert f"CREATE TABLE {table_name}" in migration_sql
        assert (
            f"alter table public.{table_name} enable row level security"
            in migration_sql
        )

    for table_name in tables_with_updated_at:
        assert f"create trigger trg_{table_name}_set_updated_at" in migration_sql

    assert "revoke all on public.subscription_plans" in migration_sql


def test_media_schema_keeps_private_verification_documents_separate() -> None:
    migration_sql = render_offline_sql()

    assert "visibility in ('public', 'private_admin_only')" in migration_sql
    assert "media_kind <> 'document' or visibility = 'private_admin_only'" in (
        migration_sql
    )
    assert (
        "document_type not in ('identity_proof', 'masked_aadhaar', 'gst_proof') "
        "or visibility = 'private_admin_only'"
    ) in migration_sql
    assert "CREATE INDEX idx_media_assets_entity" in migration_sql
    assert "CREATE INDEX idx_media_assets_private_documents" in migration_sql
    assert "'workplace_photo', 'work_photo', 'other'" in migration_sql


def test_verification_schema_supports_admin_review_and_future_provider_checks() -> None:
    migration_sql = render_offline_sql()

    assert (
        "status in ('draft', 'pending_review', 'changes_requested', 'approved', "
        "'rejected', 'cancelled')"
    ) in migration_sql
    assert "CREATE UNIQUE INDEX uq_verification_cases_active_profile" in migration_sql
    assert "admin_final_review" in migration_sql
    assert "CREATE TABLE verification_provider_checks" in migration_sql
    assert "request_json JSONB" in migration_sql
    assert "response_json JSONB" in migration_sql
    assert "fk_profile_gst_details_proof_media_asset_id_media_assets" in migration_sql


def test_saved_reports_notifications_match_mvp_behavior() -> None:
    migration_sql = render_offline_sql()
    reports_table = Base.metadata.tables["reports"]
    report_unique_constraints = [
        constraint
        for constraint in reports_table.constraints
        if isinstance(constraint, UniqueConstraint)
    ]

    assert "UNIQUE (user_id, target_type, target_id)" in migration_sql
    assert not report_unique_constraints
    assert "wrong_contact" in migration_sql
    assert "fake_profile" in migration_sql
    assert "spam" in migration_sql
    assert "read_at TIMESTAMP WITH TIME ZONE" in migration_sql
    assert "CREATE INDEX idx_notifications_unread" in migration_sql


def test_analytics_and_contact_reveal_tables_capture_required_attribution() -> None:
    migration_sql = render_offline_sql()

    assert "CREATE TABLE search_logs" in migration_sql
    assert "target_persona in ('business', 'job_worker', 'skilled_worker')" in (
        migration_sql
    )
    assert "CREATE TABLE profile_view_events" in migration_sql
    assert "CREATE TABLE contact_action_events" in migration_sql
    assert "CREATE TABLE share_events" in migration_sql
    assert "ip_address INET" in migration_sql
    assert "device_id TEXT" in migration_sql
    assert "user_agent TEXT" in migration_sql
    assert "CREATE UNIQUE INDEX uq_contact_reveals_once" in migration_sql
    assert "source_type, source_id" not in migration_sql


def test_future_monetization_tables_exist_but_default_to_inert_behavior() -> None:
    migration_sql = render_offline_sql()

    assert "CREATE TABLE user_contact_quotas" in migration_sql
    assert "CREATE TABLE subscription_plans" in migration_sql
    assert "CREATE TABLE user_subscriptions" in migration_sql
    assert "CREATE TABLE payment_transactions" in migration_sql
    assert "CREATE TABLE admin_access_grants" in migration_sql
    assert "is_active BOOLEAN DEFAULT false NOT NULL" in migration_sql
    assert "free_reveals_total INTEGER DEFAULT 0 NOT NULL" in migration_sql
    assert "subscription_reveals_unlimited BOOLEAN DEFAULT false NOT NULL" in (
        migration_sql
    )
    assert "grant_type in ('free_unlimited', 'extra_quota')" in migration_sql
