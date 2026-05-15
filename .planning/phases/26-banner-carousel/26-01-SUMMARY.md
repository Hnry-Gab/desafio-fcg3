---
phase: 26-banner-carousel
plan: 01
subsystem: api
tags: [fastapi, sqlalchemy, alembic, file-upload, banners]

# Dependency graph
requires: []
provides:
  - Banner SQLAlchemy model with image_url, is_enabled, display_order, timestamps
  - 5 REST endpoints at /api/v1/banners (public GET, staff CRUD)
  - Alembic 021a migration for banners table
  - File upload with content-type validation and 2MB size limit
affects: [26-02 (staff/provider management screen), 26-03 (student carousel)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Public unauthenticated endpoint for student-facing read (GET /banners)"
    - "Content-type allowlist validation for file uploads (jpeg/png/webp)"
    - "BannerService singleton pattern consistent with NotificationService"

key-files:
  created:
    - backend/src/features/banners/__init__.py
    - backend/src/features/banners/models.py
    - backend/src/features/banners/schemas.py
    - backend/src/features/banners/services.py
    - backend/src/features/banners/controllers.py
    - backend/src/features/banners/routes.py
    - backend/alembic/versions/021a_create_banners_table.py
  modified:
    - backend/src/main.py

key-decisions:
  - "GET /banners is public (no auth) — banner images are public content for student carousel"
  - "Content-type validation instead of extension-based — prevents MIME mismatch attacks"
  - "BannerService.delete_banner returns image_url for caller to handle file cleanup — separation of DB and filesystem concerns"

patterns-established:
  - "Public read endpoint pattern: no Depends(get_current_user_or_service) for student-facing data"
  - "Dual listing pattern: GET /resource (public/filtered) + GET /resource/all (staff full view)"

requirements-completed: [BNNR-01, BNNR-02, BNNR-03, BNNR-04, BNNR-05, BNNR-06]

# Metrics
duration: 4min
completed: 2026-05-15
---

# Phase 26 Plan 01: Banner Backend API Summary

**Complete banner feature slice with SQLAlchemy model, Alembic migration, 5 REST endpoints (public GET + staff CRUD with file upload), content-type validation, and 2MB size limit**

## Performance

- **Duration:** 4 min
- **Started:** 2026-05-15T05:14:33Z
- **Completed:** 2026-05-15T05:18:49Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Banner model with composite index on (is_enabled, display_order) for efficient carousel queries
- 5 API endpoints: public listing for students, staff CRUD with upload/toggle/delete
- File upload validates content-type (JPEG/PNG/WebP) and enforces 2MB limit with UUID-prefixed filenames
- Alembic migration 021a creates banners table chained from 020a

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Banner model, schemas, service, and Alembic migration** - `dedd182` (feat)
2. **Task 2: Create Banner controllers, routes, and wire into main.py** - `492ed3c` (feat)

## Files Created/Modified
- `backend/src/features/banners/__init__.py` - Empty package init
- `backend/src/features/banners/models.py` - Banner SQLAlchemy model with 6 columns + composite index
- `backend/src/features/banners/schemas.py` - BannerResponse and BannerUpdate Pydantic schemas
- `backend/src/features/banners/services.py` - BannerService with list/get/create/update/delete + singleton
- `backend/src/features/banners/controllers.py` - 5 endpoints (GET, GET/all, POST/upload, PUT/{id}, DELETE/{id})
- `backend/src/features/banners/routes.py` - Route registration module
- `backend/alembic/versions/021a_create_banners_table.py` - Alembic migration (021a → 020a chain)
- `backend/src/main.py` - Added banners_router import, registration, and uploads/banners directory

## Decisions Made
- GET /banners is public (no auth required) — banner images are public content for student carousel display
- Content-type validation (MIME-based) instead of extension-based — more secure against MIME mismatch attacks
- BannerService.delete_banner returns image_url for controller to handle file cleanup — clean separation of DB and filesystem

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Backend API complete, ready for Plan 02 (staff/provider management screen in Flutter)
- Ready for Plan 03 (student carousel widget consuming GET /banners)

## Self-Check: PASSED

All 7 created files verified on disk. Both commit hashes (dedd182, 492ed3c) found in git log.

---
*Phase: 26-banner-carousel*
*Completed: 2026-05-15*
