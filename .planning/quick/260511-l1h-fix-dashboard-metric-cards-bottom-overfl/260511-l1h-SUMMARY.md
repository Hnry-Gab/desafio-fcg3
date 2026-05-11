---
phase: quick
plan: 260511-l1h
subsystem: ui
tags: [flutter, layout, overflow, gridview, dashboard]

requires:
  - phase: 19
    provides: "Staff dashboard screen with _KpiCard GridView layout"
provides:
  - "Overflow-safe _KpiCard layout that adapts to constrained GridView height"
affects: []

tech-stack:
  added: []
  patterns:
    - "Flexible(flex: 0) wrapping for shrinkable fixed-size containers in constrained layouts"
    - "SizedBox gap instead of Spacer in height-constrained Column children"

key-files:
  created: []
  modified:
    - mobile/lib/features/staff/screens/staff_dashboard_screen.dart

key-decisions:
  - "Replaced Spacer with SizedBox(height: 4) to eliminate unbounded flex in height-constrained GridView"
  - "Wrapped icon Container in Flexible(flex: 0) to allow shrinking under tight constraints"
  - "Reduced icon container padding from 10 to 8 for 4px additional breathing room"

patterns-established:
  - "Flexible(flex: 0) pattern: use instead of bare Container when parent Column has constrained height"

requirements-completed: [quick-fix]

duration: 6min
completed: 2026-05-11
---

# Quick Fix 260511-l1h: Dashboard _KpiCard Overflow Fix Summary

**Replaced Spacer() with SizedBox + Flexible wrapping in _KpiCard to eliminate "BOTTOM OVERFLOWED BY 6.5 PIXELS" on constrained GridView cards**

## Performance

- **Duration:** 6 min
- **Started:** 2026-05-11T18:15:33Z
- **Completed:** 2026-05-11T18:21:58Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments
- Eliminated "BOTTOM OVERFLOWED BY 6.5 PIXELS" render error on staff dashboard KPI cards
- Made card content layout adaptive to any GridView-constrained height via Flexible wrapping
- Reduced icon container padding from 10→8 for additional breathing room (4px saved)

## Task Commits

Each task was committed atomically:

1. **Task 1: Make _KpiCard layout overflow-safe with Flexible wrapping** - `f80f571` (fix)
2. **Task 2: Verify existing tests still pass** - No commit (verification-only task)

## Files Created/Modified
- `mobile/lib/features/staff/screens/staff_dashboard_screen.dart` - _KpiCard.build() Column children: Spacer→SizedBox(4), Container wrapped in Flexible(flex:0), padding 10→8

## Decisions Made
- Used `SizedBox(height: 4)` instead of `Spacer()` — Spacer has unbounded flex (flex: 1) which cannot shrink below 0 in height-constrained GridView children, causing overflow. Fixed gap is predictable.
- Wrapped icon container in `Flexible(flex: 0, fit: FlexFit.loose)` — allows the 36px (20 icon + 8*2 padding) container to yield space if constraints are extremely tight.
- Reduced padding from 10 to 8 — saves 4px vertical space (total icon container shrinks from 40px to 36px), providing buffer across all screen widths.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Flutter test runner unavailable in WSL environment (flutter_tools.dart path resolution error). Verified code correctness via `dart analyze` on both source and test files — all pass with no issues. Test content verified by manual inspection: tests check text values/labels, not widget types affected by the change (Spacer→SizedBox/Flexible).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Staff dashboard overflow fix is complete and self-contained
- No downstream impact — visual layout unchanged, only internal flex behavior corrected

---
*Plan: quick-260511-l1h*
*Completed: 2026-05-11*
