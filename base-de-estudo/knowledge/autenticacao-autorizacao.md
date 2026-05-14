# Autenticacao e Autorizacao
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: autenticacao, autenticação, authentication, autorizacao, autorização, authorization, otp, jwt, refresh-token, session, jti, service-token, mcp-service-token, role-based-access, student, staff, provider
-->
[TOC]

## Resumo rapido

A autenticacao combina OTP por email, JWT para o app e service token para chamadas internas. A autorizacao diferencia `student`, `staff` e `provider`, aplicando ownership para impedir acesso indevido a dados de outro aluno.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `backend/src/features/auth/`, `backend/src/shared/auth.py`, `backend/src/shared/dependencies.py`, `mobile/lib/features/auth/`, `README.md`
- Decisao relacionada: ADR 006

## Keywords

- autenticacao
- autenticação
- authentication
- autorizacao
- autorização
- authorization
- otp
- email-otp
- resend
- jwt
- refresh-token
- access-token
- session
- jti
- service-token
- mcp-service-token
- role-based-access
- rbac
- student
- staff
- provider
- idor

## Contexto

O app usa login sem senha por codigo OTP enviado por email. Apos verificar o codigo, recebe tokens JWT. O MCP Server nao usa JWT do aluno; ele chama o backend com `X-Service-Token` e contexto interno resolvido a partir da sessao de chat.

## Detalhamento tecnico

Componentes principais:

- `backend/src/features/auth/routes.py`: endpoints de request-code, verify-code, me, refresh e logout.
- `backend/src/features/auth/models.py`: `students`, `staff`, `verification_codes`, `sessions`, `fcm_tokens`.
- `backend/src/shared/auth.py`: validacao de JWT e roles.
- `backend/src/shared/dependencies.py`: dependencias de usuario atual, service token, dual auth e ownership.
- `mobile/lib/core/network/auth_interceptor.dart`: injeta `Authorization: Bearer` nas chamadas do app.
- `mobile/lib/features/auth/services/auth_service.dart`: integra login OTP com a API.

## Fluxo / Arquitetura

Login no app:

```text
Usuario informa email
Flutter -> POST /auth/request-code
Backend gera verification_code
Usuario informa codigo
Flutter -> POST /auth/verify-code
Backend valida codigo, cria sessao com jti e retorna JWT
Flutter armazena tokens em flutter_secure_storage
```

Chamada interna MCP:

```text
AI Service -> MCP tool com x-chat-session-id
MCP resolve student_id da sessao ativa
MCP -> Backend com X-Service-Token e X-Student-Id
Backend valida service token e aplica contexto
```

## Interfaces e dependencias

- `MCP_SERVICE_TOKEN` nunca deve ficar em codigo-fonte.
- Tokens do app sao armazenados no Flutter com `flutter_secure_storage`.
- Sessoes usam `jti` para permitir revogacao sem armazenar o JWT inteiro.
- Provider herda permissoes de staff onde indicado, com rotas provider-only para gestao especifica.

## Exemplos

Headers principais:

```http
Authorization: Bearer {access_token}
X-Service-Token: {MCP_SERVICE_TOKEN}
X-Student-Id: {student_id_injetado_pelo_mcp}
```

## Links relacionados

- [Backend FastAPI](backend-fastapi.md)
- [API REST e contratos](api-rest-contratos.md)
- [MCP Server](mcp-server.md)
- [Seguranca da IA](seguranca-ai.md)
- [ADR 006 - OTP por email e JWT de sessao](../adr/006-otp-email-jwt.md)
- [Estudo - Seguranca e autenticacao](../study-guides/estudo-seguranca-autenticacao.md)
