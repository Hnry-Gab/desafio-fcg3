# Qualidade do RAG
<!--
TYPE: knowledge-page
SCOPE: rag
KEYWORDS: rag, qualidade, quality, avaliação, avaliacao, threshold, recall, precision, chunks, embeddings, top-k, pgvector, perguntas-de-teste
-->
[TOC]

## Resumo rapido

A qualidade do RAG depende de documentos bem escritos, chunking adequado, embeddings compativeis, threshold calibrado e testes com perguntas reais. O projeto usa top 3 resultados e threshold configuravel para equilibrar recall e precisao.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: rag
- Fontes: `ai_service/rag.py`, `ai_service/ingest.py`, `ai_service/tests/test_rag_retrieval.py`, `.planning/ADR-001-rag-threshold.md`

## Keywords

- rag
- qualidade
- quality
- avaliação
- avaliacao
- threshold
- recall
- precision
- chunks
- embeddings
- top-k
- pgvector
- perguntas-de-teste

## Contexto

Em apresentacao, e comum perguntarem "como voces sabem que o RAG responde certo?". A resposta deve separar busca, geracao e avaliacao: recuperar o chunk certo e diferente de o LLM escrever a resposta perfeita.

## Detalhamento tecnico

### Busca atual

- `MAX_RESULTS = 3` em `ai_service/rag.py`.
- Similaridade: `1 - (embedding <=> query_vector)`.
- Filtro: similaridade maior ou igual ao threshold.
- Ordenacao: `ORDER BY similarity DESC`.
- Sem resultados: retorna string vazia e registra `threshold_met=False` quando ha sessao.

### Chunking atual

- `chunk_size=500`.
- `chunk_overlap=50`.
- Tokenizer `cl100k_base`.
- Cada arquivo conhecido tem categoria fixa no `CATEGORY_MAP`.

### Como avaliar

| Dimensao | Pergunta | Evidencia esperada |
|---|---|---|
| Recall | O chunk correto aparece no top 3? | `source` e `category` corretos |
| Precisao | Os chunks recuperados sao relevantes? | score e conteudo coerentes |
| Grounding | A resposta cita apenas conteudo recuperado/tools? | sem inventar regra externa |
| Robustez | Perguntas curtas tambem encontram contexto? | threshold calibrado |
| Regressao | Mudancas em docs quebram perguntas antigas? | suite de perguntas de teste |

## Fluxo / Arquitetura

```text
Pergunta de avaliacao -> embedding -> pgvector top 3 -> verificar source/category -> resposta LLM -> revisao humana/teste
```

## Exemplos

Perguntas recomendadas para avaliacao:

- "Qual o prazo de matricula?"
- "Como solicito historico escolar?"
- "Preciso cumprir atividades complementares?"
- "Quais regras existem para TCC e plagio?"
- "Como funciona equivalencia de matriz curricular?"

## Limites e riscos

- Threshold baixo aumenta recall, mas pode trazer contexto fraco.
- Threshold alto aumenta precisao, mas pode causar falso negativo.
- O LLM ainda pode redigir mal mesmo com chunk correto.
- Nao ha verificador factual automatico pos-resposta no codigo atual.

## Links relacionados

- [Base de conhecimento RAG](base-conhecimento-rag.md)
- [Custos e escala do RAG](rag-cost-scaling.md)
- [ADR 009 - Calibracao do threshold RAG](../adr/009-rag-threshold-calibration.md)
- [Estudo - RAG e LangChain](../study-guides/estudo-rag-langchain.md)
