"""Create taxonomy and seed data tables.

Revision ID: 20260711_0003
Revises: 20260711_0002
Create Date: 2026-07-11
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260711_0003"
down_revision: str | None = "20260711_0002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


TABLES_WITH_RLS = (
    "categories",
    "category_aliases",
    "category_suggestions",
    "business_subtypes",
)

TABLES_WITH_UPDATED_AT = TABLES_WITH_RLS


SEED_TAXONOMY_SQL = """
insert into categories (
  category_type,
  parent_id,
  name,
  slug,
  normalized_name,
  sort_order,
  metadata
)
select
  v.category_type,
  null,
  v.name,
  v.slug,
  v.normalized_name,
  v.sort_order,
  '{}'::jsonb
from (
  values
    ('work_category', 'Embroidery', 'embroidery', 'embroidery', 10),
    ('work_category', 'Decorative and hand work', 'decorative-hand-work', 'decorative and hand work', 20),
    ('work_category', 'Printing', 'printing', 'printing', 30),
    ('work_category', 'Dyeing and traditional processes', 'dyeing-traditional-processes', 'dyeing and traditional processes', 40),
    ('work_category', 'Fabric finishing', 'fabric-finishing', 'fabric finishing', 50),
    ('work_category', 'Stitching', 'stitching', 'stitching', 60),
    ('product_type', 'Dupatta', 'dupatta', 'dupatta', 10),
    ('product_type', 'Saree', 'saree', 'saree', 20),
    ('product_type', 'Fabric', 'fabric', 'fabric', 30),
    ('product_type', 'Kurti', 'kurti', 'kurti', 40),
    ('product_type', 'Dress material', 'dress-material', 'dress material', 50),
    ('product_type', 'Lehenga', 'lehenga', 'lehenga', 60),
    ('product_type', 'Blouse', 'blouse', 'blouse', 70),
    ('product_type', 'Gown', 'gown', 'gown', 80),
    ('product_type', 'Scarf', 'scarf', 'scarf', 90),
    ('product_type', 'Shawl', 'shawl', 'shawl', 100)
) as v(category_type, name, slug, normalized_name, sort_order)
on conflict (category_type, slug) do nothing;

insert into categories (
  category_type,
  parent_id,
  name,
  slug,
  normalized_name,
  sort_order,
  metadata
)
select
  'work_name',
  p.id,
  v.name,
  v.slug,
  v.normalized_name,
  v.sort_order,
  '{}'::jsonb
from (
  values
    ('embroidery', 'Zari work', 'zari-work', 'zari work', 10),
    ('embroidery', 'Bead work', 'bead-work', 'bead work', 20),
    ('embroidery', 'Aari work', 'aari-work', 'aari work', 30),
    ('embroidery', 'Khatli work', 'khatli-work', 'khatli work', 40),
    ('embroidery', 'Machine embroidery', 'machine-embroidery', 'machine embroidery', 50),
    ('embroidery', 'Hand embroidery', 'hand-embroidery', 'hand embroidery', 60),
    ('decorative-hand-work', 'Mirror work', 'mirror-work', 'mirror work', 10),
    ('decorative-hand-work', 'Hand work', 'hand-work', 'hand work', 20),
    ('decorative-hand-work', 'Lace work', 'lace-work', 'lace work', 30),
    ('decorative-hand-work', 'Diamond work', 'diamond-work', 'diamond work', 40),
    ('decorative-hand-work', 'Zardhad diamond work', 'zardhad-diamond-work', 'zardhad diamond work', 50),
    ('decorative-hand-work', 'Sarokhi diamond work', 'sarokhi-diamond-work', 'sarokhi diamond work', 60),
    ('printing', 'Digital print', 'digital-print', 'digital print', 10),
    ('printing', 'Khadi print', 'khadi-print', 'khadi print', 20),
    ('printing', 'Wax print', 'wax-print', 'wax print', 30),
    ('printing', 'Table print', 'table-print', 'table print', 40),
    ('printing', 'Block print', 'block-print', 'block print', 50),
    ('printing', 'Ajrakh print', 'ajrakh-print', 'ajrakh print', 60),
    ('printing', 'Brush print', 'brush-print', 'brush print', 70),
    ('dyeing-traditional-processes', 'Hand dyeing', 'hand-dyeing', 'hand dyeing', 10),
    ('dyeing-traditional-processes', 'Murgha print', 'murgha-print', 'murgha print', 20),
    ('dyeing-traditional-processes', 'Shibori print', 'shibori-print', 'shibori print', 30),
    ('dyeing-traditional-processes', 'Lahariya print', 'lahariya-print', 'lahariya print', 40),
    ('fabric-finishing', 'Crush pleating', 'crush-pleating', 'crush pleating', 10),
    ('fabric-finishing', 'Pleating', 'pleating', 'pleating', 20),
    ('fabric-finishing', 'Washing', 'washing', 'washing', 30),
    ('fabric-finishing', 'Finishing', 'finishing', 'finishing', 40),
    ('fabric-finishing', 'Cutting', 'cutting', 'cutting', 50),
    ('fabric-finishing', 'Folding', 'folding', 'folding', 60),
    ('fabric-finishing', 'Packing', 'packing', 'packing', 70),
    ('stitching', 'Flat hemming', 'flat-hemming', 'flat hemming', 10),
    ('stitching', 'Overlock stitching', 'overlock-stitching', 'overlock stitching', 20),
    ('stitching', 'Specialised stitching', 'specialised-stitching', 'specialised stitching', 30)
) as v(parent_slug, name, slug, normalized_name, sort_order)
join categories p
  on p.category_type = 'work_category'
 and p.slug = v.parent_slug
