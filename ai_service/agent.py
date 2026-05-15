"""ReAct agent factory and invocation helpers for the AI service."""

from __future__ import annotations

import asyncio
import logging
import re
from typing import Any

from langchain.agents import create_agent
from langchain.agents.middleware import wrap_tool_call
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage, ToolMessage

from ai_service.database import load_chat_history
from ai_service.embedding_factory import create_embeddings
from ai_service.llm_factory import create_llm
from ai_service.mcp_tools import load_mcp_tools
from ai_service.rag import create_rag_tool
from ai_service.security import sanitize_input, filter_output

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Hallucination guard: detect when the LLM claims a mutating action succeeded
# but no MCP tool was actually called during the current invocation.
# ---------------------------------------------------------------------------

# Phrases that indicate the LLM claims it performed a mutating action.
# Kept case-insensitive. Only matches action-completion claims, NOT
# informational queries or suggestions.
_ACTION_CLAIM_PATTERNS = [
    r"agendamento\s+(confirmado|realizado|feito)",
    r"solicita[cç][aã]o\s+realizada",
    r"matr[ií]cula\s+(confirmada|criada|realizada|feita)",
    r"documento\s+(solicitado|pedido)",
    r"DOC-\d+",  # Fabricated document codes
    r"j[aá]\s+(pedi|solicitei|agendei|confirmei|criei|cancelei)",
]
_ACTION_CLAIM_RE = re.compile(
    "|".join(_ACTION_CLAIM_PATTERNS), re.IGNORECASE
)

# MCP tools that are mutating (non-read-only). If the LLM claims success on
# an action but none of these tools appear in the invocation messages, the
# response is likely hallucinated.
_MUTATING_TOOLS = frozenset({
    "book_appointment",
    "cancel_appointment",
    "request_document",
    "create_enrollment",
    "confirm_enrollment",
    "drop_course",
    "lock_enrollment",
})


def _agent_called_mutating_tool(messages: list[Any]) -> bool:
    """Return True if any mutating MCP tool was called in this invocation."""

    for msg in messages:
        if isinstance(msg, ToolMessage):
            # ToolMessage means a tool was called and returned.
            # Check if the preceding AIMessage had a mutating tool call.
            continue
        if isinstance(msg, AIMessage):
            tool_calls = getattr(msg, "tool_calls", None) or []
            for tc in tool_calls:
                if tc.get("name") in _MUTATING_TOOLS:
                    return True
    return False


def _response_claims_action(text: str) -> bool:
    """Return True if the response text claims a mutating action was taken."""

    return bool(_ACTION_CLAIM_RE.search(text))

FALLBACK_MESSAGE = (
    "Opa, tive um probleminha tecnico agora. "
    "Tente novamente em alguns minutos ou procure a secretaria. "
    "Desculpe pelo inconveniente!"
)


@wrap_tool_call
async def _tolerate_tool_errors(request, handler):
    """Catch any exception raised by a tool and surface it to the LLM.

    The default LangGraph ``_default_handle_tool_errors`` only catches
    ``ToolInvocationError``; ``ToolException`` (raised by
    ``langchain_mcp_adapters`` when the MCP server returns an error) is
    re-raised and kills the agent loop. That causes the whole ``/chat``
    call to fall back to the generic "Desculpe, estou com dificuldades
    tecnicas" message even when another tool (including the RAG) could
    have answered.

    This middleware converts any tool exception into a ``ToolMessage`` so
    the LLM can reason about the failure and either retry or pick another
    tool. We use the async variant because every tool wired into this
    agent (MCP tools via ``langchain-mcp-adapters`` and the RAG tool)
    executes through the async path.

    Note: Verification-blocked tool calls (D-15/D-21) are handled in the
    MCP server middleware as normal responses (not errors), so they never
    reach this handler.
    """

    try:
        return await handler(request)
    except Exception as exc:
        tool_name = request.tool_call.get("name", "?")
        error_str = str(exc)
        logger.warning(
            "Tool '%s' raised %s; surfacing error to the LLM instead of aborting.",
            tool_name,
            type(exc).__name__,
        )

        return ToolMessage(
            content=(
                f"ERRO na ferramenta '{tool_name}': {error_str}\n"
                "INSTRUCAO: NAO tente chamar esta ferramenta novamente com os mesmos parametros. "
                "Explique o erro ao aluno de forma clara e amigavel, e sugira alternativas."
            ),
            tool_call_id=request.tool_call["id"],
        )


