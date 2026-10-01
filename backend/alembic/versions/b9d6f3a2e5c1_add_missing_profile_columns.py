"""add_missing_profile_columns

Revision ID: b9d6f3a2e5c1
Revises: d1b3a1b2c4e5
Create Date: 2026-10-01 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "b9d6f3a2e5c1"
down_revision: Union[str, Sequence[str], None] = "d1b3a1b2c4e5"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "profiles",
        sa.Column("companion_name", sa.String(length=100), nullable=False, server_default="IRA"),
    )
    op.add_column(
        "profiles",
        sa.Column("pronouns", sa.String(length=50), nullable=False, server_default="she/her"),
    )

    # Ensure existing rows get the default values in case a legacy schema is already populated.
    op.alter_column("profiles", "companion_name", server_default=None)
    op.alter_column("profiles", "pronouns", server_default=None)


def downgrade() -> None:
    op.drop_column("profiles", "pronouns")
    op.drop_column("profiles", "companion_name")
