"""SQLAlchemy model for persisted notifications.

Each row represents a notification sent to a student (via FCM push or
system-generated). The `read_at` column tracks whether the student has
acknowledged it — NULL means unread.
"""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Index, String, Text, func, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

try:
    from infrastructure.database import Base
except ModuleNotFoundError:  # pragma: no cover
    from src.infrastructure.database import Base


class Notification(Base):
    __tablename__ = "notifications"
    __table_args__ = (
        Index("idx_notifications_student", "student_id"),
        Index("idx_notifications_student_read", "student_id", "read_at"),
        Index("idx_notifications_created", "created_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4,
    )
    student_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("students.id"), nullable=False,
    )
    event: Mapped[str] = mapped_column(String(50), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    data: Mapped[str | None] = mapped_column(Text, nullable=True)
    read_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(),
    )
