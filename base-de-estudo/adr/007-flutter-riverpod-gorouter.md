# ADR 007 - Flutter com Riverpod e GoRouter
<!--
TYPE: adr
SCOPE: mobile
KEYWORDS: adr, flutter, dart, riverpod, go-router, gorouter, dio, state-management, navigation, mobile, web, responsive
-->
[TOC]

## Resumo rapido

O app usa Flutter com Riverpod para estado, GoRouter para navegacao e Dio para HTTP. A combinacao sustenta rotas por papel, shells responsivos e integracao com API REST.

## Keywords

- adr
- flutter
- dart
- riverpod
- go-router
- gorouter
- dio
- state-management
- navigation
- mobile
- web
- responsive
- auth-guards

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `mobile/pubspec.yaml`, `mobile/lib/core/router/app_router.dart`, `mobile/lib/core/network/dio_client.dart`, `mobile/lib/features/`, `mobile/test/`

## Contexto

O app precisa atender aluno e staff/provider com rotas separadas, estado reativo, chamadas autenticadas e responsividade.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Riverpod + GoRouter | Forte integracao com Flutter moderno; bom para guards e providers | Exige codegen/conhecimento de providers |
| Bloc + Navigator manual | Padrao comum em apps grandes | Mais boilerplate para este projeto |
| Provider simples + rotas manuais | Simples no inicio | Menos robusto para auth guards e multiplos papeis |

## Decisao

Usar Flutter com Riverpod, GoRouter, Dio, secure storage e Firebase Messaging, mantendo shells separados para cliente e staff/provider.

## Consequencias

- Positivas: rotas por papel ficam centralizadas.
- Positivas: estado e cache podem ser isolados por feature.
- Positivas: app cobre mobile e web com uma base.
- Negativas: exige rodar build_runner quando providers gerados mudarem.
- Negativas: guardas de rota precisam ser testados para evitar vazamento entre perfis.

## Links relacionados

- [Mobile Flutter](../knowledge/mobile-flutter.md)
- [Design system mobile](../knowledge/design-system-mobile.md)
- [Notificacoes FCM](../knowledge/notificacoes-fcm.md)
- [Estudo - Flutter no projeto](../study-guides/estudo-flutter-projeto.md)
