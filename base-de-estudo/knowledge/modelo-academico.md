# Modelo Academico
<!--
TYPE: knowledge-page
SCOPE: data
KEYWORDS: modelo-academico, academic-model, students, courses, curriculum, prerequisites, grades, enrollment, documents, appointments, chat-sessions, fcm-tokens
-->
[TOC]

## Resumo rapido

O modelo academico representa alunos, staff, disciplinas, curriculos, pre-requisitos, notas, matriculas, documentos, agendamentos, chats e notificacoes. Ele sustenta tanto as telas do app quanto as acoes executadas pelo chatbot via MCP.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: data
- Fontes: `backend/src/features/*/models.py`, `docs/backup/database.md`, migrations Alembic
- Banco: PostgreSQL 16 com pgvector

## Keywords

- modelo-academico
- academic-model
- data-model
- students
- staff
- courses
- curriculum
- prerequisites
- grades
- enrollment
- documents
- appointments
- resources
- chat-sessions
- chat-messages
- mcp-action-logs
- fcm-tokens

## Contexto

O banco precisa suportar operacoes tradicionais de uma plataforma academica e tambem historico conversacional, auditoria de ferramentas MCP e busca vetorial para RAG.

## Detalhamento tecnico

Entidades principais:

- `students`: alunos e status academico.
- `staff`: usuarios administrativos e provider.
- `verification_codes`: codigos OTP.
- `sessions`: sessoes JWT com `jti`.
- `fcm_tokens`: tokens de dispositivos para push.
- `courses`: disciplinas.
- `prerequisites`: relacao de pre-requisitos entre disciplinas.
- `curriculum` e `curriculum_courses`: matriz curricular.
- `class_schedules`: grade semanal.
- `grades`: notas e historico.
- `enrollment_periods`, `enrollments`, `enrollment_courses`: matricula.
- `documents`: solicitacoes e status de documentos.
- `resources`, `scheduling_slots`, `appointments`: recursos e agendamentos.
- `chat_sessions`, `chat_messages`: conversas WhatsApp e app.
- `mcp_action_logs`: auditoria de ferramentas MCP.
- `knowledge_base_chunks`: chunks vetoriais do RAG.

## Fluxo / Arquitetura

```text
Feature models -> infrastructure/models.py -> Alembic metadata
API services/controllers -> SQLAlchemy async session -> PostgreSQL
AI RAG -> psycopg/pgvector -> knowledge_base_chunks
```

## Interfaces e dependencias

- IDs sao UUIDs e usam sufixo `_id` em FKs.
- Tabelas mutaveis possuem `created_at` e `updated_at`.
- Embeddings usam vetor de dimensao 1536 conforme `text-embedding-3-small`.
- A tabela `knowledge_base_chunks` usa indice HNSW com cosine ops nas migrations/documentacao.

## Exemplos

Consulta conceitual do RAG:

```sql
SELECT content, source, category
FROM knowledge_base_chunks
WHERE 1 - (embedding <=> :query_embedding) >= :threshold
ORDER BY embedding <=> :query_embedding
LIMIT 3;
```

## Links relacionados

- [Dados e banco](dados-banco.md)
- [Modulos academicos](modulos-academicos.md)
- [AI Service e RAG](ai-service-rag.md)
- [Base de conhecimento RAG](base-conhecimento-rag.md)
- [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md)
- [Estudo - PostgreSQL e pgvector](../study-guides/estudo-postgresql-pgvector.md)
