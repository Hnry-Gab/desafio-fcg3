# Estudo - RAG e LangChain
<!--
TYPE: study-guide
SCOPE: rag
KEYWORDS: guia-de-estudo, tutorial, rag, langchain, embeddings, pgvector, llm, openai, gemini, openrouter, retrieval, chatbot
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve entender o que e RAG, como o AI Service usa LangChain, como documentos viram embeddings e como o agente decide entre responder, consultar conhecimento ou chamar MCP.

## Metadados

- Tipo: guia de estudo
- Escopo: rag
- Nivel: intermediario
- Tempo sugerido: 4 a 6 horas

## Keywords

- guia-de-estudo
- tutorial
- rag
- retrieval-augmented-generation
- langchain
- embeddings
- pgvector
- llm
- openai
- gemini
- openrouter
- retrieval
- chatbot
- prompt

## Pre-requisitos

- Conceitos basicos de LLM.
- Nocoes de embeddings e similaridade vetorial.
- Python async basico.

## Explicacao teorica

RAG combina recuperacao de documentos com geracao por LLM. Primeiro, documentos sao quebrados em chunks e vetorizados. Em tempo de pergunta, a query tambem e vetorizada e comparada com os chunks. O LLM usa os trechos recuperados como contexto.

## Como se aplica a este projeto

- Documentos fonte ficam em `ai_service/knowledge/`.
- `ai_service/ingest.py` cria chunks e embeddings.
- `knowledge_base_chunks` armazena conteudo, embedding, source, category e chunk_index.
- `ai_service/rag.py` busca top resultados por similaridade.
- `ai_service/agent.py` conecta RAG e MCP ao agente.

## Roteiro de estudo sugerido

1. Leia [AI Service e RAG](../knowledge/ai-service-rag.md).
2. Leia [Base de conhecimento RAG](../knowledge/base-conhecimento-rag.md).
3. Abra `ai_service/ingest.py` e entenda `CATEGORY_MAP`.
4. Abra `ai_service/rag.py` e identifique a query pgvector.
5. Abra `ai_service/agent.py` e veja como tools sao registradas.
6. Leia [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md).

## Exercicios / atividades sugeridas

- Escolha um arquivo em `ai_service/knowledge/` e proponha uma pergunta que deveria recuperar esse conteudo.
- Rode o teste `ai_service/tests/test_ingest.py`.
- Explique o impacto de reduzir ou aumentar `RAG_SIMILARITY_THRESHOLD`.

## Referencias internas

- [AI Service e RAG](../knowledge/ai-service-rag.md)
- [Base de conhecimento RAG](../knowledge/base-conhecimento-rag.md)
- [Seguranca da IA](../knowledge/seguranca-ai.md)
- [ADR 005 - LLM provider-agnostic](../adr/005-llm-provider-agnostic.md)

## Referencias externas

- [LangChain documentation](https://python.langchain.com/docs/)
- [pgvector](https://github.com/pgvector/pgvector)
- [OpenAI embeddings guide](https://platform.openai.com/docs/guides/embeddings)

## Links relacionados

- [Estudo - MCP no projeto](estudo-mcp-projeto.md)
- [Estudo - PostgreSQL e pgvector](estudo-postgresql-pgvector.md)
