"""Notification schemas and event types for FCM push notifications.

Defines:
- FcmTokenRegister / FcmTokenDelete: request bodies for token CRUD
- NotificationEvent: enum of supported push notification event types
- NotificationPayload: internal payload structure for sending notifications
- NotificationResponse: API response for persisted notifications
- MarkNotificationsReadRequest: bulk mark-as-read request body
"""

from __future__ import annotations

from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, Field


class FcmTokenRegister(BaseModel):
    """Request body for PUT /students/{id}/fcm-token."""

    token: str = Field(..., min_length=1, max_length=4096, description="FCM device token")
    device_name: str | None = Field(
        default=None, max_length=100, description="Optional device identifier"
    )


class FcmTokenDelete(BaseModel):
    """Request body for DELETE /students/{id}/fcm-token."""

    token: str = Field(..., min_length=1, max_length=4096, description="FCM device token to remove")


class NotificationEvent(StrEnum):
    """Supported FCM push notification event types (D-10: chat_reply excluded)."""

    document_ready = "document_ready"
    enrollment_confirmed = "enrollment_confirmed"
    appointment_confirmed = "appointment_confirmed"


class NotificationPayload(BaseModel):
    """Internal payload structure for building FCM messages."""

    event: NotificationEvent
    title: str
    body: str
    data: dict[str, str] = Field(default_factory=dict)


# ------------------------------------------------------------------
# Persisted notification schemas (API layer)
# ------------------------------------------------------------------


class NotificationResponse(BaseModel):
    """API response for a single notification."""

    id: UUID
    event: str
    title: str
    body: str
    data: str | None = None
    read_at: datetime | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class MarkNotificationsReadRequest(BaseModel):
    """Request body for PUT /notifications/read — bulk mark as read."""

    notification_ids: list[UUID] = Field(
        ..., min_length=1, max_length=100,
        description="List of notification UUIDs to mark as read",
    )
