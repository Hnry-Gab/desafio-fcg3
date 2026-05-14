# ADR 004 - RAG com PostgreSQL e pgvector
<!--
TYPE: adr
SCOPE: rag
KEYWORDS: adr, rag, pgvector, postgresql, embeddings, vector-store, knowledge-base, hnsw, langchain, retrieval
-->
[TOC]

## Resumo rapido

O RAG usa PostgreSQL com pgvector para armazenar chunks e embeddings. A escolha aproveita o banco ja usado pelo sistema e evita operar um vector store separado no MVP.

## Keywords

- adr
- rag
- retrieval-augmented-generation
- pgvector
- postgresql
- embeddings
- vector-store
- knowledge-base
- hnsw
- langchain
- retrieval
- text-embedding-3-small

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `docs/backup/database.md`, `docs/backup/chatbot.md`, `ai_service/rag.py`, `ai_service/ingest.py`, `backend/alembic/versions/001_create_pgvector.py`

## Contexto

O chatbot precisa buscar regras academicas em documentos. O projeto ja usa PostgreSQL, e pgvector permite busca semantica diretamente no banco.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| PostgreSQL + pgvector | Menos infraestrutura; dados e vetores juntos; bom para MVP | Pode exigir tuning conforme volume |
| Vector DB externo | Recursos especializados de busca vetorial | Mais servicos, custo e operacao |
| Buscar texto sem embeddings | Simples | Menor qualidade semantica |

## Decisao

Usar `knowledge_base_chunks` no PostgreSQL com coluna vetorial, embeddings de 1536 dimensoes e busca por similaridade via pgvector. A documentacao/migrations indicam indice HNSW com cosine ops para acelerar busca vetorial.

## Consequencias

- Positivas: topologia simples e integrada ao banco existente.
- Positivas: migrations e backup podem incluir schema RAG.
- Negativas: exige cuidado com dimensao de embeddings e provider.
- Negativas: threshold e chunking impactam diretamente qualidade das respostas.
- Negativas: se volume de chunks e consultas crescer muito, pode ser necessario tuning de HNSW ou avaliar vector DB dedicado.

## Links relacionados

- [AI Service e RAG](../knowledge/ai-service-rag.md)
- [Base de conhecimento RAG](../knowledge/base-conhecimento-rag.md)
- [Dados e banco](../knowledge/dados-banco.md)
- [Estudo - RAG e LangChain](../study-guides/estudo-rag-langchain.md)
- [Estudo - PostgreSQL e pgvector](../study-guides/estudo-postgresql-pgvector.md)
