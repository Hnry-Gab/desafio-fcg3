from __future__ import annotations

import json
import time
from typing import Any
from uuid import UUID

from fastmcp.exceptions import ToolError
from fastmcp.server.dependencies import get_http_headers
from fastmcp.server.middleware import Middleware, MiddlewareContext
from fastmcp.tools.base import ToolResult

from mcp_server.api_client import RETRY_STATE_KEY
from mcp_server.dependencies import (
    get_db_pool,
    validate_active_chat_session,
    validate_chat_session_id,
)


def _to_json_payload(value: Any) -> str | None:
    if value is None:
        return None
    return json.dumps(value, default=str)


def _serialize_result(result: Any) -> Any:
    if hasattr(result, "model_dump"):
        return result.model_dump(mode="json")
    if hasattr(result, "dict"):
        return result.dict()
    if isinstance(result, (dict, list, str, int, float, bool)) or result is None:
        return result
    return str(result)


def _sanitize_input_params(input_params: dict[str, Any]) -> dict[str, Any]:
    return {
        key: value for key, value in input_params.items() if key != "student_id"
    }


class ToolLoggingMiddleware(Middleware):
    def __init__(self) -> None:
        super().__init__()

    async def on_call_tool(self, context: MiddlewareContext, call_next):
        tool_name = context.message.name
        input_params = _sanitize_input_params(context.message.arguments or {})
        headers = get_http_headers(include={"x-chat-session-id"})
        raw_chat_session_id = headers.get("x-chat-session-id")
        fastmcp_context = context.fastmcp_context
        if fastmcp_context is None:
            raise RuntimeError("FastMCP context unavailable for audit logging.")

        chat_session_id = validate_chat_session_id(raw_chat_session_id)
        db_pool = get_db_pool(fastmcp_context.lifespan_context)
        session_data = await validate_active_chat_session(db_pool, chat_session_id)

        # D-15/D-21: Check verification gate on mutating tools.
        # Returns None if allowed, or a response string if blocked.
        verification_block = await self._check_verification_gate(context, session_data)

        start = time.monotonic()
        result: Any = None
        status = "success"

        try:
            if verification_block is not None:
                # Return verification instructions as normal tool output (not an
                # error). This avoids ToolError → ToolException propagation
                # issues that caused the agent to crash with FALLBACK_MESSAGE
                # instead of initiating the OTP flow.
                result = verification_block
                status = "blocked_verification"
            else:
                result = await call_next(context)
        except Exception:
            status = "error"
            raise
        finally:
            latency_ms = int((time.monotonic() - start) * 1000)
            await self._log_call(
                context=context,
                tool_name=tool_name,
                input_params=input_params,
                db_pool=db_pool,
                chat_session_id=chat_session_id,
                result=result,
                latency_ms=latency_ms,
                status=status,
            )

        return result

    async def _check_verification_gate(
        self, context: MiddlewareContext, session_data: dict
    ) -> ToolResult | None:
        """Check whether to block a mutating tool call for unverified students.

        Read-only tools (readOnlyHint=True) are allowed for all students.
        Mutating tools (no readOnlyHint) require verification_state='verified'.

        Returns None if the call is allowed, or a ToolResult with
        verification instructions if blocked. The result is returned as a
        proper ToolResult (not a raw string) so that the FastMCP framework
        can serialize it correctly via to_mcp_result(). Unlike the previous
        approach that raised ToolError, returning a normal response ensures
        the LangChain agent receives the instructions reliably without
        exception propagation issues (D-15/D-21).
        """
        verification_state = session_data.get("verification_state", "unverified")
        if verification_state == "verified":
            return None  # Verified students can use all tools

        # Check if the tool is read-only via annotations
        tool_name = context.message.name
        try:
            tool = await context.fastmcp_context.fastmcp.get_tool(tool_name)
            annotations = getattr(tool, "annotations", None)
            if annotations and getattr(annotations, "readOnlyHint", False):
                return None  # Read-only tool, allowed for unverified students
        except Exception:
            pass  # If we can't determine, block by default (safe side)

        # Mutating tool + unverified student → return verification instructions
        # Wrapped in ToolResult with structured_content so FastMCP output
        # validation passes (tools declare dict[str, Any] return types).
        message = (
            f"VERIFICACAO NECESSARIA: A acao '{tool_name}' requer verificacao de identidade do aluno. "
            "O aluno ainda NAO verificou sua identidade nesta sessao de chat. "
            "Para prosseguir, solicite que o aluno informe o email cadastrado "
            "no sistema para receber um codigo de verificacao por email. "
            "Seja amigavel, explique que e um procedimento de seguranca rapido. "
            "Apos o aluno verificar a identidade, voce podera executar a acao novamente."
        )
        return ToolResult(
            content=message,
            structured_content={
                "status": "blocked_verification",
                "message": message,
            },
        )

    async def _log_call(
        self,
        *,
        context: MiddlewareContext,
        tool_name: str,
        input_params: dict[str, Any],
        db_pool: object,
        chat_session_id: UUID,
        result: Any,
        latency_ms: int,
        status: str,
    ) -> None:
        fastmcp_context = context.fastmcp_context
        retry = bool(await fastmcp_context.get_state(RETRY_STATE_KEY))
        effective_status = status
        if status == "success" and retry:
            effective_status = "retry_success"

        await db_pool.execute(
            """
            INSERT INTO mcp_action_logs (
                id,
                chat_session_id,
                tool_name,
                input_params,
                output_result,
                reasoning,
                latency_ms,
                retry,
                status
            )
            VALUES (gen_random_uuid(), $1, $2, $3::jsonb, $4::jsonb, $5, $6, $7, $8)
            """,
            chat_session_id,
            tool_name,
            _to_json_payload(input_params) or "{}",
            _to_json_payload(_serialize_result(result)),
            None,
            latency_ms,
            retry,
            effective_status,
        )
