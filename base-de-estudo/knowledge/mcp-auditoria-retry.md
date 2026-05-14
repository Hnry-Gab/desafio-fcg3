# MCP Auditoria e Retry
<!--
TYPE: knowledge-page
SCOPE: backend
KEYWORDS: mcp, auditoria, audit-log, retry, retry-success, mcp-action-logs, latency, status, input-params, reasoning, service-token
-->
[TOC]

## Resumo rapido

O MCP registra cada chamada de tool em `mcp_action_logs` e aplica uma unica retentativa para falhas transientes na chamada ao backend. Isso cria rastreabilidade para acoes executadas pelo agente.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: backend
- Fontes: `mcp_server/middleware.py`, `mcp_server/api_client.py`, `mcp_server/tests/test_middleware_logging.py`, `mcp_server/tests/test_api_client.py`

## Keywords

- mcp
- auditoria
- audit-log
- retry
- retry-success
- mcp-action-logs
- latency
- status
- input-params
- reasoning
- service-token

## Contexto

Como o agente executa acoes reais, a equipe precisa responder quem chamou qual ferramenta, com quais parametros, resultado, latencia e se houve retry.

## Detalhamento tecnico

### Campos logados

| Campo | Significado |
|---|---|
| `chat_session_id` | Sessao de chat associada |
| `tool_name` | Nome da tool chamada |
| `input_params` | Parametros sanitizados, sem `student_id` |
| `output_result` | Resultado serializado |
| `reasoning` | Atualmente gravado como `None` |
| `latency_ms` | Tempo da chamada |
| `retry` | Se houve retry no API client |
| `status` | `success`, `error` ou `retry_success` |

### Retry

- Implementado no `mcp_server/api_client.py`.
- Erros 4xx nao sao retentados.
- Erros 5xx, timeout e request errors recebem uma retentativa imediata.
- Se a segunda tentativa funcionar, o middleware registra `status = retry_success`.

### Falha fechada

O middleware depende de sessao valida e DB pool. Falhas de validacao ou auditoria podem bloquear a execucao, o que favorece rastreabilidade sobre execucao silenciosa.

## Fluxo / Arquitetura

```text
Tool call -> middleware inicia timer
Tool -> api_client chama FastAPI
api_client -> retry se 5xx/timeout
middleware -> serializa resultado
middleware -> INSERT em mcp_action_logs
```

## Perguntas de apresentacao

### Voces logam chain-of-thought do modelo?

Resposta: nao. O campo `reasoning` existe no schema/log, mas no codigo atual e gravado como `None`. Isso evita prometer captura de raciocinio interno do modelo.

### O `student_id` aparece nos logs?

Resposta: nao em `input_params`; o middleware remove `student_id`. O log referencia a `chat_session_id`.

### Quando ocorre retry?

Resposta: apenas para falhas transientes como 5xx ou timeout. Erros 4xx indicam problema de regra/contrato e nao sao retentados.

## Limites e riscos

- Auditoria depende do banco estar disponivel.
- O log mostra chamada e resultado, mas nao deve armazenar segredos.
- O campo `reasoning` nao deve ser apresentado como ativo.

## Links relacionados

- [MCP Server](mcp-server.md)
- [MCP sessoes e verificacao](mcp-sessoes-verificacao.md)
- [Ferramentas MCP](ferramentas-mcp.md)
- [Seguranca da IA](seguranca-ai.md)
