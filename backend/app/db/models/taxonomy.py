from datetime import datetime
from typing import Any
from uuid import UUID

from sqlalchemy import Boolean, CheckConstraint, DateTime, ForeignKey, Index, Integer
from sqlalchemy import Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import JSONB, UUID as PgUUID
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


class Category(TimestampMixin, Base):
    __tablename__ = "categories"
    __table_args__ = (
        CheckConstraint(
            (
                "category_type in ("
                "'business_category', 'work_category', 'work_name', "
                "'product_type', 'skill'"
                ")"
            ),
            name="category_type_valid",
        ),
        UniqueConstraint("category_type", "slug"),
        Index(
            "idx_categories_type_parent",
            "category_type",
            "parent_id",
            "is_active",
            "sort_order",
        ),
        Index("idx_categories_parent", "parent_id"),
        Index("idx_categories_type_normalized", "category_type", "normalized_name"),
        Index("idx_categories_created_by_admin", "created_by_admin_user_id"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    parent_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    category_type: Mapped[str] = mapped_column(Text)
    name: Mapped[str] = mapped_column(Text)
    slug: Mapped[str] = mapped_column(Text)
    normalized_name: Mapped[str] = mapped_column(Text)
    description: Mapped[str | None] = mapped_column(Text)
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("true"),
    )
    sort_order: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    created_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )
    metadata_json: Mapped[dict[str, Any]] = mapped_column(
        "metadata",
        JSONB,
        server_default=text("'{}'::jsonb"),
    )


class CategoryAlias(TimestampMixin, Base):
    __tablename__ = "category_aliases"
    __table_args__ = (
        CheckConstraint(
            "language is null or language in ('en', 'hi', 'gu', 'hinglish', 'unknown')",
            name="language_valid",
        ),
        CheckConstraint(
            "source in ('admin', 'user_suggestion', 'search_log', 'import')",
            name="source_valid",
        ),
        UniqueConstraint("category_id", "normalized_alias"),
        Index("idx_category_aliases_category", "category_id"),
        Index("idx_category_aliases_normalized", "normalized_alias"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    category_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    alias_text: Mapped[str] = mapped_column(Text)
    normalized_alias: Mapped[str] = mapped_column(Text)
    language: Mapped[str | None] = mapped_column(Text)
    source: Mapped[str] = mapped_column(Text, server_default=text("'admin'"))
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("true"),
    )


class CategorySuggestion(TimestampMixin, Base):
    __tablename__ = "category_suggestions"
    __table_args__ = (
        CheckConstraint(
            "source_entity_type is null or source_entity_type in "
            "('work_card', 'work_needed_post', 'profile')",
            name="source_entity_type_valid",
        ),
        CheckConstraint(
            (
                "category_type in ("
                "'business_category', 'work_category', 'work_name', "
                "'product_type', 'skill'"
                ")"
            ),
            name="category_type_valid",
        ),
        CheckConstraint(
            "status in ('pending', 'mapped', 'rejected')",
            name="status_valid",
        ),
        CheckConstraint(
            "status <> 'mapped' or mapped_category_id is not null",
            name="mapped_status_requires_category",
        ),
        Index("idx_category_suggestions_submitter", "submitted_by_user_id"),
        Index("idx_category_suggestions_profile", "profile_id"),
        Index("idx_category_suggestions_status", "status"),
        Index("idx_category_suggestions_type_status", "category_type", "status"),
        Index("idx_category_suggestions_normalized", "normalized_text"),
        Index("idx_category_suggestions_mapped_category", "mapped_category_id"),
        Index("idx_category_suggestions_reviewed_by", "reviewed_by_admin_user_id"),
        Index(
            "idx_category_suggestions_source",
            "source_entity_type",
            "source_entity_id",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    submitted_by_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id"),
    )
    profile_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("profiles.id"),
    )
    source_entity_type: Mapped[str | None] = mapped_column(Text)
    source_entity_id: Mapped[UUID | None] = mapped_column(PgUUID(as_uuid=True))
    category_type: Mapped[str] = mapped_column(Text)
    raw_text: Mapped[str] = mapped_column(Text)
    normalized_text: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(Text, server_default=text("'pending'"))
    mapped_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    reviewed_by_admin_user_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("admin_users.id"),
    )


class BusinessSubtype(TimestampMixin, Base):
    __tablename__ = "business_subtypes"
    __table_args__ = (
        UniqueConstraint("code"),
        Index("idx_business_subtypes_active_sort", "is_active", "sort_order"),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    code: Mapped[str] = mapped_column(Text)
    label: Mapped[str] = mapped_column(Text)
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        server_default=text("true"),
    )
    sort_order: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
