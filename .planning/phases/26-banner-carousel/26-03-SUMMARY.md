---
phase: 26-banner-carousel
plan: 03
subsystem: ui
tags: [flutter, riverpod, carousel, pageview, banner, image]

# Dependency graph
requires:
  - phase: 26-banner-carousel
    provides: Banner REST API (GET /banners public endpoint)
provides:
  - BannerItem model and studentBannersProvider for student-facing banner data
  - BannerCarousel auto-scrolling widget with swipe, dots, edge case handling
  - Home screen integration with carousel between greeting and summary cards
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Auto-scrolling PageView with Timer.periodic and manual swipe pause/resume"
    - "Expanding-dot indicator pattern using AnimatedContainer width transition"
    - "Silent failure for non-critical content (SizedBox.shrink on loading/error)"
    - "AppConfig.apiBaseUrl stripping /api/v1 suffix for static file URLs"

key-files:
  created:
    - mobile/lib/features/client/providers/banner_provider.dart
    - mobile/lib/features/client/providers/banner_provider.g.dart
    - mobile/lib/features/client/screens/widgets/banner_carousel.dart
  modified:
    - mobile/lib/features/client/screens/client_home_screen.dart

key-decisions:
  - "Created lightweight BannerItem model in client providers instead of reusing staff BannerModel — keeps plans independent during parallel execution"
  - "Image URL constructed by stripping /api/v1 from AppConfig.apiBaseUrl — uploads served at server root /uploads/"
  - "Carousel loading/error states silently hidden (SizedBox.shrink) — banner is non-critical promotional content"

patterns-established:
  - "Client-side model for read-only data: BannerItem in client providers decoupled from staff management model"
  - "PageView auto-scroll with Timer.periodic + manual swipe detection via ScrollNotification"

requirements-completed: [BNNR-01, BNNR-02, BNNR-06]

# Metrics
duration: 9min
completed: 2026-05-15
---

# Phase 26 Plan 03: Student Banner Carousel Summary

**Auto-scrolling banner carousel widget with PageView, expanding-dot indicators, swipe pause/resume, edge case handling (0/1 banner), integrated into student home screen below greeting card**

## Performance

- **Duration:** 9 min
- **Started:** 2026-05-15T05:22:51Z
- **Completed:** 2026-05-15T05:31:54Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- BannerItem model and FutureProvider fetching GET /banners (public endpoint)
- BannerCarousel widget: 4-second auto-scroll, 500ms smooth transition, continuous loop
- Manual swipe pauses auto-scroll, resumes after 6 seconds idle
- Expanding-dot indicators with AnimatedContainer (active dot wider)
- Edge cases: 0 banners = invisible, 1 banner = static image (no animation/dots)
- Integrated into client home screen between greeting card and summary cards
- Pull-to-refresh includes banner reload (BNNR-06)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create banner provider and carousel widget** - `742cc16` (feat)
2. **Task 2: Integrate carousel into student home screen** - `6824cb4` (feat)

## Files Created/Modified
- `mobile/lib/features/client/providers/banner_provider.dart` - BannerItem model + studentBannersProvider (FutureProvider calling GET /banners)
- `mobile/lib/features/client/providers/banner_provider.g.dart` - Riverpod code generation output
- `mobile/lib/features/client/screens/widgets/banner_carousel.dart` - Auto-scrolling carousel widget with PageView, Timer, dots, edge cases
- `mobile/lib/features/client/screens/client_home_screen.dart` - Banner carousel integration, refresh support, animation delay cascade

## Decisions Made
- Created lightweight BannerItem model in client providers instead of reusing staff BannerModel — keeps plan 03 independent from plan 02 during parallel execution
- Image URL constructed by stripping `/api/v1` from `AppConfig.apiBaseUrl` — static uploads served at server root `/uploads/`
- Carousel loading/error states silently hidden (SizedBox.shrink) — banner is non-critical promotional content, should not block home screen rendering

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Created BannerItem model instead of reusing staff BannerModel**
- **Found during:** Task 1 (Create banner provider)
- **Issue:** Plan suggested reusing `BannerModel` from `staff/models/banner_model.dart`, but that file doesn't exist yet (plan 26-02 running in parallel)
- **Fix:** Created lightweight `BannerItem` class directly in `banner_provider.dart` with only the fields needed for display
- **Files modified:** `mobile/lib/features/client/providers/banner_provider.dart`
- **Verification:** `dart analyze` passes, provider correctly parses API response
- **Committed in:** `742cc16` (Task 1 commit)

**2. [Rule 3 - Blocking] Removed baseUrl constructor parameter from BannerCarousel**
- **Found during:** Task 1 (Create carousel widget)
- **Issue:** Plan suggested passing `baseUrl` as constructor param, but the carousel can derive it internally from `AppConfig.apiBaseUrl` — simpler API, no need to thread DioClient through widget tree
- **Fix:** Used `AppConfig.apiBaseUrl` directly inside carousel, stripping `/api/v1` suffix to construct full image URL
- **Files modified:** `mobile/lib/features/client/screens/widgets/banner_carousel.dart`
- **Verification:** Image URL construction tested with `AppConfig` values
- **Committed in:** `742cc16` (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (2 blocking — parallel plan dependency + simpler API design)
**Impact on plan:** Both fixes necessary for independent parallel execution and cleaner architecture. No scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Student banner carousel complete, consuming GET /banners public endpoint
- Plan 01 (backend API) and Plan 03 (student carousel) fully wired
- Plan 02 (staff management screen) running in parallel — when complete, full banner feature will be operational

## Self-Check: PASSED

All 3 created files verified on disk. Both commit hashes (742cc16, 6824cb4) found in git log.

---
*Phase: 26-banner-carousel*
*Completed: 2026-05-15*
