"""Route handlers for the Banners feature slice.

5 endpoints for banner management:
- GET  /banners         — public listing of enabled banners (student carousel)
- GET  /banners/all     — staff/provider listing of all banners
- POST /banners/upload  — staff/provider image upload and banner creation
- PUT  /banners/{id}    — staff/provider toggle/reorder
- DELETE /banners/{id}  — staff/provider delete banner and file
"""

from __future__ import annotations

import os
import uuid as uuid_mod
from uuid import UUID

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database import get_db_session
from src.shared.dependencies import (
    UserContext,
    get_current_user_or_service,
    require_staff,
)
from src.features.banners.schemas import BannerResponse, BannerUpdate
from src.features.banners.services import banner_service

banners_router = APIRouter(prefix="/banners", tags=["banners"])

UPLOAD_DIR = "uploads/banners"
MAX_FILE_SIZE = 2 * 1024 * 1024  # 2MB
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}


# ------------------------------------------------------------------
# BNNR-01/02: GET /banners — public listing (enabled only)
# ------------------------------------------------------------------

@banners_router.get("", response_model=list[BannerResponse])
async def list_enabled_banners(
    db: AsyncSession = Depends(get_db_session),
) -> list[BannerResponse]:
    """Public endpoint returning only enabled banners for the student carousel.

    No authentication required — banner images are public content.
    Ordered by display_order ASC, created_at DESC.
    """
    banners = await banner_service.list_banners(db, enabled_only=True)
    return [BannerResponse.model_validate(b) for b in banners]


# ------------------------------------------------------------------
# BNNR-05: GET /banners/all — staff/provider management listing
# ------------------------------------------------------------------

@banners_router.get("/all", response_model=list[BannerResponse])
async def list_all_banners(
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> list[BannerResponse]:
    """Staff/provider listing showing all banners including disabled ones."""
    require_staff(user)
    banners = await banner_service.list_banners(db, enabled_only=False)
    return [BannerResponse.model_validate(b) for b in banners]


# ------------------------------------------------------------------
# BNNR-03: POST /banners/upload — staff/provider upload
# ------------------------------------------------------------------

@banners_router.post("/upload", response_model=BannerResponse, status_code=201)
async def upload_banner(
    file: UploadFile = File(...),
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> BannerResponse:
    """Upload an image file and create a new banner record.

    T-26-01: Validates content_type (jpeg/png/webp) and enforces 2MB limit.
    T-26-04: Content-type allowlist prevents non-image uploads.
    T-26-05: File size limit prevents storage exhaustion.
    UUID prefix prevents path traversal and naming collisions.
    """
    require_staff(user)

    # Validate content type
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=400,
            detail={
                "error": {
                    "code": "INVALID_FILE_TYPE",
                    "message": f"Allowed types: JPEG, PNG, WebP. Got: {file.content_type}",
                }
            },
        )

    # Read and validate size
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail={
                "error": {
                    "code": "FILE_TOO_LARGE",
                    "message": "Maximum file size is 2MB",
                }
            },
        )

    # Save file with UUID prefix
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    file_id = str(uuid_mod.uuid4())
    safe_filename = f"{file_id}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, safe_filename)

    with open(file_path, "wb") as f:
        f.write(content)

    # Create banner record
    image_url = f"banners/{safe_filename}"
    banner = await banner_service.create_banner(db, image_url=image_url)
    await db.commit()
    await db.refresh(banner)
    return BannerResponse.model_validate(banner)


# ------------------------------------------------------------------
# BNNR-06/D-12: PUT /banners/{banner_id} — toggle/reorder
# ------------------------------------------------------------------

@banners_router.put("/{banner_id}", response_model=BannerResponse)
async def update_banner(
    banner_id: UUID,
    data: BannerUpdate,
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> BannerResponse:
    """Toggle is_enabled and/or update display_order (staff/provider only)."""
    require_staff(user)
    banner = await banner_service.update_banner(db, banner_id, data)
    await db.commit()
    await db.refresh(banner)
    return BannerResponse.model_validate(banner)


# ------------------------------------------------------------------
# BNNR-04: DELETE /banners/{banner_id} — remove banner and file
# ------------------------------------------------------------------

@banners_router.delete("/{banner_id}", status_code=200)
async def delete_banner(
    banner_id: UUID,
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Delete banner record and remove uploaded file from disk.

    T-26-02: require_staff ensures only staff/provider can delete.
    """
    require_staff(user)
    image_url = await banner_service.delete_banner(db, banner_id)
    await db.commit()

    # Remove file from disk (ignore if already missing)
    try:
        os.remove(os.path.join("uploads", image_url))
    except OSError:
        pass

    return {"deleted": True}
