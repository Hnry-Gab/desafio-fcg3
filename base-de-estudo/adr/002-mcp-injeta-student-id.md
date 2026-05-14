# ADR 002 - MCP Injeta student_id e Oculta do Agente
<!--
TYPE: adr
SCOPE: mixed
KEYWORDS: adr, mcp, student-id, idor, seguranca, ai-security, langchain, tool-calling, x-chat-session-id, x-service-token
-->
[TOC]

## Resumo rapido

O `student_id` nunca e exposto ao agente LangChain. O MCP Server resolve o aluno por `x-chat-session-id`, injeta o contexto internamente e chama a API com service token.

## Keywords

- adr
- mcp
- model-context-protocol
- student-id
- idor
- seguranca
- security
- ai-security
- langchain
- tool-calling
- x-chat-session-id
- x-service-token
- service-token

## Metadados

- Status: aceito
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `AGENTS.md`, `docs/backup/mcp.md`, `mcp_server/dependencies.py`, `mcp_server/tests/test_tool_schemas.py`

## Contexto

Ferramentas de IA executam acoes reais sobre dados de alunos. Se o agente recebesse `student_id`, poderia tentar acessar ou manipular dados de outro aluno, intencionalmente ou por erro de prompt.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Expor `student_id` ao agente | Simples de implementar | Alto risco de IDOR; modelo controla identidade |
| Injetar `student_id` no MCP | Protege identidade; tool schema fica seguro; backend ainda valida ownership | Exige resolver sessao no MCP |
| Fazer a IA chamar backend diretamente | Menos um servico | Remove fronteira de seguranca e auditoria MCP |

## Decisao

O MCP Server recebe apenas `x-chat-session-id`, resolve a sessao ativa no banco, injeta `student_id` internamente e remove `student_id` dos schemas e logs de input expostos ao agente.

## Consequencias

- Positivas: reduz risco de IDOR e de manipulacao de identidade pelo LLM.
- Positivas: ferramentas ficam mais simples para o agente e mais auditaveis.
- Positivas: backend continua aplicando controles de ownership como defesa em profundidade.
- Negativas: MCP depende de banco e estado de chat ativo.
- Negativas: erros de sessao podem bloquear tools mesmo se a intencao do usuario estiver correta.

## Links relacionados

- [MCP Server](../knowledge/mcp-server.md)
- [Ferramentas MCP](../knowledge/ferramentas-mcp.md)
- [Seguranca da IA](../knowledge/seguranca-ai.md)
- [Autenticacao e autorizacao](../knowledge/autenticacao-autorizacao.md)
- [Estudo - MCP no projeto](../study-guides/estudo-mcp-projeto.md)
