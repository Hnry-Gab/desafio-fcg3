"""Pydantic schemas for the Banners feature slice.

Defines:
- BannerResponse: API response for a single banner
- BannerUpdate: Partial update body for toggling is_enabled / reordering
"""

from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel


class BannerResponse(BaseModel):
    """API response for a single banner."""

    id: UUID
    image_url: str
    is_enabled: bool
    display_order: int
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class BannerUpdate(BaseModel):
    """Partial update body — both fields optional."""

    is_enabled: bool | None = None
    display_order: int | None = None