def create_chat_agent(settings: Any, tools: list[Any], system_prompt: str) -> Any:
    """Create a provider-agnostic LangChain ReAct agent."""

    llm = create_llm(settings)
    return create_agent(
        model=llm,
        tools=tools,
        system_prompt=system_prompt,
        middleware=[_tolerate_tool_errors],
    )


def _normalize_message_content(content: Any) -> str:
    """Normalize LangChain message content into plain text."""

    if isinstance(content, str):
        return content.strip() or FALLBACK_MESSAGE

    if isinstance(content, list):
        text_parts: list[str] = []
        for item in content:
            if isinstance(item, str):
                text_parts.append(item)
            elif isinstance(item, dict):
                text_value = item.get("text")
                if isinstance(text_value, str):
                    text_parts.append(text_value)
        combined_text = "\n".join(part for part in text_parts if part).strip()
        return combined_text or FALLBACK_MESSAGE

    return str(content).strip() or FALLBACK_MESSAGE


def _extract_response_text(result: dict[str, Any]) -> str:
    """Return the last assistant-authored message as plain text."""

    response_messages = result.get("messages", [])
    if not response_messages:
        return FALLBACK_MESSAGE

    for message in reversed(response_messages):
        if isinstance(message, AIMessage):
            return _normalize_message_content(getattr(message, "content", ""))

    return FALLBACK_MESSAGE


