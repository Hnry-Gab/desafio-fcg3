# Mobile FCM Deep Dive
<!--
TYPE: knowledge-page
SCOPE: mobile
KEYWORDS: flutter, fcm, firebase-cloud-messaging, notificações, notificacoes, event, deep-link, safe-routing, foreground, background, cold-start
-->
[TOC]

## Resumo rapido

O app usa FCM para receber eventos do backend e navegar para telas seguras por mapeamento hardcoded. A implementacao mobile usa o campo `event` no payload para derivar rota e refresh de dados.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mobile
- Fontes: `mobile/lib/core/providers/fcm_provider.dart`, `mobile/lib/core/providers/notification_handler_provider.dart`, `mobile/lib/core/providers/notification_routes.dart`, `backend/src/features/notifications/services.py`

## Keywords

- flutter
- fcm
- firebase-cloud-messaging
- notificações
- notificacoes
- event
- deep-link
- safe-routing
- foreground
- background
- cold-start

## Contexto

Notificacoes conectam acoes academicas ao app. Em apresentacao, destaque que o payload nao injeta rota arbitraria: o app mapeia eventos conhecidos para caminhos seguros.

## Detalhamento tecnico

### Registro de token

- Aluno autenticado registra token via `/students/{studentId}/fcm-token`.
- Logout deve remover/unregister token quando aplicavel.
- Backend suporta multiplos dispositivos por aluno via tabela de tokens.

### Routing seguro

- O mobile usa `event`, nao `type`, para derivar destino.
- Eventos implementados no roteamento mobile devem ser diferenciados de eventos planejados/documentados.
- Rotas sao hardcoded em provider, evitando que payload mande caminho livre.

### Estados de app

- Foreground: pode mostrar snackbar ou atualizar dados.
- Background/tap: processa evento e navega para destino seguro.
- Cold start: evento inicial precisa ser tratado apos inicializacao.

## Perguntas de apresentacao

### Qual campo do payload o app usa?

Resposta: o mobile usa `event` para mapear notificacoes. Se algum doc citar `type`, trate como contrato conceitual antigo e prefira o codigo atual.

### O usuario pode mandar uma rota maliciosa no payload?

Resposta: nao deveria, porque o app nao navega por path arbitrario vindo do push; ele converte eventos conhecidos para rotas internas.

### O que acontece sem credenciais Firebase localmente?

Resposta: backend/mobile devem operar de modo tolerante; no backend envios podem ser no-op quando Firebase nao inicializa.

## Limites e riscos

- Nem todos os eventos planejados precisam estar roteados no mobile atual.
- Push nao substitui fetch: o app deve buscar dados atualizados apos receber evento.
- Entrega FCM nao e garantia transacional absoluta.

## Links relacionados

- [Notificacoes FCM](notificacoes-fcm.md)
- [Mobile Flutter](mobile-flutter.md)
- [Mobile architecture deep dive](mobile-architecture-deep-dive.md)
- [Processos e testes](processos-testes.md)
