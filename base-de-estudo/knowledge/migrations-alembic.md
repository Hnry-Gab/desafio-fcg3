# Migrations e Alembic
<!--
TYPE: knowledge-page
SCOPE: data
KEYWORDS: alembic, migrations, postgresql, sqlalchemy, metadata, models, pgvector, schema, seed, banco, apresentação
-->
[TOC]

## Resumo rapido

Alembic versiona o schema do banco. O backend importa os modelos em um registry central para que migrations conheçam tabelas de auth, alunos, cursos, chat, RAG, MCP logs e notificacoes.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: data
- Fontes: `backend/alembic/`, `backend/src/infrastructure/models.py`, `backend/src/features/*/models.py`, `docker-compose.yml`

## Keywords

- alembic
- migrations
- postgresql
- sqlalchemy
- metadata
- models
- pgvector
- schema
- seed
- banco
- apresentação

## Contexto

Perguntas comuns: "como o schema e criado?", "onde fica pgvector?", "como o Alembic descobre models?" e "migrations rodam automaticamente?".

## Detalhamento tecnico

- `backend/alembic/env.py` configura o ambiente de migration.
- `backend/src/infrastructure/models.py` importa modelos para metadata central.
- Migrations criam extensao pgvector, tabelas academicas, chat, knowledge base e logs.
- A stack Docker atual tambem executa migration/seed no comando do `fastapi-app`.
- O README preserva comandos manuais para controle operacional.

## Fluxo / Arquitetura

```text
Models SQLAlchemy -> infrastructure/models.py -> Alembic metadata -> migrations -> PostgreSQL
```

## Perguntas de apresentacao

### Como Alembic sabe quais tabelas existem?

Resposta: por metadata SQLAlchemy. O projeto centraliza imports em `backend/src/infrastructure/models.py` para que Alembic enxergue os models das features.

### Por que pgvector fica no mesmo banco?

Resposta: para reduzir infraestrutura no MVP e manter dados relacionais e vetoriais sob o mesmo PostgreSQL.

### Migrations rodam automatico ou manual?

Resposta: o README documenta comando manual; o `docker-compose.yml` atual tambem executa migration/seed no bootstrap do container da API. Em apresentacao, explique que o manual serve para operacao controlada e o compose para conveniencia local.

## Limites e riscos

- Rollback precisa ser avaliado por migration; nem toda mudanca de dados e reversivel automaticamente.
- Seed deve ser separado de dados reais de producao.
- Mudanca de dimensao de embedding exige migration de coluna vetorial e reingestao.

## Links relacionados

- [Dados e banco](dados-banco.md)
- [Modelo academico](modelo-academico.md)
- [Base de conhecimento RAG](base-conhecimento-rag.md)
- [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md)
