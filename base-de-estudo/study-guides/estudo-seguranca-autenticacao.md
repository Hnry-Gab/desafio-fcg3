# Estudo - Seguranca e Autenticacao
<!--
TYPE: study-guide
SCOPE: mixed
KEYWORDS: guia-de-estudo, tutorial, seguranca, security, autenticacao, authorization, jwt, otp, service-token, prompt-injection, idor, mcp
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve entender os controles de seguranca do projeto: OTP/JWT, service token, ownership, protecao contra IDOR, fronteira MCP e filtros de IA.

## Metadados

- Tipo: guia de estudo
- Escopo: mixed
- Nivel: intermediario
- Tempo sugerido: 4 a 6 horas

## Keywords

- guia-de-estudo
- tutorial
- seguranca
- security
- autenticacao
- authentication
- authorization
- jwt
- otp
- service-token
- prompt-injection
- idor
- mcp
- ai-security

## Pre-requisitos

- HTTP headers.
- JWT basico.
- Conceitos de autorizacao por papel.
- Nocoes de riscos de LLM.

## Explicacao teorica

Seguranca em sistemas com IA deve ser em camadas. O LLM nao deve ser fonte de verdade para identidade, permissao ou dados. Backends devem validar autorizacao e ferramentas devem limitar parametros expostos.

## Como se aplica a este projeto

- App usa OTP e JWT.
- Backend valida roles e ownership.
- MCP usa service token e injeta `student_id`.
- AI Service sanitiza entrada e filtra saida.
- Secrets ficam em variaveis de ambiente.

## Roteiro de estudo sugerido

1. Leia [Autenticacao e autorizacao](../knowledge/autenticacao-autorizacao.md).
2. Leia [Seguranca da IA](../knowledge/seguranca-ai.md).
3. Leia [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md).
4. Abra `backend/src/shared/dependencies.py`.
5. Abra `ai_service/security/output_filter.py`.
6. Abra `mcp_server/tests/test_tool_schemas.py`.

## Exercicios / atividades sugeridas

- Identifique onde `MCP_SERVICE_TOKEN` e lido em cada servico.
- Explique como o projeto evita que o agente acesse outro aluno.
- Crie uma lista de mensagens que deveriam ser bloqueadas pelo output filter.

## Referencias internas

- [Autenticacao e autorizacao](../knowledge/autenticacao-autorizacao.md)
- [Seguranca da IA](../knowledge/seguranca-ai.md)
- [MCP Server](../knowledge/mcp-server.md)
- [ADR 006 - OTP por email e JWT de sessao](../adr/006-otp-email-jwt.md)

## Referencias externas

- [OWASP API Security Top 10](https://owasp.org/API-Security/)
- [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [JWT Introduction](https://jwt.io/introduction)

## Links relacionados

- [Estudo - Backend FastAPI](estudo-backend-fastapi.md)
- [Estudo - MCP no projeto](estudo-mcp-projeto.md)
