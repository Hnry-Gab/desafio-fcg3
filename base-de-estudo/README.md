# Base de Estudo Codex - Desafio FCG3
<!--
TYPE: index
SCOPE: mixed
KEYWORDS: desafio-fcg3, alpha-connect, base-de-estudo, documentacao, documentação, arquitetura, backend, mobile, rag, mcp, fastapi, flutter, postgres, whatsapp, onboarding, autenticação, segurança, matrícula
-->
[TOC]

## Resumo rapido

Esta base organiza o conhecimento do projeto Desafio FCG3, uma plataforma academica full stack com API FastAPI, app Flutter, chatbot WhatsApp, servico LangChain com RAG, MCP Server, PostgreSQL/pgvector e Docker Compose.

Use este indice como ponto de entrada para entender a arquitetura, navegar pelos modulos, revisar decisoes arquiteturais e estudar os temas tecnicos centrais do projeto.

## Metadados

- Tipo: indice global
- Escopo: mixed
- Projeto: Desafio FCG3 / Alpha Connect
- Pasta: `base-de-estudo-codex/`
- Fontes principais: `README.md`, `PROJETO_RESUMO.md`, `docs/backup/`, `backend/`, `ai_service/`, `mcp_server/`, `mobile/`, `.planning/`

## Keywords

- desafio-fcg3
- alpha-connect
- base-de-estudo
- documentacao
- documentação
- conhecimento
- onboarding
- autenticação
- segurança
- matrícula
- arquitetura
- full-stack
- backend
- mobile
- web
- rag
- mcp
- fastapi
- flutter
- langchain
- whatsapp
- postgresql
- pgvector
- docker

## Areas principais

| Area | O que cobre | Documentos |
|---|---|---|
| Visao geral | Produto, proposta de valor, atores e mapa de modulos | [Visao geral do projeto](knowledge/visao-geral-projeto.md), [Arquitetura geral](knowledge/arquitetura-geral.md) |
| Backend | API REST, features, seguranca, contratos e regras academicas | [Backend FastAPI](knowledge/backend-fastapi.md), [API REST e contratos](knowledge/api-rest-contratos.md), [Autenticacao e autorizacao](knowledge/autenticacao-autorizacao.md) |
| Mobile/Web | Flutter, navegacao, estado, telas de aluno e staff/provider | [Mobile Flutter](knowledge/mobile-flutter.md), [Design system mobile](knowledge/design-system-mobile.md) |
| Chatbot e IA | WhatsApp, LangChain, RAG, prompts, filtros e MCP tools | [Chatbot WhatsApp](knowledge/chatbot-whatsapp.md), [AI Service e RAG](knowledge/ai-service-rag.md), [Seguranca da IA](knowledge/seguranca-ai.md) |
| MCP | Proxy de ferramentas, injecao de contexto, logs e retry | [MCP Server](knowledge/mcp-server.md), [Ferramentas MCP](knowledge/ferramentas-mcp.md) |
| Dados | PostgreSQL, pgvector, Alembic, entidades e seed | [Dados e banco](knowledge/dados-banco.md), [Modelo academico](knowledge/modelo-academico.md) |
| Infra | Docker Compose, variaveis de ambiente, healthchecks | [Infraestrutura local](knowledge/infraestrutura-local.md) |
| Processos | GSD, testes, verificacao e manutencao documental | [Processos e testes](knowledge/processos-testes.md) |

## Apoio para apresentacao

- [Perguntas tecnicas para apresentacao](perguntas-tecnicas.md)
- [Perguntas tecnicas - Knowledge Pages](knowledge/perguntas-tecnicas.md)
- [Perguntas tecnicas - ADRs](adr/perguntas-tecnicas.md)
- [Perguntas tecnicas - Guias de Estudo](study-guides/perguntas-tecnicas.md)

## Paginas de conhecimento