on conflict (category_type, slug) do nothing;

insert into category_aliases (
  category_id,
  alias_text,
  normalized_alias,
  language,
  source
)
select
  c.id,
  v.alias_text,
  v.normalized_alias,
  v.language,
  'import'
from (
  values
    ('work_name', 'flat-hemming', 'Pico', 'pico', 'hinglish'),
    ('work_name', 'flat-hemming', 'Piko', 'piko', 'hinglish'),
    ('work_name', 'flat-hemming', 'Hemming', 'hemming', 'en'),
    ('work_name', 'flat-hemming', 'Flat hem', 'flat hem', 'en'),
    ('work_name', 'overlock-stitching', 'Overlock', 'overlock', 'en'),
    ('work_name', 'digital-print', 'Digital printing', 'digital printing', 'en'),
    ('work_name', 'digital-print', 'Digi print', 'digi print', 'hinglish'),
    ('work_name', 'zari-work', 'Zari', 'zari', 'en'),
    ('work_name', 'zari-work', 'Jari work', 'jari work', 'hinglish'),
    ('work_name', 'aari-work', 'Aari', 'aari', 'en'),
    ('work_name', 'mirror-work', 'Mirror', 'mirror', 'en'),
    ('work_name', 'lace-work', 'Lace', 'lace', 'en'),
    ('work_category', 'embroidery', 'Bharat work', 'bharat work', 'hinglish'),
    ('work_category', 'printing', 'Print work', 'print work', 'en'),
    ('work_category', 'stitching', 'Silai work', 'silai work', 'hinglish'),
    ('product_type', 'dupatta', 'Dupatta job', 'dupatta job', 'en'),
    ('product_type', 'dupatta', 'Chunni', 'chunni', 'hinglish'),
    ('product_type', 'saree', 'Sari', 'sari', 'en'),
    ('product_type', 'saree', 'Saari', 'saari', 'hinglish'),
    ('product_type', 'fabric', 'Cloth', 'cloth', 'en'),
    ('product_type', 'fabric', 'Kapda', 'kapda', 'hinglish'),
    ('product_type', 'dress-material', 'Dress material job', 'dress material job', 'en')
) as v(category_type, slug, alias_text, normalized_alias, language)
join categories c
  on c.category_type = v.category_type
 and c.slug = v.slug
on conflict (category_id, normalized_alias) do nothing;

insert into business_subtypes (
  code,
  label,
  sort_order
)
values
  ('manufacturer', 'Manufacturer', 10),
  ('wholesaler', 'Wholesaler', 20),
  ('trader', 'Trader', 30),
  ('retailer', 'Retailer', 40),
  ('other', 'Other', 50)
