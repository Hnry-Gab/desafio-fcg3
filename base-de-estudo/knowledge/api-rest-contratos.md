# API REST e Contratos
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: api-rest, contratos, endpoints, fastapi, jwt, service-token, students, enrollments, matrícula, documents, appointments, resources, recursos, staff, provider, chat-sessions, webhook
-->
[TOC]

## Resumo rapido

A API REST exposta pelo backend usa prefixo `/api/v1` para o app e endpoints especificos para webhook WhatsApp. Os contratos seguem verbos HTTP convencionais, erros padronizados e autenticacao por JWT ou service token conforme o consumidor.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `backend/src/routes.py`, `backend/src/features/*/controllers.py`, `docs/backup/api.md`
- Consumidores: Flutter app, MCP Server, WhatsApp webhook

## Keywords

- api-rest
- rest-api
- contratos
- endpoints
- fastapi
- jwt
- bearer-token
- service-token
- x-service-token
- students
- enrollments
- matrícula
- documents
- appointments
- resources
- recursos
- staff
- provider
- chat-sessions
- webhook

## Contexto

O backend precisa servir tanto telas humanas quanto chamadas internas automatizadas pelo MCP. Por isso, endpoints de aluno validam ownership por JWT quando chamados pelo app e aceitam contexto interno quando chamados pelo MCP.

## Detalhamento tecnico

Principais grupos de endpoints:

| Grupo | Exemplos | Responsabilidade |
|---|---|---|
| Auth | `/auth/request-code`, `/auth/verify-code`, `/auth/me`, `/auth/refresh`, `/auth/logout` | OTP, JWT, sessao e usuario atual |
| Students | `/students/{student_id}/academic-summary`, `/grades`, `/transcript`, `/weekly-schedule` | Dados academicos do aluno |
| Courses/Curriculum | `/courses`, `/courses/{course_id}/prerequisites`, `/curriculum/active` | Disciplinas, curriculo e pre-requisitos |
| Enrollment | `/enrollment-periods/current`, `/enrollments`, `/enrollments/{id}/confirm` | Fluxo de matricula |
| Documents | `/documents`, `/documents/{id}`, `/documents/upload` | Solicitacao, status e upload de documentos |
| Scheduling | `/scheduling/slots`, `/appointments`, `/appointments/{id}/cancel` | Agendamentos e horarios |
| Resources | `/resources` | CRUD e disponibilidade de recursos |
| Staff/Provider | `/staff/dashboard`, `/staff/members`, `/staff/members/{staff_id}` | Dashboard staff e CRUD provider-only de membros staff |
| Chat | `/chat-sessions`, `/chat-sessions/{id}/messages`, `/chat-sessions/{id}/reply` | Historico, intervencao e resposta humana |
| Webhook | `/api/v1/webhook/whatsapp` | Verificacao e recebimento de mensagens WhatsApp |

## Interfaces e dependencias

- Convencoes de status: `200` para sucesso, `201` para criacao, `400/422` para validacao, `401/403` para auth, `404`, `409`, `429` e `500`.
- Forma de erro esperada: `{"error": {"code": "ERROR_CODE", "message": "...", "details": [...]}}`.
- Query params usam `snake_case`.
- Path params de recursos usam sufixo `_id` no nome logico.

## Exemplos

Exemplos de chamadas tipicas:

```http
POST /api/v1/auth/request-code
POST /api/v1/auth/verify-code
GET /api/v1/students/{student_id}/academic-summary
POST /api/v1/enrollments/{enrollment_id}/confirm
PUT /api/v1/appointments/{appointment_id}/cancel
GET /api/v1/resources
POST /api/v1/staff/members
POST /api/v1/webhook/whatsapp
```

## Links relacionados

- [Backend FastAPI](backend-fastapi.md)
- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [MCP Server](mcp-server.md)
- [Ferramentas MCP](ferramentas-mcp.md)
- [Modulos academicos](modulos-academicos.md)
