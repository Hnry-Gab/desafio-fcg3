"""Notifications feature route registration.

Exposes notifications_router for inclusion in the main FastAPI app:
- GET  /notifications         — list notifications (NOTIF-01)
- PUT  /notifications/read    — mark specific as read (NOTIF-02)
- PUT  /notifications/read-all — mark all as read (NOTIF-03)

All route handlers are defined in controllers.py.
"""

from src.features.notifications.controllers import notifications_router

__all__ = ["notifications_router"]
