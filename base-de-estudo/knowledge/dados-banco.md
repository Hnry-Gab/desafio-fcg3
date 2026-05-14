# Dados e Banco
<!--
TYPE: knowledge-page
SCOPE: data
KEYWORDS: dados, banco, database, postgresql, pgvector, sqlalchemy, alembic, migrations, seed, knowledge-base-chunks, mcp-action-logs, rag-logs
-->
[TOC]

## Resumo rapido

O projeto usa PostgreSQL como banco unico para dados relacionais, logs de acoes, historico de chat e embeddings da base RAG via pgvector. Alembic gerencia migrations e SQLAlchemy async e usado pelo backend.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: data
- Fontes: `backend/alembic/`, `backend/src/infrastructure/database.py`, `backend/src/infrastructure/models.py`, `docs/backup/database.md`, `ai_service/database.py`
- Tecnologias: PostgreSQL 16, pgvector, SQLAlchemy, Alembic, psycopg

## Keywords

- dados
- banco
- database
- postgresql
- pgvector
- vector-store
- embeddings
- sqlalchemy
- alembic
- migrations
- seed
- knowledge-base-chunks
- mcp-action-logs
- rag-logs
- asyncpg
- psycopg

## Contexto

Manter dados relacionais e vetoriais no mesmo PostgreSQL simplifica a topologia local e evita introduzir um vector store separado. O backend usa SQLAlchemy/Alembic; o AI service usa acesso direto para RAG e historico.

## Detalhamento tecnico

Arquivos relevantes:

- `backend/alembic/env.py`: configura Alembic com metadata central.
- `backend/alembic/versions/001_create_pgvector.py`: habilita pgvector.
- `backend/alembic/versions/006_create_chat_knowledge_tables.py`: cria estruturas de chat e conhecimento.
- `backend/src/infrastructure/database.py`: conexao SQLAlchemy async.
- `backend/src/infrastructure/models.py`: importa modelos para migrations.
- `ai_service/database.py`: pool e historico de chat para IA.
- `ai_service/rag.py`: consultas vetoriais.
- `ai_service/ingest.py`: ingestao de documentos Markdown para `knowledge_base_chunks`.

## Fluxo / Arquitetura

```text
Alembic -> cria schema e extensao pgvector
Seed -> popula dados de desenvolvimento
Backend -> usa SQLAlchemy async
AI Service -> usa psycopg/pool para RAG e historico
MCP Server -> usa asyncpg para resolver sessao e logar ferramentas
```

## Interfaces e dependencias

- `DATABASE_URL` configura conexao dos servicos.
- O compose usa imagem PostgreSQL com pgvector.
- Scripts de seed rodam dentro do container `fastapi-app`.
- O RAG depende de embeddings com dimensao compatvel com a coluna `vector(1536)`.

## Exemplos

Aplicar migrations e popular dados:

```bash
docker compose exec fastapi-app alembic upgrade head
docker compose exec fastapi-app python -m scripts.seed
```

## Links relacionados

- [Modelo academico](modelo-academico.md)
- [Base de conhecimento RAG](base-conhecimento-rag.md)
- [Infraestrutura local](infraestrutura-local.md)
- [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md)
- [Estudo - PostgreSQL e pgvector](../study-guides/estudo-postgresql-pgvector.md)
