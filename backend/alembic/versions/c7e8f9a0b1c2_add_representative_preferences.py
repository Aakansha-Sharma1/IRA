"""add representative preferences

Revision ID: c7e8f9a0b1c2
Revises: b9d6f3a2e5c1
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "c7e8f9a0b1c2"
down_revision: Union[str, Sequence[str], None] = "5d3d44ef7f9d"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "profiles",
        sa.Column("representative_name", sa.String(length=100), nullable=True),
    )
    op.add_column(
        "profiles",
        sa.Column("representative_gender", sa.String(length=20), nullable=True),
    )
    op.create_check_constraint(
        "ck_profiles_representative_gender",
        "profiles",
        "representative_gender IS NULL OR representative_gender IN "
        "('male', 'female', 'non_binary')",
    )


def downgrade() -> None:
    op.drop_constraint(
        "ck_profiles_representative_gender",
        "profiles",
        type_="check",
    )
    op.drop_column("profiles", "representative_gender")
    op.drop_column("profiles", "representative_name")
