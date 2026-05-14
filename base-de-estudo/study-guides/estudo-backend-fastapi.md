# Estudo - Backend FastAPI
<!--
TYPE: study-guide
SCOPE: backend
KEYWORDS: guia-de-estudo, tutorial, fastapi, backend, api-rest, sqlalchemy, alembic, pytest, autenticacao, features
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve conseguir navegar no backend FastAPI, localizar uma feature, entender dependencias de autenticacao e rodar os testes Python relevantes.

## Metadados

- Tipo: guia de estudo
- Escopo: backend
- Nivel: intermediario
- Tempo sugerido: 3 a 5 horas

## Keywords

- guia-de-estudo
- tutorial
- backend
- fastapi
- api-rest
- sqlalchemy
- alembic
- pytest
- vertical-slices
- autenticacao
- authorization
- features
- controllers
- services

## Pre-requisitos

- Python intermediario.
- Nocoes de async/await.
- Conceitos de REST e SQL.

## Explicacao teorica

FastAPI permite definir rotas tipadas e dependencias declarativas. SQLAlchemy async cuida da persistencia e Alembic versiona o schema. Em projetos por feature, cada dominio agrupa seus componentes.

## Como se aplica a este projeto

- `backend/src/main.py` cria o app.
- `backend/src/routes.py` registra routers.
- `backend/src/features/` contem dominios.
- `backend/src/shared/` contem auth, exceptions, responses e dependencias.
- `backend/alembic/` versiona banco.
- `backend/tests/` valida unidades, middleware e features.

## Roteiro de estudo sugerido

1. Leia [Backend FastAPI](../knowledge/backend-fastapi.md).
2. Leia [API REST e contratos](../knowledge/api-rest-contratos.md).
3. Abra `backend/src/routes.py` e liste os routers.
4. Abra uma feature simples, como `backend/src/features/courses/`.
5. Abra uma feature com regras, como `backend/src/features/enrollment/`.
6. Leia [Autenticacao e autorizacao](../knowledge/autenticacao-autorizacao.md).
7. Rode testes do backend quando o ambiente estiver pronto.

## Exercicios / atividades sugeridas

- Localize o endpoint de `GET /students/{student_id}/grades`.
- Explique como uma rota diferencia JWT de service token.
- Siga uma migration Alembic que cria tabelas de chat/RAG.

## Referencias internas

- [Backend FastAPI](../knowledge/backend-fastapi.md)
- [Modulos academicos](../knowledge/modulos-academicos.md)
- [Dados e banco](../knowledge/dados-banco.md)
- [ADR 001 - Backend FastAPI em fatias verticais](../adr/001-backend-fastapi-fatias-verticais.md)

## Referencias externas

- [FastAPI documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy asyncio](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html)
- [Alembic documentation](https://alembic.sqlalchemy.org/)
- [pytest documentation](https://docs.pytest.org/)

## Links relacionados

- [Estudo - Seguranca e autenticacao](estudo-seguranca-autenticacao.md)
- [Estudo - PostgreSQL e pgvector](estudo-postgresql-pgvector.md)
