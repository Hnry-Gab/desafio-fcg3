from __future__ import annotations

from typing import Any

from fastmcp import Context, FastMCP
from fastmcp.dependencies import CurrentContext, Depends
from fastmcp.exceptions import ToolError

from mcp_server.api_client import call_api
from mcp_server.dependencies import resolve_student_id


def register_scheduling_tools(mcp: FastMCP) -> None:
    @mcp.tool(
        name="get_available_slots",
        description=(
            "Lista horarios de atendimento disponiveis na secretaria para os proximos dias. "
            "Retorna uma lista formatada com os horarios. "
            "O aluno escolhe pelo numero da opcao para agendar com book_appointment."
        ),
        annotations={"readOnlyHint": True},
    )
    async def get_available_slots(
        student_id: str = Depends(resolve_student_id),
        ctx: Context = CurrentContext(),
    ) -> dict[str, Any]:
        # No date filters — always returns the server default window
        # (today → today+7). Removing date_from/date_to parameters
        # prevents the LLM from hallucinating bad date filters that
        # cause empty results (observed: LLM passed date_from=2026-05-20
        # which excluded all real slots on 05/16–05/18).
        client = ctx.lifespan_context["http_client"]
        data, _ = await call_api(
            client,
            "GET",
            "/scheduling/slots",
            student_id=student_id,
        )
        items = data.get("items", [])

        # Build a pre-formatted text list the LLM can relay verbatim.
        # This prevents the LLM from reformatting (and hallucinating
        # wrong dates/times in the process).
        lines: list[str] = []
        for idx, slot in enumerate(items, start=1):
            slot["slot_number"] = idx
            staff_name = slot.get("staff", {}).get("name", "?")
            lines.append(
                f"Opcao {idx}: {slot['date']} das {slot['start_time']} "
                f"as {slot['end_time']} — {staff_name}"
            )

        data["lista_formatada"] = "\n".join(lines) if lines else "Nenhum horario disponivel."
        data["instrucao"] = (
            "COPIE a lista_formatada acima e mostre ao aluno. "
            "NAO reescreva, resuma ou altere as datas e horarios. "
            "Quando o aluno escolher, chame book_appointment com o numero da opcao."
        )
        return data

    @mcp.tool(
        name="book_appointment",
        description=(
            "Agenda um atendimento presencial na secretaria para o aluno. "
            "IMPORTANTE: voce DEVE chamar get_available_slots ANTES de usar esta ferramenta "
            "para obter os horarios disponiveis e mostrar ao aluno. "
            "Requer slot_number (numero do horario retornado por get_available_slots) "
            "e o motivo (reason) do atendimento informado pelo aluno. "
            "Ao confirmar, use SOMENTE os dados retornados pela ferramenta (data, hora, local)."
        ),
    )
    async def book_appointment(
        slot_number: int,
        reason: str,
        student_id: str = Depends(resolve_student_id),
        ctx: Context = CurrentContext(),
    ) -> dict[str, Any]:
        # Resolve slot_number → real slot UUID by re-fetching available slots.
        client = ctx.lifespan_context["http_client"]
        slots_data, _ = await call_api(
            client,
            "GET",
            "/scheduling/slots",
            student_id=student_id,
        )
        items = slots_data.get("items", [])
        if not items:
            raise ToolError(
                "Nao ha horarios disponiveis no momento. "
                "Tente novamente mais tarde."
            )
        if slot_number < 1 or slot_number > len(items):
            raise ToolError(
                f"Numero de horario invalido: {slot_number}. "
                f"Escolha entre 1 e {len(items)}. "
                "Use get_available_slots para ver as opcoes."
            )
        chosen_slot = items[slot_number - 1]
        slot_id = chosen_slot["id"]

        data, _ = await call_api(
            client,
            "POST",
            "/appointments",
            json={"slot_id": slot_id, "reason": reason},
            student_id=student_id,
        )

        # Inject a human-readable confirmation summary so the LLM
        # relays accurate slot details to the student.
        slot_info = data.get("slot", {})
        staff_info = slot_info.get("staff", {})
        data["confirmacao"] = (
            f"Agendamento CONFIRMADO: {slot_info.get('date', '?')} "
            f"das {slot_info.get('start_time', '?')} as {slot_info.get('end_time', '?')} "
            f"em {staff_info.get('name', '?')}. "
            "Informe estes dados exatos ao aluno."
        )
        return data

    @mcp.tool(
        name="cancel_appointment",
        description="Cancela um agendamento de atendimento existente do aluno. Requer o appointment_id do agendamento a ser cancelado.",
    )
    async def cancel_appointment(
        appointment_id: str,
        student_id: str = Depends(resolve_student_id),
        ctx: Context = CurrentContext(),
    ) -> dict[str, Any]:
        client = ctx.lifespan_context["http_client"]
        data, _ = await call_api(
            client,
            "PUT",
            f"/appointments/{appointment_id}/cancel",
            student_id=student_id,
        )
        return data
