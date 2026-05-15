---
phase: 26-banner-carousel
plan: 02
subsystem: ui
tags: [flutter, riverpod, file-picker, banner-management, gorouter]

# Dependency graph
requires:
  - phase: 26-01
    provides: Banner REST API endpoints (GET/POST/PUT/DELETE) and model
provides:
  - Staff banner management screen with upload, toggle, delete
  - BannerModel, BannerService, BannersNotifier (AsyncNotifierProvider)
  - GoRouter route for /staff/banners
  - Dashboard "Gerenciar Banners" quick action card
affects: [26-03 (student carousel consumes same BannerModel pattern)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "AsyncNotifierProvider with optimistic local state updates for toggle/delete"
    - "Image.network with buildBannerImageUrl constructing origin/uploads/{image_url}"
    - "FilePicker.platform.pickFiles(withData: true) for cross-platform image upload"

key-files:
  created:
    - mobile/lib/features/staff/models/banner_model.dart
    - mobile/lib/features/staff/services/banner_service.dart
    - mobile/lib/features/staff/providers/banner_management_provider.dart
    - mobile/lib/features/staff/screens/staff_banner_management_screen.dart
  modified:
    - mobile/lib/core/router/route_names.dart
    - mobile/lib/core/router/app_router.dart
    - mobile/lib/features/staff/screens/staff_dashboard_screen.dart

key-decisions:
  - "Optimistic state updates for toggle and delete — immediate UI feedback with rollback on error"
  - "Image URL constructed from AppConfig.apiBaseUrl origin + /uploads/ prefix — consistent with buildDownloadUrl pattern"
  - "GridView with crossAxisCount 2 and childAspectRatio 0.85 for banner card layout"

patterns-established:
  - "Banner image URL pattern: {origin}/uploads/{image_url} where image_url is relative path from API"
  - "AsyncNotifier with optimistic updates and invalidateSelf rollback on error"

requirements-completed: [BNNR-03, BNNR-04, BNNR-05, BNNR-06]

# Metrics
duration: 9min
completed: 2026-05-15
---

# Phase 26 Plan 02: Staff Banner Management Screen Summary

**Staff banner management screen with GridView of GlassCard thumbnails, Switch toggle, delete confirmation, FAB image upload via FilePicker, and dashboard Acoes Rapidas navigation wiring**

## Performance

- **Duration:** 9 min
- **Started:** 2026-05-15T05:22:37Z
- **Completed:** 2026-05-15T05:32:33Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- BannerModel with fromJson parsing and copyWith for optimistic state updates
- BannerService with fetchAll, upload (FormData+MultipartFile), toggleEnabled, deleteBanner
- BannersNotifier (AsyncNotifierProvider) with optimistic toggle/delete and error rollback
- StaffBannerManagementScreen with grid layout, image thumbnails, Switch toggle, delete dialog, FAB upload
- Route /staff/banners registered with fadeThroughPage transition
- "Gerenciar Banners" card added to staff dashboard Acoes Rapidas section

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Banner model, service, provider, and management screen** - `cc78d4b` (feat)
2. **Task 2: Wire banner management into router and dashboard Acoes Rapidas** - `cb05a91` (feat)

## Files Created/Modified
- `mobile/lib/features/staff/models/banner_model.dart` - Banner data model with fromJson and copyWith
- `mobile/lib/features/staff/services/banner_service.dart` - API client for banner CRUD with multipart upload
- `mobile/lib/features/staff/providers/banner_management_provider.dart` - Riverpod AsyncNotifierProvider with optimistic updates
- `mobile/lib/features/staff/screens/staff_banner_management_screen.dart` - Management screen with GridView, GlassCard, Switch, delete dialog, FAB upload
- `mobile/lib/core/router/route_names.dart` - Added staffBanners route name and path
- `mobile/lib/core/router/app_router.dart` - Added GoRoute for /staff/banners with import
- `mobile/lib/features/staff/screens/staff_dashboard_screen.dart` - Added "Gerenciar Banners" quick action card

## Decisions Made
- Optimistic state updates for toggle and delete — immediate UI feedback with rollback on error via invalidateSelf
- Image URL constructed by extracting origin from AppConfig.apiBaseUrl and prepending /uploads/ — consistent with existing buildDownloadUrl pattern
- GridView with crossAxisCount: 2 and childAspectRatio: 0.85 for compact banner card layout
- MIME type derived from file extension (image/jpeg, image/png, image/webp) — matches backend content-type allowlist

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Staff banner management complete, ready for Plan 03 (student carousel widget)
- Banner CRUD fully wired: model → service → provider → screen → router → dashboard

## Self-Check: PASSED

All 4 created files verified on disk. Both commit hashes (cc78d4b, cb05a91) found in git log.

---
*Phase: 26-banner-carousel*
*Completed: 2026-05-15*
