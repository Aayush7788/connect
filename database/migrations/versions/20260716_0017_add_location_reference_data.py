"""add compact India Post location reference schema

Revision ID: 20260716_0017
Revises: 20260716_0016
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "20260716_0017"
down_revision: str | None = "20260716_0016"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


REFERENCE_TABLES = (
    "location_states",
    "location_districts",
    "postal_codes",
    "postal_areas",
)


def upgrade() -> None:
    op.create_table(
        "location_states",
        sa.Column("id", sa.SmallInteger(), autoincrement=True, nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("normalized_name", sa.Text(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_location_states")),
        sa.UniqueConstraint(
            "normalized_name", name=op.f("uq_location_states_normalized_name")
        ),
    )
    op.create_index(
        "idx_location_states_name", "location_states", ["normalized_name"]
    )

    op.create_table(
        "location_districts",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("state_id", sa.SmallInteger(), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("normalized_name", sa.Text(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["state_id"],
            ["location_states.id"],
            name=op.f("fk_location_districts_state_id_location_states"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_location_districts")),
        sa.UniqueConstraint(
            "state_id",
            "normalized_name",
            name=op.f("uq_location_districts_state_id"),
        ),
    )
    op.create_index(
        "idx_location_districts_state_name",
        "location_districts",
        ["state_id", "normalized_name"],
    )

    op.create_table(
        "postal_codes",
        sa.Column("pincode", sa.String(length=6), nullable=False),
        sa.Column("state_id", sa.SmallInteger(), nullable=False),
        sa.Column("district_id", sa.Integer(), nullable=False),
        sa.Column(
            "is_delivery", sa.Boolean(), server_default=sa.text("true"), nullable=False
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["district_id"],
            ["location_districts.id"],
            name=op.f("fk_postal_codes_district_id_location_districts"),
        ),
        sa.ForeignKeyConstraint(
            ["state_id"],
            ["location_states.id"],
            name=op.f("fk_postal_codes_state_id_location_states"),
        ),
        sa.PrimaryKeyConstraint("pincode", name=op.f("pk_postal_codes")),
        sa.CheckConstraint(
            "pincode ~ '^[0-9]{6}$'", name=op.f("ck_postal_codes_pincode_format")
        ),
    )
    op.create_index(
        "idx_postal_codes_state_district",
        "postal_codes",
        ["state_id", "district_id"],
    )

    op.create_table(
        "postal_areas",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("pincode", sa.String(length=6), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("normalized_name", sa.Text(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["pincode"],
            ["postal_codes.pincode"],
            name=op.f("fk_postal_areas_pincode_postal_codes"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_postal_areas")),
        sa.UniqueConstraint(
            "pincode",
            "normalized_name",
            name=op.f("uq_postal_areas_pincode"),
        ),
    )
    op.create_index(
        "idx_postal_areas_pincode_name",
        "postal_areas",
        ["pincode", "normalized_name"],
    )

    op.add_column("profiles", sa.Column("state_id", sa.SmallInteger()))
    op.add_column("profiles", sa.Column("district_id", sa.Integer()))
    op.add_column(
        "profiles",
        sa.Column(
            "location_validation_status",
            sa.Text(),
            server_default=sa.text("'unvalidated'"),
            nullable=False,
        ),
    )
    op.add_column(
        "profiles", sa.Column("location_validated_at", sa.DateTime(timezone=True))
    )
    op.create_foreign_key(
        op.f("fk_profiles_state_id_location_states"),
        "profiles",
        "location_states",
        ["state_id"],
        ["id"],
    )
    op.create_foreign_key(
        op.f("fk_profiles_district_id_location_districts"),
        "profiles",
        "location_districts",
        ["district_id"],
        ["id"],
    )
    op.create_check_constraint(
        op.f("ck_profiles_location_validation_status_valid"),
        "profiles",
        "location_validation_status in ('unvalidated', 'valid', 'warning', 'invalid')",
    )
    op.create_index("idx_profiles_state_id", "profiles", ["state_id"])
    op.create_index("idx_profiles_district_id", "profiles", ["district_id"])

    for table_name in REFERENCE_TABLES:
        op.execute(f"alter table public.{table_name} enable row level security")
        op.execute(f"revoke all on public.{table_name} from public")
        op.execute(
            f"revoke all on sequence public.{table_name}_id_seq from public"
            if table_name != "postal_codes"
            else "select 1"
        )


def downgrade() -> None:
    op.drop_index("idx_profiles_district_id", table_name="profiles")
    op.drop_index("idx_profiles_state_id", table_name="profiles")
    op.drop_constraint(
        op.f("ck_profiles_location_validation_status_valid"),
        "profiles",
        type_="check",
    )
    op.drop_constraint(
        op.f("fk_profiles_district_id_location_districts"),
        "profiles",
        type_="foreignkey",
    )
    op.drop_constraint(
        op.f("fk_profiles_state_id_location_states"),
        "profiles",
        type_="foreignkey",
    )
    op.drop_column("profiles", "location_validated_at")
    op.drop_column("profiles", "location_validation_status")
    op.drop_column("profiles", "district_id")
    op.drop_column("profiles", "state_id")
    op.drop_index("idx_postal_areas_pincode_name", table_name="postal_areas")
    op.drop_table("postal_areas")
    op.drop_index("idx_postal_codes_state_district", table_name="postal_codes")
    op.drop_table("postal_codes")
    op.drop_index(
        "idx_location_districts_state_name", table_name="location_districts"
    )
    op.drop_table("location_districts")
    op.drop_index("idx_location_states_name", table_name="location_states")
    op.drop_table("location_states")
