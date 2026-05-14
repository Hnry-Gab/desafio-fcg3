# Mobile Architecture Deep Dive
<!--
TYPE: knowledge-page
SCOPE: mobile
KEYWORDS: flutter, mobile, arquitetura, architecture, riverpod, gorouter, go-router, feature-first, client, staff, provider, responsive, apresentação
-->
[TOC]

## Resumo rapido

O app Flutter e organizado por core, features e shared widgets. Riverpod injeta estado/servicos, GoRouter controla navegacao por papel e shells responsivos separam experiencia de aluno e staff/provider.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mobile
- Fontes: `mobile/lib/core/router/app_router.dart`, `mobile/lib/features/client/`, `mobile/lib/features/staff/`, `mobile/lib/core/providers/`, `mobile/test/app_router_test.dart`

## Keywords

- flutter
- mobile
- arquitetura
- architecture
- riverpod
- gorouter
- go-router
- feature-first
- client
- staff
- provider
- responsive
- apresentação

## Contexto

Perguntas de apresentacao sobre mobile normalmente focam em separacao de telas, estado, navegacao e por que a UI nao e a unica camada de seguranca.

## Detalhamento tecnico

### Organizacao

- `core/`: config, networking, router, providers globais, tema, responsividade.
- `features/auth/`: login OTP e estado de autenticacao.
- `features/client/`: telas e services do aluno.
- `features/staff/`: telas e services staff/provider.
- `shared/`: widgets reutilizaveis.

### Estado

- Riverpod fornece services e async state.
- Providers gerados (`.g.dart`) reduzem boilerplate.
- Alguns dados usam TTL/cache para evitar refetch excessivo.

### Navegacao

- GoRouter aplica redirects por auth/role.
- Nao autenticados vao para login.
- `student` nao acessa `/staff`.
- `staff/provider` nao acessa `/client`.
- Backend continua sendo a autorizacao real.

### Responsividade

- Phone usa bottom navigation.
- Tablet/desktop usa NavigationRail.
- Client e staff possuem shells separados.

## Fluxo / Arquitetura

```text
main.dart -> ProviderScope -> appRouterProvider
AuthState -> GoRouter redirect
Route -> client_shell ou staff_shell
Screen -> provider -> service -> Dio -> FastAPI
```

## Perguntas de apresentacao

### Por que Riverpod?

Resposta: porque funciona como injeção de dependencias e estado reativo por feature, com testes por override de provider.

### Por que GoRouter?

Resposta: porque centraliza rotas declarativas e redirects por auth/role, reduzindo logica espalhada em telas.

### Se alguem burlar a rota no app, acessa dados?

Resposta: nao deveria. O backend valida JWT, role e ownership; a rota no app e UX/primeira barreira, nao a autorizacao final.

## Links relacionados

- [Mobile Flutter](mobile-flutter.md)
- [Mobile auth, Dio e secure storage](mobile-auth-dio-secure-storage.md)
- [Mobile FCM deep dive](mobile-fcm-deep-dive.md)
- [ADR 007 - Flutter com Riverpod e GoRouter](../adr/007-flutter-riverpod-gorouter.md)
