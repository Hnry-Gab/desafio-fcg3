---
status: resolved
trigger: "After long conversation flow, LLM hallucinates document creation — tells user DOC-8402 was created but never calls request_document MCP tool. Fresh sessions work correctly."
created: 2026-05-14T00:00:00Z
updated: 2026-05-15T02:15:00Z
---

## Current Focus

hypothesis: CONFIRMED — LLM hallucinates tool results when conversation context is rich enough to fabricate plausible responses. Compounding effect: first hallucination in history reinforces pattern.
test: Applied fix (system prompt anti-hallucination section + runtime hallucination guard). Tested 3 scenarios.
expecting: All scenarios should show real tool calls in MCP logs
next_action: RESOLVED — human verified via full WhatsApp flow

## Symptoms

expected: When user asks to request a document, the LLM should call the `request_document` MCP tool, and a real document request should be created in the database.
actual: The LLM fabricates a document code ("DOC-8402", "DOC-7392") and tells the user the document was requested, but NO MCP tool call is made. The document does not exist in the database or the mobile app.
errors: No errors in logs — the LLM simply doesn't call the tool. It confidently hallucinates.
reproduction: |
  Flow that WORKS (fresh session): greeting → request document → OTP → document created ✅
  Flow that FAILS (long session): greeting → book appointment → OTP → appointment confirmed → ask about next class → request document → LLM hallucinates DOC code, no MCP call ❌
started: Discovered during OTP bypass fix verification. New issue — LLM stops calling tools after many interactions.

## Eliminated

- hypothesis: Token limit overflow causing LLM to skip tools
  evidence: Total history at failure point was ~3544 chars + 11.7KB system prompt. Gemini Flash supports 1M tokens — nowhere near limit.
  timestamp: 2026-05-14T00:10:00Z

- hypothesis: MAX_AGENT_ITERATIONS (recursion_limit=10) too low
  evidence: Agent is rebuilt fresh per invocation. Document request needs only 1 tool call (3 steps). Limit of 10 is sufficient. No GraphRecursionError in logs.
  timestamp: 2026-05-14T00:12:00Z

- hypothesis: Memory window k=20 not enforced / keeps all messages
  evidence: load_chat_history uses SQL LIMIT 20. Session had 16-19 messages total, all within limit. Memory works correctly.
  timestamp: 2026-05-14T00:08:00Z

- hypothesis: Agent timeout causing fallback
  evidence: No timeout warnings in logs. All /chat responses returned 200 OK.
  timestamp: 2026-05-14T00:11:00Z

- hypothesis: Verification state blocking tool call
  evidence: Session verification_state='verified' after OTP. MCP middleware allows mutating tools when verified. No blocked_verification status for document request.
  timestamp: 2026-05-14T00:15:00Z

## Evidence

- timestamp: 2026-05-14T00:05:00Z
  checked: MCP action logs for session 574d4d2b
  found: Only 5 tool calls total — get_student_info, get_enrollment_period, get_available_slots, book_appointment (BLOCKED), get_grades. NO book_appointment after OTP, NO request_document ever.
  implication: The LLM hallucinated BOTH the appointment confirmation and the document creation. Neither tool was called.

- timestamp: 2026-05-14T00:06:00Z
  checked: Chat messages for session 574d4d2b
  found: 19 messages total. Assistant says "Agendamento confirmado com sucesso" (hallucinated) and "Solicitação realizada com sucesso... DOC-7392" (hallucinated). Both claim successful actions without any backing tool call.
  implication: Compounding hallucination — first hallucination (appointment) appears in history and reinforces pattern for second (document).

- timestamp: 2026-05-14T00:07:00Z
  checked: AI service logs
  found: No errors, warnings, or timeouts. All /chat requests returned 200 OK. No GraphRecursionError.
  implication: The agent runs successfully — the LLM simply doesn't call tools. This is LLM behavior, not infrastructure.

