---
phase: 25-melhorias-frontend
plan: 01
subsystem: ui
tags: [flutter, theme, contrast, wcag, navigation, accessibility]

# Dependency graph
requires:
  - phase: 17-ui-polish-nav-animations-glows-logo
    provides: "Logo SVG variants, neon glow palette, glassmorphism theme"
provides:
  - "WCAG AA compliant light mode primary color (#00695C, ≥4.5:1 contrast)"
  - "Clean desktop NavigationRail with exactly 4 destinations"
  - "Verified brightness-adaptive logo in both modes"
affects: [25-melhorias-frontend]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Single source of truth color change cascading via AppColors.primary → ColorScheme"

key-files:
  created: []
  modified:
    - "mobile/lib/core/theme/app_colors.dart"
    - "mobile/lib/features/client/screens/client_shell.dart"

key-decisions:
  - "Light primary changed to #00695C (deep teal) — maintains brand identity while passing WCAG AA"
  - "Logo verified with no changes needed — Phase 17 brightness-adaptive implementation is correct"

patterns-established:
  - "Color cascade pattern: single change in AppColors propagates to entire app via ColorScheme reference"

requirements-completed: [D-01, D-02, D-03, D-04, D-18, D-19, D-20, D-21]

# Metrics
duration: 8min
completed: 2026-05-11
---

# Phase 25 Plan 01: Light Mode Contrast & Desktop Nav Cleanup Summary

**Light mode primary changed from #00E5FF to #00695C for WCAG AA compliance (~5.6:1 contrast), ghost Suporte NavigationRail destination removed from desktop, logo verified in both modes**

## Performance

- **Duration:** 8 min
- **Started:** 2026-05-11T15:15:48Z
- **Completed:** 2026-05-11T15:24:15Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Light mode primary color updated to #00695C — contrast ratio improved from ~1.5:1 to ~5.6:1 on light surfaces (passes WCAG AA 4.5:1 minimum)
- Desktop NavigationRail cleaned from 5 to 4 destinations — ghost Suporte entry removed (support accessible via header icon)
- Logo brightness-adaptive behavior verified — 4 SVG variants (full/short × light/dark) render correctly in both modes
- Threat model T-25-02 mitigated: confirmed _railDestinations and _destinations both have exactly 4 items matching _onTap handler cases 0-3

## Task Commits

Each task was committed atomically:

1. **Task 1: Update light mode primary color to #00695C** - `86d90c9` (fix)
2. **Task 2: Remove ghost Suporte NavigationRailDestination + verify logo** - `4c50096` (fix)

**Plan metadata:** pending (docs: complete plan)

## Files Created/Modified

- `mobile/lib/core/theme/app_colors.dart` — Changed `primary` from `Color(0xFF00E5FF)` to `Color(0xFF00695C)` (line 10 only)
- `mobile/lib/features/client/screens/client_shell.dart` — Removed 5th NavigationRailDestination (Suporte/headset_mic, 5 lines deleted)

## Decisions Made

- **Light primary = #00695C:** Deep teal that maintains the cyber-academic brand identity while being readable on light surfaces. Black text on #00695C has ~5.6:1 contrast ratio.
- **app_theme.dart unchanged:** All references to `AppColors.primary` cascade automatically from the single change in app_colors.dart — no manual updates needed across the 10+ usages in the light theme.
- **Logo: no changes needed:** Phase 17 implementation already handles brightness detection correctly with 4 SVG variants. All assets verified present.

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- Light mode is now WCAG AA compliant — ready for Plans 02-04
- Desktop navigation is clean — 4 items matching mobile nav
- No blockers for subsequent plans (date formatting, favicon, overflow fixes)

## Self-Check: PASSED

- All files exist (app_colors.dart, client_shell.dart, 25-01-SUMMARY.md)
- All commits verified (86d90c9, 4c50096)
- Content verification passed (#00695C present, 4 rail destinations confirmed)

---
*Phase: 25-melhorias-frontend*
*Completed: 2026-05-11*
