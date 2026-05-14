# Visao Geral do Projeto
<!--
TYPE: knowledge-page
SCOPE: mixed
KEYWORDS: desafio-fcg3, alpha-connect, plataforma-academica, plataforma-acadêmica, chatbot-whatsapp, fastapi, flutter, langchain, mcp, rag, postgresql, pgvector, aluno, staff, provider
-->
[TOC]

## Resumo rapido

O Desafio FCG3 e uma plataforma academica para alunos de Ciencia da Computacao interagirem com servicos universitarios via app Flutter, API REST e chatbot WhatsApp. O valor central e permitir que o aluno consulte situacao academica e execute acoes reais, como matricula, documentos e agendamentos, com apoio de IA e dados em tempo real.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mixed
- Fontes: `README.md`, `PROJETO_RESUMO.md`, `AGENTS.md`, `docs/backup/architecture.md`, `docs/backup/chatbot.md`
- Modulos relacionados: backend, mobile, AI service, MCP server, PostgreSQL

## Keywords

- desafio-fcg3
- alpha-connect
- plataforma-academica
- plataforma-acadêmica
- academic-platform
- chatbot-whatsapp
- whatsapp-bot
- aluno
- student
- staff
- provider
- fastapi
- flutter
- langchain
- mcp
- rag
- postgresql
- pgvector
- docker-compose

## Contexto

O projeto combina atendimento conversacional e gestao academica. O aluno pode usar WhatsApp para perguntas e acoes rapidas, enquanto o app mobile/web permite visualizar dashboards, historico, documentos, notificacoes e recursos. A equipe administrativa usa telas de staff/provider para acompanhar atendimentos, documentos, agendamentos e intervencoes humanas.

## Detalhamento tecnico

Os principais componentes sao:

- `backend/`: API FastAPI, regras de negocio, autenticacao, banco, notificacoes e webhook WhatsApp.
- `ai_service/`: servico LangChain que processa mensagens, consulta RAG e chama ferramentas MCP.
- `mcp_server/`: servidor de ferramentas que injeta contexto seguro e faz proxy para a API.
- `mobile/`: app Flutter para aluno e staff/provider.
- `PostgreSQL + pgvector`: banco unico para dados relacionais e embeddings da base RAG.
- `Docker Compose`: orquestracao local dos servicos `fastapi-app`, `langchain-service`, `mcp-server` e `postgres`.
- `flutter-web`: container web do app Flutter exposto localmente na porta `3000`.

## Fluxo / Arquitetura

Fluxo principal do WhatsApp:

```text
Aluno -> WhatsApp Cloud API -> Backend FastAPI webhook
Backend -> AI Service LangChain
AI Service -> RAG em pgvector para conhecimento academico
AI Service -> MCP Server para acoes concretas
MCP Server -> Backend FastAPI com X-Service-Token e contexto do aluno
Backend -> banco PostgreSQL
Backend/AI -> resposta ao WhatsApp
```

Fluxo principal do app:

```text
Flutter app -> Dio/AuthInterceptor -> FastAPI /api/v1
FastAPI -> SQLAlchemy/PostgreSQL
FastAPI -> FCM para notificacoes quando necessario
```

## Interfaces e dependencias

- API publica do app: `http://localhost:8000/api/v1`.
- AI service interno no Compose: `http://langchain-service:8001` dentro da rede Docker.
- MCP server interno no Compose: `http://mcp-server:8002` dentro da rede Docker.
- Banco: PostgreSQL 16 com pgvector.
- Auth do app: OTP por email, JWT e refresh token.
- Auth interna: `X-Service-Token` com `MCP_SERVICE_TOKEN` em variavel de ambiente.

## Exemplos

Servicos locais documentados no `README.md`:

```bash
curl http://localhost:8000/health
curl http://localhost:3000/
```

Para AI Service e MCP Server, o Compose atual define healthchecks internos sem publicar portas no host; use `docker compose ps` para ver o estado ou execute comandos dentro da rede Docker.

## Links relacionados

- [Arquitetura geral](arquitetura-geral.md)
- [Backend FastAPI](backend-fastapi.md)
- [AI Service e RAG](ai-service-rag.md)
- [MCP Server](mcp-server.md)
- [Mobile Flutter](mobile-flutter.md)
- [Infraestrutura local](infraestrutura-local.md)
- [ADR 008 - Docker Compose para ambiente local](../adr/008-docker-compose-local.md)
- [Estudo - Arquitetura do projeto](../study-guides/estudo-arquitetura-projeto.md)
