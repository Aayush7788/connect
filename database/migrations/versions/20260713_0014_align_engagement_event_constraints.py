"""Align engagement event constraints with the public API contract.

Revision ID: 20260713_0014
Revises: 20260713_0013
"""

from collections.abc import Sequence

from alembic import op


revision: str = "20260713_0014"
down_revision: str | None = "20260713_0013"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.drop_constraint(
        op.f("ck_contact_action_events_action_type_valid"),
        "contact_action_events",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_contact_action_events_action_type_valid"),
        "contact_action_events",
        "action_type in ('call', 'whatsapp', 'address', 'show_contact')",
    )
    op.drop_constraint(
        op.f("ck_share_events_share_channel_valid"),
        "share_events",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_share_events_share_channel_valid"),
        "share_events",
        "share_channel is null or share_channel in "
        "('copy_link', 'whatsapp', 'sms', 'x', 'email', 'linkedin', "
        "'native_other', 'system_share')",
    )


def downgrade() -> None:
    op.execute(
        "update contact_action_events set action_type = 'show_contact' "
        "where action_type = 'address'"
    )
    op.execute(
        "update share_events set share_channel = 'system_share' "
        "where share_channel in ('copy_link', 'native_other')"
    )
    op.drop_constraint(
        op.f("ck_share_events_share_channel_valid"),
        "share_events",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_share_events_share_channel_valid"),
        "share_events",
        "share_channel is null or share_channel in "
        "('whatsapp', 'sms', 'x', 'email', 'linkedin', 'system_share')",
    )
    op.drop_constraint(
        op.f("ck_contact_action_events_action_type_valid"),
        "contact_action_events",
        type_="check",
    )
    op.create_check_constraint(
        op.f("ck_contact_action_events_action_type_valid"),
        "contact_action_events",
        "action_type in ('call', 'whatsapp', 'show_contact')",
    )
