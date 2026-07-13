from datetime import datetime
from decimal import Decimal
from uuid import UUID

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Index, Integer, Numeric
from sqlalchemy import Text, text
from sqlalchemy.dialects.postgresql import TSVECTOR, UUID as PgUUID
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


class WorkCard(TimestampMixin, Base):
    __tablename__ = "work_cards"
    __table_args__ = (
        CheckConstraint(
            "status in "
            "('draft', 'published', 'hidden_by_user', 'removed_by_admin', 'deleted')",
            name="status_valid",
        ),
        CheckConstraint("photo_count >= 0", name="photo_count_non_negative"),
        CheckConstraint(
            "ranking_score >= 0",
            name="ranking_score_non_negative",
        ),
        CheckConstraint(
            "experience_years is null or experience_years >= 0",
            name="experience_years_non_negative",
        ),
        CheckConstraint(
            "nullif(btrim(title), '') is not null",
            name="title_non_empty",
        ),
        CheckConstraint(
            "(creation_idempotency_key is null and creation_request_hash is null) "
            "or (creation_idempotency_key is not null and "
            "creation_request_hash is not null)",
            name="idempotency_fields_together",
        ),
        CheckConstraint(
            "creation_idempotency_key is null or "
            "char_length(creation_idempotency_key) between 1 and 128",
            name="idempotency_key_length",
        ),
        CheckConstraint(
            "status not in ('published', 'hidden_by_user') or "
            "(photo_count >= 3 and "
            "nullif(btrim(description), '') is not null and "
            "(work_category_id is not null or "
            "nullif(btrim(custom_work_category_text), '') is not null) and "
            "(work_name_category_id is not null or "
            "nullif(btrim(custom_work_name), '') is not null))",
            name="publish_requires_required_fields",
        ),
        Index("idx_work_cards_profile_status", "profile_id", "status"),
        Index(
            "idx_work_cards_category_status",
            "work_category_id",
            "work_name_category_id",
            "status",
        ),
        Index(
            "idx_work_cards_ranking",
            "status",
            text("ranking_score desc"),
            text("last_activity_at desc"),
        ),
        Index("idx_work_cards_search_vector", "search_vector", postgresql_using="gin"),
        Index(
            "idx_work_cards_search_text_trgm",
            "search_text",
            postgresql_using="gin",
            postgresql_ops={"search_text": "gin_trgm_ops"},
        ),
        Index(
            "uq_work_cards_creation_idempotency",
            "profile_id",
            "creation_idempotency_key",
            unique=True,
            postgresql_where=text("creation_idempotency_key is not null"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    profile_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("job_worker_profiles.profile_id"),
    )
    work_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    work_name_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    custom_work_category_text: Mapped[str | None] = mapped_column(Text)
    custom_work_name: Mapped[str | None] = mapped_column(Text)
    title: Mapped[str] = mapped_column(Text)
    description: Mapped[str | None] = mapped_column(Text)
    experience_years: Mapped[int | None] = mapped_column(Integer)
    creation_idempotency_key: Mapped[str | None] = mapped_column(Text)
    creation_request_hash: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'draft'"),
    )
    photo_count: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    last_activity_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    ranking_score: Mapped[Decimal] = mapped_column(
        Numeric(10, 4),
        server_default=text("0"),
    )
    search_text: Mapped[str | None] = mapped_column(Text)
    search_vector: Mapped[str | None] = mapped_column(TSVECTOR)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class WorkCardProductType(Base):
    __tablename__ = "work_card_product_types"
    __table_args__ = (
        CheckConstraint(
            "product_type_category_id is not null or "
            "nullif(btrim(custom_product_type_text), '') is not null",
            name="product_type_or_custom_required",
        ),
        Index("idx_work_card_product_types_work_card", "work_card_id"),
        Index(
            "idx_work_card_product_types_category",
            "product_type_category_id",
            "work_card_id",
        ),
        Index(
            "uq_work_card_product_types_mapped",
            "work_card_id",
            "product_type_category_id",
            unique=True,
            postgresql_where=text("product_type_category_id is not null"),
        ),
        Index(
            "uq_work_card_product_types_custom",
            "work_card_id",
            text("lower(btrim(custom_product_type_text))"),
            unique=True,
            postgresql_where=text("custom_product_type_text is not null"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    work_card_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("work_cards.id"),
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


class WorkNeededPost(TimestampMixin, Base):
    __tablename__ = "work_needed_posts"
    __table_args__ = (
        CheckConstraint(
            "status in "
            "('draft', 'active', 'paused', 'closed_by_user', "
            "'removed_by_admin', 'deleted')",
            name="status_valid",
        ),
        CheckConstraint("photo_count >= 0", name="photo_count_non_negative"),
        CheckConstraint(
            "ranking_score >= 0",
            name="ranking_score_non_negative",
        ),
        CheckConstraint(
            "nullif(btrim(title), '') is not null",
            name="title_non_empty",
        ),
        CheckConstraint(
            "(creation_idempotency_key is null and creation_request_hash is null) "
            "or (creation_idempotency_key is not null and "
            "creation_request_hash is not null)",
            name="idempotency_fields_together",
        ),
        CheckConstraint(
            "creation_idempotency_key is null or "
            "char_length(creation_idempotency_key) between 1 and 128",
            name="idempotency_key_length",
        ),
        CheckConstraint(
            "closed_at is null or "
            "status in ('closed_by_user', 'removed_by_admin', 'deleted')",
            name="closed_at_requires_closed_status",
        ),
        CheckConstraint(
            "status not in ('active', 'paused', 'closed_by_user') or "
            "(photo_count >= 3 and "
            "nullif(btrim(description), '') is not null and "
            "(work_category_id is not null or "
            "nullif(btrim(custom_work_category_text), '') is not null) and "
            "(work_name_category_id is not null or "
            "nullif(btrim(custom_work_name), '') is not null))",
            name="publish_requires_required_fields",
        ),
        Index("idx_work_needed_posts_profile_status", "profile_id", "status"),
        Index(
            "idx_work_needed_posts_category_status",
            "work_category_id",
            "work_name_category_id",
            "status",
        ),
        Index(
            "idx_work_needed_posts_ranking",
            "status",
            text("ranking_score desc"),
            text("last_activity_at desc"),
        ),
        Index(
            "idx_work_needed_posts_search_vector",
            "search_vector",
            postgresql_using="gin",
        ),
        Index(
            "idx_work_needed_posts_search_text_trgm",
            "search_text",
            postgresql_using="gin",
            postgresql_ops={"search_text": "gin_trgm_ops"},
        ),
        Index(
            "uq_work_needed_posts_creation_idempotency",
            "profile_id",
            "creation_idempotency_key",
            unique=True,
            postgresql_where=text("creation_idempotency_key is not null"),
        ),
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
    work_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    work_name_category_id: Mapped[UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("categories.id"),
    )
    custom_work_category_text: Mapped[str | None] = mapped_column(Text)
    custom_work_name: Mapped[str | None] = mapped_column(Text)
    title: Mapped[str] = mapped_column(Text)
    description: Mapped[str | None] = mapped_column(Text)
    creation_idempotency_key: Mapped[str | None] = mapped_column(Text)
    creation_request_hash: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str] = mapped_column(
        Text,
        server_default=text("'draft'"),
    )
    photo_count: Mapped[int] = mapped_column(
        Integer,
        server_default=text("0"),
    )
    last_activity_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    ranking_score: Mapped[Decimal] = mapped_column(
        Numeric(10, 4),
        server_default=text("0"),
    )
    search_text: Mapped[str | None] = mapped_column(Text)
    search_vector: Mapped[str | None] = mapped_column(TSVECTOR)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class WorkNeededPostProductType(Base):
    __tablename__ = "work_needed_post_product_types"
    __table_args__ = (
        CheckConstraint(
            "product_type_category_id is not null or "
            "nullif(btrim(custom_product_type_text), '') is not null",
            name="product_type_or_custom_required",
        ),
        Index(
            "idx_work_needed_post_product_types_post",
            "work_needed_post_id",
        ),
        Index(
            "idx_work_needed_post_product_types_category",
            "product_type_category_id",
            "work_needed_post_id",
        ),
        Index(
            "uq_work_needed_post_product_types_mapped",
            "work_needed_post_id",
            "product_type_category_id",
            unique=True,
            postgresql_where=text("product_type_category_id is not null"),
        ),
        Index(
            "uq_work_needed_post_product_types_custom",
            "work_needed_post_id",
            text("lower(btrim(custom_product_type_text))"),
            unique=True,
            postgresql_where=text("custom_product_type_text is not null"),
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()"),
    )
    work_needed_post_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("work_needed_posts.id"),
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
