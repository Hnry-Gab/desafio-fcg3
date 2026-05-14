# Estudo - PostgreSQL e pgvector
<!--
TYPE: study-guide
SCOPE: data
KEYWORDS: guia-de-estudo, tutorial, postgresql, pgvector, database, alembic, sqlalchemy, embeddings, hnsw, vector-search, rag
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve entender como o projeto usa PostgreSQL para dados relacionais e pgvector para embeddings RAG, alem de como migrations Alembic mantem o schema.

## Metadados

- Tipo: guia de estudo
- Escopo: data
- Nivel: intermediario
- Tempo sugerido: 3 a 5 horas

## Keywords

- guia-de-estudo
- tutorial
- postgresql
- pgvector
- database
- alembic
- sqlalchemy
- embeddings
- hnsw
- vector-search
- rag
- migrations

## Pre-requisitos

- SQL basico.
- Conceitos de migrations.
- Nocoes de embeddings.

## Explicacao teorica

PostgreSQL e um banco relacional robusto. pgvector adiciona tipo vetorial e operadores de similaridade, permitindo busca semantica. Alembic versiona alteracoes de schema para manter ambientes sincronizados.

## Como se aplica a este projeto

- Dados academicos e chat ficam em tabelas relacionais.
- `knowledge_base_chunks` armazena conteudo e embeddings.
- Alembic cria extensao pgvector e tabelas.
- Backend usa SQLAlchemy async.
- AI Service usa consultas vetoriais diretas.
- MCP usa asyncpg para sessao e logs.

## Roteiro de estudo sugerido

1. Leia [Dados e banco](../knowledge/dados-banco.md).
2. Leia [Modelo academico](../knowledge/modelo-academico.md).
3. Abra `backend/alembic/versions/001_create_pgvector.py`.
4. Abra migration de chat/knowledge.
5. Abra `ai_service/rag.py`.
6. Leia [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md).

## Exercicios / atividades sugeridas

- Liste as tabelas que conectam chatbot, MCP e RAG.
- Explique por que a dimensao do embedding precisa bater com o schema.
- Rode migrations em ambiente local com `alembic upgrade head`.

## Referencias internas

- [Dados e banco](../knowledge/dados-banco.md)
- [Modelo academico](../knowledge/modelo-academico.md)
- [Base de conhecimento RAG](../knowledge/base-conhecimento-rag.md)

## Referencias externas

- [PostgreSQL documentation](https://www.postgresql.org/docs/)
- [pgvector](https://github.com/pgvector/pgvector)
- [Alembic documentation](https://alembic.sqlalchemy.org/)

## Links relacionados

- [Estudo - RAG e LangChain](estudo-rag-langchain.md)
- [Estudo - Backend FastAPI](estudo-backend-fastapi.md)
