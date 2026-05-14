"""create notifications table for persistent read tracking

Revision ID: 019a
Revises: 018a
Create Date: 2026-05-14 18:00:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "019a"
down_revision = "018a"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "notifications",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("event", sa.String(length=50), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("body", sa.Text(), nullable=False),
        sa.Column("data", sa.Text(), nullable=True),
        sa.Column("read_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["student_id"], ["students.id"]),
    )

    op.create_index(
        "idx_notifications_student", "notifications", ["student_id"],
    )
    op.create_index(
        "idx_notifications_student_read",
        "notifications",
        ["student_id", "read_at"],
    )
    op.create_index(
        "idx_notifications_created", "notifications", ["created_at"],
    )


def downgrade() -> None:
    op.drop_index("idx_notifications_created", table_name="notifications")
    op.drop_index("idx_notifications_student_read", table_name="notifications")
    op.drop_index("idx_notifications_student", table_name="notifications")
    op.drop_table("notifications")
