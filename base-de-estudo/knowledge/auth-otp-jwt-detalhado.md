# Auth OTP/JWT Detalhado
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: auth, autenticacao, autenticação, otp, email, resend, jwt, refresh-token, jti, code-hash, code-salt, dev-master-otp, segurança
-->
[TOC]

## Resumo rapido

O login usa OTP por email e JWT com sessoes rastreadas por `jti`. O codigo OTP e gerado com CSPRNG, enviado por Resend e salvo apenas como hash com salt, nunca em texto puro.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `backend/src/features/auth/routes.py`, `backend/src/features/auth/services/otp_service.py`, `backend/src/features/auth/services/jwt_service.py`, `backend/src/features/auth/services/session_service.py`, `backend/src/features/auth/models.py`

## Keywords

- auth
- autenticacao
- autenticação
- otp
- email
- resend
- jwt
- refresh-token
- jti
- code-hash
- code-salt
- dev-master-otp
- segurança

## Contexto

Em apresentacao, auth costuma gerar perguntas sobre envio de email, protecao do codigo, expiracao, tentativas, refresh token e revogacao. Esta pagina concentra as respostas tecnicas.

## Detalhamento tecnico

### Pedido de codigo

- Endpoint: `POST /api/v1/auth/request-code`.
- O codigo tem 6 digitos.
- A geracao usa `secrets.randbelow(10**6)`.
- O backend cria um `salt` por linha.
- O banco guarda `code_hash` e `code_salt`, nao o codigo em claro.
- O envio usa `resend.Emails.send_async` quando o email pertence a aluno ou staff.

### Verificacao de codigo

- Endpoint: `POST /api/v1/auth/verify-code`.
- O codigo submetido e reprocessado com o mesmo salt.
- A comparacao usa `hmac.compare_digest`.
- `DEV_MASTER_OTP` pode bypassar em desenvolvimento e deve estar ausente em producao.

### Sessao JWT

- O access token autentica chamadas do app.
- O refresh token permite renovar sessao.
- Sessoes sao rastreadas por `jti`.
- Revogacao nao exige armazenar JWT inteiro.
- Refresh rotation marca o token antigo como usado e emite novo par.

## Fluxo / Arquitetura

```text
Flutter -> request-code -> backend gera OTP + hash/salt -> Resend envia email
Flutter -> verify-code -> backend valida hash -> cria sessoes JWT -> app salva tokens
Flutter -> chamada API -> AuthInterceptor injeta Bearer token
401 -> AuthInterceptor tenta /auth/refresh -> backend rotaciona refresh
```

## Perguntas de apresentacao

### Como voces enviam email?

Resposta: o backend usa Resend via `resend.Emails.send_async`, com remetente configurado por settings e email HTML simples contendo o codigo e validade.

### O codigo fica salvo no banco?

Resposta: nao em texto puro. O banco recebe apenas `code_hash` e `code_salt`; o plaintext so existe no momento do envio.

### O que acontece se alguem roubar refresh token?

Resposta: a rotacao reduz replay. Quando um refresh e usado, ele e marcado como usado e o par antigo e invalidado; reutilizacao posterior pode ser detectada como sessao invalida.

## Limites e riscos

- Entregabilidade depende do Resend e configuracao DNS/remetente.
- OTP por email depende de acesso ao email institucional.
- `DEV_MASTER_OTP` e perigoso fora de desenvolvimento.
- O endpoint atual pode revelar email inexistente conforme implementacao; em apresentacao, diferencie objetivo de timing parity no service e contrato real da rota.

## Links relacionados

- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [Mobile auth, Dio e secure storage](mobile-auth-dio-secure-storage.md)
- [ADR 006 - OTP por email e JWT de sessao](../adr/006-otp-email-jwt.md)
- [Estudo - Seguranca e autenticacao](../study-guides/estudo-seguranca-autenticacao.md)
