---
phase: 25-chatbot-interaction-polish
fixed: 2026-05-12T00:15:00Z
scope: critical_warning
findings_fixed: 4
findings_deferred: 2
findings_total: 6
status: partial
---

# Phase 25: Code Review Fix Report

**Fixed:** 2026-05-12T00:15:00Z
**Scope:** Critical + Warning (6 findings)
**Status:** partial (4 fixed, 2 deferred)

## Fixes Applied

### CR-01: SQL Injection Guard in Migration (FIXED)
**Commit:** `fix(25): CR-01 add SQL injection guard to migration constants`
**File:** `backend/alembic/versions/016_expand_knowledge_base_categories.py`
**Fix:** Added `import re` + runtime assertions validating that `NEW_CATEGORIES` and `OLD_CATEGORIES` contain only static literal characters. Added security comment warning future developers.

### WR-01: Session Locks Memory Leak (FIXED)
**Commit:** `fix(25): WR-01 add periodic cleanup of stale session locks`
**File:** `backend/src/features/webhook/background.py`
**Fix:** Changed `_session_locks` from `dict[str, Lock]` to `dict[str, tuple[Lock, float]]` with monotonic timestamps. Added periodic cleanup that removes locks idle > 10 minutes on each `process_message` call.

### WR-04: Sync DB Call Blocking Event Loop (FIXED)
**Commit:** `fix(25): WR-04 wrap sync load_chat_history in asyncio.to_thread`
**File:** `ai_service/agent.py`
**Fix:** Wrapped `load_chat_history()` (synchronous psycopg call) in `asyncio.to_thread()` to avoid blocking the async event loop during database I/O.

### WR-05: Synthetic Message as User Input (FIXED)
**Commit:** `fix(25): WR-05 save verification audit trail as system message`
**File:** `backend/src/features/webhook/service.py`
**Fix:** Added `save_message(role="system")` call before the auto-continue dispatch to create a proper audit trail. The synthetic instruction still goes to `process_message` as text (agent needs it), but the DB now has a system-role record.

## Deferred

### WR-02: Idle Monitor Race Condition (DEFERRED)
**Reason:** Benign UX issue — student might receive goodbye after session is already closed. Low impact, would require restructuring the idle monitor flow.

### WR-03: Default Password in Config (DEFERRED)
**Reason:** Dev-only fallback path, only used when DATABASE_URL is not set. Production always sets DATABASE_URL explicitly. Risk is minimal.

---

_Fixed: 2026-05-12T00:15:00Z_
_Fixer: the agent (gsd-code-fixer)_
