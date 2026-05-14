"""Integration tests for notification persistence, endpoints, and IDOR protection.

Tests cover:
- Notification model persistence (create, read, mark as read)
- GET  /notifications — list notifications for authenticated student
- PUT  /notifications/read — mark specific notifications as read
- PUT  /notifications/read-all — mark all notifications as read
- IDOR protection: students only see their own notifications
- send_push now persists notification row before sending FCM
- Edge cases: empty list, already-read idempotency, 401 without auth
"""

from __future__ import annotations

import uuid
from unittest.mock import AsyncMock, patch

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

from src.features.auth.models import Session as SessionModel
from src.features.auth.services import jwt_service
from src.features.notifications.models import Notification
from src.features.notifications.schemas import NotificationEvent
from src.features.notifications.services import NotificationService
from src.infrastructure.database import get_db_session
from src.shared.dependencies import get_current_user_or_service, UserContext


# ---------------------------------------------------------------------------
# Auth helpers
# ---------------------------------------------------------------------------

async def _make_token(db_session, user, role):
    """Issue a real JWT and persist the Session row."""
    tok = jwt_service.issue_access(user.id, role, user.name, user.email)
    db_session.add(SessionModel(
        jti=tok.jti, user_id=user.id, token_type="access",
        user_type=role, platform="app",
        parent_jti=None, used=False, expires_at=tok.expires_at,
    ))
    await db_session.commit()
    return tok


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest_asyncio.fixture
async def student_client(app, db_session, seed_users):
    """httpx AsyncClient authenticated as student via dependency override."""
    student = seed_users["student"]

    async def _override_get_db():
        yield db_session

    def _override_auth():
        return UserContext(id=student.id, role="student", name=student.name)

    app.dependency_overrides[get_db_session] = _override_get_db
    app.dependency_overrides[get_current_user_or_service] = _override_auth

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c

    app.dependency_overrides.pop(get_db_session, None)
    app.dependency_overrides.pop(get_current_user_or_service, None)


@pytest_asyncio.fixture
async def other_student_client(app, db_session, seed_users):
    """httpx AsyncClient authenticated as a DIFFERENT student (for IDOR tests)."""
    other_id = uuid.uuid4()

    async def _override_get_db():
        yield db_session

    def _override_auth():
        return UserContext(id=other_id, role="student", name="Other Student")

    app.dependency_overrides[get_db_session] = _override_get_db
    app.dependency_overrides[get_current_user_or_service] = _override_auth

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c

    app.dependency_overrides.pop(get_db_session, None)
    app.dependency_overrides.pop(get_current_user_or_service, None)


async def _seed_notification(db_session, student_id, event="document_ready",
                              title="Test", body="Test body", read=False):
    """Insert a notification directly into the database."""
    from datetime import datetime, timezone

    n = Notification(
        student_id=student_id,
        event=event,
        title=title,
        body=body,
        data=None,
    )
    if read:
        n.read_at = datetime.now(timezone.utc)
    db_session.add(n)
    await db_session.flush()
    return n


# ===========================================================================
# Unit tests — NotificationService persistence methods
# ===========================================================================


