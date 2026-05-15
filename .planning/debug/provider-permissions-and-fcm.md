---
status: awaiting_human_verify
trigger: "Provider role gets 403 on staff endpoints; FCM credential file not recognized"
created: 2026-05-11T00:00:00Z
updated: 2026-05-11T00:01:00Z
---

## Current Focus

hypothesis: CONFIRMED — two root causes found and fixed
test: Provider role with JWT should now pass all staff permission checks; FCM credential mounted in container
expecting: Provider can access interventions, docs, enrollments, appointments; FCM initializes in Docker
next_action: User verifies in running environment

## Symptoms

expected: Provider role should pass all staff permission checks and have full access to staff endpoints (same as staff role). FCM service should read the credential file correctly.
actual: Provider gets 403 Forbidden on staff endpoints like chat-sessions/interventions and docs (no documents appear). FCM credential file not recognized.
errors: 403 Forbidden HTTP status on provider requests to staff-restricted endpoints
reproduction: Log in as provider role, try accessing chat-sessions/interventions endpoint or docs endpoint. FCM: check Docker logs for credential initialization.
started: Provider permission never worked — role was recently added. FCM credential issue likely from configuration path.

## Eliminated

## Evidence

- timestamp: 2026-05-11T00:00:30Z
  checked: src/shared/auth.py require_role() function
  found: Line 90 does exact match `current_user.role != role` — "provider" != "staff" → 403
  implication: This is the root cause for chat interventions 403

- timestamp: 2026-05-11T00:00:31Z
  checked: src/features/chat/router.py
  found: 4 endpoints use `Depends(require_role("staff"))` — interventions, assign, reply, resolve
  implication: All four chat staff endpoints block provider

- timestamp: 2026-05-11T00:00:32Z
  checked: src/shared/dependencies.py require_staff()
  found: Newer function correctly checks `user.role not in ("staff", "provider")` — but chat router doesn't use it
  implication: Two parallel permission systems exist — old one (auth.py) is broken for provider

- timestamp: 2026-05-11T00:00:33Z
  checked: src/features/documents/controllers.py list_documents
  found: Line 97 `if user.role != "staff"` forces provider to only see own documents (they have none)
  implication: Provider sees empty doc list because they're treated as a student for IDOR scoping

- timestamp: 2026-05-11T00:00:34Z
  checked: docker-compose.yml volumes for fastapi-app
  found: No volume mount for FCM credential JSON file; file lives at project root, container WORKDIR is /app
  implication: FCM_CREDENTIALS_PATH resolves to a nonexistent file inside the container

- timestamp: 2026-05-11T00:00:35Z
  checked: .env file
  found: FCM_CREDENTIALS_PATH=desafio-fcg-g3-firebase-adminsdk-fbsvc-a31712f7e2.json (relative path, file exists at project root)
  implication: Path is relative — inside container it would be /app/<filename> but file is never mounted there

- timestamp: 2026-05-11T00:00:36Z
  checked: src/features/enrollment/controllers.py, src/features/appointments/controllers.py
  found: Same `role != "staff"` pattern forces provider to be scoped to own data
  implication: Enrollment and appointment list endpoints also broken for provider

## Resolution

root_cause: |
  Two issues:
  1. PERMISSION: `require_role("staff")` in `src/shared/auth.py` does exact string match — provider fails.
     Additionally, `role != "staff"` checks in documents, enrollment, and appointments controllers
     force provider to be scoped like a student (seeing only own data, which is empty for provider).
  2. FCM: The credential JSON file at project root is never volume-mounted into the Docker container.
     The env var FCM_CREDENTIALS_PATH is a relative filename that resolves to /app/<file> in the
     container, but no volume bind places the file there.

fix: |
  1. Updated `require_role()` in auth.py to allow "provider" when checking for "staff" role (D-04).
  2. Updated documents/controllers.py to use `user.role in ("staff", "provider")` for list scoping.
  3. Updated enrollment/controllers.py same pattern.
  4. Updated appointments/controllers.py same pattern (list + file upload IDOR check).
  5. Added volume mount in docker-compose.yml to bind FCM credential file into container at /app/.

verification: |
  - All modified Python files pass syntax check (ast.parse)
  - docker-compose.yml passes YAML validation
  - Logic verified: require_role("staff") now builds set {"staff", "provider"} and checks membership

files_changed:
  - backend/src/shared/auth.py
  - backend/src/features/documents/controllers.py
  - backend/src/features/enrollment/controllers.py
  - backend/src/features/appointments/controllers.py
  - docker-compose.yml
