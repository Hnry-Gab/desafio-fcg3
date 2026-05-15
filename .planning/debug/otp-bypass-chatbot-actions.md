---
status: awaiting_human_verify
trigger: "otp-bypass-chatbot-actions — Chatbot claims OTP-required operations succeeded without ever requesting OTP verification"
created: 2026-05-14T00:00:00Z
updated: 2026-05-15T01:00:00Z
---

## Current Focus

hypothesis: ALL issues fixed. Full webhook E2E test passed: 10/10 slots match DB, OTP gate works, booking succeeds after verification, correct slot lands in DB.
test: Webhook simulation via HMAC-signed POST to /api/v1/webhook/whatsapp — full pipeline through background task → AI service → MCP.
expecting: User confirms via WhatsApp
next_action: Awaiting human verification via real WhatsApp

## Symptoms

expected: When an action requiring OTP is performed, if the current session is not verified, a message should be returned instructing the chatbot to perform the verification process (OTP via email). After OTP verification succeeds, the agent retries the action with the now-authenticated session.
actual: Chatbot responds saying the operation succeeded without ever asking for OTP verification. No actual action is performed on the backend. After OTP fix, appointment booking fails with 422 due to LLM sending invalid slot IDs.
errors: No errors visible in logs (original); POST /api/v1/appointments → 422 (follow-up)
reproduction: Send a WhatsApp message asking to create an appointment or request a document.
started: Regression after a recent merge.

## Eliminated

- hypothesis: MCP middleware verification gate was removed or broken by merge
  evidence: Code intact, git diff shows zero changes to mcp_server/, ai_service/, or webhook code.
  timestamp: 2026-05-15T00:10:00Z

- hypothesis: Tool annotations (readOnlyHint) not being read correctly
  evidence: readOnlyHint=True correctly set and accessible.
  timestamp: 2026-05-15T00:12:00Z

- hypothesis: Tools not loading properly in LangChain
  evidence: 16 tools loaded correctly.
  timestamp: 2026-05-15T00:15:00Z

- hypothesis: The merge (8f559ea) overwrote OTP-related code
  evidence: git diff shows ZERO changes.
  timestamp: 2026-05-15T00:08:00Z

- hypothesis: LLM is hallucinating without calling tools (pure prompt issue)
  evidence: LLM WAS calling tools, but they failed with exceptions.
  timestamp: 2026-05-15T00:30:00Z

- hypothesis: Pydantic rejects extra student_id in appointment body causing 422
  evidence: Pydantic v2 default extra='ignore' — tested AppointmentCreate with extra student_id, it works. Not the cause.
  timestamp: 2026-05-15T00:50:00Z

## Evidence

- timestamp: 2026-05-15T00:25:00Z
  checked: Direct tool invocation of request_document on unverified session
  found: ToolException: "mcp_action_logs violates check constraint ck_mcp_action_logs_status — blocked_verification"
  implication: DB constraint missing blocked_verification status.

- timestamp: 2026-05-15T00:30:00Z
  checked: After constraint fix, tested again
  found: ToolException: "'str' object has no attribute 'to_mcp_result'"
  implication: Middleware returned raw string, FastMCP 3.2.4 expects ToolResult.

- timestamp: 2026-05-15T00:35:00Z
  checked: After ToolResult fix, tested again
  found: ToolException: "Output validation error: outputSchema defined but no structured output returned"
  implication: ToolResult needs structured_content for tools with typed returns.

- timestamp: 2026-05-15T00:40:00Z
  checked: After structured_content fix, full flow test
  found: Verification gate works end-to-end. LLM asks for email correctly.
  implication: OTP bypass fixed.

- timestamp: 2026-05-15T00:50:00Z
  checked: mcp_action_logs for book_appointment errors
  found: slot_id values were "slot_005", "slot_18_05_1400_coord", "slot_5" — LLM hallucinated fake IDs instead of using real UUIDs.
  implication: LLM not extracting the UUID 'id' field from get_available_slots response.

- timestamp: 2026-05-15T00:52:00Z
  checked: After adding example UUID to tool description
  found: LLM used the EXAMPLE UUID from the description instead of the real slot ID.
  implication: Example UUIDs in descriptions get copied literally by LLMs.

- timestamp: 2026-05-15T00:55:00Z
  checked: After removing example, tested book_appointment with real slot_id
  found: Appointment created successfully, status "scheduled", slot marked unavailable.
  implication: Tool works correctly when given valid slot_id.

## Resolution

root_cause: |
  **Issue A — OTP bypass:** Three-layer failure cascade:
  (1) DB constraint `ck_mcp_action_logs_status` missing 'blocked_verification' status.
  (2) INSERT failure → exception propagated as ToolException to LLM.
  (3) Middleware returned raw string instead of ToolResult — FastMCP 3.2.4 serialization failure.
  Result: LLM received generic errors and hallucinated success.

  **Issue B — Appointment 422:** LLM hallucinated fake slot IDs (e.g., "slot_005", "slot_5").

  **Issue C — Appointment 404:** After fixing 422, LLM still hallucinated valid-format UUIDs that don't exist in the DB. Prompt/description fixes were insufficient — Gemini Flash stubbornly generates fake UUIDs.

  **Root fix for B+C:** Replaced UUID-based `slot_id` parameter with integer `slot_number`. get_available_slots now adds sequential slot_number (1, 2, 3...) to each slot. book_appointment accepts slot_number and re-fetches available slots internally to resolve the real UUID. This makes UUID hallucination structurally impossible.

fix: |
  1. Alembic migration 020a: added 'blocked_verification' to DB constraint
  2. mcp_server/middleware.py: return ToolResult(content=..., structured_content=...) instead of raw string; imported ToolResult
  3. ai_service/prompts/system_prompt.txt: anti-hallucination rules (#2, #6), explicit tool-call requirements, aligned verification wording (#8)
  4. ai_service/agent.py: simplified verification context — no longer reveals verification status
  5. mcp_server/tools/scheduling_tools.py: replaced slot_id (UUID str) with slot_number (int) in book_appointment; get_available_slots now adds slot_number to each item; book_appointment re-fetches slots internally and resolves slot_number → UUID; removed student_id from POST body
  6. backend/src/features/chat/models.py: updated model constraint

verification: |
  OTP flow:
  - request_document on unverified session → returns VERIFICACAO NECESSARIA (no exception)
  - book_appointment on unverified session → returns VERIFICACAO NECESSARIA (no exception)
  - Full LLM flow: unverified → tool blocked → LLM asks for email
  
  Appointment booking:
  - Direct: book_appointment(slot_number=1) → appointment created, status "scheduled"
  - Full LLM flow: user asks for appointment → LLM shows numbered slots → user picks → LLM calls book_appointment(slot_number=1) → success
  - MCP logs confirm: input_params = {"slot_number": 1, "reason": "..."} (integer, not UUID)
  - UUID hallucination is structurally impossible with this interface
  
  All 44/47 existing tests pass (3 pre-existing failures unrelated)

files_changed:
  - backend/alembic/versions/020_add_blocked_verification_status.py (NEW)
  - backend/src/features/chat/models.py
  - mcp_server/middleware.py
  - mcp_server/tools/scheduling_tools.py
  - ai_service/prompts/system_prompt.txt
  - ai_service/agent.py
