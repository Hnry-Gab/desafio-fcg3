"""Route handlers for the Notifications feature slice.

3 endpoints for student notification management:
- GET  /notifications         — list all notifications (IDOR-safe)
- PUT  /notifications/read    — mark specific notifications as read
- PUT  /notifications/read-all — mark all notifications as read
"""

from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database import get_db_session
from src.shared.dependencies import (
    UserContext,
    get_current_user_or_service,
)
from src.features.notifications.schemas import (
    MarkNotificationsReadRequest,
    NotificationResponse,
)
from src.features.notifications.services import notification_service

notifications_router = APIRouter(prefix="/notifications", tags=["notifications"])


# ------------------------------------------------------------------
# NOTIF-01: GET /notifications — list student notifications
# ------------------------------------------------------------------

@notifications_router.get("", response_model=list[NotificationResponse])
async def list_notifications(
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> list[NotificationResponse]:
    """List all notifications for the authenticated student.

    Sorted by created_at descending (newest first).
    IDOR-safe: always scoped to user.id.
    """
    rows = await notification_service.list_notifications(db, student_id=user.id)
    return [NotificationResponse.model_validate(r) for r in rows]


# ------------------------------------------------------------------
# NOTIF-02: PUT /notifications/read — mark specific as read
# ------------------------------------------------------------------

@notifications_router.put("/read", status_code=200)
async def mark_notifications_read(
    data: MarkNotificationsReadRequest,
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Mark specific notifications as read.

    Only updates notifications belonging to the authenticated student.
    Idempotent — already-read notifications are silently skipped.
    """
    count = await notification_service.mark_as_read(
        db, student_id=user.id, notification_ids=data.notification_ids,
    )
    return {"updated": count}


# ------------------------------------------------------------------
# NOTIF-03: PUT /notifications/read-all — mark all as read
# ------------------------------------------------------------------

@notifications_router.put("/read-all", status_code=200)
async def mark_all_notifications_read(
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Mark all unread notifications as read for the authenticated student."""
    count = await notification_service.mark_all_as_read(
        db, student_id=user.id,
    )
    return {"updated": count}
