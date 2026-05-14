# Perguntas Tecnicas - Knowledge Pages
<!--
TYPE: knowledge-page
SCOPE: mixed
KEYWORDS: perguntas-tecnicas, knowledge-pages, apresentação, q-and-a, rag, backend, mcp, mobile, whatsapp, fcm, banco, segurança
-->
[TOC]

## Resumo rapido

Perguntas provaveis sobre as paginas de conhecimento da base. Use este arquivo quando a pergunta for sobre funcionamento tecnico, implementacao, fluxo, dados, seguranca ou operacao.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mixed
- Pasta: `base-de-estudo-codex/knowledge/`

## Keywords

- perguntas-tecnicas
- knowledge-pages
- apresentação
- q-and-a
- rag
- backend
- mcp
- mobile
- whatsapp
- fcm
- banco
- segurança

## RAG e AI Service

### O que responder se perguntarem sobre embeddings?

Resposta curta: usamos embeddings para transformar texto academico e pergunta do aluno em vetores comparaveis por similaridade. O default atual e `text-embedding-3-small` com `vector(1536)`.

Detalhes para aprofundar:

- Embeddings sao gerados na ingestao para os documentos.
- A pergunta do aluno tambem vira embedding em tempo de consulta.
- A busca usa pgvector e retorna ate 3 chunks.
- Trocar modelo exige confirmar dimensao ou migrar schema.

Links: [AI Service e RAG](ai-service-rag.md), [Custos e escala do RAG](rag-cost-scaling.md), [Qualidade do RAG](rag-quality-evaluation.md).

### O que responder sobre custo de IA?

Resposta curta: o custo recorrente vem das chamadas LLM por mensagem; o custo de embedding ocorre principalmente quando reingerimos a base.

Detalhes para aprofundar:

- Formula basica: mensagens mensais x tokens por conversa x preco do provider.
- RAG aumenta tokens de entrada porque adiciona contexto recuperado.
- Historico de conversa tambem aumenta tokens.
- Como o provider e agnostico, preco final depende de `LLM_PROVIDER` e `LLM_MODEL`.

Links: [Custos e escala do RAG](rag-cost-scaling.md), [AI Service e RAG](ai-service-rag.md).

## Backend e API

### O que responder sobre organizacao FastAPI?

Resposta curta: o backend usa FastAPI por features em `backend/src/features/`; os routers atuais sao registrados diretamente em `backend/src/main.py` com prefixo `/api/v1`.

Detalhes para aprofundar:

- Cada feature agrupa dominio, controllers, schemas, services e models.
- `shared/` contem auth, dependencias, erros e respostas comuns.
- `infrastructure/` contem config, banco e registry de modelos.

Links: [Backend FastAPI](backend-fastapi.md), [Contratos API por modulo](contratos-api-por-modulo.md).

### O que responder sobre OTP e email?

Resposta curta: o OTP e enviado por Resend e salvo apenas como hash com salt; o codigo em texto puro nao e persistido.

Detalhes para aprofundar:

- Geracao com CSPRNG (`secrets.randbelow`).
- Salva `code_hash` e `code_salt`.
- Envia email HTML com validade configurada.
- `DEV_MASTER_OTP` existe apenas para desenvolvimento.

Links: [Auth OTP/JWT detalhado](auth-otp-jwt-detalhado.md), [Autenticacao e autorizacao](autenticacao-autorizacao.md).

## MCP e seguranca

### O que responder sobre IDOR?

Resposta curta: o agente nao recebe `student_id`; o MCP injeta a identidade a partir da sessao ativa, e o backend ainda valida ownership.

Detalhes para aprofundar:

- `x-chat-session-id` identifica a sessao.
- MCP busca `chat_sessions` ativa.
- `X-Student-Id` e enviado internamente para o backend.
- `student_id` e removido dos parametros logados.

Links: [MCP sessoes e verificacao](mcp-sessoes-verificacao.md), [MCP auditoria e retry](mcp-auditoria-retry.md).

## Mobile e infra

### O que responder sobre Flutter, Riverpod e GoRouter?

Resposta curta: Flutter entrega app mobile/web; Riverpod gerencia estado e dependencias; GoRouter aplica guards de autenticacao e papel.

Detalhes para aprofundar:

- Rotas redirecionam por estado de auth.
- Dio injeta Bearer token e renova em 401.
- Secure storage guarda tokens.
- Staff/provider e aluno usam shells separados.

Links: [Mobile architecture deep dive](mobile-architecture-deep-dive.md), [Mobile auth, Dio e secure storage](mobile-auth-dio-secure-storage.md).

## Links relacionados

- [Perguntas tecnicas globais](../perguntas-tecnicas.md)
- [Perguntas tecnicas sobre ADRs](../adr/perguntas-tecnicas.md)
- [Perguntas tecnicas dos guias](../study-guides/perguntas-tecnicas.md)
