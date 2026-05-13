---
status: awaiting_human_verify
trigger: "Staff resources toggle causes resource to disappear from list instead of moving to bottom"
created: 2026-05-13T00:00:00Z
updated: 2026-05-13T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED — backend resource service checks `user_role != "staff"` but provider role is "provider", not "staff"
test: Verified the code path: services.py line 44 uses `if user_role != "staff"` which excludes "provider" role from seeing all resources
expecting: Changing to `if user_role not in ("staff", "provider")` will fix it
next_action: Apply fix to backend/src/features/resources/services.py

## Symptoms

expected: When staff deactivates a resource, it should remain visible in the list but move to the bottom with the toggle in the "off" state
actual: The resource completely disappears from the list when deactivated
errors: No error — the item simply vanishes from the UI
reproduction: Go to staff resources screen, toggle a resource to deactivate it — it disappears
started: Likely since the toggle was implemented

## Eliminated

## Evidence

- timestamp: 2026-05-13T00:01:00Z
  checked: backend/src/features/resources/services.py line 44
  found: `if user_role != "staff":` filters out is_available=False for ALL non-"staff" roles, including "provider"
  implication: Provider users (who manage resources) only see available resources — toggling to unavailable hides them

- timestamp: 2026-05-13T00:01:30Z
  checked: backend/src/shared/dependencies.py line 163 and auth/routes.py line 139
  found: Provider role is "provider" (not "staff"), and the pattern used everywhere else is `if user.role not in ("staff", "provider")`
  implication: The resources service is inconsistent with the rest of the codebase

## Resolution

root_cause: backend/src/features/resources/services.py uses `if user_role != "staff"` which excludes "provider" role from seeing unavailable resources. Provider users get the student filter (only is_available=True), so toggling a resource to inactive makes it disappear from their list.
fix: Change condition to `if user_role not in ("staff", "provider"):` to match the pattern used throughout the codebase
verification: Python syntax check passed; Dart analysis passed (no new issues). Needs manual test in app.
files_changed: [backend/src/features/resources/services.py, mobile/lib/features/staff/screens/staff_resources_screen.dart]
