# Estudo - Docker, Testes e Operacao Local
<!--
TYPE: study-guide
SCOPE: infra
KEYWORDS: guia-de-estudo, tutorial, docker, docker-compose, pytest, flutter-test, flutter-analyze, healthcheck, env, local-dev, operacao
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve conseguir subir a stack local, verificar saude dos servicos, rodar migrations, executar testes Python e Flutter e diagnosticar falhas basicas de ambiente.

## Metadados

- Tipo: guia de estudo
- Escopo: infra
- Nivel: pratico
- Tempo sugerido: 2 a 4 horas

## Keywords

- guia-de-estudo
- tutorial
- docker
- docker-compose
- pytest
- flutter-test
- flutter-analyze
- healthcheck
- env
- local-dev
- operacao
- database-url
- mcp-service-token

## Pre-requisitos

- Docker e Docker Compose instalados.
- Python 3.12.
- Flutter 3.41.6 para app mobile/web.
- Conhecimento basico de terminal.

## Explicacao teorica

Ambientes compostos por varios servicos precisam de orquestracao local. Healthchecks indicam disponibilidade, migrations aplicam schema e testes validam comportamento. Variaveis de ambiente separam configuracao de codigo.

## Como se aplica a este projeto

- `docker compose up --build -d` sobe backend, AI, MCP e banco.
- `alembic upgrade head` aplica migrations.
- `scripts.seed` popula dados de desenvolvimento.
- `pytest` cobre backend, AI e MCP.
- `flutter analyze` e `flutter test` cobrem app.

## Roteiro de estudo sugerido

1. Leia [Infraestrutura local](../knowledge/infraestrutura-local.md).
2. Leia `README.md`.
3. Copie `.env.example` para `.env` e preencha valores locais.
4. Suba a stack com Docker Compose.
5. Verifique `/health` nos tres servicos HTTP.
6. Rode migrations e seed.
7. Execute testes por area.

## Exercicios / atividades sugeridas

- Suba a stack e aguarde estabilizacao por ate 60 segundos antes de diagnosticar falha.
- Rode `docker compose logs -f fastapi-app` e identifique a inicializacao da API.
- Rode uma suite pequena: `python -m pytest mcp_server/tests/test_tool_schemas.py`.
- No mobile, rode `flutter analyze --no-pub` se dependencias ja estiverem instaladas.

## Referencias internas

- [Infraestrutura local](../knowledge/infraestrutura-local.md)
- [Processos e testes](../knowledge/processos-testes.md)
- [Dados e banco](../knowledge/dados-banco.md)
- [ADR 008 - Docker Compose para ambiente local](../adr/008-docker-compose-local.md)

## Referencias externas

- [Docker Compose documentation](https://docs.docker.com/compose/)
- [pytest documentation](https://docs.pytest.org/)
- [Flutter testing](https://docs.flutter.dev/testing)

## Links relacionados

- [Estudo - Arquitetura do projeto](estudo-arquitetura-projeto.md)
- [Estudo - Backend FastAPI](estudo-backend-fastapi.md)
