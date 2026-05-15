---
phase: 25-chatbot-interaction-polish
reviewed: 2026-05-11T22:45:00Z
depth: standard
files_reviewed: 11
files_reviewed_list:
  - ai_service/prompts/system_prompt.txt
  - ai_service/config.py
  - ai_service/llm_factory.py
  - ai_service/agent.py
  - ai_service/ingest.py
  - backend/src/features/webhook/background.py
  - backend/src/features/webhook/idle_monitor.py
  - backend/src/features/webhook/router.py
  - backend/src/features/webhook/service.py
  - mcp_server/api_client.py
  - backend/alembic/versions/016_expand_knowledge_base_categories.py
findings:
  critical: 1
  warning: 5
  info: 3
  total: 9
status: issues_found
---

# Phase 25: Code Review Report

**Reviewed:** 2026-05-11T22:45:00Z
**Depth:** standard
**Files Reviewed:** 11
**Status:** issues_found

## Summary

This phase implements chatbot interaction polish including: a comprehensive system prompt, LLM provider factory, agent invocation with middleware for tool error handling, knowledge base ingestion expansion, idle session monitoring, verification state machine (lazy OTP), and markdown-to-WhatsApp formatting. Overall code quality is solid with good documentation, proper error handling patterns, and security-conscious design (canary token in prompt, injection detection, service token auth).

Key concerns: a potential SQL injection vector in the Alembic migration via f-string interpolation, an unbounded memory leak in the session locks dictionary, and several edge cases in the idle monitor and verification flow that could lead to unexpected behavior.

## Critical Issues

### CR-01: SQL Injection Risk in Alembic Migration via f-string Interpolation

**File:** `backend/alembic/versions/016_expand_knowledge_base_categories.py:34-38`
**Issue:** The `upgrade()` and `downgrade()` functions use f-string interpolation to build raw SQL statements (`op.execute(f"ALTER TABLE ... CHECK (category IN ({NEW_CATEGORIES}))")`). While the interpolated values are currently hardcoded string constants defined in the same file (not user input), this pattern is dangerous and sets a precedent: any future developer who modifies `NEW_CATEGORIES` or `OLD_CATEGORIES` to include dynamic content (e.g., reading from config) would introduce a SQL injection vulnerability. Alembic's `op.execute()` with string interpolation bypasses parameterized queries.
**Fix:** Since this is a DDL statement (CHECK constraint) that cannot use parameterized queries, add an explicit comment warning that values MUST be string literals, or validate the constants at module level:
```python
# SECURITY: These MUST remain hardcoded string literals — never dynamic input.
# DDL CHECK constraints cannot use parameterized queries.
import re
assert re.match(r"^['\w\s,_]+$", NEW_CATEGORIES), "Categories must be static literals"
assert re.match(r"^['\w\s,_]+$", OLD_CATEGORIES), "Categories must be static literals"
```

## Warnings

### WR-01: Unbounded Session Locks Dictionary (Memory Leak)

**File:** `backend/src/features/webhook/background.py:31`
**Issue:** `_session_locks: dict[str, asyncio.Lock] = {}` grows without bound. The cleanup at line 410 (`if not lock.locked(): _session_locks.pop(lock_key, None)`) only fires after the current task releases the lock, but if concurrent messages arrive rapidly for many distinct sessions, the dictionary grows indefinitely. In a long-running process handling thousands of students, this leaks memory.
**Fix:** Use a bounded LRU cache or add periodic cleanup. A simple mitigation:
```python
import time

_session_locks: dict[str, tuple[asyncio.Lock, float]] = {}

# In process_message, after the async with lock block:
# Periodic cleanup — remove locks idle > 10 minutes
now = time.monotonic()
stale = [k for k, (_, ts) in _session_locks.items() if now - ts > 600 and not _session_locks[k][0].locked()]
for k in stale:
    _session_locks.pop(k, None)
```

### WR-02: Idle Monitor Race Condition on Session Status

**File:** `backend/src/features/webhook/idle_monitor.py:128-133`
**Issue:** Between the first `asyncio.sleep(IDLE_FOLLOWUP_SECONDS)` (line 109) and the second DB check (line 112-133), the session may have already been closed by farewell detection in `background.py`. While the code checks `session.status != "active"` (line 132), there's a window where the goodbye message is sent (line 153) AFTER `close_session` but the `send_text_message` could fail silently or send to an already-closed conversation. More importantly, if `close_session` runs between the DB read at line 128-132 and the `send_text_message` at line 153, the student receives a goodbye after the session is already marked closed (benign but confusing UX).
**Fix:** Move the WhatsApp send inside the DB session block and check status atomically before sending:
```python
# Inside the async with async_session() block:
if not session or session.status != "active":
    return
# ... close session, commit, THEN send message
await db.commit()
await wa_client.send_text_message(phone, goodbye)
```
The code currently does this on lines 150-153 but the `send_text_message` is OUTSIDE the `async with` block, meaning the DB session is closed before sending. If the send fails, the session is already closed with no recovery. Consider wrapping with try/except.

