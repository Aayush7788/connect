from datetime import datetime
from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import Boolean, CheckConstraint, DateTime, ForeignKey, Index, Integer
from sqlalchemy import SmallInteger
from sqlalchemy import Numeric, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import JSONB, TSVECTOR, UUID as PgUUID
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


class Profile(TimestampMixin, Base):
    __tablename__ = "profiles"
    __table_args__ = (
        CheckConstraint(
            "role in ('business', 'job_worker', 'skilled_worker')",
            name="role_valid",
        ),
        CheckConstraint(
            "visibility_status in "
            "('draft', 'public', 'hidden_by_user', 'suspended_by_admin', 'deleted')",
            name="visibility_status_valid",
        ),
        CheckConstraint(
            "verification_status in "
            "('unverified', 'pending', 'verified', 'changes_requested', 'rejected')",
            name="verification_status_valid",
        ),
        CheckConstraint(
            "completion_score between 0 and 100",
            name="completion_score_valid",
        ),
        CheckConstraint("photo_count >= 0", name="photo_count_non_negative"),
        CheckConstraint(
            "ranking_score >= 0",
            name="ranking_score_non_negative",
        ),
        CheckConstraint(
            "is_verified = false or verification_status = 'verified'",
            name="verified_flag_requires_verified_status",
        ),
        CheckConstraint(
            "reverification_required = false or "
            "(is_verified = false and verification_status <> 'verified')",
            name="reverification_requires_unverified_profile",
        ),
        CheckConstraint(
            "owner_user_id is not null or is_admin_seeded = true",
            name="owner_or_admin_seeded_required",
        ),
        CheckConstraint(
            "claim_status is null or claim_status in "
            "('unclaimed', 'claimed', 'not_claimable')",
            name="claim_status_valid",
        ),
        CheckConstraint(
            "location_validation_status in "
            "('unvalidated', 'valid', 'warning', 'invalid')",
            name="location_validation_status_valid",
        ),
        Index(
            "uq_profiles_owner_active",
            "owner_user_id",
            unique=True,
            postgresql_where=text("owner_user_id is not null and deleted_at is null"),
        ),
        Index(
            "idx_profiles_role_visibility",
            "role",
            "visibility_status",
            "verification_status",
        ),
        Index(
            "idx_profiles_location",
            "state",
            "city",
            "normalized_locality",
            "pincode",
        ),
        Index(
            "idx_profiles_ranking",
            "role",
            "visibility_status",
            text("ranking_score desc"),
            text("last_activity_at desc"),
        ),
        Index("idx_profiles_owner", "owner_user_id"),
        Index("idx_profiles_state_id", "state_id"),
        Index("idx_profiles_district_id", "district_id"),
        Index("idx_profiles_created_by_admin", "created_by_admin_user_id"),
        Index("idx_profiles_search_vector", "search_vector", postgresql_using="gin"),
        Index(
            "idx_profiles_search_text_trgm",
            "search_text",
            postgresql_using="gin",
            postgresql_ops={"search_text": "gin_trgm_ops"},
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    owner_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    role: Mapped[str] = mapped_column(Text)
    public_name: Mapped[str | None] = mapped_column(Text)
    owner_name: Mapped[str | None] = mapped_column(Text)
    alternate_contact_number: Mapped[str | None] = mapped_column(Text)
    full_address: Mapped[str | None] = mapped_column(Text)
    address_line1: Mapped[str | None] = mapped_column(Text)
    address_line2: Mapped[str | None] = mapped_column(Text)
    locality: Mapped[str | None] = mapped_column(Text)
    normalized_locality: Mapped[str | None] = mapped_column(Text)
    city: Mapped[str | None] = mapped_column(Text)
    state: Mapped[str | None] = mapped_column(Text)
    pincode: Mapped[str | None] = mapped_column(Text)
    state_id: Mapped[int | None] = mapped_column(
        SmallInteger,
        ForeignKey("location_states.id"),
    )
    district_id: Mapped[int | None] = mapped_column(
        Integer,
        ForeignKey("location_districts.id"),
    )
    location_validation_status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'unvalidated'"),
        default="unvalidated",
    )
    location_validated_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True)
    )
    visibility_status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'draft'"),
    )
    verification_status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'unverified'"),
    )
    completion_score: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    completion_flags: Mapped[dict[str, Any]] = mapped_column(
        JSONB,
        server_default=text("'{}'::jsonb"),
    )
    photo_count: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    is_verified: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("false"),
    )
    reverification_required: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("false"),
    )
    ranking_score: Mapped[Decimal] = mapped_column(
        Numeric(10, 4),
        server_default=text("0"),
    )
    last_activity_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    search_text: Mapped[str | None] = mapped_column(Text)
    search_vector: Mapped[str | None] = mapped_column(TSVECTOR)
    is_admin_seeded: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("false"),
    )
    created_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    claim_status: Mapped[str | None] = mapped_column(Text)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class BusinessProfile(TimestampMixin, Base):
    __tablename__ = "business_profiles"
    __table_args__ = (
        Index("idx_business_profiles_business_category", "business_category_id"),
    )

    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
        primary_key=True,
    )
    business_name: Mapped[str] = mapped_column(Text)
    business_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    custom_business_category: Mapped[str | None] = mapped_column(Text)
    manufacture_sell_details: Mapped[str] = mapped_column(Text)
    product_notes: Mapped[str | None] = mapped_column(Text)


