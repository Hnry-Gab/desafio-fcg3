"""Banners feature route registration.

Exposes banners_router for inclusion in the main FastAPI app:
- GET  /banners         — public list of enabled banners (BNNR-01/02)
- GET  /banners/all     — staff/provider list all banners (BNNR-05)
- POST /banners/upload  — staff/provider upload image (BNNR-03)
- PUT  /banners/{id}    — staff/provider toggle/reorder (BNNR-06)
- DELETE /banners/{id}  — staff/provider delete (BNNR-04)
"""

from src.features.banners.controllers import banners_router

__all__ = ["banners_router"]
