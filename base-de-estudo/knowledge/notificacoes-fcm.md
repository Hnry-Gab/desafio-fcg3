# Notificacoes FCM
<!--
TYPE: knowledge-page
SCOPE: mixed
KEYWORDS: notificacoes, notificações, notifications, fcm, firebase-cloud-messaging, push-notifications, document-ready, enrollment-confirmed, appointment-confirmed, chat-reply, action-status
-->
[TOC]

## Resumo rapido

As notificacoes FCM conectam eventos do backend ao app Flutter. No codigo atual, os eventos implementados sao documento pronto, matricula confirmada e agendamento confirmado.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mixed
- Fontes: `backend/src/features/notifications/`, `mobile/lib/core/providers/fcm_provider.dart`, `.planning/phases/22-fcm-push-notifications/`
- Tecnologia: Firebase Cloud Messaging

## Keywords

- notificacoes
- notificações
- notifications
- fcm
- firebase-cloud-messaging
- push-notifications
- document-ready
- enrollment-confirmed
- appointment-confirmed
- chat-reply
- action-status
- fcm-token
- mobile
- backend

## Contexto

O WhatsApp pode executar acoes que precisam aparecer no app, e fluxos administrativos tambem geram eventos relevantes. O app registra o token FCM do dispositivo; o backend envia notificacoes quando eventos ocorrem.

## Detalhamento tecnico

Eventos implementados no codigo atual:

- `document_ready`: documento pronto.
- `enrollment_confirmed`: matricula confirmada.
- `appointment_confirmed`: agendamento confirmado.

Eventos discutidos na arquitetura, mas que nao devem ser apresentados como implementados no FCM atual sem nova verificacao:

- `chat_reply`: nova resposta de chat.
- `action_status`: status de acao executada.

No mobile, rotas de notificacao usam caminhos conhecidos para evitar injecao via payload.

## Fluxo / Arquitetura

```text
Flutter obtem token FCM
Flutter -> PUT /students/{studentId}/fcm-token
Backend salva token
Evento academico ocorre
Backend envia push via Firebase
App recebe payload e navega para tela segura
```

## Interfaces e dependencias

- Backend deve tolerar ausencia de credenciais FCM em ambiente local.
- Falhas de envio sao logadas em vez de quebrar o fluxo principal.
- Mobile unregister token em logout ou troca de usuario quando aplicavel.

## Exemplos

Contrato conceitual de payload. No mobile atual, o campo usado para roteamento seguro e `event`:

```json
{
  "event": "document_ready",
  "resource_id": "uuid",
  "title": "Documento pronto"
}
```

## Links relacionados

- [Mobile Flutter](mobile-flutter.md)
- [Backend FastAPI](backend-fastapi.md)
- [Chatbot WhatsApp](chatbot-whatsapp.md)
- [Processos e testes](processos-testes.md)
