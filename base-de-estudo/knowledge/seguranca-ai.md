# Seguranca da IA
<!--
TYPE: knowledge-page
SCOPE: rag
KEYWORDS: seguranca-ai, segurança-ai, ai-security, prompt-injection, output-filter, input-sanitizer, system-prompt, data-leakage, tool-leakage, student-id, idor, canary-token
-->
[TOC]

## Resumo rapido

A seguranca da IA combina separacao de contexto, sanitizacao de entrada, filtro de saida, prompt de sistema restritivo e MCP como fronteira para acoes. O objetivo e impedir vazamento de internals e proteger dados de alunos.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: rag
- Fontes: `ai_service/security/input_sanitizer.py`, `ai_service/security/output_filter.py`, `ai_service/prompts/system_prompt.txt`, `mcp_server/dependencies.py`, `mcp_server/middleware.py`
- Riscos cobertos: prompt injection, vazamento de ferramentas, IDOR, exposicao de internals

## Keywords

- seguranca-ai
- segurança-ai
- ai-security
- prompt-injection
- jailbreak
- input-sanitizer
- output-filter
- system-prompt
- data-leakage
- tool-leakage
- api-leakage
- student-id
- idor
- canary-token
- mcp-boundary

## Contexto

Um chatbot academico tem acesso potencial a dados sensiveis e acoes reais. A arquitetura evita confiar no LLM para identidade, autorizacao ou escolha de aluno.

## Detalhamento tecnico

Controles principais:

- `student_id` nunca aparece em schemas de tools expostos ao agente.
- `x-chat-session-id` identifica a sessao; MCP resolve aluno internamente.
- Input sanitizer remove/detecta padroes de prompt injection.
- Output filter bloqueia mencoes a canary token, prompt de sistema, nomes internos de tools, URLs de API, tabelas de banco e detalhes de arquitetura.
- System prompt proibe inventar dados e revelar internals.
- Backend aplica ownership e roles independentemente do agente.

## Fluxo / Arquitetura

```text
Mensagem recebida
  -> input_sanitizer
  -> agente LangChain com system prompt
  -> RAG/MCP se necessario
  -> output_filter
  -> resposta ao aluno
```

## Interfaces e dependencias

- `MCP_SERVICE_TOKEN` deve ser variavel de ambiente.
- O app usa JWT; chamadas internas usam service token.
- O MCP registra logs sem `student_id` em `input_params`.
- Rotas backend tambem validam ownership, criando defesa em profundidade.

## Exemplos

Exemplo de conteudo que deve ser bloqueado na resposta final:

```text
"A ferramenta interna get_grades chamou http://fastapi-app:8000/students/..."
```

O aluno deve receber apenas a resposta academica, nao detalhes internos.

## Links relacionados

- [AI Service e RAG](ai-service-rag.md)
- [MCP Server](mcp-server.md)
- [Autenticacao e autorizacao](autenticacao-autorizacao.md)
- [ADR 002 - MCP injeta student_id e oculta do agente](../adr/002-mcp-injeta-student-id.md)
- [Estudo - Seguranca e autenticacao](../study-guides/estudo-seguranca-autenticacao.md)