class BusinessProfileProductType(Base):
    __tablename__ = "business_profile_product_types"
    __table_args__ = (
        CheckConstraint(
            "product_type_category_id is not null or custom_product_type_text is not null",
            name="product_type_or_custom_required",
        ),
        Index(
            "uq_business_profile_product_types_mapped",
            "profile_id",
            "product_type_category_id",
            unique=True,
            postgresql_where=text("product_type_category_id is not null"),
        ),
        Index(
            "idx_business_profile_product_types_category",
            "product_type_category_id",
            "profile_id",
        ),
        Index("idx_business_profile_product_types_profile", "profile_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("business_profiles.profile_id"),
    )
    product_type_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    custom_product_type_text: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class ProfileBusinessSubtype(Base):
    __tablename__ = "profile_business_subtypes"
    __table_args__ = (
        Index(
            "idx_profile_business_subtypes_subtype",
            "business_subtype_id",
            "profile_id",
        ),
    )

    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("business_profiles.profile_id"),
        primary_key=True,
    )
    business_subtype_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("business_subtypes.id"),
        primary_key=True,
    )
    free_text: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )


class JobWorkerProfile(TimestampMixin, Base):
    __tablename__ = "job_worker_profiles"
    __table_args__ = (
        CheckConstraint(
            "profile_experience_years is null or profile_experience_years >= 0",
            name="profile_experience_years_non_negative",
        ),
    )

    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
        primary_key=True,
    )
    workshop_name: Mapped[str | None] = mapped_column(Text)
    has_workshop: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("true"),
    )
    work_summary: Mapped[str | None] = mapped_column(Text)
    profile_experience_years: Mapped[int | None] = mapped_column(Integer)


class SkilledWorkerProfile(TimestampMixin, Base):
    __tablename__ = "skilled_worker_profiles"
    __table_args__ = (
        CheckConstraint(
            "experience_years is null or experience_years >= 0",
            name="experience_years_non_negative",
        ),
        Index("idx_skilled_worker_profiles_skill", "primary_skill_category_id"),
    )

    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
        primary_key=True,
    )
    primary_skill_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    skill_mastery: Mapped[str] = mapped_column(Text)
    experience_years: Mapped[int | None] = mapped_column(Integer)
    bio: Mapped[str | None] = mapped_column(Text)


class ProfileGstDetail(TimestampMixin, Base):
    __tablename__ = "profile_gst_details"
    __table_args__ = (
        CheckConstraint(
            "review_status in ('unreviewed', 'pending', 'approved', 'rejected')",
            name="review_status_valid",
        ),
        UniqueConstraint("profile_id"),
        Index("idx_profile_gst_details_profile", "profile_id"),
        Index("idx_profile_gst_details_review_status", "review_status"),
        Index("idx_profile_gst_details_reviewed_by", "reviewed_by_admin_user_id"),
        Index("idx_profile_gst_details_proof_media", "proof_media_asset_id"),
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
    gstin: Mapped[str] = mapped_column(Text)
    gst_legal_name: Mapped[str | None] = mapped_column(Text)
    gst_trade_name: Mapped[str | None] = mapped_column(Text)
    gst_status: Mapped[str | None] = mapped_column(Text)
    review_status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'unreviewed'"),
    )
    proof_media_asset_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("media_assets.id"),
    )
    reviewed_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    gst_reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class ProfileChangeHistory(Base):
    __tablename__ = "profile_change_history"
    __table_args__ = (
        CheckConstraint(
            "changed_by_user_id is not null or changed_by_admin_user_id is not null",
            name="changed_by_actor_required",
        ),
        Index("idx_profile_change_history_profile", "profile_id", "created_at"),
        Index("idx_profile_change_history_user", "changed_by_user_id"),
        Index("idx_profile_change_history_admin", "changed_by_admin_user_id"),
        Index(
            "idx_profile_change_history_reverification",
            "requires_reverification",
            "created_at",
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
    changed_by_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    changed_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    changed_fields: Mapped[dict[str, Any]] = mapped_column(JSONB)
    before_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB)
    after_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB)
    requires_reverification: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("false"),
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=text("now()"),
        nullable=False,
    )
