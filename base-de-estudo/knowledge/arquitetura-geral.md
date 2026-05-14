# Arquitetura Geral
<!--
TYPE: knowledge-page
SCOPE: mixed
KEYWORDS: arquitetura, architecture, microservicos, fastapi, langchain, mcp-server, flutter, postgresql, pgvector, docker-compose, whatsapp, fcm, rag
-->
[TOC]

## Resumo rapido

A arquitetura e composta por servicos independentes: app Flutter, backend FastAPI, AI service LangChain, MCP Server e PostgreSQL com pgvector. A separacao protege dados sensiveis, isola responsabilidades e permite que o chatbot execute acoes academicas sem expor `student_id` ao agente de IA.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mixed
- Fontes: `docs/backup/architecture.md`, `README.md`, `docker-compose.yml`, codigo em `backend/`, `ai_service/`, `mcp_server/`, `mobile/`
- Decisoes relacionadas: ADR 001, ADR 002, ADR 003, ADR 004, ADR 008

## Keywords

- arquitetura
- architecture
- microservicos
- service-boundaries
- fastapi
- langchain
- mcp-server
- flutter
- postgresql
- pgvector
- rag
- whatsapp
- webhook
- fcm
- docker-compose

## Contexto

O sistema precisa atender dois canais: app mobile/web e WhatsApp. O app consome API REST com JWT. O WhatsApp passa pelo backend, que delega o processamento de linguagem natural ao AI service. Quando a IA precisa executar acoes, ela chama ferramentas do MCP Server, que injeta o contexto seguro do aluno e chama a API.

## Detalhamento tecnico

Responsabilidades por camada:

| Camada | Local | Responsabilidade |
|---|---|---|
| Mobile/Web | `mobile/lib/` | UX do aluno e staff/provider, auth, navegacao, consumo REST |
| Backend API | `backend/src/` | Regras de negocio, REST, auth, banco, webhook, notificacoes |
| AI Service | `ai_service/` | LangChain agent, RAG, sanitizacao, resposta conversacional |
| MCP Server | `mcp_server/` | Tool calling, injecao de `student_id`, logs, retry interno |
| Dados | PostgreSQL | Entidades academicas, sessoes, chats, logs MCP, embeddings |

## Fluxo / Arquitetura

```text
                      +----------------+
                      | Flutter Mobile |
                      +-------+--------+
                              |
                              | JWT Bearer /api/v1
                              v
+----------+          +-------+--------+          +----------------+
| WhatsApp | -------> | FastAPI Backend | -------> | PostgreSQL     |
+----------+ webhook  +-------+--------+          | + pgvector      |
                              |                   +----------------+
                              | X-Service-Token
                              v
                      +-------+--------+
                      | AI Service     |
                      | LangChain/RAG  |
                      +-------+--------+
                              |
                              | MCP tools + chat session
                              v
                      +-------+--------+
                      | MCP Server     |
                      +----------------+
```

## Interfaces e dependencias

- O backend e o ponto central para dados e regras de negocio.
- O AI service depende do MCP Server para acoes concretas e do banco para RAG/chat history.
- O MCP Server depende do backend para executar endpoints internos com `X-Service-Token`.
- O mobile depende apenas da API REST e de servicos de plataforma como FCM.

## Exemplos

Topologia local descrita pelo projeto:

```text
fastapi-app:8000
langchain-service:8001
mcp-server:8002
postgres:5432
```

## Links relacionados

- [Visao geral do projeto](visao-geral-projeto.md)
- [Backend FastAPI](backend-fastapi.md)
- [AI Service e RAG](ai-service-rag.md)
- [MCP Server](mcp-server.md)
- [Dados e banco](dados-banco.md)
- [ADR 001 - Backend FastAPI em fatias verticais](../adr/001-backend-fastapi-fatias-verticais.md)
- [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md)
- [ADR 003 - Webhook WhatsApp com processamento assincrono](../adr/003-webhook-whatsapp-assincrono.md)
