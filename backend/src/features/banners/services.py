"""Business logic for the Banners feature slice.

Provides BannerService with CRUD operations and a module-level singleton.
"""

from __future__ import annotations

from uuid import UUID

from fastapi import HTTPException
from sqlalchemy import select, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.features.banners.models import Banner
from src.features.banners.schemas import BannerUpdate


class BannerService:
    """CRUD operations for banners."""

    async def list_banners(
        self,
        db: AsyncSession,
        enabled_only: bool = False,
    ) -> list[Banner]:
        """List banners ordered by display_order ASC, created_at DESC.

        If enabled_only=True, filters to is_enabled=True only.
        """
        stmt = select(Banner).order_by(
            Banner.display_order.asc(),
            Banner.created_at.desc(),
        )
        if enabled_only:
            stmt = stmt.where(Banner.is_enabled.is_(True))
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_banner(self, db: AsyncSession, banner_id: UUID) -> Banner:
        """Get a single banner by ID. Raises 404 if not found."""
        result = await db.execute(
            select(Banner).where(Banner.id == banner_id)
        )
        banner = result.scalar_one_or_none()
        if banner is None:
            raise HTTPException(
                status_code=404,
                detail={
                    "error": {
                        "code": "NOT_FOUND",
                        "message": "Banner not found",
                    }
                },
            )
        return banner

    async def create_banner(
        self,
        db: AsyncSession,
        image_url: str,
    ) -> Banner:
        """Create a new banner with is_enabled=True and display_order=0."""
        banner = Banner(
            image_url=image_url,
            is_enabled=True,
            display_order=0,
        )
        db.add(banner)
        await db.flush()
        await db.refresh(banner)
        return banner

    async def update_banner(
        self,
        db: AsyncSession,
        banner_id: UUID,
        data: BannerUpdate,
    ) -> Banner:
        """Partial update — only set fields that are not None."""
        banner = await self.get_banner(db, banner_id)
        if data.is_enabled is not None:
            banner.is_enabled = data.is_enabled
        if data.display_order is not None:
            banner.display_order = data.display_order
        await db.flush()
        await db.refresh(banner)
        return banner

    async def delete_banner(
        self,
        db: AsyncSession,
        banner_id: UUID,
    ) -> str:
        """Delete banner from DB and return image_url for file cleanup."""
        banner = await self.get_banner(db, banner_id)
        image_url = banner.image_url
        await db.execute(
            sa_delete(Banner).where(Banner.id == banner_id)
        )
        await db.flush()
        return image_url


# Module-level singleton
banner_service = BannerService()