class TestNotificationPersistence:
    """Tests for service-level persistence: _persist, list, mark_as_read."""

    @pytest.mark.asyncio
    async def test_persist_creates_notification_row(self, db_session, seed_users):
        """_persist should insert a row into the notifications table."""
        student = seed_users["student"]
        service = NotificationService()

        await service._persist(
            db_session, student.id,
            NotificationEvent.document_ready,
            "Documento pronto", "Seu historico esta pronto",
            {"document_id": "abc-123"},
        )
        await db_session.commit()

        rows = await service.list_notifications(db_session, student.id)
        assert len(rows) == 1
        assert rows[0].title == "Documento pronto"
        assert rows[0].event == "document_ready"
        assert rows[0].read_at is None
        assert '"document_id"' in rows[0].data

    @pytest.mark.asyncio
    async def test_list_notifications_returns_all_for_student(self, db_session, seed_users):
        """list_notifications should return all notifications for the student."""
        student = seed_users["student"]

        await _seed_notification(db_session, student.id, title="First")
        await _seed_notification(db_session, student.id, title="Second")
        await db_session.commit()

        service = NotificationService()
        rows = await service.list_notifications(db_session, student.id)

        assert len(rows) == 2
        titles = {r.title for r in rows}
        assert titles == {"First", "Second"}

    @pytest.mark.asyncio
    async def test_list_notifications_empty_for_new_student(self, db_session, seed_users):
        """list_notifications should return empty list for student with no notifications."""
        student = seed_users["student"]
        service = NotificationService()

        rows = await service.list_notifications(db_session, student.id)
        assert rows == []

    @pytest.mark.asyncio
    async def test_mark_as_read_updates_specific_notifications(self, db_session, seed_users):
        """mark_as_read should set read_at on specified IDs only."""
        student = seed_users["student"]

        n1 = await _seed_notification(db_session, student.id, title="Read me")
        n2 = await _seed_notification(db_session, student.id, title="Keep unread")
        await db_session.commit()

        service = NotificationService()
        count = await service.mark_as_read(db_session, student.id, [n1.id])

        assert count == 1

        rows = await service.list_notifications(db_session, student.id)
        read_row = [r for r in rows if r.title == "Read me"][0]
        unread_row = [r for r in rows if r.title == "Keep unread"][0]
        assert read_row.read_at is not None
        assert unread_row.read_at is None

    @pytest.mark.asyncio
    async def test_mark_as_read_idempotent(self, db_session, seed_users):
        """mark_as_read on already-read notification should update 0 rows."""
        student = seed_users["student"]

        n = await _seed_notification(db_session, student.id, read=True)
        await db_session.commit()

        service = NotificationService()
        count = await service.mark_as_read(db_session, student.id, [n.id])
        assert count == 0

    @pytest.mark.asyncio
    async def test_mark_as_read_ignores_other_student(self, db_session, seed_users):
        """mark_as_read should NOT update notifications belonging to another student."""
        student = seed_users["student"]
        other_student_id = uuid.uuid4()

        n = await _seed_notification(db_session, student.id, title="Not yours")
        await db_session.commit()

        service = NotificationService()
        count = await service.mark_as_read(db_session, other_student_id, [n.id])
        assert count == 0

        # Verify it's still unread
        rows = await service.list_notifications(db_session, student.id)
        assert rows[0].read_at is None

    @pytest.mark.asyncio
    async def test_mark_all_as_read(self, db_session, seed_users):
        """mark_all_as_read should set read_at on all unread notifications."""
        student = seed_users["student"]

        await _seed_notification(db_session, student.id, title="A")
        await _seed_notification(db_session, student.id, title="B")
        await _seed_notification(db_session, student.id, title="C", read=True)
        await db_session.commit()

        service = NotificationService()
        count = await service.mark_all_as_read(db_session, student.id)

        # Only 2 were unread
        assert count == 2

        rows = await service.list_notifications(db_session, student.id)
        assert all(r.read_at is not None for r in rows)

    @pytest.mark.asyncio
    async def test_mark_all_as_read_returns_zero_when_none_unread(self, db_session, seed_users):
        """mark_all_as_read returns 0 when all are already read."""
        student = seed_users["student"]

        await _seed_notification(db_session, student.id, read=True)
        await db_session.commit()

        service = NotificationService()
        count = await service.mark_all_as_read(db_session, student.id)
        assert count == 0


# ===========================================================================
# Unit test — send_push persists notification
# ===========================================================================


