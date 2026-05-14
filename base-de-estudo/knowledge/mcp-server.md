# MCP Server
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: mcp-server, model-context-protocol, fastmcp, tool-calling, student-id, x-chat-session-id, x-service-token, auditoria, retry, mcp-action-logs
-->
[TOC]

## Resumo rapido

O MCP Server expoe ferramentas academicas para o agente LangChain e atua como proxy seguro para a API FastAPI. Ele resolve `student_id` a partir da sessao de chat, injeta esse contexto internamente e registra cada chamada em `mcp_action_logs`.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `mcp_server/`, `mcp_server/tests/`, `docs/backup/mcp.md`
- Servico: `mcp-server` em `:8002`

## Keywords

- mcp-server
- model-context-protocol
- fastmcp
- tool-calling
- mcp-tools
- student-id
- x-chat-session-id
- x-service-token
- service-token
- auditoria
- audit-log
- retry
- mcp-action-logs
- idor

## Contexto

O agente de IA nao deve receber nem manipular `student_id`. O MCP cria uma fronteira de seguranca: a IA escolhe uma ferramenta e fornece parametros de negocio, enquanto o servidor resolve o aluno autenticado por sessao ativa e chama o backend.

## Detalhamento tecnico

Arquivos principais:

- `mcp_server/main.py`: instancia FastMCP, registra middleware e ferramentas.
- `mcp_server/lifespan.py`: cria pool asyncpg e client HTTP para backend com `X-Service-Token`.
- `mcp_server/settings.py`: carrega `DATABASE_URL`, `FASTAPI_BASE_URL`, `MCP_SERVICE_TOKEN`.
- `mcp_server/dependencies.py`: valida `x-chat-session-id` e resolve contexto de aluno.
- `mcp_server/api_client.py`: chama backend, injeta `X-Student-Id` e aplica retry.
- `mcp_server/middleware.py`: sanitiza input, bloqueia mutacoes se sessao nao verificada e loga tool calls.
- `mcp_server/tools/`: ferramentas por dominio.

## Fluxo / Arquitetura

```text
LangChain agent -> MCP tool call com x-chat-session-id
MCP dependencies -> busca chat_session ativa
MCP -> injeta student_id internamente
MCP api_client -> FastAPI com X-Service-Token e X-Student-Id
MCP middleware -> grava mcp_action_logs
```

## Interfaces e dependencias

- Ferramentas exigem `x-chat-session-id`.
- `student_id` fica oculto do schema exposto ao LLM.
- Erros 5xx/timeouts recebem uma retentativa imediata.
- Erros 4xx nao sao retentados.
- Ferramentas mutantes exigem sessao verificada; read-only pode operar antes da verificacao.

## Exemplos

Regra de seguranca essencial:

```text
get_grades(semester_year="2026.1")
```

O agente informa apenas `semester_year`; o MCP resolve e injeta o aluno.

## Links relacionados

- [Ferramentas MCP](ferramentas-mcp.md)
- [MCP sessoes e verificacao](mcp-sessoes-verificacao.md)
- [MCP auditoria e retry](mcp-auditoria-retry.md)
- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [Chatbot WhatsApp](chatbot-whatsapp.md)
- [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md)
- [Estudo - MCP no projeto](../study-guides/estudo-mcp-projeto.md)