async def invoke_agent(
    settings: Any,
    db_pool: Any,
    system_prompt: str,
    session_id: str,
    user_message: str,
    is_new_session: bool = False,
    student_name: str = "",
    verification_state: str = "unverified",
) -> str:
    """Process one student message through the LangChain agent.

    The agent is rebuilt on every request because the MCP tool client needs a
    session-specific ``X-Chat-Session-ID`` header. Conversation history is
    loaded fresh from PostgreSQL on every invocation to preserve the stateless
    service design for the AI container.

    When is_new_session=True and no prior history exists, a welcome instruction
    is injected so the agent generates a personalized greeting (D-01, LANG-01).
    """

    # Layer 2: Input sanitization (D-05)
    sanitized_message, injection_detected = sanitize_input(user_message)

    # If injection detected, prepend a context note for the agent (D-06)
    if injection_detected:
        logger.warning("Injection attempt detected for session %s", session_id)
        # The agent's system prompt instructs it to warn the student (## Seguranca section)
        # We use the sanitized message so the agent still sees context
        user_message = sanitized_message

    mcp_tools = await load_mcp_tools(settings.MCP_SERVER_URL, session_id)
    embeddings = create_embeddings(settings)
    rag_tool = create_rag_tool(
        db_pool,
        embeddings,
        similarity_threshold=settings.RAG_SIMILARITY_THRESHOLD,
        session_id=session_id,
    )
    agent = create_chat_agent(settings, [*mcp_tools, rag_tool], system_prompt)

    history_messages = await asyncio.to_thread(
        load_chat_history,
        db_pool,
        session_id,
        k=settings.CHAT_HISTORY_K,
    )

    # D-01, LANG-01: Inject welcome generation instruction on new sessions
    # D-13 to D-16: Differentiate first-time vs returning students
    if is_new_session:
        name_part = f" o aluno {student_name}" if student_name else " o aluno"
        has_prior_history = len(history_messages) > 0
        if has_prior_history:
            welcome_instruction = SystemMessage(
                content=(
                    f"Este e o inicio de uma nova conversa com{name_part}, "
                    "que ja conversou com voce antes. "
                    "Cumprimente de forma breve e calorosa pelo nome — SEM se apresentar novamente. "
                    "IMPORTANTE: Use a ferramenta get_student_info para verificar pendencias "
                    "(matricula em rascunho, documento pronto, prazo de matricula). "
                    "Se houver pendencias, mencione-as proativamente. "
                    "Depois, responda a mensagem do aluno."
                )
            )
        else:
            welcome_instruction = SystemMessage(
                content=(
                    f"Este e o inicio de uma NOVA conversa com{name_part}. "
                    "O aluno NUNCA conversou com voce antes. "
                    "Faca uma apresentacao completa: cumprimente pelo nome com 👋, "
                    "apresente-se como Alphredo (assistente da secretaria academica), "
                    "e diga brevemente como pode ajudar. "
                    "IMPORTANTE: Use a ferramenta get_student_info para verificar se o aluno "
                    "tem pendencias (matricula em rascunho, documento pronto, prazo de matricula). "
                    "Se houver pendencias, mencione-as proativamente na saudacao. "
                    "Depois, responda a mensagem do aluno."
                )
            )
        all_messages = [welcome_instruction, *history_messages, HumanMessage(content=user_message)]
    else:
        all_messages = [*history_messages, HumanMessage(content=user_message)]

    # D-14/D-15: Inject verification state context so agent knows student status
    # Positioned AFTER welcome/history so the greeting instruction takes priority.
    # Phrased as reactive-only to prevent the LLM from proactively asking for email.
    if verification_state != "verified":
        verification_context = SystemMessage(
            content=(
                "NAO peca email, nome ou qualquer identificacao proativamente. "
                "Voce ja sabe quem e o aluno pelo contexto da sessao. "
                "Quando o aluno pedir qualquer acao, chame a ferramenta correspondente normalmente. "
                "A ferramenta informara se ha algum procedimento adicional necessario."
            )
        )
        all_messages.append(verification_context)

    try:
        result = await asyncio.wait_for(
            agent.ainvoke(
                {"messages": all_messages},
                config={"recursion_limit": settings.MAX_AGENT_ITERATIONS},
            ),
            timeout=settings.MAX_AGENT_EXECUTION_TIME,
        )
    except asyncio.TimeoutError:
        logger.warning("Agent execution timed out for session %s", session_id)
        return FALLBACK_MESSAGE
    except Exception as exc:
        if exc.__class__.__name__ == "GraphRecursionError":
            logger.warning(
                "Agent iteration limit hit for session %s",
                session_id,
            )
            return FALLBACK_MESSAGE

        logger.exception("Agent execution failed for session %s", session_id)
        return FALLBACK_MESSAGE

    response_text = _extract_response_text(result)
    result_messages = result.get("messages", [])

    # ---------------------------------------------------------------
    # Hallucination guard: if the LLM claims a mutating action was
    # completed but never actually called a mutating MCP tool during
    # this invocation, retry with an explicit correction prompt.
    # This catches Gemini Flash's tendency to fabricate tool results
    # when the conversation context is rich enough for it to guess.
    # ---------------------------------------------------------------
    if (
        _response_claims_action(response_text)
        and not _agent_called_mutating_tool(result_messages)
    ):
        logger.warning(
            "Hallucination detected for session %s: response claims action "
            "but no mutating tool was called. Retrying with correction.",
            session_id,
        )

        correction = SystemMessage(
            content=(
                "ATENCAO: Voce NAO chamou nenhuma ferramenta nesta rodada, mas sua resposta "
                "afirma que uma acao foi realizada com sucesso. Isso e INCORRETO — voce DEVE "
                "chamar a ferramenta correspondente (request_document, book_appointment, "
                "create_enrollment, etc.) ANTES de dizer ao aluno que a acao foi feita. "
                "Responda novamente: chame a ferramenta necessaria AGORA e so depois "
                "comunique o resultado REAL ao aluno."
            )
        )
        retry_messages = [*all_messages, AIMessage(content=response_text), correction]

        try:
            retry_result = await asyncio.wait_for(
                agent.ainvoke(
                    {"messages": retry_messages},
                    config={"recursion_limit": settings.MAX_AGENT_ITERATIONS},
                ),
                timeout=settings.MAX_AGENT_EXECUTION_TIME,
            )
            retry_text = _extract_response_text(retry_result)
            retry_msgs = retry_result.get("messages", [])

            if _agent_called_mutating_tool(retry_msgs):
                logger.info(
                    "Hallucination corrected for session %s: tool called on retry.",
                    session_id,
                )
                response_text = retry_text
            else:
                logger.warning(
                    "Hallucination persisted after retry for session %s. "
                    "Using corrected response anyway.",
                    session_id,
                )
                # Use the retry response which may still be better than the
                # original hallucinated one, or fall back to the original
                # if the retry also failed to call tools.
                if not _response_claims_action(retry_text):
                    response_text = retry_text
                # else: keep original — at least it's a response

        except (asyncio.TimeoutError, Exception) as retry_exc:
            logger.warning(
                "Hallucination retry failed for session %s: %s. "
                "Using original response.",
                session_id,
                retry_exc,
            )

    # Layer 4: Output filtering (D-05)
    filtered_response, was_filtered = filter_output(response_text)
    if was_filtered:
        logger.warning("Output filter triggered for session %s", session_id)
    response_text = filtered_response

    return response_text
