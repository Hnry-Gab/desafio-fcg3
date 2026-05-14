# Infraestrutura Local
<!--
TYPE: knowledge-page
SCOPE: infra
KEYWORDS: infraestrutura, infra, docker, docker-compose, fastapi-app, langchain-service, mcp-server, postgres, flutter-web, environment, env-vars, healthcheck
-->
[TOC]

## Resumo rapido

A infraestrutura local usa Docker Compose para subir backend, AI service, MCP server e PostgreSQL com pgvector. Variaveis de ambiente controlam tokens, provedores, banco, WhatsApp, JWT e embeddings.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: infra
- Fontes: `README.md`, `docker-compose.yml`, `.env.example`, `backend/src/infrastructure/config.py`, `ai_service/config.py`, `mcp_server/settings.py`
- Ambientes: desenvolvimento local e containers

## Keywords

- infraestrutura
- infra
- docker
- docker-compose
- fastapi-app
- langchain-service
- mcp-server
- postgres
- flutter-web
- pgvector
- environment
- env-vars
- healthcheck
- mcp-service-token
- database-url

## Contexto

O projeto tem multiplos servicos. Docker Compose padroniza a execucao local e reduz divergencia de setup entre backend, IA, MCP e banco.

## Detalhamento tecnico

Servicos locais:

- `fastapi-app:8000`: API principal.
- `langchain-service:8001`: AI Service.
- `mcp-server:8002`: MCP tool server.
- `postgres:5432`: PostgreSQL com pgvector.
- `flutter-web:3000`: app Flutter web servido em container.

Variaveis criticas:

- `DATABASE_URL`
- `JWT_SECRET`
- `MCP_SERVICE_TOKEN`
- `WHATSAPP_TOKEN`
- `LLM_PROVIDER`
- `LLM_MODEL`
- `OPENAI_API_KEY`, `GEMINI_API_KEY`, `OPENROUTER_API_KEY`
- `EMBEDDING_PROVIDER`
- `EMBEDDING_MODEL`

## Fluxo / Arquitetura

```text
docker compose up --build -d
  -> postgres inicia
  -> fastapi-app aplica runtime API
  -> langchain-service roda ingestao RAG best-effort e API AI
  -> mcp-server registra tools
  -> flutter-web serve o app web em :3000
```

## Interfaces e dependencias

- `.env` nao deve ser versionado.
- Healthchecks podem levar alguns segundos apos `docker compose up`.
- Migrations precisam rodar com Alembic; o compose atual automatiza isso no bootstrap da API, e o README tambem documenta comando manual para operacao controlada.
- Seed de desenvolvimento e executado via modulo Python dentro do container; no compose atual, tambem pode rodar no bootstrap da API.

## Exemplos

Comandos do `README.md`:

```bash
docker compose up --build -d
docker compose ps
curl http://localhost:8000/health
curl http://localhost:3000/
docker compose down
```

Observacao: no `docker-compose.yml` atual, `langchain-service` e `mcp-server` possuem healthchecks internos, mas nao publicam portas no host. Para verificar esses healthchecks a partir da maquina local, use `docker compose ps` ou execute `curl` dentro da rede/container Docker.

## Links relacionados

- [Arquitetura geral](arquitetura-geral.md)
- [Dados e banco](dados-banco.md)
- [Migrations e Alembic](migrations-alembic.md)
- [Backend FastAPI](backend-fastapi.md)
- [AI Service e RAG](ai-service-rag.md)
- [MCP Server](mcp-server.md)
- [ADR 008 - Docker Compose para ambiente local](../adr/008-docker-compose-local.md)
- [Estudo - Docker, testes e operacao local](../study-guides/estudo-docker-testes-operacao.md)
