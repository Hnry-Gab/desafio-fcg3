# Modulos Academicos
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: modulos-academicos, módulos-acadêmicos, students, courses, curriculum, enrollment, matricula, matrícula, grades, transcript, documents, scheduling, appointments, resources, staff, provider, fastapi
-->
[TOC]

## Resumo rapido

Os modulos academicos implementam as capacidades centrais do produto: dados do aluno, cursos, curriculo, matricula, notas, documentos, agendamentos, recursos e operacao staff/provider. Eles sao expostos pela API REST e tambem acionados indiretamente por ferramentas MCP.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `backend/src/features/`, `backend/tests/`, `docs/backup/api.md`
- Modulos: students, courses, enrollment, grades, documents, scheduling, resources, staff, chat

## Keywords

- modulos-academicos
- módulos-acadêmicos
- academic-modules
- students
- alunos
- courses
- disciplinas
- curriculum
- curriculo
- enrollment
- matricula
- matrícula
- grades
- notas
- transcript
- historico
- documents
- documentos
- scheduling
- agendamento
- appointments
- recursos
- resources
- staff
- provider

## Contexto

O backend e estruturado por features. Cada dominio possui controllers, modelos, schemas e services quando necessario. Esse desenho facilita evoluir regras academicas sem concentrar toda logica em um unico arquivo.

## Detalhamento tecnico

| Modulo | Responsabilidade | Arquivos principais |
|---|---|---|
| Auth | OTP, JWT, sessoes, FCM token | `backend/src/features/auth/` |
| Students | perfil, resumo academico, disciplinas disponiveis, notas, historico, grade semanal | `backend/src/features/students/` |
| Courses | disciplinas, pre-requisitos e curriculo ativo | `backend/src/features/courses/` |
| Enrollment | periodos, rascunho, confirmacao, cancelamento e bloqueio de matricula | `backend/src/features/enrollment/` |
| Documents | solicitacao, status e upload | `backend/src/features/documents/` |
| Scheduling | slots e appointments | `backend/src/features/scheduling/`, `backend/src/features/appointments/` |
| Resources | recursos fisicos/digitais e disponibilidade | `backend/src/features/resources/` |
| Staff | dashboard, membros e operacao administrativa | `backend/src/features/staff/` |
| Chat | sessoes, mensagens, intervencao humana e action logs | `backend/src/features/chat/`, `backend/src/features/webhook/` |

## Fluxo / Arquitetura

O MCP usa esses modulos por meio da API:

```text
MCP tool get_grades -> GET /students/{student_id}/grades
MCP tool create_enrollment -> POST /enrollments
MCP tool request_document -> POST /documents
MCP tool book_appointment -> POST /appointments
```

## Interfaces e dependencias

- Modulos dependem de SQLAlchemy async para persistencia.
- Fluxos com notificacao podem acionar FCM.
- Fluxos acionados pelo chatbot passam pelo MCP e geram logs em `mcp_action_logs`.
- Fluxos de staff/provider usam autorizacao por papel.

## Exemplos

Estados de entidades academicas citados nas convencoes:

```text
enrollments: draft -> confirmed -> cancelled
documents: requested -> processing -> ready -> delivered
chat_sessions: active -> closed
```

## Links relacionados

- [Backend FastAPI](backend-fastapi.md)
- [API REST e contratos](api-rest-contratos.md)
- [Modelo academico](modelo-academico.md)
- [Ferramentas MCP](ferramentas-mcp.md)
- [Mobile Flutter](mobile-flutter.md)
