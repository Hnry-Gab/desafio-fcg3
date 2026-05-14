"""Centralized notification service with Firebase Admin SDK integration.

Provides:
- init_firebase(): Called at app startup to initialize Firebase Admin SDK
- NotificationService: Sends push notifications to student devices via FCM
  and persists every notification in the ``notifications`` table so read
  status can be tracked server-side.
- notification_service: Module-level singleton instance

Design decisions:
- Fire-and-forget (D-12): send failures are logged, never raised
- Invalid token cleanup (D-05): UnregisteredError triggers token deletion
- Graceful degradation: If FCM_CREDENTIALS_PATH is None, all sends are no-op
- All notification content in Portuguese
- Every send_push also inserts a row into the notifications table
"""

from __future__ import annotations

import asyncio
import json
import logging
from uuid import UUID

from sqlalchemy import select, update, delete as sql_delete, func
from sqlalchemy.ext.asyncio import AsyncSession

from src.features.notifications.schemas import NotificationEvent
from src.infrastructure.config import get_settings

logger = logging.getLogger(__name__)

# Module-level state — set by init_firebase()
_firebase_initialized = False


def init_firebase() -> None:
    """Initialize Firebase Admin SDK from FCM_CREDENTIALS_PATH.

    Called once at app startup (from main.py lifespan).
    If fcm_credentials_path is None or empty, logs a warning and makes all
    send operations no-op (graceful degradation per D-12).
    """
    global _firebase_initialized

    settings = get_settings()
    if not settings.fcm_credentials_path:
        logger.warning(
            "FCM_CREDENTIALS_PATH not set — push notifications disabled. "
            "Set the environment variable to enable FCM."
        )
        return

    try:
        import firebase_admin
        from firebase_admin import credentials

        if not firebase_admin._apps:
            cred = credentials.Certificate(settings.fcm_credentials_path)
            firebase_admin.initialize_app(cred)
            _firebase_initialized = True
            logger.info("Firebase Admin SDK initialized successfully")
        else:
            _firebase_initialized = True
            logger.info("Firebase Admin SDK already initialized")
    except Exception as exc:
        logger.error("Failed to initialize Firebase Admin SDK: %s", exc)
        _firebase_initialized = False


