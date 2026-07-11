from datetime import datetime
from typing import Any
from uuid import UUID

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Index, String, Text, text
from sqlalchemy.dialects.postgresql import INET, JSONB, UUID as PgUUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class User(TimestampMixin, Base):
    __tablename__ = "users"
    __table_args__ = (
        CheckConstraint(
            "account_status in ('active', 'suspended', 'terminated')",
            name="account_status_valid",
        ),
        CheckConstraint(
            "role is null or role in ('business', 'job_worker', 'skilled_worker')",
            name="role_valid",
        ),
        Index(
            "uq_users_active_mobile",
            "primary_mobile",
            unique=True,
            postgresql_where=text(
                "account_status <> 'terminated' and deleted_at is null"
            ),
        ),
        Index("idx_users_account_status", "account_status"),
        Index("idx_users_role", "role"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    auth_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        unique=True,
    )
    display_name: Mapped[str] = mapped_column(Text)
    primary_mobile: Mapped[str] = mapped_column(Text)
    account_status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'active'"),
    )
    role: Mapped[str | None] = mapped_column(Text)
    role_confirmed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    profile_completed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True)
    )
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    accepted_terms_version: Mapped[str | None] = mapped_column(Text)
    accepted_terms_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    accepted_privacy_version: Mapped[str | None] = mapped_column(Text)
    accepted_privacy_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True)
    )
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class UserSetting(TimestampMixin, Base):
    __tablename__ = "user_settings"

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
        unique=True,
    )
    locale: Mapped[str] = mapped_column(Text, server_default=text("'en'"))
    notification_preferences: Mapped[dict[str, Any]] = mapped_column(
        JSONB,
        server_default=text("'{}'::jsonb"),
    )


class UserDevice(TimestampMixin, Base):
    __tablename__ = "user_devices"
    __table_args__ = (
        CheckConstraint("platform in ('android')", name="platform_valid"),
        CheckConstraint("status in ('active', 'revoked')", name="status_valid"),
        Index("idx_user_devices_user_status", "user_id", "status"),
        Index(
            "uq_user_devices_active_fcm_token",
            "fcm_token",
            unique=True,
            postgresql_where=text("status = 'active'"),
        ),
        Index(
            "uq_user_devices_active_device",
            "user_id",
            "device_id",
            unique=True,
            postgresql_where=text("device_id is not null and status = 'active'"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True), ForeignKey("users.id"))
    device_id: Mapped[str | None] = mapped_column(Text)
    platform: Mapped[str] = mapped_column(Text)
    fcm_token: Mapped[str] = mapped_column(Text)
    app_version: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str] = mapped_column(Text, server_default=text("'active'"))
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class AdminUser(TimestampMixin, Base):
    __tablename__ = "admin_users"
    __table_args__ = (
        CheckConstraint(
            "role in ('super_admin', 'verifier', 'support', 'viewer')",
            name="role_valid",
        ),
        CheckConstraint("status in ('active', 'disabled')", name="status_valid"),
        Index(
            "uq_admin_users_lower_email",
            text("lower(email)"),
            unique=True,
            postgresql_where=text("email is not null"),
        ),
        Index("idx_admin_users_status", "status"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
        unique=True,
    )
    email: Mapped[str | None] = mapped_column(String(320))
    display_name: Mapped[str | None] = mapped_column(Text)
    role: Mapped[str] = mapped_column(Text, server_default=text("'super_admin'"))
    status: Mapped[str] = mapped_column(Text, server_default=text("'active'"))
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class AdminAuditLog(Base):
    __tablename__ = "admin_audit_logs"
    __table_args__ = (
        Index(
            "idx_admin_audit_logs_actor_created",
            "actor_admin_user_id",
            "created_at",
        ),
        Index("idx_admin_audit_logs_entity", "entity_type", "entity_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    actor_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    action: Mapped[str] = mapped_column(Text)
    entity_type: Mapped[str] = mapped_column(Text)
    entity_id: Mapped[UUID | None] = mapped_column(PgUUID(as_uuid=True))
    before_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB)
    after_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB)
    metadata_json: Mapped[dict[str, Any]] = mapped_column(
        JSONB,
        server_default=text("'{}'::jsonb"),
    )
    ip_address: Mapped[str | None] = mapped_column(INET)
    user_agent: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class AppSetting(TimestampMixin, Base):
    __tablename__ = "app_settings"
    __table_args__ = (
        Index("idx_app_settings_updated_by_admin", "updated_by_admin_user_id"),
    )

    key: Mapped[str] = mapped_column(Text, primary_key=True)
    value_json: Mapped[dict[str, Any]] = mapped_column(JSONB)
    description: Mapped[str | None] = mapped_column(Text)
    updated_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
