"""Create identity, admin, device, and settings tables.

Revision ID: 20260711_0002
Revises: 20260711_0001
Create Date: 2026-07-11
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260711_0002"
down_revision: str | None = "20260711_0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


TABLES_WITH_RLS = (
    "users",
    "user_settings",
    "user_devices",
    "admin_users",
    "admin_audit_logs",
    "app_settings",
)

TABLES_WITH_UPDATED_AT = (
    "users",
    "user_settings",
    "user_devices",
    "admin_users",
    "app_settings",
)


def upgrade() -> None:
    op.execute(
        """
        create or replace function public.set_updated_at()
        returns trigger
        language plpgsql
        as $$
        begin
          new.updated_at = now();
          return new;
        end;
        $$;
        """
    )

    op.create_table(
        "users",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("auth_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=False),
        sa.Column("primary_mobile", sa.Text(), nullable=False),
        sa.Column(
            "account_status",
            sa.Text(),
            server_default=sa.text("'active'"),
            nullable=False,
        ),
        sa.Column("role", sa.Text(), nullable=True),
        sa.Column("role_confirmed_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column("profile_completed_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column("last_login_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column("accepted_terms_version", sa.Text(), nullable=True),
        sa.Column("accepted_terms_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column("accepted_privacy_version", sa.Text(), nullable=True),
        sa.Column("accepted_privacy_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("deleted_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.CheckConstraint(
            "account_status in ('active', 'suspended', 'terminated')",
            name=op.f("ck_users_account_status_valid"),
        ),
        sa.CheckConstraint(
            "role is null or role in ('business', 'job_worker', 'skilled_worker')",
            name=op.f("ck_users_role_valid"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_users")),
        sa.UniqueConstraint("auth_user_id", name=op.f("uq_users_auth_user_id")),
    )
    op.create_index(
        "uq_users_active_mobile",
        "users",
        ["primary_mobile"],
        unique=True,
        postgresql_where=sa.text(
            "account_status <> 'terminated' and deleted_at is null"
        ),
    )
    op.create_index("idx_users_account_status", "users", ["account_status"])
    op.create_index("idx_users_role", "users", ["role"])

    op.create_table(
        "user_settings",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("locale", sa.Text(), server_default=sa.text("'en'"), nullable=False),
        sa.Column(
            "notification_preferences",
            postgresql.JSONB(astext_type=sa.Text()),
            server_default=sa.text("'{}'::jsonb"),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_user_settings_user_id_users"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_settings")),
        sa.UniqueConstraint("user_id", name=op.f("uq_user_settings_user_id")),
    )

    op.create_table(
        "user_devices",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("device_id", sa.Text(), nullable=True),
        sa.Column("platform", sa.Text(), nullable=False),
        sa.Column("fcm_token", sa.Text(), nullable=False),
        sa.Column("app_version", sa.Text(), nullable=True),
        sa.Column(
            "status",
            sa.Text(),
            server_default=sa.text("'active'"),
            nullable=False,
        ),
        sa.Column("last_seen_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "platform in ('android')", name=op.f("ck_user_devices_platform_valid")
        ),
        sa.CheckConstraint(
            "status in ('active', 'revoked')",
            name=op.f("ck_user_devices_status_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_user_devices_user_id_users"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_devices")),
    )
    op.create_index(
        "idx_user_devices_user_status",
        "user_devices",
        ["user_id", "status"],
    )
    op.create_index(
        "uq_user_devices_active_fcm_token",
        "user_devices",
        ["fcm_token"],
        unique=True,
        postgresql_where=sa.text("status = 'active'"),
    )
    op.create_index(
        "uq_user_devices_active_device",
        "user_devices",
        ["user_id", "device_id"],
        unique=True,
        postgresql_where=sa.text("device_id is not null and status = 'active'"),
    )

    op.create_table(
        "admin_users",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("email", sa.String(length=320), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column(
            "role",
            sa.Text(),
            server_default=sa.text("'super_admin'"),
            nullable=False,
        ),
        sa.Column(
            "status",
            sa.Text(),
            server_default=sa.text("'active'"),
            nullable=False,
        ),
        sa.Column("last_login_at", sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "role in ('super_admin', 'verifier', 'support', 'viewer')",
            name=op.f("ck_admin_users_role_valid"),
        ),
        sa.CheckConstraint(
            "status in ('active', 'disabled')",
            name=op.f("ck_admin_users_status_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_admin_users_user_id_users"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_admin_users")),
        sa.UniqueConstraint("user_id", name=op.f("uq_admin_users_user_id")),
    )
    op.create_index("idx_admin_users_status", "admin_users", ["status"])
    op.create_index(
        "uq_admin_users_lower_email",
        "admin_users",
        [sa.text("lower(email)")],
        unique=True,
        postgresql_where=sa.text("email is not null"),
    )

    op.create_table(
        "admin_audit_logs",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("actor_admin_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("action", sa.Text(), nullable=False),
        sa.Column("entity_type", sa.Text(), nullable=False),
        sa.Column("entity_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column(
            "before_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True
        ),
        sa.Column("after_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column(
            "metadata_json",
            postgresql.JSONB(astext_type=sa.Text()),
            server_default=sa.text("'{}'::jsonb"),
            nullable=False,
        ),
        sa.Column("ip_address", postgresql.INET(), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["actor_admin_user_id"],
            ["admin_users.id"],
            name=op.f("fk_admin_audit_logs_actor_admin_user_id_admin_users"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_admin_audit_logs")),
    )
    op.create_index(
        "idx_admin_audit_logs_actor_created",
        "admin_audit_logs",
        ["actor_admin_user_id", "created_at"],
    )
    op.create_index(
        "idx_admin_audit_logs_entity",
        "admin_audit_logs",
        ["entity_type", "entity_id"],
    )

    op.create_table(
        "app_settings",
        sa.Column("key", sa.Text(), nullable=False),
        sa.Column(
            "value_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False
        ),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column(
            "updated_by_admin_user_id", postgresql.UUID(as_uuid=True), nullable=True
        ),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["updated_by_admin_user_id"],
            ["admin_users.id"],
            name=op.f("fk_app_settings_updated_by_admin_user_id_admin_users"),
        ),
        sa.PrimaryKeyConstraint("key", name=op.f("pk_app_settings")),
    )
    op.create_index(
        "idx_app_settings_updated_by_admin",
        "app_settings",
        ["updated_by_admin_user_id"],
    )

    for table_name in TABLES_WITH_UPDATED_AT:
        op.execute(
            f"""
            create trigger trg_{table_name}_set_updated_at
            before update on public.{table_name}
            for each row
            execute function public.set_updated_at();
            """
        )

    for table_name in TABLES_WITH_RLS:
        op.execute(f"alter table public.{table_name} enable row level security")

    op.execute(
        f"""
        do $$
        begin
          if exists (select 1 from pg_roles where rolname = 'anon') then
            revoke all on {", ".join("public." + table for table in TABLES_WITH_RLS)} from anon;
          end if;
          if exists (select 1 from pg_roles where rolname = 'authenticated') then
            revoke all on {", ".join("public." + table for table in TABLES_WITH_RLS)} from authenticated;
          end if;
        end $$;
        """
    )

    op.execute(
        """
        insert into app_settings (key, value_json, description)
        values (
          'contact_reveal_mode',
          '"free_unlimited"'::jsonb,
          'Controls contact and address reveal access. MVP launch is free unlimited.'
        )
        on conflict (key) do nothing;
        """
    )


def downgrade() -> None:
    op.execute("delete from app_settings where key = 'contact_reveal_mode'")

    for table_name in reversed(TABLES_WITH_UPDATED_AT):
        op.execute(
            f"drop trigger if exists trg_{table_name}_set_updated_at on public.{table_name}"
        )

    op.drop_index("idx_app_settings_updated_by_admin", table_name="app_settings")
    op.drop_table("app_settings")

    op.drop_index("idx_admin_audit_logs_entity", table_name="admin_audit_logs")
    op.drop_index("idx_admin_audit_logs_actor_created", table_name="admin_audit_logs")
    op.drop_table("admin_audit_logs")

    op.drop_index("uq_admin_users_lower_email", table_name="admin_users")
    op.drop_index("idx_admin_users_status", table_name="admin_users")
    op.drop_table("admin_users")

    op.drop_index("uq_user_devices_active_device", table_name="user_devices")
    op.drop_index("uq_user_devices_active_fcm_token", table_name="user_devices")
    op.drop_index("idx_user_devices_user_status", table_name="user_devices")
    op.drop_table("user_devices")

    op.drop_table("user_settings")

    op.drop_index("idx_users_role", table_name="users")
    op.drop_index("idx_users_account_status", table_name="users")
    op.drop_index("uq_users_active_mobile", table_name="users")
    op.drop_table("users")

    op.execute("drop function if exists public.set_updated_at()")