class NotificationService:
    """Centralized FCM push notification service.

    All methods are fire-and-forget — errors are logged but never propagated.
    Invalid tokens are cleaned up automatically on send failure.
    Every notification is persisted in the ``notifications`` table for
    server-side read tracking.
    """

    # ------------------------------------------------------------------
    # Persistence helpers
    # ------------------------------------------------------------------

    async def _persist(
        self,
        db: AsyncSession,
        student_id: UUID,
        event: NotificationEvent,
        title: str,
        body: str,
        data: dict[str, str] | None = None,
    ) -> None:
        """Insert a notification row so the client can fetch & track reads."""
        from src.features.notifications.models import Notification

        notification = Notification(
            student_id=student_id,
            event=event.value,
            title=title,
            body=body,
            data=json.dumps(data) if data else None,
        )
        db.add(notification)
        await db.flush()

    # ------------------------------------------------------------------
    # Query helpers (used by controllers)
    # ------------------------------------------------------------------

    async def list_notifications(
        self,
        db: AsyncSession,
        student_id: UUID,
    ) -> list:
        """Return all notifications for a student, newest first."""
        from src.features.notifications.models import Notification

        result = await db.execute(
            select(Notification)
            .where(Notification.student_id == student_id)
            .order_by(Notification.created_at.desc())
        )
        return list(result.scalars().all())

    async def mark_as_read(
        self,
        db: AsyncSession,
        student_id: UUID,
        notification_ids: list[UUID],
    ) -> int:
        """Mark specific notifications as read. Returns count updated."""
        from src.features.notifications.models import Notification

        result = await db.execute(
            update(Notification)
            .where(
                Notification.id.in_(notification_ids),
                Notification.student_id == student_id,
                Notification.read_at.is_(None),
            )
            .values(read_at=func.now())
        )
        await db.commit()
        return result.rowcount  # type: ignore[return-value]

    async def mark_all_as_read(
        self,
        db: AsyncSession,
        student_id: UUID,
    ) -> int:
        """Mark all unread notifications as read. Returns count updated."""
        from src.features.notifications.models import Notification

        result = await db.execute(
            update(Notification)
            .where(
                Notification.student_id == student_id,
                Notification.read_at.is_(None),
            )
            .values(read_at=func.now())
        )
        await db.commit()
        return result.rowcount  # type: ignore[return-value]

    # ------------------------------------------------------------------
    # FCM push dispatch
    # ------------------------------------------------------------------

    async def send_push(
        self,
        db: AsyncSession,
        student_id: UUID,
        event: NotificationEvent,
        title: str,
        body: str,
        data: dict[str, str] | None = None,
    ) -> None:
        """Persist notification and dispatch FCM message to all registered tokens.

        Args:
            db: Async database session for token queries and cleanup
            student_id: Target student UUID
            event: Notification event type
            title: Push notification title (displayed in system tray)
            body: Push notification body text
            data: Optional data payload (key-value pairs for client handling)
        """
        # Always persist — even if FCM is disabled the notification should be
        # available for the client to fetch via the REST API.
        try:
            await self._persist(db, student_id, event, title, body, data)
            await db.commit()
        except Exception as exc:
            logger.error(
                "Failed to persist notification: student=%s event=%s error=%s",
                student_id, event, exc,
            )
            await db.rollback()

        if not _firebase_initialized:
            logger.debug(
                "FCM not initialized — skipping push for student %s, event %s",
                student_id,
                event,
            )
            return

        from src.features.auth.models import FcmToken

        # Query all tokens for this student
        result = await db.execute(
            select(FcmToken).where(FcmToken.student_id == student_id)
        )
        tokens = result.scalars().all()

        if not tokens:
            logger.debug(
                "No FCM tokens registered for student %s — skipping push",
                student_id,
            )
            return

        from firebase_admin import messaging

        payload_data = data or {}
        payload_data["event"] = event.value

        for fcm_token in tokens:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=title,
                        body=body,
                    ),
                    data=payload_data,
                    token=fcm_token.token,
                )
                # firebase-admin messaging.send() is blocking — run in thread
                await asyncio.to_thread(messaging.send, message)
                logger.info(
                    "FCM push sent: student=%s event=%s token=%s...",
                    student_id,
                    event,
                    fcm_token.token[:20],
                )
            except (
                messaging.UnregisteredError,
                messaging.SenderIdMismatchError,
            ):
                # D-05: Invalid token — remove from database
                logger.warning(
                    "FCM token invalid (unregistered/mismatch), removing: "
                    "student=%s token=%s...",
                    student_id,
                    fcm_token.token[:20],
                )
                await db.execute(
                    sql_delete(FcmToken).where(FcmToken.id == fcm_token.id)
                )
                await db.commit()
            except Exception as exc:
                # D-12: Fire-and-forget — log error, continue to next token
                logger.error(
                    "FCM send failed: student=%s token=%s... error=%s",
                    student_id,
                    fcm_token.token[:20],
                    exc,
                )

    # ------------------------------------------------------------------
    # Event-specific helpers (called by feature controllers)
    # ------------------------------------------------------------------

    async def notify_document_ready(
        self,
        db: AsyncSession,
        student_id: UUID,
        document_type: str,
        document_id: UUID,
    ) -> None:
        """Notify student that their document is ready for pickup (D-09)."""
        await self.send_push(
            db=db,
            student_id=student_id,
            event=NotificationEvent.document_ready,
            title="Documento pronto",
            body=f"Seu {document_type} está pronto para retirada",
            data={"document_id": str(document_id)},
        )

    async def notify_enrollment_confirmed(
        self,
        db: AsyncSession,
        student_id: UUID,
        enrollment_id: UUID,
    ) -> None:
        """Notify student that their enrollment was confirmed."""
        await self.send_push(
            db=db,
            student_id=student_id,
            event=NotificationEvent.enrollment_confirmed,
            title="Matrícula confirmada",
            body="Sua matrícula foi confirmada com sucesso",
            data={"enrollment_id": str(enrollment_id)},
        )

    async def notify_appointment_confirmed(
        self,
        db: AsyncSession,
        student_id: UUID,
        appointment_id: UUID,
        resource_name: str = "",
        slot_date: str = "",
        slot_time: str = "",
    ) -> None:
        """Notify student that their appointment was booked successfully."""
        detail = self._appointment_detail(resource_name, slot_date, slot_time)
        await self.send_push(
            db=db,
            student_id=student_id,
            event=NotificationEvent.appointment_confirmed,
            title="Agendamento criado",
            body=f"Seu agendamento{detail} foi registrado",
            data={"appointment_id": str(appointment_id)},
        )

    async def notify_appointment_completed(
        self,
        db: AsyncSession,
        student_id: UUID,
        appointment_id: UUID,
        resource_name: str = "",
        slot_date: str = "",
        slot_time: str = "",
    ) -> None:
        """Notify student that staff confirmed their appointment."""
        detail = self._appointment_detail(resource_name, slot_date, slot_time)
        await self.send_push(
            db=db,
            student_id=student_id,
            event=NotificationEvent.appointment_completed,
            title="Agendamento confirmado",
            body=f"Seu agendamento{detail} foi confirmado pelo staff",
            data={"appointment_id": str(appointment_id)},
        )

    async def notify_appointment_cancelled(
        self,
        db: AsyncSession,
        student_id: UUID,
        appointment_id: UUID,
        resource_name: str = "",
        slot_date: str = "",
        slot_time: str = "",
    ) -> None:
        """Notify student that their appointment was cancelled."""
        detail = self._appointment_detail(resource_name, slot_date, slot_time)
        await self.send_push(
            db=db,
            student_id=student_id,
            event=NotificationEvent.appointment_cancelled,
            title="Agendamento cancelado",
            body=f"Seu agendamento{detail} foi cancelado",
            data={"appointment_id": str(appointment_id)},
        )

    async def notify_appointment_no_show(
        self,
        db: AsyncSession,
        student_id: UUID,
        appointment_id: UUID,
        resource_name: str = "",
        slot_date: str = "",
        slot_time: str = "",
    ) -> None:
        """Notify student they were marked as no-show."""
        detail = self._appointment_detail(resource_name, slot_date, slot_time)
        await self.send_push(
            db=db,
            student_id=student_id,
            event=NotificationEvent.appointment_no_show,
            title="Ausência registrada",
            body=f"Você foi marcado como ausente no agendamento{detail}",
            data={"appointment_id": str(appointment_id)},
        )

    @staticmethod
    def _appointment_detail(resource_name: str, slot_date: str, slot_time: str) -> str:
        """Build a human-readable detail fragment for appointment notifications."""
        parts: list[str] = []
        if resource_name:
            parts.append(resource_name)
        if slot_date:
            date_str = slot_date
            if slot_time:
                date_str = f"{slot_date} {slot_time}"
            parts.append(date_str)
        if not parts:
            return ""
        return " para " + " em ".join(parts)


# Module-level singleton
notification_service = NotificationService()
