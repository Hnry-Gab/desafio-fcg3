# ADR 006 - OTP por Email e JWT de Sessao
<!--
TYPE: adr
SCOPE: backend
KEYWORDS: adr, otp, email-otp, resend, jwt, refresh-token, session, jti, autenticacao, authentication, flutter-secure-storage
-->
[TOC]

## Resumo rapido

O app usa login por OTP enviado por email e sessoes JWT com `jti`. Essa escolha evita senha tradicional no MVP e permite revogacao de sessao pelo backend.

## Keywords

- adr
- otp
- email-otp
- resend
- jwt
- refresh-token
- access-token
- session
- jti
- autenticacao
- authentication
- flutter-secure-storage
- login

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `AGENTS.md`, `backend/src/features/auth/`, `backend/src/shared/auth.py`, `mobile/lib/features/auth/`, `mobile/lib/core/network/auth_interceptor.dart`

## Contexto

O app precisa autenticar alunos e staff sem introduzir fluxo completo de senha. O backend precisa validar sessao, refresh e logout.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Login com senha | Familiar | Exige reset, politica de senha e armazenamento seguro |
| OTP por email | Simples para MVP; sem senha persistida | Depende de entregabilidade de email |
| SSO institucional | Melhor UX institucional | Depende de integracao externa nao evidenciada |

## Decisao

Usar OTP por email, com Resend como provider definido nas restricoes, e emitir JWT de acesso/refresh com sessao rastreada por `jti`.

## Consequencias

- Positivas: reduz superficie de senhas.
- Positivas: permite logout/revogacao por sessao.
- Negativas: UX depende do recebimento rapido do email.
- Negativas: exige protecao contra abuso de OTP por rate limit e max attempts.

## Links relacionados

- [Autenticacao e autorizacao](../knowledge/autenticacao-autorizacao.md)
- [Mobile Flutter](../knowledge/mobile-flutter.md)
- [Backend FastAPI](../knowledge/backend-fastapi.md)
- [Estudo - Seguranca e autenticacao](../study-guides/estudo-seguranca-autenticacao.md)
