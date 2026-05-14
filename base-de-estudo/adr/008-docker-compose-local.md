# ADR 008 - Docker Compose para Ambiente Local
<!--
TYPE: adr
SCOPE: infra
KEYWORDS: adr, docker, docker-compose, infraestrutura, local-dev, fastapi-app, langchain-service, mcp-server, postgres, pgvector, flutter-web, healthcheck
-->
[TOC]

## Resumo rapido

O ambiente local usa Docker Compose para executar API, AI Service, MCP Server e PostgreSQL/pgvector. Isso padroniza dependencias e reduz setup manual.

## Keywords

- adr
- docker
- docker-compose
- infraestrutura
- infra
- local-dev
- fastapi-app
- langchain-service
- mcp-server
- postgres
- pgvector
- flutter-web
- healthcheck
- env-vars

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `README.md`, `docker-compose.yml`, `AGENTS.md`, `.planning/research/STACK.md`

## Contexto

O projeto combina Python, Flutter, PostgreSQL/pgvector, LangChain e MCP. Executar manualmente todos os servicos aumenta risco de divergencia local.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Docker Compose | Ambiente reprodutivel; sobe servicos juntos | Cold start e healthchecks exigem espera |
| Instalar tudo localmente | Pode ser mais rapido para debugging pontual | Setup fragil e dependente da maquina |
| Kubernetes local | Proximo de producao complexa | Excesso de complexidade para MVP |

## Decisao

Usar Docker Compose para orquestrar `fastapi-app`, `langchain-service`, `mcp-server`, `postgres` e `flutter-web`, com variaveis de ambiente e healthchecks.

## Consequencias

- Positivas: onboarding local mais previsivel.
- Positivas: PostgreSQL com pgvector fica padronizado.
- Negativas: logs e falhas iniciais podem exigir aguardar estabilizacao.
- Negativas: o app Flutter ainda pode rodar fora do Compose durante desenvolvimento.

## Links relacionados

- [Infraestrutura local](../knowledge/infraestrutura-local.md)
- [Visao geral do projeto](../knowledge/visao-geral-projeto.md)
- [Dados e banco](../knowledge/dados-banco.md)
- [Estudo - Docker, testes e operacao local](../study-guides/estudo-docker-testes-operacao.md)