### WR-03: `config.py` Defaults Contain Credentials

**File:** `ai_service/config.py:50`
**Issue:** `POSTGRES_PASSWORD` defaults to `"change_me_in_production"` (line 50). While this is only used when `DATABASE_URL` is not set (development fallback), shipping a default password in source code — even a placeholder — risks accidental production deployment with the default. The CONVENTIONS.md states `MCP_SERVICE_TOKEN` should never be in source, and the same principle should apply to database credentials.
**Fix:** Remove the default and require the env var or raise an error:
```python
password = os.environ.get("POSTGRES_PASSWORD")
if not password:
    raise ValueError("POSTGRES_PASSWORD environment variable is required when DATABASE_URL is not set")
```

### WR-04: Missing `await` Check on `load_chat_history`

**File:** `ai_service/agent.py:150-154`
**Issue:** `load_chat_history` is called synchronously (`history_messages = load_chat_history(...)`) but the function name and context suggest database I/O. If `load_chat_history` in `ai_service/database.py` is an async function, this call would return a coroutine object (never awaited) — resulting in an empty history list being silently used. If it's synchronous (using `psycopg` sync), it blocks the event loop during the DB query.
**Fix:** Verify the implementation of `load_chat_history`:
- If async: change to `history_messages = await load_chat_history(...)`
- If sync with blocking I/O: wrap in `asyncio.to_thread()` to avoid blocking the event loop:
```python
history_messages = await asyncio.to_thread(load_chat_history, db_pool, session_id, k=settings.CHAT_HISTORY_K)
```

### WR-05: Verification Auto-Continue Sends Synthetic Message as Student Input

**File:** `backend/src/features/webhook/service.py:431-433`
**Issue:** After OTP verification succeeds, the code dispatches a synthetic message to `process_message` with `message_text` being an instruction: `"O aluno acabou de verificar..."`. This instruction is sent to the AI agent as if the student typed it. If the agent's conversation history is persisted (which it is — the `save_message` in `background.py` saves assistant responses), this synthetic message may leak into the student's visible history or confuse the agent in subsequent turns. The message was also never saved to `chat_messages` as a user message, creating an asymmetry where the agent response is saved but the triggering "message" is not.
**Fix:** Save the synthetic message as a `system` role message (not `user`) before dispatching, or use a SystemMessage injection in the agent layer instead of masquerading as user input:
```python
# Save as system message for audit trail
await self.save_message(
    session_id=session.id,
    role="system",
    content="[Verificação concluída — retomando ação pendente]",
    media_type=None,
    wamid=None,
    db=db,
)
```

## Info

### IN-01: Unused Import `get_model_string` in `llm_factory.py`

**File:** `ai_service/llm_factory.py:11-26`
**Issue:** The function `get_model_string` is defined but never imported or called from `agent.py` or any other module in the reviewed files. Only `create_llm` is used. This appears to be dead code or a remnant of an older API design.
**Fix:** Verify if `get_model_string` is used elsewhere. If not, remove it to reduce maintenance burden.

### IN-02: Hardcoded Fallback Message Duplicated Across Services

**File:** `ai_service/agent.py:22-26` and `backend/src/features/webhook/background.py:33-37`
**Issue:** The `FALLBACK_MESSAGE` constant is defined identically in both the AI service and the backend webhook module. If the message is ever updated, both must be changed in sync — a maintenance risk.
**Fix:** This is acceptable for now (decoupled services), but consider documenting the coupling or defining the fallback in a shared contract/config.

### IN-03: `ingest.py` Requires ALL Knowledge Files to Exist

**File:** `ai_service/ingest.py:79-83`
**Issue:** `ensure_known_sources` raises `FileNotFoundError` if any file in `CATEGORY_MAP` is missing. This is strict — adding a new category mapping before creating the file will crash the entire ingestion. A partial-ingestion mode (skip missing, warn) might be more practical during development.
**Fix:** Consider a `--strict` flag that controls behavior:
```python
def ensure_known_sources(source_dir: Path, strict: bool = True) -> list[Path]:
    missing = [name for name in CATEGORY_MAP if not (source_dir / name).exists()]
    if missing:
        if strict:
            raise FileNotFoundError(...)
        LOGGER.warning("Skipping missing files: %s", ", ".join(missing))
    return [source_dir / name for name in CATEGORY_MAP if (source_dir / name).exists()]
```

---

_Reviewed: 2026-05-11T22:45:00Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
