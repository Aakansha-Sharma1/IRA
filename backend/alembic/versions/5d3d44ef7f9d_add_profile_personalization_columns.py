"""add_profile_personalization_columns

Revision ID: 5d3d44ef7f9d
Revises: d1b3a1b2c4e5
Create Date: 2026-09-28 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "5d3d44ef7f9d"
down_revision: Union[str, Sequence[str], None] = "d1b3a1b2c4e5"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table("profiles") as batch_op:
        batch_op.add_column(sa.Column("companion_name", sa.String(length=100), nullable=True, server_default="IRA"))
        batch_op.add_column(sa.Column("pronouns", sa.String(length=50), nullable=True, server_default="she/her"))

    # Backfill any existing rows and normalize nulls.
    op.execute(
        "UPDATE profiles SET companion_name = 'IRA' WHERE companion_name IS NULL"
    )
    op.execute(
        "UPDATE profiles SET pronouns = 'she/her' WHERE pronouns IS NULL"
    )

    with op.batch_alter_table("profiles") as batch_op:
        batch_op.alter_column("companion_name", nullable=False, server_default=None)
        batch_op.alter_column("pronouns", nullable=False, server_default=None)


def downgrade() -> None:
    with op.batch_alter_table("profiles") as batch_op:
        batch_op.drop_column("pronouns")
        batch_op.drop_column("companion_name")