on conflict (code) do nothing;
"""


def upgrade() -> None:
    op.create_table(
        "categories",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("parent_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("category_type", sa.Text(), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("slug", sa.Text(), nullable=False),
        sa.Column("normalized_name", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column(
            "is_active",
            sa.Boolean(),
            server_default=sa.text("true"),
            nullable=False,
        ),
        sa.Column(
            "sort_order",
            sa.Integer(),
            server_default=sa.text("0"),
            nullable=False,
        ),
        sa.Column(
            "created_by_admin_user_id",
            postgresql.UUID(as_uuid=True),
            nullable=True,
        ),
        sa.Column(
            "metadata",
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
        sa.CheckConstraint(
            (
                "category_type in ("
                "'business_category', 'work_category', 'work_name', "
                "'product_type', 'skill'"
                ")"
            ),
            name=op.f("ck_categories_category_type_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["created_by_admin_user_id"],
            ["admin_users.id"],
            name=op.f("fk_categories_created_by_admin_user_id_admin_users"),
        ),
        sa.ForeignKeyConstraint(
            ["parent_id"],
            ["categories.id"],
            name=op.f("fk_categories_parent_id_categories"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_categories")),
        sa.UniqueConstraint(
            "category_type",
            "slug",
            name=op.f("uq_categories_category_type"),
        ),
    )
    op.create_index(
        "idx_categories_created_by_admin",
        "categories",
        ["created_by_admin_user_id"],
    )
    op.create_index("idx_categories_parent", "categories", ["parent_id"])
    op.create_index(
        "idx_categories_type_normalized",
        "categories",
        ["category_type", "normalized_name"],
    )
    op.create_index(
        "idx_categories_type_parent",
        "categories",
        ["category_type", "parent_id", "is_active", "sort_order"],
    )

    op.create_table(
        "category_aliases",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("category_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("alias_text", sa.Text(), nullable=False),
        sa.Column("normalized_alias", sa.Text(), nullable=False),
        sa.Column("language", sa.Text(), nullable=True),
        sa.Column(
            "source",
            sa.Text(),
            server_default=sa.text("'admin'"),
            nullable=False,
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            server_default=sa.text("true"),
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
        sa.CheckConstraint(
            "language is null or language in ('en', 'hi', 'gu', 'hinglish', 'unknown')",
            name=op.f("ck_category_aliases_language_valid"),
        ),
        sa.CheckConstraint(
            "source in ('admin', 'user_suggestion', 'search_log', 'import')",
            name=op.f("ck_category_aliases_source_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["category_id"],
            ["categories.id"],
            name=op.f("fk_category_aliases_category_id_categories"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_category_aliases")),
        sa.UniqueConstraint(
            "category_id",
            "normalized_alias",
            name=op.f("uq_category_aliases_category_id"),
        ),
    )
    op.create_index(
        "idx_category_aliases_category",
        "category_aliases",
        ["category_id"],
    )
    op.create_index(
        "idx_category_aliases_normalized",
        "category_aliases",
        ["normalized_alias"],
    )

    op.create_table(
        "category_suggestions",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column(
            "submitted_by_user_id",
            postgresql.UUID(as_uuid=True),
            nullable=True,
        ),
        sa.Column("profile_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("source_entity_type", sa.Text(), nullable=True),
        sa.Column("source_entity_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("category_type", sa.Text(), nullable=False),
        sa.Column("raw_text", sa.Text(), nullable=False),
        sa.Column("normalized_text", sa.Text(), nullable=False),
        sa.Column(
            "status",
            sa.Text(),
            server_default=sa.text("'pending'"),
            nullable=False,
        ),
        sa.Column("mapped_category_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column(
            "reviewed_by_admin_user_id",
            postgresql.UUID(as_uuid=True),
            nullable=True,
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
        sa.CheckConstraint(
            "source_entity_type is null or source_entity_type in "
            "('work_card', 'work_needed_post', 'profile')",
            name=op.f("ck_category_suggestions_source_entity_type_valid"),
        ),
        sa.CheckConstraint(
            (
                "category_type in ("
                "'business_category', 'work_category', 'work_name', "
                "'product_type', 'skill'"
                ")"
            ),
            name=op.f("ck_category_suggestions_category_type_valid"),
        ),
        sa.CheckConstraint(
            "status in ('pending', 'mapped', 'rejected')",
            name=op.f("ck_category_suggestions_status_valid"),
        ),
        sa.CheckConstraint(
            "status <> 'mapped' or mapped_category_id is not null",
            name=op.f("ck_category_suggestions_mapped_status_requires_category"),
        ),
        sa.ForeignKeyConstraint(
            ["mapped_category_id"],
            ["categories.id"],
            name=op.f("fk_category_suggestions_mapped_category_id_categories"),
        ),
        sa.ForeignKeyConstraint(
            ["reviewed_by_admin_user_id"],
            ["admin_users.id"],
            name=op.f("fk_category_suggestions_reviewed_by_admin_user_id_admin_users"),
        ),
        sa.ForeignKeyConstraint(
            ["submitted_by_user_id"],
            ["users.id"],
            name=op.f("fk_category_suggestions_submitted_by_user_id_users"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_category_suggestions")),
    )
    op.create_index(
        "idx_category_suggestions_mapped_category",
        "category_suggestions",
        ["mapped_category_id"],
    )
    op.create_index(
        "idx_category_suggestions_normalized",
        "category_suggestions",
        ["normalized_text"],
    )
    op.create_index(
        "idx_category_suggestions_profile",
        "category_suggestions",
        ["profile_id"],
    )
    op.create_index(
        "idx_category_suggestions_reviewed_by",
        "category_suggestions",
        ["reviewed_by_admin_user_id"],
    )
    op.create_index(
        "idx_category_suggestions_source",
        "category_suggestions",
        ["source_entity_type", "source_entity_id"],
    )
    op.create_index(
        "idx_category_suggestions_status",
        "category_suggestions",
        ["status"],
    )
    op.create_index(
        "idx_category_suggestions_submitter",
        "category_suggestions",
        ["submitted_by_user_id"],
    )
    op.create_index(
        "idx_category_suggestions_type_status",
        "category_suggestions",
        ["category_type", "status"],
    )

    op.create_table(
        "business_subtypes",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("code", sa.Text(), nullable=False),
        sa.Column("label", sa.Text(), nullable=False),
        sa.Column(
            "is_active",
            sa.Boolean(),
            server_default=sa.text("true"),
            nullable=False,
        ),
        sa.Column(
            "sort_order",
            sa.Integer(),
            server_default=sa.text("0"),
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
        sa.PrimaryKeyConstraint("id", name=op.f("pk_business_subtypes")),
        sa.UniqueConstraint("code", name=op.f("uq_business_subtypes_code")),
    )
    op.create_index(
        "idx_business_subtypes_active_sort",
        "business_subtypes",
        ["is_active", "sort_order"],
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

    op.execute(SEED_TAXONOMY_SQL)


def downgrade() -> None:
    for table_name in reversed(TABLES_WITH_UPDATED_AT):
        op.execute(
            f"drop trigger if exists trg_{table_name}_set_updated_at on public.{table_name}"
        )

    op.drop_index(
        "idx_business_subtypes_active_sort",
        table_name="business_subtypes",
    )
    op.drop_table("business_subtypes")

    op.drop_index(
        "idx_category_suggestions_type_status",
        table_name="category_suggestions",
    )
    op.drop_index(
        "idx_category_suggestions_submitter",
        table_name="category_suggestions",
    )
    op.drop_index(
        "idx_category_suggestions_status",
        table_name="category_suggestions",
    )
    op.drop_index(
        "idx_category_suggestions_source",
        table_name="category_suggestions",
    )
    op.drop_index(
        "idx_category_suggestions_reviewed_by",
        table_name="category_suggestions",
    )
    op.drop_index(
        "idx_category_suggestions_profile",
        table_name="category_suggestions",
    )
    op.drop_index(
        "idx_category_suggestions_normalized",
        table_name="category_suggestions",
    )
    op.drop_index(
        "idx_category_suggestions_mapped_category",
        table_name="category_suggestions",
    )
    op.drop_table("category_suggestions")

    op.drop_index(
        "idx_category_aliases_normalized",
        table_name="category_aliases",
    )
    op.drop_index(
        "idx_category_aliases_category",
        table_name="category_aliases",
    )
    op.drop_table("category_aliases")

    op.drop_index("idx_categories_type_parent", table_name="categories")
    op.drop_index("idx_categories_type_normalized", table_name="categories")
    op.drop_index("idx_categories_parent", table_name="categories")
    op.drop_index("idx_categories_created_by_admin", table_name="categories")
    op.drop_table("categories")
