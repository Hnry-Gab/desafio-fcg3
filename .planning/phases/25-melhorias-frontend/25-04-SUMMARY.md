---
phase: 25-melhorias-frontend
plan: 04
subsystem: ui
tags: [flutter, overflow, font-size, pt-br, accessibility, layout]

# Dependency graph
requires:
  - phase: 25-melhorias-frontend/03
    provides: Shared date_utils.dart used across screens
provides:
  - Overflow-safe dashboard "Taxa de Resolução Automatizada" row with Expanded wrapper
  - Overflow-safe OTP input row with Flexible wrappers for 320dp screens
  - All informational labels at fontSize 11+ (up from 10)
  - PT-BR grammar corrections across 8 files (missing accents fixed)
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Expanded + TextOverflow.ellipsis for long text in Row with spaceBetween"
    - "Flexible wrapper on fixed-width SizedBox for narrow screen safety"

key-files:
  created: []
  modified:
    - mobile/lib/features/staff/screens/staff_dashboard_screen.dart
    - mobile/lib/features/auth/screens/login_screen.dart
    - mobile/lib/features/staff/screens/staff_resources_screen.dart
    - mobile/lib/features/client/screens/client_resources_screen.dart
    - mobile/lib/features/staff/screens/staff_schedule_screen.dart
    - mobile/lib/features/staff/screens/staff_intervention_screen.dart
    - mobile/lib/features/staff/screens/staff_documents_screen.dart
    - mobile/lib/features/client/screens/client_notifications_screen.dart
    - mobile/lib/features/client/screens/client_documents_screen.dart
    - mobile/lib/features/client/screens/client_chat_screen.dart
    - mobile/lib/features/staff/screens/staff_chats_screen.dart
    - mobile/lib/features/staff/screens/staff_intervention_chat_screen.dart
    - mobile/lib/features/staff/screens/staff_ai_screen.dart
    - mobile/lib/features/client/screens/widgets/booking_flow_sheet.dart
    - mobile/lib/features/client/providers/notification_provider.dart
    - mobile/lib/features/staff/screens/staff_chat_detail_screen.dart
    - mobile/lib/features/staff/screens/widgets/create_slot_sheet.dart
    - mobile/lib/features/staff/screens/widgets/send_document_sheet.dart
    - mobile/lib/features/staff/screens/widgets/update_status_sheet.dart

key-decisions:
  - "Requer Autorização confirmed correct PT-BR — no change needed (D-22)"
  - "fontSize 10→11 for all informational text; nav labels kept at 10 per D-26"
  - "OTP boxes wrapped in Flexible rather than reducing width, preserving 44px when space allows"

patterns-established:
  - "Expanded wrapper pattern: any Row with spaceBetween and long Text gets Expanded + ellipsis"

requirements-completed: [D-15, D-16, D-17, D-22, D-23, D-24, D-25, D-26]

# Metrics
duration: 19min
completed: 2026-05-11
---

# Phase 25 Plan 04: Overflow Fixes, Font Size Upgrades & PT-BR Grammar Summary

**Overflow-safe dashboard/OTP layouts, fontSize 10→11 on all informational labels, and PT-BR accent corrections across 19 files**

## Performance

- **Duration:** 19 min
- **Started:** 2026-05-11T16:16:54Z
- **Completed:** 2026-05-11T16:36:10Z
- **Tasks:** 2
- **Files modified:** 19

## Accomplishments

- Fixed pixel overflow on "Taxa de Resolução Automatizada" row using Expanded + TextOverflow.ellipsis with SizedBox(width: 8) spacer
- Fixed OTP code input row overflow on 320dp screens by wrapping each SizedBox in Flexible
- Upgraded fontSize: 10 → 11 on all 18 informational label occurrences across 14 screen files
- Fixed PT-BR grammar: missing accents in 8 files (próximo, sessão, ação)
- Navigation labels (glass_bottom_nav.dart, app_theme.dart) correctly preserved at fontSize: 10

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix pixel overflow on dashboard and OTP input row** - `9f78935` (fix)
2. **Task 2: Fix grammar, increase font sizes, and audit remaining overflows** - `df78985` (fix)

## Files Created/Modified

