# Mobile Auth, Dio e Secure Storage
<!--
TYPE: knowledge-page
SCOPE: mobile
KEYWORDS: flutter, auth, dio, queuedinterceptor, secure-storage, flutter-secure-storage, jwt, refresh-token, bearer, login, otp, segurança
-->
[TOC]

## Resumo rapido

O app usa Dio com `AuthInterceptor` para anexar Bearer token e tentar refresh em `401`. Tokens ficam em `flutter_secure_storage`; em falha de refresh, o app remove tokens locais.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mobile
- Fontes: `mobile/lib/core/network/auth_interceptor.dart`, `mobile/lib/core/network/dio_client.dart`, `mobile/lib/core/providers/storage_provider.dart`, `mobile/lib/features/auth/`

## Keywords

- flutter
- auth
- dio
- queuedinterceptor
- secure-storage
- flutter-secure-storage
- jwt
- refresh-token
- bearer
- login
- otp
- segurança

## Contexto

Essa pagina responde perguntas sobre onde tokens ficam, como a API e chamada, como refresh evita loop e como o mobile participa do fluxo OTP/JWT.

## Detalhamento tecnico

### Armazenamento

- Chaves: `access_token` e `refresh_token`.
- Biblioteca: `flutter_secure_storage`.
- Android usa encrypted shared preferences quando configurado no provider.
- iOS usa Keychain conforme opcoes da biblioteca/provedor.

### Interceptor

- `AuthInterceptor` estende `QueuedInterceptor`.
- `onRequest` le access token e injeta `Authorization: Bearer`.
- `onError` trata `401` se a request ainda nao e retry.
- Usa um Dio separado para `/auth/refresh`, evitando loop de interceptor.
- Se refresh funciona, grava novos tokens e repete request original.
- Se refresh falha, remove tokens.

## Fluxo / Arquitetura

```text
Request -> AuthInterceptor -> adiciona Bearer
Backend responde 401
AuthInterceptor -> le refresh_token
refreshDio -> POST /auth/refresh
Sucesso -> salva tokens -> retry request original
Falha -> apaga tokens -> erro propaga
```

## Perguntas de apresentacao

### Por que usar `QueuedInterceptor`?

Resposta: para serializar operacoes async e evitar varias tentativas de refresh concorrentes ou handler disparando antes de `await` concluir.

### Onde fica a URL da API?

Resposta: em config por `--dart-define=API_BASE_URL`; defaults variam para Android emulator e web.

### O app salva senha?

Resposta: nao. O login e por OTP; o app salva tokens de sessao, nao senha.

## Limites e riscos

- Secure storage em web tem garantias diferentes das plataformas mobile.
- Refresh falho exige redirecionar usuario para login.
- A protecao real de dados continua no backend.

## Links relacionados

- [Mobile architecture deep dive](mobile-architecture-deep-dive.md)
- [Auth OTP/JWT detalhado](auth-otp-jwt-detalhado.md)
- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [ADR 007 - Flutter com Riverpod e GoRouter](../adr/007-flutter-riverpod-gorouter.md)
