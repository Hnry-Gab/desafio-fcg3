# Estudo - Arquitetura do Projeto
<!--
TYPE: study-guide
SCOPE: mixed
KEYWORDS: guia-de-estudo, tutorial, onboarding, arquitetura, full-stack, fastapi, flutter, langchain, mcp, rag, postgresql, whatsapp
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve entender como os servicos do Desafio FCG3 se conectam, por que existem backend, AI Service, MCP Server, app Flutter e PostgreSQL, e como seguir um fluxo do WhatsApp ou app ate o banco.

## Metadados

- Tipo: guia de estudo
- Escopo: mixed
- Nivel: introdutorio a intermediario
- Tempo sugerido: 2 a 4 horas

## Keywords

- guia-de-estudo
- tutorial
- onboarding
- arquitetura
- architecture
- full-stack
- fastapi
- flutter
- langchain
- mcp
- rag
- postgresql
- pgvector
- whatsapp
- docker-compose

## Pre-requisitos

- Entender HTTP basico.
- Saber o papel de API REST, banco relacional e app cliente.
- Conhecer conceitos basicos de autenticacao com token.

## Explicacao teorica

Uma arquitetura full stack separa responsabilidades entre frontend, backend, dados e servicos auxiliares. Neste projeto, a IA nao substitui o backend: ela interpreta linguagem natural e chama ferramentas. O backend continua sendo a fonte de regras e autorizacao.

## Como se aplica a este projeto

- App Flutter consome `backend` por `/api/v1`.
- WhatsApp chama webhook no `backend`.
- Backend delega linguagem natural ao `ai_service`.
- AI Service usa RAG para conhecimento e MCP para acoes.
- MCP chama backend com contexto seguro.
- PostgreSQL guarda dados relacionais, chat, logs e embeddings.

## Roteiro de estudo sugerido

1. Leia [Visao geral do projeto](../knowledge/visao-geral-projeto.md).
2. Leia [Arquitetura geral](../knowledge/arquitetura-geral.md).
3. Abra `README.md` e entenda os servicos locais.
4. Leia [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md).
5. Siga um fluxo WhatsApp em [Chatbot WhatsApp](../knowledge/chatbot-whatsapp.md).
6. Siga um fluxo app em [Mobile Flutter](../knowledge/mobile-flutter.md).

## Exercicios / atividades sugeridas

- Desenhe o caminho de uma pergunta: "Quais sao minhas notas?".
- Liste quais servicos participam de uma solicitacao de documento pelo WhatsApp.
- Explique por que o agente LangChain nao deve receber `student_id`.

## Referencias internas

- [Arquitetura geral](../knowledge/arquitetura-geral.md)
- [Backend FastAPI](../knowledge/backend-fastapi.md)
- [AI Service e RAG](../knowledge/ai-service-rag.md)
- [MCP Server](../knowledge/mcp-server.md)
- [Infraestrutura local](../knowledge/infraestrutura-local.md)

## Referencias externas

- [FastAPI documentation](https://fastapi.tiangolo.com/)
- [Flutter documentation](https://docs.flutter.dev/)
- [LangChain documentation](https://python.langchain.com/docs/)
- [Model Context Protocol](https://modelcontextprotocol.io/)

## Links relacionados

- [Indice global](../README.md)
- [ADR 008 - Docker Compose para ambiente local](../adr/008-docker-compose-local.md)
