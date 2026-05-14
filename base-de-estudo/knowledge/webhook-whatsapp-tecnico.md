# Webhook WhatsApp Tecnico
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: whatsapp, webhook, hmac, raw-body, asyncio, background-task, deduplicacao, dedup, wamid, telefone, media, ai-service, fallback
-->
[TOC]

## Resumo rapido

O webhook WhatsApp valida assinatura, registra mensagem/sessao e delega IA para background, mantendo resposta HTTP rapida. O desenho protege contra spoofing, duplicidade e timeout da plataforma.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `backend/src/features/webhook/router.py`, `backend/src/features/webhook/service.py`, `backend/src/features/webhook/background.py`, `backend/tests/features/webhook/`

## Keywords

- whatsapp
- webhook
- hmac
- raw-body
- asyncio
- background-task
- deduplicacao
- dedup
- wamid
- telefone
- media
- ai-service
- fallback

## Contexto

Webhooks precisam responder rapido. Chamadas a LLM e MCP podem ser lentas ou falhar. Por isso, o backend trata a entrada do WhatsApp como evento: valida, persiste, responde `200`, e processa depois.

## Detalhamento tecnico

### Validacao de assinatura

- O backend usa o corpo bruto da requisicao.
- A assinatura `X-Hub-Signature-256` e validada com HMAC-SHA256.
- A validacao ocorre antes de confiar no JSON.

### Persistencia e deduplicacao

- Mensagens usam identificador WhatsApp (`wamid`).
- Duplicidade e tratada pela restricao/erro de integridade do `whatsapp_message_id`.
- Se mensagem ja existe, o processamento evita duplicar efeitos.

### Processamento assíncrono

- O POST dispara processamento background.
- O backend evita aguardar LLM no ciclo HTTP do webhook.
- Em falha de AI Service, deve haver resposta fallback tecnica para o aluno.

### Midias

- Midias sao tratadas com respostas padrao no MVP.
- O fluxo de MVP nao envia midia para IA.

## Fluxo / Arquitetura

```text
WhatsApp -> POST /api/v1/webhook/whatsapp
Backend valida HMAC com raw body
Backend normaliza telefone e identifica aluno/sessao
Backend salva chat_message com wamid
Backend retorna 200 OK
Background chama AI Service
AI Service usa RAG/MCP
Backend envia resposta ao WhatsApp
```

## Perguntas de apresentacao

### Como evita spoofing?

Resposta: validando `X-Hub-Signature-256` com HMAC-SHA256 sobre o raw body antes do parse confiavel.

### Como garante menos de 5 segundos?

Resposta: nao espera a IA no webhook; usa background task e retorna 200 rapidamente apos validacao/persistencia.

### Como evita processar a mesma mensagem duas vezes?

Resposta: usa o ID da mensagem WhatsApp (`wamid`) e trata duplicidade na persistencia.

### O que acontece se a IA cair?

Resposta: o backend deve enviar fallback informando indisponibilidade/erro tecnico sem quebrar o webhook.

## Limites e riscos

- `asyncio.create_task` pode perder tarefas em restart do processo.
- Em escala maior, fila externa daria retry e observabilidade melhores.
- Midias ainda nao passam por IA no MVP.

## Links relacionados

- [Chatbot WhatsApp](chatbot-whatsapp.md)
- [AI Service e RAG](ai-service-rag.md)
- [MCP Server](mcp-server.md)
- [ADR 003 - Webhook WhatsApp com processamento assincrono](../adr/003-webhook-whatsapp-assincrono.md)
