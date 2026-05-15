---
status: awaiting_human_verify
trigger: "otp-bypass-chatbot-actions — Chatbot claims OTP-required operations succeeded without ever requesting OTP verification"
created: 2026-05-14T00:00:00Z
updated: 2026-05-15T00:45:00Z
---

## Current Focus

hypothesis: CONFIRMED and FIXED — Three-layer root cause: (1) DB constraint missing 'blocked_verification' status → (2) MCP middleware logging INSERT fails → (3) exception propagates as ToolException → LLM sees generic error and hallucinates success. Additional layer: middleware returned raw string instead of ToolResult, causing FastMCP serialization failure.
test: Deployed fix, verified via direct tool invocation AND full LLM chat flow
expecting: LLM now calls mutating tools, receives VERIFICACAO NECESSARIA response, and asks student for email verification
next_action: Awaiting human verification of end-to-end flow via WhatsApp

## Symptoms

expected: When an action requiring OTP is performed, if the current session is not verified, a message should be returned instructing the chatbot to perform the verification process (OTP via email). After OTP verification succeeds, the agent retries the action with the now-authenticated session.
actual: Chatbot responds saying the operation succeeded without ever asking for OTP verification. No actual action is performed on the backend.
errors: No errors visible in logs (backend, langchain, mcp-server) — the flow silently skips the real action.
reproduction: Send a WhatsApp message asking to create an appointment or request a document. The chatbot will respond that it was done successfully, without triggering OTP.
started: Regression after a recent merge.

## Eliminated

- hypothesis: MCP middleware verification gate was removed or broken by merge
  evidence: mcp_server/middleware.py _check_verification_gate is intact. git diff c48c3c1..8f559ea shows zero changes to mcp_server/, ai_service/, or webhook code. The gate code itself is correct.
  timestamp: 2026-05-15T00:10:00Z

- hypothesis: Tool annotations (readOnlyHint) not being read correctly
  evidence: Tested fastmcp annotation handling — readOnlyHint=True is correctly set and accessible.
  timestamp: 2026-05-15T00:12:00Z

- hypothesis: Tools not loading properly in LangChain
  evidence: 16 tools loaded correctly including book_appointment, request_document.
  timestamp: 2026-05-15T00:15:00Z

- hypothesis: The merge (8f559ea) overwrote OTP-related code
  evidence: git diff shows ZERO changes to mcp_server/, ai_service/, or webhook code.
  timestamp: 2026-05-15T00:08:00Z

- hypothesis: LLM is hallucinating without calling tools (pure prompt issue)
  evidence: Partially true for initial symptom, but the root cause is deeper — the LLM WAS trying to call tools, but the tool calls were failing with exceptions that were surfaced as generic errors, leading the LLM to hallucinate success instead.
  timestamp: 2026-05-15T00:30:00Z

## Evidence

- timestamp: 2026-05-15T00:10:00Z
  checked: mcp_action_logs for session 1f217c7c (unverified session)
  found: Only read-only tools called. NO book_appointment or request_document calls logged.
  implication: Initial evidence suggested tools weren't called, but actual cause was logging failures preventing the calls from being recorded.

- timestamp: 2026-05-15T00:12:00Z
  checked: chat_messages for same session
  found: Bot said "Vou solicitar o comprovante de matrícula ✅" and "Agendamento confirmado! ✅" without any tool call.
  implication: LLM hallucinated success because the tool calls were failing silently.

- timestamp: 2026-05-15T00:25:00Z
  checked: Direct tool invocation of request_document on unverified session
  found: ToolException: "new row for relation mcp_action_logs violates check constraint ck_mcp_action_logs_status — Failing row contains... blocked_verification"
  implication: ROOT CAUSE LAYER 1: DB constraint only allows 'success', 'error', 'retry_success' — the 'blocked_verification' status added by middleware is rejected by DB.

- timestamp: 2026-05-15T00:27:00Z
  checked: DB constraint definition
  found: CHECK (status IN ('success', 'error', 'retry_success')) — missing 'blocked_verification'
  implication: Constraint was never updated when blocked_verification was introduced in commit c48c3c1.

- timestamp: 2026-05-15T00:30:00Z
  checked: After fixing DB constraint, tested again
  found: ToolException: "'str' object has no attribute 'to_mcp_result'"
  implication: ROOT CAUSE LAYER 2: Middleware returns raw string but FastMCP 3.2.4 expects ToolResult with to_mcp_result() method.

- timestamp: 2026-05-15T00:35:00Z
  checked: After fixing ToolResult return, tested again
  found: ToolException: "Output validation error: outputSchema defined but no structured output returned"
  implication: ROOT CAUSE LAYER 3: Tools declare dict return types, so ToolResult needs structured_content, not just content.

- timestamp: 2026-05-15T00:40:00Z
  checked: After fixing ToolResult with structured_content, full flow test
  found: Tool correctly returns VERIFICACAO NECESSARIA message. LLM correctly interprets it and asks for email.
  implication: All three layers fixed. Verification gate now works end-to-end.

## Resolution

root_cause: Three-layer failure cascade in the MCP verification gate:
(1) DB constraint `ck_mcp_action_logs_status` only allowed 'success', 'error', 'retry_success' — the 'blocked_verification' status introduced in commit c48c3c1 was never added to the constraint. When middleware tried to log a blocked call, the DB INSERT failed.
(2) The exception from the failed INSERT propagated out of the middleware, causing FastMCP to return an error to the langchain-mcp-adapters client, which converted it to a ToolException.
(3) The _tolerate_tool_errors middleware in agent.py caught the ToolException and surfaced a generic error message to the LLM, which then hallucinated success instead of reporting the error.
Additional: Even after fixing the constraint, the middleware returned a raw string instead of a ToolResult object, causing FastMCP 3.2.4's serialization to fail (to_mcp_result attribute error and output schema validation).

fix: |
  1. Added 'blocked_verification' to DB constraint via Alembic migration 020a
  2. Changed middleware _check_verification_gate to return ToolResult(content=..., structured_content=...) instead of raw string
  3. Improved system prompt anti-hallucination rules (rule #2, #6, #8) and verification context injection
  4. Aligned verification detection wording ("VERIFICACAO NECESSARIA" instead of "ERRO")

verification: |
  - Direct tool invocation: request_document on unverified session returns VERIFICACAO NECESSARIA (no exception)
  - Direct tool invocation: book_appointment on unverified session returns VERIFICACAO NECESSARIA (no exception)
  - Direct tool invocation: request_document on VERIFIED session creates document successfully
  - Read-only tools (get_student_info, get_grades, get_available_slots) work correctly on unverified sessions
  - Full LLM chat flow: unverified student asks for document → LLM calls tool → receives VERIFICACAO NECESSARIA → asks for email → verification flow initiated
  - MCP action logs correctly record 'blocked_verification' status
  - All 44/47 existing tests pass (3 pre-existing failures unrelated to changes)

files_changed:
  - backend/alembic/versions/020_add_blocked_verification_status.py (NEW)
  - backend/src/features/chat/models.py
  - mcp_server/middleware.py
  - ai_service/prompts/system_prompt.txt
  - ai_service/agent.py
