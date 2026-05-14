# Processos e Testes
<!--
TYPE: knowledge-page
SCOPE: process
KEYWORDS: processos, gsd, testes, pytest, flutter-test, flutter-analyze, verification, code-review, planning, roadmap, state, quality
-->
[TOC]

## Resumo rapido

O projeto usa artefatos GSD em `.planning/` para roadmap, planos, revisoes e verificacoes. A qualidade e validada com pytest nos servicos Python e `flutter analyze`/`flutter test` no app.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: process
- Fontes: `.planning/`, `backend/tests/`, `ai_service/tests/`, `mcp_server/tests/`, `mobile/test/`, `AGENTS.md`
- Objetivo: orientar manutencao e verificacao

## Keywords

- processos
- process
- gsd
- planning
- roadmap
- state
- testes
- tests
- pytest
- flutter-test
- flutter-analyze
- verification
- code-review
- quality
- ci-local

## Contexto

O repositorio contem planejamento incremental por fases e quick tasks. Esses artefatos ajudam a entender o estado do projeto, decisoes recentes e requisitos de cada entrega.

## Detalhamento tecnico

Fontes de processo:

- `.planning/ROADMAP.md`: roadmap e fases.
- `.planning/STATE.md`: estado atual.
- `.planning/REQUIREMENTS.md`: requisitos.
- `.planning/phases/`: planos, summaries, reviews e verificacoes por fase.
- `.planning/quick/`: tarefas pontuais planejadas.
- `AGENTS.md`: convencoes do projeto e workflow GSD.

Testes por area:

- Backend: `backend/tests/` com pytest.
- AI service: `ai_service/tests/` com pytest.
- MCP server: `mcp_server/tests/` com pytest.
- Mobile: `mobile/test/` com Flutter test.

## Fluxo / Arquitetura

```text
Requisito -> plano GSD -> implementacao -> testes -> review -> verificacao -> atualizacao de estado
```

## Interfaces e dependencias

- Antes de editar codigo, o workflow do projeto pede uso de comando GSD apropriado.
- Commits nao devem incluir secrets como `.env`.
- Verificacoes devem ser reportadas com comando executado e resultado observado.

## Exemplos

Comandos de verificacao por area:

```bash
python -m pytest backend/tests
python -m pytest ai_service/tests
python -m pytest mcp_server/tests
cd mobile && flutter analyze && flutter test
```

## Links relacionados

- [Visao geral do projeto](visao-geral-projeto.md)
- [Infraestrutura local](infraestrutura-local.md)
- [Backend FastAPI](backend-fastapi.md)
- [Mobile Flutter](mobile-flutter.md)
- [Estudo - Docker, testes e operacao local](../study-guides/estudo-docker-testes-operacao.md)
