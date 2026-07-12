from datetime import datetime
from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import BigInteger, Boolean, CheckConstraint, DateTime, ForeignKey
from sqlalchemy import Index, Integer, Numeric, Text, UniqueConstraint, text
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


class MediaAsset(TimestampMixin, Base):
    __tablename__ = "media_assets"
    __table_args__ = (
        CheckConstraint(
            "entity_type in "
            "('profile', 'work_card', 'work_needed_post', 'verification_case')",
            name="entity_type_valid",
        ),
        CheckConstraint(
            "media_kind in ('image', 'document')",
            name="media_kind_valid",
        ),
        CheckConstraint(
            "document_type is null or document_type in "
            "('identity_proof', 'masked_aadhaar', 'gst_proof', 'shop_photo', "
            "'workplace_photo', 'other')",
            name="document_type_valid",
        ),
        CheckConstraint(
            "visibility in ('public', 'private_admin_only')",
            name="visibility_valid",
        ),
        CheckConstraint(
            "upload_status in "
            "('pending_upload', 'uploaded', 'processing', 'ready', 'failed', "
            "'deleted')",
            name="upload_status_valid",
        ),
        CheckConstraint(
            "media_kind <> 'document' or visibility = 'private_admin_only'",
            name="document_media_is_private",
        ),
        CheckConstraint(
            "document_type not in ('identity_proof', 'masked_aadhaar', 'gst_proof') "
            "or visibility = 'private_admin_only'",
            name="proof_documents_are_private",
        ),
        CheckConstraint(
            "nullif(btrim(original_path), '') is not null",
            name="original_path_non_empty",
        ),
        CheckConstraint("sort_order >= 0", name="sort_order_non_negative"),
        CheckConstraint(
            "file_size_bytes is null or file_size_bytes >= 0",
            name="file_size_bytes_non_negative",
        ),
        CheckConstraint("width is null or width > 0", name="width_positive"),
        CheckConstraint("height is null or height > 0", name="height_positive"),
        Index(
            "idx_media_assets_entity",
            "entity_type",
            "entity_id",
            "visibility",
            "upload_status",
            "sort_order",
        ),
        Index("idx_media_assets_uploaded_by", "uploaded_by_user_id", "created_at"),
        Index("idx_media_assets_status", "upload_status", "created_at"),
        Index(
            "idx_media_assets_private_documents",
            "entity_type",
            "entity_id",
            "document_type",
            postgresql_where=text("visibility = 'private_admin_only'"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    entity_type: Mapped[str] = mapped_column(Text)
    entity_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True))
    media_kind: Mapped[str] = mapped_column(Text)
    document_type: Mapped[str | None] = mapped_column(Text)
    visibility: Mapped[str] = mapped_column(Text)
    upload_status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'pending_upload'"),
    )
    original_path: Mapped[str] = mapped_column(Text)
    compressed_path: Mapped[str | None] = mapped_column(Text)
    thumbnail_path: Mapped[str | None] = mapped_column(Text)
    sort_order: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    file_size_bytes: Mapped[int | None] = mapped_column(BigInteger)
    mime_type: Mapped[str | None] = mapped_column(Text)
    width: Mapped[int | None] = mapped_column(Integer)
    height: Mapped[int | None] = mapped_column(Integer)
    uploaded_by_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class VerificationCase(TimestampMixin, Base):
    __tablename__ = "verification_cases"
    __table_args__ = (
        CheckConstraint(
            "case_reason in ('initial_verification', 'reverification', 'admin_review')",
            name="case_reason_valid",
        ),
        CheckConstraint(
            "status in "
            "('draft', 'pending_review', 'changes_requested', 'approved', "
            "'rejected', 'cancelled')",
            name="status_valid",
        ),
        CheckConstraint(
            "resubmission_count >= 0",
            name="resubmission_count_non_negative",
        ),
        CheckConstraint(
            "consent_version is null or consent_accepted_at is not null",
            name="consent_version_requires_accepted_at",
        ),
        CheckConstraint(
            "status in ('draft', 'cancelled') or submitted_at is not null",
            name="submitted_status_requires_submitted_at",
        ),
        CheckConstraint(
            "status not in ('changes_requested', 'approved', 'rejected') "
            "or reviewed_at is not null",
            name="reviewed_status_requires_reviewed_at",
        ),
        Index("idx_verification_cases_profile_status", "profile_id", "status"),
        Index("idx_verification_cases_submitted_at", "status", "submitted_at"),
        Index("idx_verification_cases_reviewed_by", "reviewed_by_admin_user_id"),
        Index(
            "uq_verification_cases_active_profile",
            "profile_id",
            unique=True,
            postgresql_where=text(
                "status in ('draft', 'pending_review', 'changes_requested')"
            ),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
    )
    submitted_by_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    case_reason: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(Text, server_default=text("'draft'"))
    notes_to_user: Mapped[str | None] = mapped_column(Text)
    internal_notes: Mapped[str | None] = mapped_column(Text)
    resubmission_count: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    consent_version: Mapped[str | None] = mapped_column(Text)
    consent_accepted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True)
    )
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    reviewed_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class VerificationCheck(TimestampMixin, Base):
    __tablename__ = "verification_checks"
    __table_args__ = (
        CheckConstraint(
            "check_type in "
            "('profile_details', 'mobile', 'shop_or_workplace_photos', "
            "'identity_proof', 'gst_proof', 'admin_final_review')",
            name="check_type_valid",
        ),
        CheckConstraint(
            "status in "
            "('pending', 'approved', 'rejected', 'changes_requested', "
            "'not_required')",
            name="status_valid",
        ),
        CheckConstraint(
            "status not in ('approved', 'rejected', 'changes_requested') "
            "or reviewed_at is not null",
            name="reviewed_status_requires_reviewed_at",
        ),
        UniqueConstraint("verification_case_id", "check_type"),
        Index(
            "idx_verification_checks_case_status",
            "verification_case_id",
            "status",
        ),
        Index("idx_verification_checks_evidence", "evidence_media_asset_id"),
        Index("idx_verification_checks_reviewed_by", "reviewed_by_admin_user_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    verification_case_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("verification_cases.id"),
    )
    check_type: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(Text, server_default=text("'pending'"))
    evidence_media_asset_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("media_assets.id"),
    )
    reviewed_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    notes_to_user: Mapped[str | None] = mapped_column(Text)
    internal_notes: Mapped[str | None] = mapped_column(Text)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class VerificationProviderCheck(Base):
    __tablename__ = "verification_provider_checks"
    __table_args__ = (
        CheckConstraint(
            "check_type in ('gst', 'identity', 'liveness', 'other')",
            name="check_type_valid",
        ),
        CheckConstraint(
            "status in ('pending', 'passed', 'failed', 'error')",
            name="status_valid",
        ),
        Index(
            "idx_verification_provider_checks_case",
            "verification_case_id",
            "created_at",
        ),
        Index(
            "idx_verification_provider_checks_profile",
            "profile_id",
            "created_at",
        ),
        Index(
            "idx_verification_provider_checks_reference",
            "provider_name",
            "provider_reference",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    verification_case_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("verification_cases.id"),
    )
    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
    )
    provider_name: Mapped[str] = mapped_column(Text)
    check_type: Mapped[str] = mapped_column(Text)
    provider_reference: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str] = mapped_column(Text)
    request_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB)
    response_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB)
    checked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class SavedItem(Base):
    __tablename__ = "saved_items"
    __table_args__ = (
        CheckConstraint(
            "target_type in ('profile', 'work_card', 'work_needed_post')",
            name="target_type_valid",
        ),
        UniqueConstraint("user_id", "target_type", "target_id"),
        Index("idx_saved_items_user", "user_id", text("created_at desc")),
        Index("idx_saved_items_target", "target_type", "target_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True), ForeignKey("users.id"))
    target_type: Mapped[str] = mapped_column(Text)
    target_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class Report(TimestampMixin, Base):
    __tablename__ = "reports"
    __table_args__ = (
        CheckConstraint(
            "reported_entity_type in "
            "('profile', 'work_card', 'work_needed_post', 'media_asset')",
            name="reported_entity_type_valid",
        ),
        CheckConstraint(
            "reason in "
            "('wrong_contact', 'wrong_category', 'inappropriate_photo', "
            "'wrong_details', 'fake_profile', 'spam', 'other')",
            name="reason_valid",
        ),
        CheckConstraint(
            "status in "
            "('submitted', 'in_review', 'resolved_no_action', 'action_taken', "
            "'dismissed')",
            name="status_valid",
        ),
        Index("idx_reports_status", "status", text("created_at desc")),
        Index("idx_reports_target", "reported_entity_type", "reported_entity_id"),
        Index("idx_reports_reporter", "reporter_user_id", "created_at"),
        Index("idx_reports_reviewed_by", "reviewed_by_admin_user_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    reporter_user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    reported_entity_type: Mapped[str] = mapped_column(Text)
    reported_entity_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True))
    reason: Mapped[str] = mapped_column(Text)
    message: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str] = mapped_column(Text, server_default=text("'submitted'"))
    reviewed_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    resolution_notes: Mapped[str | None] = mapped_column(Text)


class Notification(Base):
    __tablename__ = "notifications"
    __table_args__ = (
        CheckConstraint("priority in ('low', 'normal', 'high')", name="priority_valid"),
        CheckConstraint(
            "push_status is null or push_status in ('not_sent', 'sent', 'failed')",
            name="push_status_valid",
        ),
        CheckConstraint(
            "nullif(btrim(notification_type), '') is not null",
            name="notification_type_non_empty",
        ),
        CheckConstraint(
            "nullif(btrim(title), '') is not null",
            name="title_non_empty",
        ),
        CheckConstraint(
            "nullif(btrim(message), '') is not null",
            name="message_non_empty",
        ),
        Index("idx_notifications_user_created", "user_id", text("created_at desc")),
        Index(
            "idx_notifications_unread",
            "user_id",
            text("created_at desc"),
            postgresql_where=text("read_at is null"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True), ForeignKey("users.id"))
    notification_type: Mapped[str] = mapped_column(Text)
    title: Mapped[str] = mapped_column(Text)
    message: Mapped[str] = mapped_column(Text)
    data_json: Mapped[dict[str, Any]] = mapped_column(
        JSONB,
        server_default=text("'{}'::jsonb"),
    )
    priority: Mapped[str] = mapped_column(Text, server_default=text("'normal'"))
    push_status: Mapped[str | None] = mapped_column(Text)
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class SearchLog(Base):
    __tablename__ = "search_logs"
    __table_args__ = (
        CheckConstraint(
            "target_persona in ('business', 'job_worker', 'skilled_worker')",
            name="target_persona_valid",
        ),
        CheckConstraint("result_count >= 0", name="result_count_non_negative"),
        Index("idx_search_logs_created_at", text("created_at desc")),
        Index(
            "idx_search_logs_target_created",
            "target_persona",
            text("created_at desc"),
        ),
        Index("idx_search_logs_user_created", "user_id", text("created_at desc")),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    query: Mapped[str | None] = mapped_column(Text)
    normalized_query: Mapped[str | None] = mapped_column(Text)
    target_persona: Mapped[str] = mapped_column(Text)
    filters_json: Mapped[dict[str, Any]] = mapped_column(
        JSONB,
        server_default=text("'{}'::jsonb"),
    )
    result_count: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class ProfileViewEvent(Base):
    __tablename__ = "profile_view_events"
    __table_args__ = (
        CheckConstraint(
            "source_type is null or source_type in "
            "('search', 'saved', 'share_link', 'work_card', 'work_needed_post')",
            name="source_type_valid",
        ),
        Index(
            "idx_profile_view_events_profile_created",
            "viewed_profile_id",
            text("created_at desc"),
        ),
        Index(
            "idx_profile_view_events_viewer_created",
            "viewer_user_id",
            text("created_at desc"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    viewer_user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    viewed_profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
    )
    source_type: Mapped[str | None] = mapped_column(Text)
    source_id: Mapped[UUID | None] = mapped_column(PgUUID(as_uuid=True))
    ip_address: Mapped[str | None] = mapped_column(INET)
    device_id: Mapped[str | None] = mapped_column(Text)
    user_agent: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class ContactActionEvent(Base):
    __tablename__ = "contact_action_events"
    __table_args__ = (
        CheckConstraint(
            "action_type in ('call', 'whatsapp', 'show_contact')",
            name="action_type_valid",
        ),
        CheckConstraint(
            "source_type is null or source_type in "
            "('search', 'saved', 'profile', 'work_card', 'work_needed_post')",
            name="source_type_valid",
        ),
        Index(
            "idx_contact_action_events_target_created",
            "target_profile_id",
            text("created_at desc"),
        ),
        Index(
            "idx_contact_action_events_actor_created",
            "actor_user_id",
            text("created_at desc"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    actor_user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    target_profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
    )
    action_type: Mapped[str] = mapped_column(Text)
    source_type: Mapped[str | None] = mapped_column(Text)
    source_id: Mapped[UUID | None] = mapped_column(PgUUID(as_uuid=True))
    ip_address: Mapped[str | None] = mapped_column(INET)
    device_id: Mapped[str | None] = mapped_column(Text)
    user_agent: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class ShareEvent(Base):
    __tablename__ = "share_events"
    __table_args__ = (
        CheckConstraint(
            "target_type in ('profile', 'work_card', 'work_needed_post', 'app_invite')",
            name="target_type_valid",
        ),
        CheckConstraint(
            "target_type = 'app_invite' or target_id is not null",
            name="non_invite_share_requires_target",
        ),
        CheckConstraint(
            "share_channel is null or share_channel in "
            "('whatsapp', 'sms', 'x', 'email', 'linkedin', 'system_share')",
            name="share_channel_valid",
        ),
        Index("idx_share_events_user_created", "user_id", text("created_at desc")),
        Index("idx_share_events_target", "target_type", "target_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True), ForeignKey("users.id"))
    target_type: Mapped[str] = mapped_column(Text)
    target_id: Mapped[UUID | None] = mapped_column(PgUUID(as_uuid=True))
    share_channel: Mapped[str | None] = mapped_column(Text)
    ip_address: Mapped[str | None] = mapped_column(INET)
    device_id: Mapped[str | None] = mapped_column(Text)
    user_agent: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class ContactReveal(TimestampMixin, Base):
    __tablename__ = "contact_reveals"
    __table_args__ = (
        CheckConstraint(
            "source_type is null or source_type in "
            "('work_card', 'work_needed_post', 'profile', 'saved', 'search')",
            name="source_type_valid",
        ),
        CheckConstraint(
            "reveal_mode in ('free_unlimited', 'quota', 'subscription', 'admin_grant')",
            name="reveal_mode_valid",
        ),
        CheckConstraint("reveal_count >= 1", name="reveal_count_positive"),
        CheckConstraint(
            "last_revealed_at >= first_revealed_at",
            name="last_revealed_at_after_first",
        ),
        Index(
            "uq_contact_reveals_once",
            "viewer_user_id",
            "revealed_profile_id",
            unique=True,
        ),
        Index(
            "idx_contact_reveals_profile_created",
            "revealed_profile_id",
            text("created_at desc"),
        ),
        Index(
            "idx_contact_reveals_viewer_created",
            "viewer_user_id",
            text("created_at desc"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    viewer_user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    revealed_profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
    )
    source_type: Mapped[str | None] = mapped_column(Text)
    source_id: Mapped[UUID | None] = mapped_column(PgUUID(as_uuid=True))
    reveal_mode: Mapped[str] = mapped_column(Text)
    first_revealed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
    )
    last_revealed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
    )
    reveal_count: Mapped[int] = mapped_column(Integer, server_default=text("1"))
    ip_address: Mapped[str | None] = mapped_column(INET)
    device_id: Mapped[str | None] = mapped_column(Text)
    user_agent: Mapped[str | None] = mapped_column(Text)


class UserContactQuota(TimestampMixin, Base):
    __tablename__ = "user_contact_quotas"
    __table_args__ = (
        CheckConstraint(
            "free_reveals_total >= 0 and free_reveals_used >= 0 and "
            "verified_bonus_total >= 0 and verified_bonus_used >= 0",
            name="quota_counts_non_negative",
        ),
        CheckConstraint(
            "free_reveals_used <= free_reveals_total",
            name="free_reveals_used_within_total",
        ),
        CheckConstraint(
            "verified_bonus_used <= verified_bonus_total",
            name="verified_bonus_used_within_total",
        ),
    )

    user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
        primary_key=True,
    )
    free_reveals_total: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    free_reveals_used: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    verified_bonus_total: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    verified_bonus_used: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    subscription_reveals_unlimited: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("false"),
    )


class SubscriptionPlan(TimestampMixin, Base):
    __tablename__ = "subscription_plans"
    __table_args__ = (
        CheckConstraint(
            "billing_period in ('monthly', 'yearly')",
            name="billing_period_valid",
        ),
        CheckConstraint(
            "price_amount is null or price_amount >= 0",
            name="price_amount_non_negative",
        ),
        CheckConstraint("nullif(btrim(code), '') is not null", name="code_non_empty"),
        CheckConstraint("nullif(btrim(name), '') is not null", name="name_non_empty"),
        CheckConstraint(
            "nullif(btrim(currency), '') is not null",
            name="currency_non_empty",
        ),
        UniqueConstraint("code"),
        Index("idx_subscription_plans_active", "is_active", "billing_period"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    code: Mapped[str] = mapped_column(Text)
    name: Mapped[str] = mapped_column(Text)
    billing_period: Mapped[str] = mapped_column(Text)
    price_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    currency: Mapped[str] = mapped_column(Text, server_default=text("'INR'"))
    features_json: Mapped[dict[str, Any]] = mapped_column(
        JSONB,
        server_default=text("'{}'::jsonb"),
    )
    is_active: Mapped[bool] = mapped_column(Boolean, server_default=text("false"))


class UserSubscription(TimestampMixin, Base):
    __tablename__ = "user_subscriptions"
    __table_args__ = (
        CheckConstraint(
            "status in ('active', 'cancelled', 'expired', 'payment_pending')",
            name="status_valid",
        ),
        CheckConstraint(
            "current_period_start is null or current_period_end is null or "
            "current_period_end >= current_period_start",
            name="current_period_valid",
        ),
        Index("idx_user_subscriptions_user_status", "user_id", "status"),
        Index("idx_user_subscriptions_plan_status", "plan_id", "status"),
        Index(
            "idx_user_subscriptions_provider",
            "provider",
            "provider_subscription_id",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True), ForeignKey("users.id"))
    plan_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("subscription_plans.id"),
    )
    status: Mapped[str] = mapped_column(Text)
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    current_period_start: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True)
    )
    current_period_end: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    provider: Mapped[str | None] = mapped_column(Text)
    provider_subscription_id: Mapped[str | None] = mapped_column(Text)


class PaymentTransaction(TimestampMixin, Base):
    __tablename__ = "payment_transactions"
    __table_args__ = (
        CheckConstraint(
            "status in ('created', 'paid', 'failed', 'refunded')",
            name="status_valid",
        ),
        CheckConstraint("amount is null or amount >= 0", name="amount_non_negative"),
        CheckConstraint(
            "nullif(btrim(currency), '') is not null",
            name="currency_non_empty",
        ),
        Index("idx_payment_transactions_user_created", "user_id", "created_at"),
        Index("idx_payment_transactions_subscription", "subscription_id"),
        Index(
            "idx_payment_transactions_provider_payment",
            "provider",
            "provider_payment_id",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True), ForeignKey("users.id"))
    subscription_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("user_subscriptions.id"),
    )
    provider: Mapped[str | None] = mapped_column(Text)
    provider_payment_id: Mapped[str | None] = mapped_column(Text)
    amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    currency: Mapped[str] = mapped_column(Text, server_default=text("'INR'"))
    status: Mapped[str] = mapped_column(Text)
    raw_payload_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB)


class AdminAccessGrant(TimestampMixin, Base):
    __tablename__ = "admin_access_grants"
    __table_args__ = (
        CheckConstraint(
            "grant_type in ('free_unlimited', 'extra_quota')",
            name="grant_type_valid",
        ),
        CheckConstraint(
            "status in ('active', 'revoked', 'expired')",
            name="status_valid",
        ),
        CheckConstraint(
            "quota_amount is null or quota_amount > 0",
            name="quota_amount_positive",
        ),
        CheckConstraint(
            "grant_type <> 'extra_quota' or quota_amount is not null",
            name="extra_quota_requires_amount",
        ),
        CheckConstraint(
            "starts_at is null or ends_at is null or ends_at >= starts_at",
            name="grant_period_valid",
        ),
        Index("idx_admin_access_grants_user_status", "user_id", "status"),
        Index("idx_admin_access_grants_admin", "granted_by_admin_user_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    user_id: Mapped[UUID] = mapped_column(PgUUID(as_uuid=True), ForeignKey("users.id"))
    grant_type: Mapped[str] = mapped_column(Text)
    quota_amount: Mapped[int | None] = mapped_column(Integer)
    status: Mapped[str] = mapped_column(Text, server_default=text("'active'"))
    starts_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    ends_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    granted_by_admin_user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    reason: Mapped[str | None] = mapped_column(Text)
