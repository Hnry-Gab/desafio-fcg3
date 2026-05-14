# Estudo - MCP no Projeto
<!--
TYPE: study-guide
SCOPE: backend
KEYWORDS: guia-de-estudo, tutorial, mcp, model-context-protocol, fastmcp, tool-calling, student-id, idor, service-token, audit-log
-->
[TOC]

## Resumo rapido

Ao final deste guia, voce deve entender por que o MCP existe, como ele protege `student_id`, como ferramentas viram chamadas REST e como os logs de auditoria sao gravados.

## Metadados

- Tipo: guia de estudo
- Escopo: backend
- Nivel: intermediario
- Tempo sugerido: 3 a 5 horas

## Keywords

- guia-de-estudo
- tutorial
- mcp
- model-context-protocol
- fastmcp
- tool-calling
- student-id
- idor
- service-token
- audit-log
- mcp-action-logs
- langchain-tools

## Pre-requisitos

- Entender APIs REST.
- Nocoes de LLM tool calling.
- Conceitos basicos de autorizacao e IDOR.

## Explicacao teorica

MCP padroniza como modelos acessam ferramentas externas. Em sistemas sensiveis, ferramentas devem esconder identidade e autorizacao do LLM. O modelo informa a intencao e parametros permitidos; o servidor de ferramentas aplica contexto seguro.

## Como se aplica a este projeto

- `mcp_server/main.py` registra tools.
- `mcp_server/dependencies.py` resolve `student_id` por sessao.
- `mcp_server/api_client.py` chama backend.
- `mcp_server/middleware.py` loga calls e bloqueia mutacoes sem verificacao.
- `mcp_server/tests/test_tool_schemas.py` verifica que `student_id` nao aparece.

## Roteiro de estudo sugerido

1. Leia [MCP Server](../knowledge/mcp-server.md).
2. Leia [Ferramentas MCP](../knowledge/ferramentas-mcp.md).
3. Abra `mcp_server/tools/grade_tools.py`.
4. Abra `mcp_server/dependencies.py`.
5. Abra `mcp_server/middleware.py`.
6. Leia [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md).

## Exercicios / atividades sugeridas

- Explique por que `get_grades` nao recebe `student_id`.
- Siga `book_appointment` ate o endpoint backend correspondente.
- Rode `python -m pytest mcp_server/tests/test_tool_schemas.py`.

## Referencias internas

- [MCP Server](../knowledge/mcp-server.md)
- [Ferramentas MCP](../knowledge/ferramentas-mcp.md)
- [Seguranca da IA](../knowledge/seguranca-ai.md)

## Referencias externas

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [FastMCP documentation](https://gofastmcp.com/)

## Links relacionados

- [Estudo - Seguranca e autenticacao](estudo-seguranca-autenticacao.md)
- [Estudo - RAG e LangChain](estudo-rag-langchain.md)
