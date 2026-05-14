# Perguntas Tecnicas - ADRs
<!--
TYPE: knowledge-page
SCOPE: mixed
KEYWORDS: perguntas-tecnicas, adr, decisão, decisao, arquitetura, trade-offs, fastapi, mcp, rag, flutter, docker, jwt, otp
-->
[TOC]

## Resumo rapido

Este arquivo ajuda a responder perguntas do tipo "qual decisao foi tomada?", "por que escolheram X?" e "quais alternativas foram consideradas?". Use junto dos ADRs individuais.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mixed
- Pasta: `base-de-estudo-codex/adr/`

## Keywords

- perguntas-tecnicas
- adr
- decisão
- decisao
- arquitetura
- trade-offs
- fastapi
- mcp
- rag
- flutter
- docker
- jwt
- otp

## Perguntas por decisao

### Por que FastAPI e fatias verticais?

Resposta curta: FastAPI combina bem com APIs async em Python, e fatias verticais deixam cada dominio academico mais facil de localizar e evoluir.

Trade-off: pode haver repeticao pequena entre features, mas evita um monolito de controllers/services globais.

Link: [ADR 001](001-backend-fastapi-fatias-verticais.md).

### Por que ocultar `student_id` do agente?

Resposta curta: para reduzir risco de IDOR e impedir que o LLM controle identidade.

Trade-off: o MCP precisa consultar sessao ativa e injeta contexto internamente, adicionando complexidade, mas melhora seguranca.

Link: [ADR 002](002-mcp-injeta-student-id.md).

### Por que webhook assincrono?

Resposta curta: para responder ao WhatsApp rapidamente e nao depender da latencia do LLM.

Trade-off: `asyncio.create_task` e simples para MVP, mas fila externa seria mais robusta em escala.

Link: [ADR 003](003-webhook-whatsapp-assincrono.md).

### Por que PostgreSQL + pgvector?

Resposta curta: reduz infraestrutura no MVP e permite usar o mesmo banco para dados relacionais e vetores.

Trade-off: em escala maior pode exigir tuning de indice ou migracao para vector DB dedicado.

Link: [ADR 004](004-rag-postgresql-pgvector.md).

### Por que provider-agnostic para LLM?

Resposta curta: para trocar provider por ambiente e evitar acoplamento de custo/disponibilidade.

Trade-off: provedores diferem em custo, modelos, limites e compatibilidade de embeddings.

Link: [ADR 005](005-llm-provider-agnostic.md).

### Por que OTP por email?

Resposta curta: simplifica MVP sem senha persistida e atende login de alunos/staff.

Trade-off: depende de entregabilidade de email e precisa rate limit/max attempts.

Link: [ADR 006](006-otp-email-jwt.md).

### Por que Flutter com Riverpod e GoRouter?

Resposta curta: Flutter entrega mobile/web; Riverpod organiza estado e DI; GoRouter centraliza guards por papel.

Trade-off: exige codegen e testes de rota para evitar regressao nos redirects.

Link: [ADR 007](007-flutter-riverpod-gorouter.md).

### Por que calibrar threshold RAG?

Resposta curta: queries curtas de WhatsApp podem ter similaridade menor contra chunks longos; threshold alto demais causa falso negativo.

Trade-off: threshold baixo aumenta recall, mas pode trazer contexto menos preciso.

Link: [ADR 009](009-rag-threshold-calibration.md).

## Links relacionados

- [Perguntas tecnicas globais](../perguntas-tecnicas.md)
- [Perguntas tecnicas de knowledge](../knowledge/perguntas-tecnicas.md)
- [Indice global](../README.md)
