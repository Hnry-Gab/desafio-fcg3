# Backend FastAPI
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: backend, fastapi, api-rest, vertical-slices, sqlalchemy, alembic, auth, webhook, fcm, features, python, pytest
-->
[TOC]

## Resumo rapido

O backend FastAPI centraliza regras academicas, autenticacao, APIs REST, webhook WhatsApp, persistencia e notificacoes. Ele e o limite confiavel do sistema: app, MCP e webhook passam por ele para acessar dados e executar regras.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `backend/src/main.py`, `backend/src/features/`, `backend/tests/`, `docs/backup/api.md`
- Framework: FastAPI com SQLAlchemy async e Alembic

## Keywords

- backend
- fastapi
- api-rest
- rest-api
- vertical-slices
- sqlalchemy
- alembic
- async-python
- python-3.12
- pytest
- webhook
- whatsapp
- fcm
- service-token

## Contexto

O backend atende tres consumidores principais: o app Flutter com JWT, o MCP Server com `X-Service-Token` e o webhook da WhatsApp Cloud API. Por isso, ele concentra validacao, ownership, status de entidades e integracao com banco.

## Detalhamento tecnico

Arquivos centrais:

- `backend/src/main.py`: cria a aplicacao, registra rotas, healthcheck, handlers de erro e arquivos estaticos.
- `backend/src/main.py`: registra routers diretamente sob `/api/v1`.
- `backend/src/infrastructure/config.py`: configuracoes por variavel de ambiente.
- `backend/src/infrastructure/database.py`: engine e sessoes SQLAlchemy async.
- `backend/src/infrastructure/models.py`: registry central de modelos usado pelo Alembic.
- `backend/src/shared/auth.py`: validacao JWT e papeis.
- `backend/src/shared/dependencies.py`: dependencias de usuario atual, service token e ownership.
- `backend/src/shared/exceptions.py`: erros padronizados.

## Fluxo / Arquitetura

```text
FastAPI app
  -> routers /api/v1
  -> dependencies shared/auth
  -> feature controllers/services
  -> SQLAlchemy async session
  -> PostgreSQL
```

As features seguem uma organizacao por fatias verticais em `backend/src/features/`, mantendo modelos, controllers, services e schemas proximos do dominio.

## Interfaces e dependencias

- App Flutter: usa `Authorization: Bearer {token}`.
- MCP Server: usa `X-Service-Token` e `X-Student-Id` em endpoints internos.
- WhatsApp: chama `GET/POST /api/v1/webhook/whatsapp` no backend FastAPI.
- Banco: PostgreSQL 16 com pgvector.
- Email OTP: Resend como provider planejado/evidenciado nas restricoes do projeto.
- Notificacoes: Firebase Cloud Messaging.

## Exemplos

Comandos de operacao documentados:

```bash
docker compose exec fastapi-app alembic upgrade head
docker compose exec fastapi-app python -m scripts.seed
```

Comandos de teste do backend:

```bash
cd backend
pytest
pytest --cov=src --cov-report=html
```

## Links relacionados

- [API REST e contratos](api-rest-contratos.md)
- [Contratos API por modulo](contratos-api-por-modulo.md)
- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [Auth OTP/JWT detalhado](auth-otp-jwt-detalhado.md)
- [Modulos academicos](modulos-academicos.md)
- [Webhook WhatsApp tecnico](webhook-whatsapp-tecnico.md)
- [Migrations e Alembic](migrations-alembic.md)
- [Dados e banco](dados-banco.md)
- [Chatbot WhatsApp](chatbot-whatsapp.md)
- [Notificacoes FCM](notificacoes-fcm.md)
- [ADR 001 - Backend FastAPI em fatias verticais](../adr/001-backend-fastapi-fatias-verticais.md)
- [Estudo - Backend FastAPI](../study-guides/estudo-backend-fastapi.md)