- timestamp: 2026-05-14T00:08:00Z
  checked: load_chat_history implementation (ai_service/database.py)
  found: Only loads role+content from chat_messages. Only stores user/assistant/system roles. Tool calls and tool responses are NOT persisted or loaded. The LLM sees no evidence of which responses were backed by real tool calls.
  implication: STRUCTURAL ISSUE — without tool call history, the LLM cannot distinguish tool-backed responses from its own generated text. After seeing confident "success" messages in history, it mimics the pattern.

- timestamp: 2026-05-14T00:09:00Z
  checked: Agent rebuilding per invocation
  found: Agent is rebuilt from scratch each invocation (agent.py line 159). History loaded fresh from DB. No state carries over between invocations.
  implication: Each invocation starts clean BUT inherits the chat history which may contain hallucinated content from previous invocations.

- timestamp: 2026-05-14T00:13:00Z
  checked: get_grades tool call for "próxima aula" query
  found: get_grades WAS called (MCP log at 01:53:23). Read-only tools still work even in long sessions.
  implication: The LLM still calls tools when it NEEDS data it doesn't have. But when it "thinks" it already knows the answer (booking details from context, document codes it can fabricate), it skips the tool call.

- timestamp: 2026-05-14T00:14:00Z
  checked: OTP auto-continue mechanism
  found: After OTP, synthetic message sent: "O aluno acabou de verificar... execute automaticamente." The LLM sees this + history showing all booking details (slot 9, reason, date). It has enough context to fabricate a "confirmed" response without calling the tool.
  implication: The auto-continue message + rich history context gives the LLM all info it needs to hallucinate rather than call tools.

- timestamp: 2026-05-15T02:06:00Z
  checked: Fix validation — 3 test scenarios after applying changes
  found: |
    Test 1 (document after rich history): request_document called, doc edf0a7ca created ✅
    Test 2 (OTP auto-continue appointment): book_appointment called with slot_number=2 ✅
    Test 3 (exact original failing flow): request_document called, doc 3235c3fd created ✅
    Unit tests: 7/7 passed for hallucination detection regex patterns ✅
    Existing test: "Olá! Consultei seus dados e sua matrícula está ativa." does NOT trigger guard ✅
  implication: Fix is working correctly — both prompt reinforcement and runtime guard function as designed.

## Resolution

root_cause: |
  Gemini Flash hallucinates tool results when the conversation history is rich enough
  for it to fabricate plausible-sounding responses. The chat_messages table only stores
  user/assistant/system roles — tool call artifacts are not persisted. When the LLM
  sees its own previous "success" messages in history (from real tool calls in earlier
  invocations), it learns the pattern and mimics it without actually calling tools.
  This is exacerbated by: (1) OTP auto-continue flow where the LLM has all booking
  details in history and skips the tool call, (2) compounding effect where the first
  hallucination (appointment confirmation) appears in history and reinforces the pattern
  for subsequent requests (document creation).

fix: |
  Two-pronged fix:
  1. System prompt: Added "REGRA CRITICA: Anti-Alucinacao de Ferramentas" section that
     explicitly tells the LLM it MUST call tools even if history suggests an action was
     already done. Emphasizes that history shows past events, not current state, and that
     calling a tool twice is better than inventing a result.
  2. Runtime hallucination guard (agent.py): After each agent invocation, checks if the
     response claims a mutating action was taken (via regex patterns like "agendamento
     confirmado", "DOC-XXXX", "solicitação realizada") but no mutating MCP tool was
     called during the invocation. If detected, retries with an explicit correction
     prompt telling the LLM it did NOT call the tool and must do so now.

verification: |
  Tested 3 scenarios simulating the exact failing conditions:
  1. Document request after rich history (10+ messages) → request_document called, real document created ✅
  2. OTP auto-continue appointment booking → book_appointment called with correct slot_number ✅  
  3. Exact reproduction of original failing flow (greeting→appointment→OTP→next class→document) → request_document called, real document in DB ✅
  All 3 scenarios: MCP action logs confirm real tool calls, documents/appointments created in DB.

files_changed:
  - ai_service/agent.py
  - ai_service/prompts/system_prompt.txt
