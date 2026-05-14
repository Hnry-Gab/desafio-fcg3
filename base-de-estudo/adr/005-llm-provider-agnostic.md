# ADR 005 - LLM Provider-Agnostic
<!--
TYPE: adr
SCOPE: rag
KEYWORDS: adr, llm, provider-agnostic, openai, gemini, openrouter, langchain, llm-factory, embedding-factory, configuracao
-->
[TOC]

## Resumo rapido

O AI Service abstrai provedores de LLM e embeddings por factories. Isso permite trocar entre OpenAI, Gemini e OpenRouter por variaveis de ambiente, sem mudar o fluxo principal do agente.

## Keywords

- adr
- llm
- provider-agnostic
- openai
- gemini
- openrouter
- langchain
- llm-factory
- embedding-factory
- configuracao
- environment

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `AGENTS.md`, `ai_service/llm_factory.py`, `ai_service/embedding_factory.py`, `ai_service/config.py`, `ai_service/tests/test_llm_factory.py`

## Contexto

A decisao de provider de LLM e tratada como externa ao dominio do projeto. O codigo precisa suportar troca de provider sem reescrever a orquestracao.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Fixar OpenAI | Simples e maduro | Acopla custo e disponibilidade a um provider |
| Fixar Gemini | Integracao direta com Google | Mesmo acoplamento a um provider |
| Factory provider-agnostic | Flexivel; configuravel por ambiente | Mais casos de teste e configuracao |

## Decisao

Criar factories para chat model e embeddings, selecionando provider por `LLM_PROVIDER` e `EMBEDDING_PROVIDER`. O suporte evidenciado no codigo atual e: LLM com OpenAI, Gemini e OpenRouter; embeddings com OpenAI e OpenRouter.

## Consequencias

- Positivas: troca de provider sem alterar agente principal.
- Positivas: facilita comparacao de custo, latencia e qualidade.
- Negativas: providers podem divergir em suporte a features, streaming, limites e formato de erro.
- Negativas: embeddings precisam manter dimensao compativel com o schema.
- Negativas: suporte de providers nao e simetrico; Gemini aparece para LLM, mas nao como provider de embeddings no codigo atual.

## Links relacionados

- [AI Service e RAG](../knowledge/ai-service-rag.md)
- [Base de conhecimento RAG](../knowledge/base-conhecimento-rag.md)
- [Estudo - RAG e LangChain](../study-guides/estudo-rag-langchain.md)
