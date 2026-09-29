"""create_mood_entries_table

Revision ID: d1b3a1b2c4e5
Revises: 7f4b9c2d1e80
Create Date: 2026-09-28 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "d1b3a1b2c4e5"
down_revision: Union[str, Sequence[str], None] = "7f4b9c2d1e80"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "mood_entries",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("mood", sa.String(length=20), nullable=False),
        sa.Column("intensity", sa.Integer(), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("entry_date", sa.Date(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint(
            "mood IN ('very_low', 'low', 'neutral', 'good', 'very_good')",
            name="ck_mood_entries_mood",
        ),
        sa.CheckConstraint("intensity BETWEEN 1 AND 5", name="ck_mood_entries_intensity"),
        sa.CheckConstraint("note IS NULL OR char_length(note) <= 280", name="ck_mood_entries_note_length"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_mood_entries_user_id"), "mood_entries", ["user_id"], unique=False)
    op.create_index(
        "ix_mood_entries_user_id_created_at",
        "mood_entries",
        ["user_id", "created_at"],
        unique=False,
    )
    op.create_index(
        "ix_mood_entries_user_id_entry_date",
        "mood_entries",
        ["user_id", "entry_date"],
        unique=True,
    )


def downgrade() -> None:
    op.drop_index("ix_mood_entries_user_id_entry_date", table_name="mood_entries")
    op.drop_index("ix_mood_entries_user_id_created_at", table_name="mood_entries")
    op.drop_index(op.f("ix_mood_entries_user_id"), table_name="mood_entries")
    op.drop_table("mood_entries")
