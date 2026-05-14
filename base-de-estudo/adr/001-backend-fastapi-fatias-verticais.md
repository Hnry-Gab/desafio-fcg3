# ADR 001 - Backend FastAPI em Fatias Verticais
<!--
TYPE: adr
SCOPE: backend
KEYWORDS: adr, fastapi, backend, vertical-slices, features, sqlalchemy, alembic, api-rest, python, arquitetura
-->
[TOC]

## Resumo rapido

O backend usa FastAPI e organiza dominios em fatias verticais sob `backend/src/features/`. Essa decisao concentra modelos, controllers, schemas e services por dominio, reduzindo acoplamento entre features academicas.

## Keywords

- adr
- fastapi
- backend
- vertical-slices
- feature-slices
- arquitetura
- architecture
- sqlalchemy
- alembic
- api-rest
- python
- academic-platform

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `AGENTS.md`, `docs/backup/architecture.md`, `backend/src/features/`, `backend/src/routes.py`

## Contexto

O backend precisa evoluir modulos academicos diferentes: autenticacao, alunos, cursos, matriculas, documentos, agendamentos, chat, notificacoes e staff. Uma estrutura por camada global poderia espalhar regras de um mesmo dominio por muitos diretorios.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Fatias verticais por feature | Facilita localizar regra por dominio; reduz acoplamento; combina bem com rotas FastAPI | Pode duplicar pequenos padroes entre features |
| Camadas globais por tipo | Familiar para muitos times; separa models/services/controllers | Espalha mudancas de uma feature por varias pastas |
| Monolito simples em poucos arquivos | Rapido no inicio | Dificil de manter com muitos dominios |

## Decisao

Adotar FastAPI com organizacao por fatias verticais em `backend/src/features/`, agregando rotas em `backend/src/routes.py` e compartilhando infraestrutura em `backend/src/infrastructure/` e utilitarios em `backend/src/shared/`.

## Consequencias

- Positivas: modulos academicos ficam mais navegaveis; testes podem focar dominios; novos endpoints seguem padrao existente.
- Positivas: infraestrutura comum continua centralizada sem misturar regras de negocio.
- Negativas: padroes repetidos podem surgir entre features e devem ser extraidos apenas quando houver reutilizacao real.
- Negativas: exige disciplina para nao colocar regra de negocio em `shared/` sem necessidade.

## Links relacionados

- [Backend FastAPI](../knowledge/backend-fastapi.md)
- [Modulos academicos](../knowledge/modulos-academicos.md)
- [API REST e contratos](../knowledge/api-rest-contratos.md)
- [Estudo - Backend FastAPI](../study-guides/estudo-backend-fastapi.md)
