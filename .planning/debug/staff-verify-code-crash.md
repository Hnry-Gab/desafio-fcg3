---
status: awaiting_human_verify
trigger: "POST /api/v1/auth/verify-code crashes for staff accounts after merging phases 20-22"
created: 2026-05-11T00:00:00Z
updated: 2026-05-11T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED — Migration 014a DDL was skipped during branch merge; alembic_version shows 015a but staff.status column never created
test: Queried information_schema.columns — staff table missing status, work_schedule, position columns
expecting: Running 014a DDL manually will fix the crash
next_action: Apply missing DDL from migration 014a and verify

## Symptoms

expected: Staff user completes OTP verification and receives JWT token, same as student flow
actual: After POST /api/v1/auth/verify-code for a staff account, the connection errors with "XMLHttpRequest onError callback was called" — indicating the backend crashed or dropped the connection
errors: "[API] POST http://localhost:8000/api/v1/auth/verify-code" followed by "[API ERROR] null The connection errored: The XMLHttpRequest onError callback was called. This typically indicates an error on the network layer."
reproduction: Login as staff user → receive OTP → submit OTP code → error occurs at verify-code POST
started: After merging phases 20-22 branches. Student login works fine, only staff login fails.

## Eliminated

- hypothesis: Bug in Python code (routes.py logic, jwt_service, session_service)
  evidence: All Python code is correct. The crash is a DB-level UndefinedColumnError, not a logic bug.
  timestamp: 2026-05-11T00:05:00Z

## Evidence

- timestamp: 2026-05-11T00:02:00Z
  checked: Docker container logs (fcg3-api)
  found: "asyncpg.exceptions.UndefinedColumnError: column staff.status does not exist" at routes.py:131 (select(Staff).where(Staff.email == ...))
  implication: The SQLAlchemy Staff model has a status column, but the DB table doesn't

- timestamp: 2026-05-11T00:04:00Z
  checked: information_schema.columns for staff table + alembic_version
  found: Staff table has only [id, name, email, phone, role, created_at, updated_at] — missing status, work_schedule, position. But alembic_version says 015a (head).
  implication: Migration 014a DDL was never applied despite alembic_version progressing past it

- timestamp: 2026-05-11T00:05:00Z
  checked: Migration chain: 013a → 014a → 014b → 014c → 015a
  found: Three 014_* files exist from parallel branches (phases 20-22). The merge resulted in alembic_version being stamped at 015a without actually executing 014a's DDL.
  implication: Branch merge skipped intermediate migration DDL

- timestamp: 2026-05-11T00:08:00Z
  checked: Applied missing DDL manually, then tested POST /api/v1/auth/verify-code with staff email
  found: verify-code returned 200 OK with valid JWT token pair (was 500 before fix)
  implication: Fix confirmed — the root cause was the missing staff.status column

- timestamp: 2026-05-11T00:09:00Z
  checked: Migration chain integrity (alembic history --verbose)
  found: Single linear chain with no branches. Fresh alembic upgrade head will apply 014a correctly.
  implication: No code changes needed — this was a one-time DB state issue from the branch merge

## Resolution

root_cause: Migration 014a (expand_staff_table_provider_role) DDL was skipped during merge of phases 20-22. The alembic_version table shows 015a (head), but the staff table never received the status, work_schedule, and position columns. When verify-code queries Staff by email, SQLAlchemy generates SELECT ... staff.status ... which fails with UndefinedColumnError at routes.py:131.
fix: Applied missing DDL from migration 014a directly to the running database — added status (VARCHAR(20), NOT NULL, DEFAULT 'active'), work_schedule (TEXT), position (VARCHAR(100)) columns, ck_staff_role constraint expanded to include 'provider', ck_staff_status constraint added, and idx_staff_email + idx_staff_status indexes created. No code changes needed — the migration chain (013a→014a→014b→014c→015a) is correct for fresh installs.
verification: POST /api/v1/auth/verify-code for staff user universalblackout1@gmail.com returned 200 OK with valid JWT token pair. Docker logs confirmed no errors.
files_changed: []
