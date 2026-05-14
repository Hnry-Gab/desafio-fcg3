# Contratos API por Modulo
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: api, contratos, endpoints, fastapi, auth, students, enrollment, documents, appointments, resources, staff, chat, webhook, service-token
-->
[TOC]

## Resumo rapido

Esta pagina resume os contratos por modulo para responder perguntas de apresentacao sobre endpoints, autenticacao, regras principais e consumidores.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `backend/src/main.py`, `backend/src/features/*/controllers.py`, `backend/src/features/*/router.py`

## Keywords

- api
- contratos
- endpoints
- fastapi
- auth
- students
- enrollment
- documents
- appointments
- resources
- staff
- chat
- webhook
- service-token

## Detalhamento tecnico

| Modulo | Endpoints principais | Auth | Pergunta que responde |
|---|---|---|---|
| Auth | `/auth/request-code`, `/auth/verify-code`, `/auth/me`, `/auth/refresh`, `/auth/logout` | Publico/JWT | Como login funciona? |
| Students | `/students/{student_id}/academic-summary`, `/grades`, `/transcript`, `/weekly-schedule`, `/fcm-token` | JWT ou service token | Como o aluno ve dados? |
| Courses | `/courses`, `/courses/{course_id}/prerequisites`, `/curriculum/active` | JWT/service | Como curriculo e pre-requisitos aparecem? |
| Enrollment | `/enrollment-periods/current`, `/enrollments`, `/enrollments/{id}/confirm`, `/lock` | JWT/service | Como matricula e confirmada? |
| Documents | `/documents`, `/documents/{id}`, `/documents/upload`, `/documents/{id}/status` | JWT/service/staff | Como documentos sao solicitados e acompanhados? |
| Scheduling | `/scheduling/slots`, `/appointments`, `/appointments/{id}/cancel`, `/confirm`, `/authorization` | JWT/service/staff | Como agendamentos funcionam? |
| Resources | `/resources`, `/resources/{id}` | staff/provider conforme regra | Como recursos sao gerenciados? |
| Staff | `/staff/dashboard`, `/staff/members` | staff/provider | Como operacao administrativa funciona? |
| Chat | `/chat-sessions`, `/messages`, `/assign`, `/reply`, `/resolve`, `/action-logs` | staff/provider | Como intervencao humana funciona? |
| Webhook | `/api/v1/webhook/whatsapp` | assinatura WhatsApp | Como WhatsApp entra no sistema? |

## Regras de resposta em apresentacao

- Sempre diferencie **endpoint do app** de **chamada interna MCP**.
- Para aluno, destaque ownership e JWT.
- Para MCP, destaque `X-Service-Token` e `X-Student-Id` injetado.
- Para staff/provider, destaque que UI ajuda, mas backend e a autorizacao real.

## Exemplos

```http
Authorization: Bearer {access_token}
X-Service-Token: {MCP_SERVICE_TOKEN}
X-Student-Id: {student_id_injetado}
```

## Links relacionados

- [API REST e contratos](api-rest-contratos.md)
- [Backend FastAPI](backend-fastapi.md)
- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [Ferramentas MCP](ferramentas-mcp.md)