- `mobile/lib/features/staff/screens/staff_dashboard_screen.dart` - Expanded wrapper on "Taxa de Resolução" text
- `mobile/lib/features/auth/screens/login_screen.dart` - Flexible wrapper on OTP SizedBox inputs
- `mobile/lib/features/staff/screens/staff_resources_screen.dart` - fontSize 10→11 on "Requer Autorização" badge
- `mobile/lib/features/client/screens/client_resources_screen.dart` - fontSize 10→11 on authorization + status badges
- `mobile/lib/features/staff/screens/staff_schedule_screen.dart` - fontSize 10→11 on status badge
- `mobile/lib/features/staff/screens/staff_intervention_screen.dart` - fontSize 10→11 on identifier + status badges
- `mobile/lib/features/staff/screens/staff_documents_screen.dart` - fontSize 10→11 on document status badge
- `mobile/lib/features/client/screens/client_notifications_screen.dart` - fontSize 10→11 on category label
- `mobile/lib/features/client/screens/client_documents_screen.dart` - fontSize 10→11 on document status badge
- `mobile/lib/features/client/screens/client_chat_screen.dart` - fontSize 10→11 on 3 chat metadata labels
- `mobile/lib/features/staff/screens/staff_chats_screen.dart` - fontSize 10→11 on relative time label
- `mobile/lib/features/staff/screens/staff_intervention_chat_screen.dart` - fontSize 10→11 on role + time labels
- `mobile/lib/features/staff/screens/staff_ai_screen.dart` - fontSize 10→11 on session status + grammar fix (sessão, ação)
- `mobile/lib/features/client/screens/widgets/booking_flow_sheet.dart` - fontSize 10→11 on auth + step labels
- `mobile/lib/features/client/providers/notification_provider.dart` - Grammar: proximo→próximo
- `mobile/lib/features/staff/screens/staff_chat_detail_screen.dart` - Grammar: sessao→sessão, acao→ação
- `mobile/lib/features/staff/screens/widgets/create_slot_sheet.dart` - Grammar: acao→ação
- `mobile/lib/features/staff/screens/widgets/send_document_sheet.dart` - Grammar: acao→ação
- `mobile/lib/features/staff/screens/widgets/update_status_sheet.dart` - Grammar: acao→ação

## Decisions Made

- **"Requer Autorização" kept as-is**: Grammatically correct PT-BR for resource authorization badge. D-22 referenced "Requer Aprovação" but actual codebase text is "Autorização" which is semantically appropriate.
- **OTP: Flexible wrapper chosen over width reduction**: Preserves 44px when space allows, gracefully shrinks on 320dp. Better than hardcoding a smaller width.
- **fontSize 10 scope**: Only glass_bottom_nav.dart (line 221) and app_theme.dart (nav theme config lines 228, 235, 366, 373) retain fontSize: 10. All other occurrences upgraded.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Fixed 8 additional PT-BR grammar errors beyond plan scope**
- **Found during:** Task 2 (grammar scan)
- **Issue:** Missing accent marks in 5 additional files not listed in plan: staff_chat_detail_screen.dart, create_slot_sheet.dart, send_document_sheet.dart, update_status_sheet.dart, notification_provider.dart
- **Fix:** Corrected "proximo"→"próximo", "sessao"→"sessão", "acao"→"ação" across all affected files
- **Files modified:** 5 extra files beyond plan scope
- **Verification:** dart analyze confirms no new issues
- **Committed in:** df78985 (Task 2 commit)

**2. [Rule 1 - Bug] Fixed missed fontSize: 10 at client_resources_screen.dart line 555**
- **Found during:** Task 2 (post-change audit)
- **Issue:** Plan listed fontSize: 10 at line 280 but a second occurrence existed at line 555 in a badge builder function
- **Fix:** Changed fontSize: 10 → 11
- **Files modified:** mobile/lib/features/client/screens/client_resources_screen.dart
- **Verification:** grep confirms 0 fontSize: 10 in features/
- **Committed in:** df78985 (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 missing critical grammar, 1 bug — missed fontSize occurrence)
**Impact on plan:** All auto-fixes necessary for correctness. No scope creep — grammar fixes and font audit are within plan objective.

## Issues Encountered

- Flutter tools had a path issue preventing `flutter analyze` — used `dart analyze` as equivalent alternative. All files analyzed successfully with no new errors or warnings.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 25 (melhorias-frontend) is now complete — all 4 plans executed
- All visual polish, overflow fixes, font size improvements, and grammar corrections are in place
- Zero fontSize: 10 remaining in features/ directory (nav labels correctly excluded)
- dart analyze clean on all modified files (only pre-existing info-level lints)

---
*Phase: 25-melhorias-frontend*
*Completed: 2026-05-11*

## Self-Check: PASSED

- All 19 modified files exist on disk
- Commit 9f78935 found in git log
- Commit df78985 found in git log
- SUMMARY.md created at .planning/phases/25-melhorias-frontend/25-04-SUMMARY.md