- [Visao geral do projeto](knowledge/visao-geral-projeto.md)
- [Arquitetura geral](knowledge/arquitetura-geral.md)
- [Backend FastAPI](knowledge/backend-fastapi.md)
- [API REST e contratos](knowledge/api-rest-contratos.md)
- [Contratos API por modulo](knowledge/contratos-api-por-modulo.md)
- [Autenticacao e autorizacao](knowledge/autenticacao-autorizacao.md)
- [Auth OTP/JWT detalhado](knowledge/auth-otp-jwt-detalhado.md)
- [Modulos academicos](knowledge/modulos-academicos.md)
- [Modelo academico](knowledge/modelo-academico.md)
- [Dados e banco](knowledge/dados-banco.md)
- [Migrations e Alembic](knowledge/migrations-alembic.md)
- [AI Service e RAG](knowledge/ai-service-rag.md)
- [Base de conhecimento RAG](knowledge/base-conhecimento-rag.md)
- [Custos e escala do RAG](knowledge/rag-cost-scaling.md)
- [Qualidade do RAG](knowledge/rag-quality-evaluation.md)
- [Chatbot WhatsApp](knowledge/chatbot-whatsapp.md)
- [Webhook WhatsApp tecnico](knowledge/webhook-whatsapp-tecnico.md)
- [MCP Server](knowledge/mcp-server.md)
- [Ferramentas MCP](knowledge/ferramentas-mcp.md)
- [MCP sessoes e verificacao](knowledge/mcp-sessoes-verificacao.md)
- [MCP auditoria e retry](knowledge/mcp-auditoria-retry.md)
- [Seguranca da IA](knowledge/seguranca-ai.md)
- [Mobile Flutter](knowledge/mobile-flutter.md)
- [Mobile architecture deep dive](knowledge/mobile-architecture-deep-dive.md)
- [Mobile auth, Dio e secure storage](knowledge/mobile-auth-dio-secure-storage.md)
- [Mobile FCM deep dive](knowledge/mobile-fcm-deep-dive.md)
- [Design system mobile](knowledge/design-system-mobile.md)
- [Notificacoes FCM](knowledge/notificacoes-fcm.md)
- [Infraestrutura local](knowledge/infraestrutura-local.md)
- [Processos e testes](knowledge/processos-testes.md)

## ADRs

- [ADR 001 - Backend FastAPI em fatias verticais](adr/001-backend-fastapi-fatias-verticais.md)
- [ADR 002 - MCP injeta student_id e oculta do agente](adr/002-mcp-injeta-student-id.md)
- [ADR 003 - Webhook WhatsApp com processamento assincrono](adr/003-webhook-whatsapp-assincrono.md)
- [ADR 004 - RAG com PostgreSQL e pgvector](adr/004-rag-postgresql-pgvector.md)
- [ADR 005 - LLM provider-agnostic](adr/005-llm-provider-agnostic.md)
- [ADR 006 - OTP por email e JWT de sessao](adr/006-otp-email-jwt.md)
- [ADR 007 - Flutter com Riverpod e GoRouter](adr/007-flutter-riverpod-gorouter.md)
- [ADR 008 - Docker Compose para ambiente local](adr/008-docker-compose-local.md)
- [ADR 009 - Calibracao do threshold RAG](adr/009-rag-threshold-calibration.md)

## Guias de estudo

- [Estudo - Arquitetura do projeto](study-guides/estudo-arquitetura-projeto.md)
- [Estudo - Backend FastAPI](study-guides/estudo-backend-fastapi.md)
- [Estudo - Flutter no projeto](study-guides/estudo-flutter-projeto.md)
- [Estudo - RAG e LangChain](study-guides/estudo-rag-langchain.md)
- [Estudo - MCP no projeto](study-guides/estudo-mcp-projeto.md)
- [Estudo - Seguranca e autenticacao](study-guides/estudo-seguranca-autenticacao.md)
- [Estudo - PostgreSQL e pgvector](study-guides/estudo-postgresql-pgvector.md)
- [Estudo - Docker, testes e operacao local](study-guides/estudo-docker-testes-operacao.md)
- [Estudo - Operacao staff/provider](study-guides/estudo-operacao-staff-provider.md)

## Como pesquisar

- Procure por siglas e termos em portugues e ingles, como `autenticacao`, `auth`, `jwt`, `mcp`, `rag`, `vector-store`, `matricula`, `enrollment`, `whatsapp`, `webhook`, `flutter`, `riverpod`.
- Cada documento contem `KEYWORDS` no bloco de metadados e uma secao `## Keywords` para facilitar busca textual.
- Para entender uma feature, comece pela pagina de conhecimento do modulo e depois abra ADRs e guias relacionados.
- Para onboarding, siga os guias de estudo na ordem: arquitetura, backend, banco, AI/RAG, MCP, mobile, seguranca e operacao.

## Links relacionados

- [README do projeto](../README.md)
- [Resumo do projeto](../PROJETO_RESUMO.md)
- [Documentacao backup da arquitetura](../docs/backup/architecture.md)
- [Documentacao backup da API](../docs/backup/api.md)
- [Documentacao backup do chatbot](../docs/backup/chatbot.md)
- [Documentacao backup do MCP](../docs/backup/mcp.md)
- [Documentacao backup do banco](../docs/backup/database.md)
