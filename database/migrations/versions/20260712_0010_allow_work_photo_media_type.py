"""allow work photo media type

Revision ID: 20260712_0010
Revises: 20260712_0009
Create Date: 2026-07-12 22:30:00.000000
"""

from collections.abc import Sequence

from alembic import op


revision: str = "20260712_0010"
down_revision: str | None = "20260712_0009"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.drop_constraint(
        op.f("ck_media_assets_document_type_valid"),
        "media_assets",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_media_assets_document_type_valid"),
        "media_assets",
        "document_type is null or document_type in "
        "('identity_proof', 'masked_aadhaar', 'gst_proof', 'shop_photo', "
        "'workplace_photo', 'work_photo', 'other')",
    )


def downgrade() -> None:
    op.execute(
        "update media_assets set document_type = 'other' "
        "where document_type = 'work_photo'"
    )
    op.drop_constraint(
        op.f("ck_media_assets_document_type_valid"),
        "media_assets",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_media_assets_document_type_valid"),
        "media_assets",
        "document_type is null or document_type in "
        "('identity_proof', 'masked_aadhaar', 'gst_proof', 'shop_photo', "
        "'workplace_photo', 'other')",
    )
