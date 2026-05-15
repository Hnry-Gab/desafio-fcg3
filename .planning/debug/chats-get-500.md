---
status: awaiting_human_verify
trigger: "GET /students/{id}/chats endpoint returns HTTP 500 error"
created: 2026-05-11T00:00:00Z
updated: 2026-05-11T07:30:00Z
---

## Current Focus

hypothesis: CONFIRMED — missing `name` column in `chat_sessions` table causes ProgrammingError
test: Added column via ALTER TABLE, endpoint now returns 200
expecting: User confirms the endpoint works in their environment
next_action: Await human verification

## Symptoms

expected: Should return a JSON array with the student's chat sessions
actual: Returns HTTP 500 Internal Server Error
errors: `asyncpg.exceptions.UndefinedColumnError: column chat_sessions.name does not exist`
reproduction: Call GET /api/v1/chat-sessions with valid JWT
started: Was working before, broke after commit b376e9f (feat(19-08)) which added `name` field access

## Eliminated

## Evidence

- timestamp: 2026-05-11T07:27:00Z
  checked: Direct endpoint call via httpx in container
  found: `sqlalchemy.exc.ProgrammingError: column chat_sessions.name does not exist`
  implication: The ORM model has a `name` column but the actual DB table doesn't

- timestamp: 2026-05-11T07:28:00Z
  checked: psql \d chat_sessions
  found: Table has no `name` column despite alembic_version showing `015a` (which depends on `014a` that adds `name`)
  implication: Migration `014a` was never actually applied despite alembic tracking it as done

- timestamp: 2026-05-11T07:28:30Z
  checked: resources table for `is_deleted` column (from migration 015a)
  found: Column EXISTS — proving 015a ran but 014a's DDL didn't
  implication: Alembic version was stamped/advanced past 014a without its DDL being applied

- timestamp: 2026-05-11T07:29:00Z
  checked: Added column via `ALTER TABLE chat_sessions ADD COLUMN name VARCHAR(100)`
  found: Endpoint now returns 200 OK with proper data including student_name and student_ra
  implication: Fix confirmed — the only issue was the missing column

- timestamp: 2026-05-11T07:29:22Z
  checked: Staff endpoint call with all 10 chat sessions
  found: Returns 200 with full data: `{"data":[...10 sessions...],"pagination":{"page":1,"per_page":20,"total":10}}`
  implication: Full fix verified end-to-end

## Resolution

root_cause: Migration `014_add_name_to_chat_sessions.py` (revision 014a) was tracked by alembic as applied, but its DDL (`ALTER TABLE chat_sessions ADD COLUMN name VARCHAR(100)`) never actually executed against the database. The ORM model `ChatSession` defines `name: Mapped[str | None]`, so any query against `chat_sessions` triggers `asyncpg.exceptions.UndefinedColumnError`. This surfaced as HTTP 500 because commit b376e9f introduced explicit access to `s.name` in the router and `selectinload` query includes all mapped columns.
fix: Applied missing DDL directly — `ALTER TABLE chat_sessions ADD COLUMN name VARCHAR(100)` — bringing the live schema in sync with what migration 014a intended.
verification: Endpoint GET /api/v1/chat-sessions returns 200 OK with proper paginated data for both student and staff users.
files_changed: []