class TestSendPushPersistence:
    """Verify that send_push now creates a notification row."""

    @pytest.mark.asyncio
    @patch("src.features.notifications.services._firebase_initialized", False)
    async def test_send_push_persists_even_without_fcm(self, db_session, seed_users):
        """send_push should persist notification even when FCM is not initialized."""
        student = seed_users["student"]
        service = NotificationService()

        await service.send_push(
            db=db_session,
            student_id=student.id,
            event=NotificationEvent.enrollment_confirmed,
            title="Matrícula confirmada",
            body="Sua matrícula foi confirmada com sucesso",
            data={"enrollment_id": str(uuid.uuid4())},
        )

        rows = await service.list_notifications(db_session, student.id)
        assert len(rows) == 1
        assert rows[0].title == "Matrícula confirmada"
        assert rows[0].event == "enrollment_confirmed"
        assert rows[0].read_at is None


# ===========================================================================
# Integration tests — API endpoints
# ===========================================================================


class TestGetNotifications:
    """Tests for GET /api/v1/notifications."""

    @pytest.mark.asyncio
    async def test_returns_200_with_notifications(
        self, student_client, db_session, seed_users,
    ):
        """Authenticated student should see their notifications."""
        student = seed_users["student"]
        await _seed_notification(db_session, student.id, title="Test 1",
                                  event="document_ready")
        await _seed_notification(db_session, student.id, title="Test 2",
                                  event="enrollment_confirmed")
        await db_session.commit()

        r = await student_client.get("/api/v1/notifications")
        assert r.status_code == 200

        data = r.json()
        assert len(data) == 2
        titles = {d["title"] for d in data}
        assert titles == {"Test 1", "Test 2"}

    @pytest.mark.asyncio
    async def test_returns_empty_list_when_no_notifications(self, student_client):
        """Student with no notifications should get empty list."""
        r = await student_client.get("/api/v1/notifications")
        assert r.status_code == 200
        assert r.json() == []

    @pytest.mark.asyncio
    async def test_returns_401_without_auth(self, client):
        """Unauthenticated request should return 401."""
        r = await client.get("/api/v1/notifications")
        assert r.status_code == 401

    @pytest.mark.asyncio
    async def test_idor_student_cannot_see_other_notifications(
        self, other_student_client, db_session, seed_users,
    ):
        """Student should NOT see notifications belonging to another student."""
        student = seed_users["student"]
        await _seed_notification(db_session, student.id, title="Private notif")
        await db_session.commit()

        # Authenticated as "other student"
        r = await other_student_client.get("/api/v1/notifications")
        assert r.status_code == 200
        assert r.json() == []

    @pytest.mark.asyncio
    async def test_response_includes_read_at_field(
        self, student_client, db_session, seed_users,
    ):
        """Response should expose read_at as null or datetime."""
        student = seed_users["student"]
        await _seed_notification(db_session, student.id, title="Unread")
        await _seed_notification(db_session, student.id, title="Read", read=True)
        await db_session.commit()

        r = await student_client.get("/api/v1/notifications")
        data = r.json()

        read_item = [d for d in data if d["title"] == "Read"][0]
        unread_item = [d for d in data if d["title"] == "Unread"][0]

        assert read_item["read_at"] is not None
        assert unread_item["read_at"] is None


