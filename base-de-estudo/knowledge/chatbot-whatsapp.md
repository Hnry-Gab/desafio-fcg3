# Chatbot WhatsApp
<!--
TYPE: knowledge-page
SCOPE: mixed
KEYWORDS: chatbot, whatsapp, whatsapp-cloud-api, webhook, fastapi, langchain, rag, mcp, chat-sessions, chat-messages, human-intervention
-->
[TOC]

## Resumo rapido

O chatbot WhatsApp e o canal conversacional do aluno. O backend recebe mensagens no webhook, registra a conversa, aciona o AI Service em background e devolve respostas baseadas em RAG ou acoes executadas via MCP.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mixed
- Fontes: `docs/backup/chatbot.md`, `backend/src/features/webhook/`, `backend/src/features/chat/`, `ai_service/agent.py`
- Canais: WhatsApp Cloud API e app Flutter

## Keywords

- chatbot
- whatsapp
- whatsapp-cloud-api
- webhook
- fastapi
- langchain
- rag
- mcp
- chat-sessions
- chat-messages
- human-intervention
- intervencao-humana
- media-message
- hmac
- background-task

## Contexto

O WhatsApp impoe limite pratico de resposta rapida do webhook. Por isso, a API deve responder `200 OK` rapidamente e processar IA de forma assincrona. Mensagens de midia recebem respostas padrao no MVP.

## Detalhamento tecnico

Arquivos relevantes:

- `backend/src/features/webhook/router.py`: verificacao GET, recepcao POST, validacao HMAC e dispatch background.
- `backend/src/features/webhook/background.py`: processamento fora do ciclo HTTP.
- `backend/src/features/webhook/service.py`: parse, sessoes e envio de resposta.
- `backend/src/features/chat/router.py`: historico, mensagens, assign, reply e resolve.
- `ai_service/main.py`: endpoint `/chat` chamado pelo backend.
- `ai_service/agent.py`: decisao de resposta, RAG e ferramentas.

## Fluxo / Arquitetura

```text
WhatsApp Cloud API -> POST /api/v1/webhook/whatsapp
Backend valida assinatura HMAC
Backend cria/atualiza chat_session e chat_message
Backend retorna 200 rapido
Background task chama AI Service
AI Service usa RAG e MCP
Backend envia resposta ao WhatsApp
Staff pode intervir via chat-sessions no app
```

## Interfaces e dependencias

- Webhook GET valida challenge da plataforma.
- Webhook POST valida assinatura antes de processar JSON.
- Chat usa `chat_sessions` e `chat_messages`.
- Acoes do agente geram `mcp_action_logs`.
- Eventos de chat e status de acao aparecem como arquitetura planejada; no FCM atual, confirme implementacao antes de apresentar `chat_reply` ou `action_status` como push ativo.

## Exemplos

Intent e resposta conceitual:

```text
Aluno: "Quais disciplinas posso cursar?"
Agente: chama get_available_courses no MCP
MCP: injeta student_id e consulta backend
Agente: responde com disciplinas disponiveis
```

## Links relacionados

- [AI Service e RAG](ai-service-rag.md)
- [MCP Server](mcp-server.md)
- [Ferramentas MCP](ferramentas-mcp.md)
- [Notificacoes FCM](notificacoes-fcm.md)
- [ADR 003 - Webhook WhatsApp com processamento assincrono](../adr/003-webhook-whatsapp-assincrono.md)
