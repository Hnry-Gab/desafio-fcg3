# MCP Sessoes e Verificacao
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: mcp, sessão, sessao, verificacao, verificação, x-chat-session-id, student-id, idor, readOnlyHint, tool-calling, verified, unverified
-->
[TOC]

## Resumo rapido

Toda tool MCP depende de `x-chat-session-id`. O MCP valida que a sessao esta ativa, resolve `student_id` internamente e bloqueia tools mutantes quando a sessao ainda nao esta verificada.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `mcp_server/dependencies.py`, `mcp_server/middleware.py`, `mcp_server/tools/*.py`, `mcp_server/tests/test_session_resolver.py`, `mcp_server/tests/test_tool_schemas.py`

## Keywords

- mcp
- sessão
- sessao
- verificacao
- verificação
- x-chat-session-id
- student-id
- idor
- readOnlyHint
- tool-calling
- verified
- unverified

## Contexto

O agente LangChain nao deve decidir identidade do aluno. A sessao de chat e o elo entre conversa WhatsApp e aluno autenticado/verificado.

## Detalhamento tecnico

### Header obrigatorio

```http
x-chat-session-id: {uuid-da-chat-session}
```

O header e exigido tambem para tools read-only, porque todas as tools sao escopadas por aluno ou passam `X-Student-Id` ao backend por consistencia.

### Resolucao de aluno

O MCP valida:

- se o header existe;
- se e UUID valido;
- se a sessao existe;
- se `status = 'active'`;
- qual e o `student_id` associado;
- qual e o `verification_state`.

### Regra verified/unverified

| Estado | Tools permitidas |
|---|---|
| `verified` | Todas as tools |
| diferente de `verified` | Apenas tools com `readOnlyHint=True` |

### Tools mutantes

- `create_enrollment`
- `confirm_enrollment`
- `drop_course`
- `lock_enrollment`
- `request_document`
- `book_appointment`
- `cancel_appointment`

## Fluxo / Arquitetura

```text
Agent -> MCP tool call
MCP middleware -> le x-chat-session-id
MCP dependencies -> valida chat_sessions ativa
MCP -> resolve student_id e verification_state
Middleware -> bloqueia mutacao se nao verificado
Tool -> chama backend com X-Student-Id
```

## Perguntas de apresentacao

### Quem envia `x-chat-session-id`?

Resposta: o AI Service carrega as MCP tools com o contexto da sessao de chat; o agente usa tools nesse contexto, sem receber `student_id`.

### Uma tool read-only precisa de sessao?

Resposta: sim. Mesmo leitura e vinculada ao contexto do aluno ou ao contrato de chamada interna, entao sem sessao ativa a tool falha fechada.

### O que acontece se a sessao nao estiver verificada?

Resposta: tools read-only passam; tools mutantes retornam erro pedindo verificacao de identidade por email institucional.

## Limites e riscos

- Se a sessao expirar ou fechar, tools deixam de executar.
- Se a verificacao estiver incorreta, o usuario pode ficar bloqueado para acoes mutantes.
- A UI/conversa precisa orientar o aluno a verificar identidade quando necessario.

## Links relacionados

- [MCP Server](mcp-server.md)
- [Ferramentas MCP](ferramentas-mcp.md)
- [MCP auditoria e retry](mcp-auditoria-retry.md)
- [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md)
