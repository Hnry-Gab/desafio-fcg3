# Ferramentas MCP
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: ferramentas-mcp, mcp-tools, tool-schemas, get-grades, create-enrollment, request-document, book-appointment, student-tools, enrollment-tools, document-tools
-->
[TOC]

## Resumo rapido

As ferramentas MCP sao funcoes que o agente LangChain pode chamar para consultar ou alterar dados academicos. Elas cobrem aluno, notas, curriculo, matricula, documentos e agendamentos, sempre sem expor `student_id` nos parametros do LLM.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `mcp_server/tools/*.py`, `mcp_server/tests/test_tool_schemas.py`, `mcp_server/tests/test_tool_http_wiring.py`, `docs/backup/mcp.md`
- Servico: MCP Server

## Keywords

- ferramentas-mcp
- mcp-tools
- tool-schemas
- tool-calling
- get-student-info
- get-grades
- get-transcript
- get-curriculum
- create-enrollment
- confirm-enrollment
- request-document
- book-appointment
- cancel-appointment
- read-only-tools
- mutating-tools

## Contexto

As tools conectam linguagem natural a acoes concretas. Testes verificam que `student_id` nao aparece nos schemas expostos, reduzindo risco de IDOR e impedindo que o modelo escolha outro aluno.

## Detalhamento tecnico

Ferramentas registradas e uso em apresentacao:

| Tool | Tipo | Parametros expostos | Backend |
|---|---|---|---|
| `get_student_info` | leitura | nenhum | `GET /students/{student_id}/academic-summary` |
| `get_available_courses` | leitura | nenhum | `GET /students/{student_id}/available-courses` |
| `get_grades` | leitura | `semester_year?` | `GET /students/{student_id}/grades` |
| `get_transcript` | leitura | nenhum | `GET /students/{student_id}/transcript` |
| `get_curriculum` | leitura | nenhum | `GET /curriculum/active` |
| `get_course_prerequisites` | leitura | `course_id` | `GET /courses/{course_id}/prerequisites` |
| `get_enrollment_period` | leitura | nenhum | `GET /enrollment-periods/current` |
| `create_enrollment` | mutacao | `enrollment_period_id`, `course_ids` | `POST /enrollments` |
| `confirm_enrollment` | mutacao | `enrollment_id` | `POST /enrollments/{enrollment_id}/confirm` |
| `drop_course` | mutacao | `enrollment_id`, `course_id` | `DELETE /enrollments/{enrollment_id}/courses/{course_id}` |
| `lock_enrollment` | mutacao | `enrollment_id` | `POST /enrollments/{enrollment_id}/lock` |
| `request_document` | mutacao | `type` | `POST /documents` |
| `get_document_status` | leitura | `document_id` | `GET /documents/{document_id}` |
| `get_available_slots` | leitura | `date_from?`, `date_to?` | `GET /scheduling/slots` |
| `book_appointment` | mutacao | `slot_id`, `reason` | `POST /appointments` |
| `cancel_appointment` | mutacao | `appointment_id` | `PUT /appointments/{appointment_id}/cancel` |

## Interfaces e dependencias

- Tools read-only usam anotacao `readOnlyHint` quando aplicavel.
- Tools mutantes sao bloqueadas para sessoes nao verificadas.
- Cada tool chama um endpoint backend correspondente via `api_client`.
- O middleware remove `student_id` de `input_params` antes de logar.
- Todas as tools dependem de sessao ativa via `x-chat-session-id`.
- `student_id` entra como dependencia oculta do FastMCP e nao como parametro do LLM.

## Exemplos

Exemplo de contrato logico:

```text
Tool: create_enrollment
Entrada exposta: enrollment_period_id, course_ids
Entrada interna: student_id resolvido pelo MCP
Backend: POST /enrollments
```

## Links relacionados

- [MCP Server](mcp-server.md)
- [MCP sessoes e verificacao](mcp-sessoes-verificacao.md)
- [MCP auditoria e retry](mcp-auditoria-retry.md)
- [API REST e contratos](api-rest-contratos.md)
- [Modulos academicos](modulos-academicos.md)
- [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md)
