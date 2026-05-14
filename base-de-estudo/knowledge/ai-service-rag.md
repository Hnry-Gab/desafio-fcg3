# AI Service e RAG
<!--
TYPE: knowledge-page
SCOPE: rag
KEYWORDS: ai-service, langchain, rag, retrieval-augmented-generation, llm, openai, gemini, openrouter, embeddings, pgvector, agente-react, chatbot
-->
[TOC]

## Resumo rapido

O AI Service processa mensagens do WhatsApp com LangChain, consulta a base RAG em PostgreSQL/pgvector e chama ferramentas MCP quando precisa executar acoes academicas. Ele e agnostico de provider de LLM e aplica sanitizacao de entrada e filtros de saida.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: rag
- Fontes: `ai_service/main.py`, `ai_service/agent.py`, `ai_service/rag.py`, `ai_service/ingest.py`, `ai_service/llm_factory.py`, `ai_service/embedding_factory.py`
- Servico: `langchain-service` em `:8001`

## Keywords

- ai-service
- langchain
- rag
- retrieval-augmented-generation
- llm
- provider-agnostic
- openai
- gemini
- openrouter
- embeddings
- pgvector
- agente-react
- react-agent
- chatbot
- whatsapp
- mcp-tools

## Contexto

O chatbot precisa responder perguntas sobre regras academicas e executar acoes. O RAG evita depender apenas do conhecimento do modelo, enquanto o MCP permite acoes controladas sem expor dados sensiveis diretamente ao agente.

## Detalhamento tecnico

Arquivos centrais:

- `ai_service/main.py`: FastAPI, `/health`, `/chat` protegido por `X-Service-Token`.
- `ai_service/agent.py`: cria agente por request, carrega historico, liga MCP tools e RAG.
- `ai_service/rag.py`: ferramenta de busca vetorial em `knowledge_base_chunks`.
- `ai_service/ingest.py`: ingestao de Markdown em chunks e embeddings.
- `ai_service/mcp_tools.py`: carrega ferramentas MCP com `X-Chat-Session-ID`.
- `ai_service/llm_factory.py`: cria modelos OpenAI, Gemini ou OpenRouter.
- `ai_service/embedding_factory.py`: cria embeddings OpenAI/OpenRouter.
- `ai_service/security/`: sanitizacao de prompt e filtro de saida.

## Fluxo / Arquitetura

```text
Backend -> POST /chat no AI Service
AI Service -> sanitiza mensagem
AI Service -> carrega historico recente do chat
AI Service -> agente LangChain decide entre responder, buscar RAG ou chamar MCP
RAG -> consulta knowledge_base_chunks via pgvector
MCP -> executa acao academica via backend
AI Service -> filtra saida e retorna resposta
```

## Interfaces e dependencias

- Entrada principal: `POST /chat` com service token.
- MCP tools: carregadas via `mcp_server` e associadas a `x-chat-session-id`.
- Banco: usado para historico e RAG.
- Providers: `LLM_PROVIDER` aceita OpenAI, Gemini e OpenRouter; embeddings usam `EMBEDDING_PROVIDER`.

## Exemplos

Ingestao da base RAG:

```bash
python -m ai_service.ingest --source ai_service/knowledge --chunk-size 500 --overlap 50
```

Testes relevantes:

```bash
python -m pytest ai_service/tests
python -m pytest ai_service/tests/test_rag_retrieval.py
python -m pytest ai_service/tests/test_ingest.py
```

## Links relacionados

- [Base de conhecimento RAG](base-conhecimento-rag.md)
- [Custos e escala do RAG](rag-cost-scaling.md)
- [Qualidade do RAG](rag-quality-evaluation.md)
- [Chatbot WhatsApp](chatbot-whatsapp.md)
- [MCP Server](mcp-server.md)
- [Seguranca da IA](seguranca-ai.md)
- [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md)
- [ADR 005 - LLM provider-agnostic](../adr/005-llm-provider-agnostic.md)
- [Estudo - RAG e LangChain](../study-guides/estudo-rag-langchain.md)
