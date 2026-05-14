# Custos e Escala do RAG
<!--
TYPE: knowledge-page
SCOPE: rag
KEYWORDS: rag, custos, escala, cost-scaling, llm-cost, embedding-cost, tokens, openai, gemini, openrouter, pgvector, vector-store, apresentação
-->
[TOC]

## Resumo rapido

O custo do RAG cresce em duas frentes: embeddings durante ingestao e chamadas LLM durante uso. No projeto, embeddings sao custo eventual de manutencao da base; chamadas LLM sao custo recorrente por mensagem do aluno.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: rag
- Fontes: `ai_service/config.py`, `ai_service/ingest.py`, `ai_service/rag.py`, `ai_service/llm_factory.py`, `ai_service/embedding_factory.py`

## Keywords

- rag
- custos
- escala
- cost-scaling
- llm-cost
- embedding-cost
- tokens
- openai
- gemini
- openrouter
- pgvector
- vector-store
- apresentação

## Contexto

Uma pergunta comum em apresentacao e: "quanto custa escalar isso?" A resposta correta nao deve inventar valores fixos, porque precos de provedores mudam. O projeto deve explicar a formula de estimativa, quais variaveis controlam custo e quais decisoes reduzem risco.

## Detalhamento tecnico

### Componentes de custo

| Componente | Quando ocorre | Cresce com | Observacao |
|---|---|---|---|
| Embedding de documentos | Ingestao/reingestao | Tokens dos documentos | Custo eventual, nao por usuario |
| Embedding da pergunta | Toda busca RAG | Numero de perguntas que usam RAG | Custo pequeno por consulta |
| LLM input | Toda resposta do agente | Mensagem, historico, prompt, chunks RAG e outputs de tools | Principal custo recorrente |
| LLM output | Toda resposta | Tamanho da resposta | Controlavel por prompt/UX |
| Banco pgvector | Operacao local/infra | Numero de chunks e consultas | Custo de infraestrutura, nao token |

### Formula pratica de estimativa

```text
custo_mensal = custo_embeddings_consulta + custo_llm

custo_embeddings_consulta = perguntas_rag_mes * tokens_query * preco_embedding_input

custo_llm = mensagens_mes * (
  tokens_input_medio * preco_llm_input +
  tokens_output_medio * preco_llm_output
)

custo_reingestao = tokens_documentos * preco_embedding_input
```

### O que aumenta tokens de input

- System prompt.
- Mensagem atual do aluno.
- Historico recente (`CHAT_HISTORY_K`, default 20).
- Chunks recuperados pelo RAG (`MAX_RESULTS=3`).
- Resultados de tools MCP.

### O que reduz custo

- Usar modelo menor para atendimento comum.
- Restringir historico quando a conversa estiver longa.
- Manter chunks objetivos e autosuficientes.
- Nao chamar RAG ou MCP quando a pergunta for simples.
- Cachear respostas de FAQ estaticas em fase futura, se necessario.

## Fluxo / Arquitetura

```text
Documento atualizado -> reingestao -> custo embedding eventual
Mensagem do aluno -> embedding query + LLM -> custo recorrente
Mais alunos -> mais mensagens -> custo LLM cresce quase linearmente
Mais documentos -> mais chunks -> custo de reingestao e busca cresce
```

## Interfaces e dependencias

- `LLM_PROVIDER`: `openai`, `gemini` ou `openrouter`.
- `LLM_MODEL`: modelo de chat.
- `EMBEDDING_PROVIDER`: `openai` ou `openrouter`.
- `EMBEDDING_MODEL`: modelo de embedding, default `text-embedding-3-small`.
- `RAG_SIMILARITY_THRESHOLD`: controla recall/precisao e pode afetar quantas respostas incluem contexto.

## Exemplos

Resposta curta para banca:

```text
O custo recorrente e dominado pelo LLM por mensagem. A ingestao da base gera custo de embedding, mas e eventual. Como o provider e configuravel, estimamos por tokens e escolhemos modelo conforme custo, latencia e qualidade.
```

## Limites e riscos

- A base ainda nao inclui uma planilha com valores comerciais de provedores.
- Se documentos crescerem muito, pgvector pode exigir tuning ou vector DB dedicado.
- Chunks muito grandes aumentam custo de contexto; chunks muito pequenos podem perder sentido.

## Links relacionados

- [AI Service e RAG](ai-service-rag.md)
- [Base de conhecimento RAG](base-conhecimento-rag.md)
- [Qualidade do RAG](rag-quality-evaluation.md)
- [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md)
- [ADR 005 - LLM provider-agnostic](../adr/005-llm-provider-agnostic.md)
