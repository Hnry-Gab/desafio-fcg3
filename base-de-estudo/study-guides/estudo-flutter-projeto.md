# Estudo - Flutter no Projeto
<!--
TYPE: study-guide
SCOPE: mobile
KEYWORDS: guia-de-estudo, tutorial, flutter, dart, riverpod, gorouter, dio, mobile, web, auth, fcm, responsive
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve entender a organizacao do app Flutter, como as rotas por papel funcionam, como o app autentica na API e como rodar analise e testes.

## Metadados

- Tipo: guia de estudo
- Escopo: mobile
- Nivel: intermediario
- Tempo sugerido: 3 a 5 horas

## Keywords

- guia-de-estudo
- tutorial
- flutter
- dart
- riverpod
- gorouter
- go-router
- dio
- mobile
- web
- auth
- fcm
- responsive
- design-system

## Pre-requisitos

- Dart basico.
- Flutter widgets e navegacao basicos.
- Nocoes de REST e JWT.

## Explicacao teorica

Flutter cria UIs declarativas multiplataforma. Riverpod gerencia estado e dependencias, GoRouter centraliza rotas e redirects, Dio executa chamadas HTTP e secure storage guarda tokens.

## Como se aplica a este projeto

- `mobile/lib/core/router/app_router.dart` aplica guards de auth e papel.
- `mobile/lib/core/network/` configura Dio e interceptors.
- `mobile/lib/features/auth/` implementa OTP.
- `mobile/lib/features/client/` contem jornadas do aluno.
- `mobile/lib/features/staff/` contem operacao staff/provider.
- `mobile/lib/core/theme/` contem Cyber-Academic design.

## Roteiro de estudo sugerido

1. Leia [Mobile Flutter](../knowledge/mobile-flutter.md).
2. Leia [Design system mobile](../knowledge/design-system-mobile.md).
3. Abra `mobile/lib/main.dart` e siga a inicializacao.
4. Abra `app_router.dart` e entenda redirects.
5. Abra `auth_service.dart` e `auth_interceptor.dart`.
6. Compare uma tela de aluno e uma tela de staff.

## Exercicios / atividades sugeridas

- Explique o que acontece quando usuario nao autenticado acessa rota staff.
- Localize onde `API_BASE_URL` e definido.
- Rode `flutter analyze` e `flutter test` no diretorio `mobile`.

## Referencias internas

- [Mobile Flutter](../knowledge/mobile-flutter.md)
- [Design system mobile](../knowledge/design-system-mobile.md)
- [Notificacoes FCM](../knowledge/notificacoes-fcm.md)
- [ADR 007 - Flutter com Riverpod e GoRouter](../adr/007-flutter-riverpod-gorouter.md)

## Referencias externas

- [Flutter documentation](https://docs.flutter.dev/)
- [Riverpod documentation](https://riverpod.dev/)
- [GoRouter package](https://pub.dev/packages/go_router)
- [Dio package](https://pub.dev/packages/dio)

## Links relacionados

- [Estudo - Seguranca e autenticacao](estudo-seguranca-autenticacao.md)
- [Estudo - Docker, testes e operacao local](estudo-docker-testes-operacao.md)
