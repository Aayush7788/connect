"""Add the dedicated skilled-worker profile photo type.

Revision ID: 20260720_0022
Revises: 20260719_0021
Create Date: 2026-07-20
"""

from collections.abc import Sequence

from alembic import op


revision: str = "20260720_0022"
down_revision: str | None = "20260719_0021"
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
        "'workplace_photo', 'profile_photo', 'work_photo', 'other')",
    )
    op.execute(
        """
        update media_assets as media
        set document_type = 'profile_photo'
        from profiles
        where media.entity_type = 'profile'
          and media.entity_id = profiles.id
          and profiles.role = 'skilled_worker'
          and media.media_kind = 'image'
          and media.visibility = 'public'
          and media.document_type = 'other'
        """
    )


def downgrade() -> None:
    op.execute(
        "update media_assets set document_type = 'other' "
        "where document_type = 'profile_photo'"
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
        "'workplace_photo', 'work_photo', 'other')",
    )
