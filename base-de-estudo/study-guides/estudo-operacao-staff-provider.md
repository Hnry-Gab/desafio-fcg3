# Estudo - Operacao Staff/Provider
<!--
TYPE: study-guide
SCOPE: mixed
KEYWORDS: guia-de-estudo, tutorial, staff, provider, operação, operacao, human-intervention, intervenção-humana, resources, recursos, appointments, agendamentos, notifications, fcm
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve entender os fluxos operacionais de staff/provider: dashboard administrativo, intervencao humana em chats, gestao de membros staff, recursos, agendamentos, documentos e notificacoes.

## Metadados

- Tipo: guia de estudo
- Escopo: mixed
- Nivel: intermediario
- Tempo sugerido: 3 a 5 horas

## Keywords

- guia-de-estudo
- tutorial
- staff
- provider
- operacao
- operação
- human-intervention
- intervencao-humana
- intervenção-humana
- resources
- recursos
- appointments
- agendamentos
- documents
- documentos
- notifications
- notificacoes
- notificações
- fcm

## Pre-requisitos

- Entender os papeis `student`, `staff` e `provider`.
- Conhecer o fluxo basico de API REST e JWT.
- Ter lido a visao geral da arquitetura.

## Explicacao teorica

Em plataformas academicas com atendimento automatizado, a operacao humana continua necessaria para excecoes, supervisao, documentos, recursos e atendimento especializado. O papel `staff` cobre operacao administrativa; o papel `provider` possui permissoes adicionais para gerenciar membros staff.

## Como se aplica a este projeto

- `backend/src/features/staff/controllers.py` expoe dashboard e CRUD provider-only de membros staff.
- `backend/src/features/chat/` expoe sessoes, mensagens, action logs, assign, reply e resolve.
- `backend/src/features/resources/` expoe CRUD de recursos.
- `backend/src/features/appointments/` e `backend/src/features/scheduling/` cobrem agenda e slots.
- `backend/src/features/documents/` cobre solicitacoes e status.
- `mobile/lib/features/staff/` contem telas operacionais de staff/provider.
- FCM implementado no codigo atual cobre `document_ready`, `enrollment_confirmed` e `appointment_confirmed`; `chat_reply` e `action_status` aparecem como eventos arquiteturais/planejados e devem ser confirmados antes de apresentar como implementados.

## Roteiro de estudo sugerido

1. Leia [Modulos academicos](../knowledge/modulos-academicos.md).
2. Leia [API REST e contratos](../knowledge/api-rest-contratos.md).
3. Leia [Notificacoes FCM](../knowledge/notificacoes-fcm.md).
4. Abra `backend/src/features/staff/controllers.py` e identifique endpoints provider-only.
5. Abra `backend/src/features/chat/router.py` e siga o fluxo de intervencao humana.
6. Abra `mobile/lib/features/staff/` e relacione telas com endpoints.

## Exercicios / atividades sugeridas

- Explique a diferenca entre `staff` e `provider` no projeto.
- Trace o fluxo de uma conversa que exige intervencao humana ate `resolve`.
- Liste quais telas staff/provider podem depender de `/resources` e `/appointments`.
- Identifique quais eventos deveriam disparar notificacoes para o app.

## Referencias internas

- [Modulos academicos](../knowledge/modulos-academicos.md)
- [API REST e contratos](../knowledge/api-rest-contratos.md)
- [Mobile Flutter](../knowledge/mobile-flutter.md)
- [Notificacoes FCM](../knowledge/notificacoes-fcm.md)
- [Autenticacao e autorizacao](../knowledge/autenticacao-autorizacao.md)

## Referencias externas

- [FastAPI documentation](https://fastapi.tiangolo.com/)
- [Flutter documentation](https://docs.flutter.dev/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

## Links relacionados

- [Estudo - Flutter no projeto](estudo-flutter-projeto.md)
- [Estudo - Backend FastAPI](estudo-backend-fastapi.md)
- [Estudo - Seguranca e autenticacao](estudo-seguranca-autenticacao.md)
