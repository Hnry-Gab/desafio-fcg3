# ADR 003 - Webhook WhatsApp com Processamento Assincrono
<!--
TYPE: adr
SCOPE: backend
KEYWORDS: adr, whatsapp, webhook, background-task, asyncio, fastapi, async-processing, langchain, timeout, chat-sessions
-->
[TOC]

## Resumo rapido

O webhook WhatsApp deve responder rapidamente e processar IA em background. Essa decisao protege o SLA do webhook e evita que chamadas ao LLM ou MCP bloqueiem a resposta HTTP inicial.

## Keywords

- adr
- whatsapp
- webhook
- whatsapp-cloud-api
- background-task
- asyncio
- fastapi
- async-processing
- langchain
- timeout
- chat-sessions
- ai-service

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `AGENTS.md`, `docs/backup/chatbot.md`, `backend/src/features/webhook/router.py`, `backend/src/features/webhook/background.py`

## Contexto

Webhooks do WhatsApp precisam responder dentro de uma janela curta. Processamento de IA pode envolver LLM, RAG, MCP, API e rede externa, o que pode exceder o tempo aceitavel.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Processar tudo dentro do POST | Simples de entender | Risco de timeout e reentrega pelo WhatsApp |
| Usar `asyncio.create_task` no MVP | Simples e rapido; atende limite de resposta | Menos robusto que fila externa |
| Usar Celery/RQ/fila externa | Mais resiliente e observavel | Mais infraestrutura para o MVP |

## Decisao

O backend valida a requisicao, registra o necessario e retorna `200 OK` rapidamente, delegando o processamento da IA para tarefa assincrona em background no MVP.

## Consequencias

- Positivas: reduz risco de timeout no webhook.
- Positivas: mantem infraestrutura inicial simples.
- Negativas: tarefas em memoria podem ser perdidas em restart do processo.
- Negativas: observabilidade e retry sao mais limitados do que em uma fila dedicada.
- Futuro: se volume crescer, avaliar fila externa para processamento resiliente.

## Links relacionados

- [Chatbot WhatsApp](../knowledge/chatbot-whatsapp.md)
- [Backend FastAPI](../knowledge/backend-fastapi.md)
- [AI Service e RAG](../knowledge/ai-service-rag.md)
- [Processos e testes](../knowledge/processos-testes.md)