class TestMarkNotificationsRead:
    """Tests for PUT /api/v1/notifications/read."""

    @pytest.mark.asyncio
    async def test_marks_specific_notifications_as_read(
        self, student_client, db_session, seed_users,
    ):
        """PUT /notifications/read should update read_at for given IDs."""
        student = seed_users["student"]
        n1 = await _seed_notification(db_session, student.id, title="To read")
        n2 = await _seed_notification(db_session, student.id, title="Stay unread")
        await db_session.commit()

        r = await student_client.put(
            "/api/v1/notifications/read",
            json={"notification_ids": [str(n1.id)]},
        )
        assert r.status_code == 200
        assert r.json()["updated"] == 1

        # Verify via GET
        r2 = await student_client.get("/api/v1/notifications")
        data = r2.json()
        read_item = [d for d in data if d["title"] == "To read"][0]
        unread_item = [d for d in data if d["title"] == "Stay unread"][0]
        assert read_item["read_at"] is not None
        assert unread_item["read_at"] is None

    @pytest.mark.asyncio
    async def test_idempotent_already_read(
        self, student_client, db_session, seed_users,
    ):
        """Marking already-read notifications should return updated=0."""
        student = seed_users["student"]
        n = await _seed_notification(db_session, student.id, read=True)
        await db_session.commit()

        r = await student_client.put(
            "/api/v1/notifications/read",
            json={"notification_ids": [str(n.id)]},
        )
        assert r.status_code == 200
        assert r.json()["updated"] == 0

    @pytest.mark.asyncio
    async def test_idor_cannot_mark_other_student_notifications(
        self, other_student_client, db_session, seed_users,
    ):
        """Student cannot mark another student's notifications as read."""
        student = seed_users["student"]
        n = await _seed_notification(db_session, student.id, title="Not yours")
        await db_session.commit()

        r = await other_student_client.put(
            "/api/v1/notifications/read",
            json={"notification_ids": [str(n.id)]},
        )
        assert r.status_code == 200
        assert r.json()["updated"] == 0

    @pytest.mark.asyncio
    async def test_validation_error_empty_list(self, student_client):
        """Empty notification_ids list should return 422."""
        r = await student_client.put(
            "/api/v1/notifications/read",
            json={"notification_ids": []},
        )
        assert r.status_code == 422

    @pytest.mark.asyncio
    async def test_returns_401_without_auth(self, client):
        """Unauthenticated request should return 401."""
        r = await client.put(
            "/api/v1/notifications/read",
            json={"notification_ids": [str(uuid.uuid4())]},
        )
        assert r.status_code == 401


class TestMarkAllNotificationsRead:
    """Tests for PUT /api/v1/notifications/read-all."""

    @pytest.mark.asyncio
    async def test_marks_all_unread_as_read(
        self, student_client, db_session, seed_users,
    ):
        """PUT /notifications/read-all should mark all unread notifications."""
        student = seed_users["student"]
        await _seed_notification(db_session, student.id, title="A")
        await _seed_notification(db_session, student.id, title="B")
        await _seed_notification(db_session, student.id, title="C", read=True)
        await db_session.commit()

        r = await student_client.put("/api/v1/notifications/read-all")
        assert r.status_code == 200
        assert r.json()["updated"] == 2

        # Verify all are now read
        r2 = await student_client.get("/api/v1/notifications")
        data = r2.json()
        assert all(d["read_at"] is not None for d in data)

    @pytest.mark.asyncio
    async def test_returns_zero_when_all_already_read(
        self, student_client, db_session, seed_users,
    ):
        """Returns updated=0 when no unread notifications exist."""
        student = seed_users["student"]
        await _seed_notification(db_session, student.id, read=True)
        await db_session.commit()

        r = await student_client.put("/api/v1/notifications/read-all")
        assert r.status_code == 200
        assert r.json()["updated"] == 0

    @pytest.mark.asyncio
    async def test_returns_zero_when_no_notifications(self, student_client):
        """Returns updated=0 when student has no notifications at all."""
        r = await student_client.put("/api/v1/notifications/read-all")
        assert r.status_code == 200
        assert r.json()["updated"] == 0

    @pytest.mark.asyncio
    async def test_idor_only_marks_own_notifications(
        self, other_student_client, db_session, seed_users,
    ):
        """read-all should only mark the authenticated student's notifications."""
        student = seed_users["student"]
        await _seed_notification(db_session, student.id, title="Not yours")
        await db_session.commit()

        r = await other_student_client.put("/api/v1/notifications/read-all")
        assert r.status_code == 200
        assert r.json()["updated"] == 0

    @pytest.mark.asyncio
    async def test_returns_401_without_auth(self, client):
        """Unauthenticated request should return 401."""
        r = await client.put("/api/v1/notifications/read-all")
        assert r.status_code == 401
