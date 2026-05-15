"""create class_schedules table for weekly timetable

Revision ID: 018a
Revises: 017a
Create Date: 2026-05-14 12:00:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "018a"
down_revision = "017a"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "class_schedules",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("day_of_week", sa.Integer(), nullable=False),
        sa.Column("start_time", sa.Time(), nullable=False),
        sa.Column("end_time", sa.Time(), nullable=False),
        sa.Column("room", sa.String(length=100), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["course_id"], ["courses.id"]),
        sa.CheckConstraint(
            "day_of_week >= 0 AND day_of_week <= 6",
            name="ck_class_schedules_day_of_week",
        ),
        sa.UniqueConstraint(
            "course_id",
            "day_of_week",
            "start_time",
            name="uq_class_schedules_course_day_start",
        ),
    )

    op.create_index(
        "idx_class_schedules_day",
        "class_schedules",
        ["day_of_week"],
    )


def downgrade() -> None:
    op.drop_index("idx_class_schedules_day", table_name="class_schedules")
    op.drop_table("class_schedules")
