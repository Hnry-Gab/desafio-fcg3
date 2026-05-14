# Perguntas Tecnicas - Guias de Estudo
<!--
TYPE: study-guide
SCOPE: mixed
KEYWORDS: perguntas-tecnicas, guia-de-estudo, tutorial, apresentação, onboarding, exercícios, backend, rag, mcp, mobile, docker, testes
-->
[TOC]

## Resumo rapido

Este guia transforma os estudos em perguntas de treino para apresentacao. Use para simular uma banca tecnica e praticar respostas curtas com aprofundamento.

## Metadados

- Tipo: guia de estudo
- Escopo: mixed
- Publico: apresentadores e equipe tecnica
- Objetivo: treino de Q&A

## Keywords

- perguntas-tecnicas
- guia-de-estudo
- tutorial
- apresentação
- onboarding
- exercícios
- backend
- rag
- mcp
- mobile
- docker
- testes

## Como treinar

1. Escolha um tema.
2. Responda primeiro em ate 30 segundos.
3. Depois responda com detalhes tecnicos e cite arquivos reais.
4. Abra o documento relacionado e compare sua resposta.
5. Se nao conseguir citar evidencia, marque a pergunta para revisar.

## Perguntas de treino

### Arquitetura

- Como uma mensagem do WhatsApp vira uma resposta academica?
- Por que o backend continua sendo fonte de verdade mesmo com IA?
- Qual servico conhece a identidade do aluno?
- Onde ficam os dados vetoriais e relacionais?

### Backend

- Onde os routers FastAPI sao registrados?
- Como erros sao normalizados?
- Como JWT e service token diferem?
- Como ownership impede IDOR?

### RAG

- O que e embedding?
- Por que `vector(1536)` importa?
- Quantos chunks existem e onde verificar?
- O que acontece quando o RAG nao encontra contexto?
- Como custo cresce com uso?

### MCP

- O que e uma MCP tool?
- Por que `x-chat-session-id` e obrigatorio?
- Quais tools exigem sessao verificada?
- Como retry e auditoria funcionam?

### Mobile

- Como GoRouter bloqueia rotas por papel?
- Como Dio renova token?
- Onde tokens sao armazenados?
- Quais eventos FCM estao implementados no app?

### Operacao

- Como subir a stack local?
- O que verificar em cada healthcheck?
- Quais testes provariam cada parte da arquitetura?
- Quando considerar fila externa em vez de `asyncio.create_task`?

## Links relacionados

- [Perguntas tecnicas globais](../perguntas-tecnicas.md)
- [Estudo - Arquitetura do projeto](estudo-arquitetura-projeto.md)
- [Estudo - RAG e LangChain](estudo-rag-langchain.md)
- [Estudo - MCP no projeto](estudo-mcp-projeto.md)
- [Estudo - Flutter no projeto](estudo-flutter-projeto.md)
