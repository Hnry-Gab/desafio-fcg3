---
status: awaiting_human_verify
trigger: "merge-duplicate-staff-nav: After merging phases 20-22, duplicated lines in staff/provider Flutter code causing compilation failure"
created: 2026-05-11T00:00:00Z
updated: 2026-05-11T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED — Merge caused 3 distinct issues: duplicated NavigationRailDestination args, missing staffCadastro route constants, and incorrect index mapping
test: flutter analyze passes with zero compilation errors
expecting: n/a — fix verified via static analysis
next_action: Await human verification that app compiles and runs correctly

## Symptoms

expected: Flutter app compiles and runs successfully after branch merge
actual: Compilation fails with duplicated named arguments and missing member errors
errors: |
  1. staff_shell.dart:111:7 — Duplicated named argument 'icon' (Icons.people_outline)
  2. staff_shell.dart:112:7 — Duplicated named argument 'selectedIcon' (Icons.people)
  3. staff_shell.dart:113:7 — Duplicated named argument 'label' (Text('Alunos'))
  4. app_router.dart:222:30 — Member not found: 'staffCadastro' on RoutePaths
  5. app_router.dart:223:30 — Member not found: 'staffCadastro' on RouteNames
  6. staff_shell.dart:49:40 — Member not found: 'staffCadastro' on RoutePaths
  7. staff_shell.dart:67:31 — Member not found: 'staffCadastro' on RoutePaths
  8. staff_dashboard_screen.dart:220:64 — Member not found: 'staffCadastro' on RoutePaths
  9. Dart compiler crash (Null check on null value) — secondary to above
reproduction: Run `fvm flutter run` on Chrome target after merging the 3 branches
started: Immediately after merging phases 20-22

## Eliminated

## Evidence

- timestamp: 2026-05-11T00:01:00Z
  checked: staff_shell.dart _railDestinations list (lines 107-114)
  found: "Gestão" NavigationRailDestination was missing closing `)` before "Alunos" entry — the icon/selectedIcon/label args for Alunos were INSIDE the Gestão constructor
  implication: This is the source of "Duplicated named argument" errors (icon, selectedIcon, label)

- timestamp: 2026-05-11T00:01:00Z
  checked: route_names.dart — both RouteNames and RoutePaths classes
  found: No `staffCadastro` constant defined in either class, despite being referenced in app_router.dart, staff_shell.dart, and staff_dashboard_screen.dart
  implication: Phase 21 added the staffCadastro route/screen but the route constant was lost during merge

- timestamp: 2026-05-11T00:01:00Z
  checked: staff_shell.dart _onTap case 5 and _currentIndex
  found: case 5 had TWO context.go() calls (staffGestao AND staffCadastro) — merge concatenated both branches' additions. _currentIndex also mapped staffCadastro to index 5 (same as staffGestao) but the nav bar has 7 items (indices 0-6)
  implication: staffCadastro should be index 6 with its own switch case

- timestamp: 2026-05-11T00:02:00Z
  checked: fvm flutter analyze on all 4 affected files
  found: 0 errors, only 1 pre-existing info-level lint
  implication: Fix resolves all compilation errors

- timestamp: 2026-05-11T00:02:00Z
  checked: fvm flutter analyze (full project)
  found: 39 issues total — all warnings/infos. Zero errors related to our fix. Only 1 error exists (pre-existing test issue in staff_services_test.dart about missing resourceId param)
  implication: Fix is complete, no regressions introduced

## Resolution

root_cause: Three-way merge of phases 20-22 caused improper concatenation in staff_shell.dart and omission of staffCadastro route constants. Specifically: (1) Two NavigationRailDestination entries were merged into one constructor call (missing closing paren + new constructor), (2) RoutePaths.staffCadastro and RouteNames.staffCadastro were never added to route_names.dart, (3) The _onTap switch and _currentIndex method had conflicting/duplicate entries for index 5.
fix: |
  1. Split the merged NavigationRailDestination into two separate entries (Gestão + Alunos)
  2. Added `staffCadastro = 'staff-cadastro'` to RouteNames and `staffCadastro = '/staff/cadastro'` to RoutePaths
  3. Fixed _currentIndex to return 6 for staffCadastro (not 5)
  4. Fixed _onTap to use case 6 for staffCadastro navigation (separate from case 5 staffGestao)
verification: `fvm flutter analyze` passes with zero compilation errors on all affected files
files_changed:
  - mobile/lib/features/staff/screens/staff_shell.dart
  - mobile/lib/core/router/route_names.dart
