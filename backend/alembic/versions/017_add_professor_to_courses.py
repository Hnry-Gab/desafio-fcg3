"""add professor column to courses table

Revision ID: 017a
Revises: 016a
Create Date: 2026-05-14 00:00:01
"""

from alembic import op
import sqlalchemy as sa

revision = "017a"
down_revision = "016a"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("courses", sa.Column("professor", sa.String(255), nullable=True))


def downgrade() -> None:
    op.drop_column("courses", "professor")
