# Mobile Flutter
<!--
TYPE: knowledge-page
SCOPE: mobile
KEYWORDS: mobile, flutter, dart, riverpod, gorouter, dio, flutter-secure-storage, firebase-messaging, student-app, staff-app, provider, web
-->
[TOC]

## Resumo rapido

O app Flutter e a interface mobile/web para alunos e staff/provider. Ele consome a API FastAPI com Dio, usa autenticacao OTP/JWT, gerencia estado com Riverpod e navega por GoRouter com guardas por papel.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mobile
- Fontes: `mobile/lib/`, `mobile/pubspec.yaml`, `mobile/test/`, `requerimentos_frontend.md`, `design ideas/DESIGN.md`
- Plataforma: Flutter 3.41.6 / Dart 3.11.4+

## Keywords

- mobile
- flutter
- dart
- web
- riverpod
- go-router
- gorouter
- dio
- flutter-secure-storage
- firebase-messaging
- fcm
- student-app
- client-app
- staff-app
- provider
- otp-login
- responsive

## Contexto

O WhatsApp e o canal primario de interacao conversacional, mas o app fornece acompanhamento visual, gestao e operacao administrativa. O mesmo projeto Flutter atende aluno e staff/provider com rotas separadas.

## Detalhamento tecnico

Estrutura principal:

- `mobile/lib/core/`: config, router, network, providers, theme e responsividade.
- `mobile/lib/features/auth/`: login OTP e estado de auth.
- `mobile/lib/features/splash/`: verificacao inicial de sessao.
- `mobile/lib/features/client/`: telas e services do aluno.
- `mobile/lib/features/staff/`: telas e services de staff/provider.
- `mobile/lib/shared/`: widgets reutilizaveis.

## Fluxo / Arquitetura

```text
main.dart
  -> ProviderScope
  -> Splash/Auth check
  -> GoRouter redirect por auth/role
  -> Shell aluno ou staff
  -> Services Dio
  -> FastAPI /api/v1
```

## Interfaces e dependencias

- `API_BASE_URL` via `--dart-define`.
- Padrao local Android emulator: `10.0.2.2:8000/api/v1`.
- Padrao web: `localhost:8000/api/v1`.
- Tokens em `flutter_secure_storage`.
- `AuthInterceptor` injeta `Authorization: Bearer` e lida com refresh.
- FCM registra token em `/students/{studentId}/fcm-token`.

## Exemplos

Comandos uteis:

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

## Links relacionados

- [Design system mobile](design-system-mobile.md)
- [Mobile architecture deep dive](mobile-architecture-deep-dive.md)
- [Mobile auth, Dio e secure storage](mobile-auth-dio-secure-storage.md)
- [Mobile FCM deep dive](mobile-fcm-deep-dive.md)
- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [Notificacoes FCM](notificacoes-fcm.md)
- [API REST e contratos](api-rest-contratos.md)
- [ADR 007 - Flutter com Riverpod e GoRouter](../adr/007-flutter-riverpod-gorouter.md)
- [Estudo - Flutter no projeto](../study-guides/estudo-flutter-projeto.md)
