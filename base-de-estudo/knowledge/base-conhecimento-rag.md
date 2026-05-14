# Base de Conhecimento RAG
<!--
TYPE: knowledge-page
SCOPE: rag
KEYWORDS: base-de-conhecimento, knowledge-base, rag, documentos-academicos, ingestao, chunks, embeddings, pgvector, matricula, regulamento, faq, curriculo, documentos
-->
[TOC]

## Resumo rapido

A base de conhecimento RAG fica em `ai_service/knowledge/` e contem documentos academicos em Markdown. O pipeline de ingestao transforma esses arquivos em chunks, gera embeddings e grava tudo em `knowledge_base_chunks` para busca semantica.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: rag
- Fontes: `ai_service/knowledge/*.md`, `ai_service/ingest.py`, `ai_service/rag.py`, `.planning/quick/260504-i90-*`
- Tabela: `knowledge_base_chunks`

## Keywords

- base-de-conhecimento
- knowledge-base
- rag
- retrieval
- documentos-academicos
- academic-documents
- ingestao
- ingestion
- chunks
- embeddings
- pgvector
- matricula
- regulamento
- faq
- curriculo
- documentos
- calendario
- bolsas
- equivalencia
- estagio
- tcc

## Contexto

O RAG permite responder perguntas sobre regras academicas com base em documentos mantidos no repositorio. A qualidade das respostas depende da granularidade dos chunks, categorias corretas e manutencao dos arquivos fonte.

## Detalhamento tecnico

Arquivos atualmente mapeados pelo `CATEGORY_MAP` em `ai_service/ingest.py` incluem:

- `matricula.md`: regras de matricula.
- `regulamento.md`: regulamento academico.
- `documentos.md`: solicitacoes e documentos.
- `faq.md`: perguntas frequentes.
- `calendario.md`: prazos e agendamento.
- `curriculo.md`: matriz curricular.
- `atividades_complementares_regras.md`: atividades complementares.
- `bolsas_auxilios.md`: bolsas e auxilios.
- `canais_atendimento.md`: atendimento.
- `corpo_docente.md`: docentes.
- `edital_mobilidade_2026_1.md`: mobilidade academica.
- `equivalencia_matrizes.md`: equivalencia.
- `grade_horaria.md`: horarios.
- `infraestrutura_laboratorios.md`: laboratorios.
- `manual_estagio.md`: estagio.
- `manual_tcc_plagio.md`: TCC e plagio.
- `projetos_extensao.md`: extensao.
- `sla_atendimento_digital.md`: SLA.

## Fluxo / Arquitetura

```text
Markdown fonte -> splitter por tokens -> chunks -> embeddings -> knowledge_base_chunks
Mensagem do aluno -> query embedding -> pgvector similarity -> top resultados -> contexto para agente
```

## Interfaces e dependencias

- Chunk size evidenciado: 500 tokens com overlap 50.
- Embedding padrao: `text-embedding-3-small`, dimensao 1536.
- Threshold e configuravel por `RAG_SIMILARITY_THRESHOLD`; documentos antigos citam 0.75, enquanto codigo atual permite outro padrao.
- A ingestao substitui chunks por `source`, mantendo o conteudo sincronizado com os arquivos.

## Exemplos

Formato esperado de resultado de busca:

```text
Fonte: matricula.md
Categoria: regras_matricula
Relevancia: 0.82
Conteudo: ...
```

## Links relacionados

- [AI Service e RAG](ai-service-rag.md)
- [Custos e escala do RAG](rag-cost-scaling.md)
- [Qualidade do RAG](rag-quality-evaluation.md)
- [Dados e banco](dados-banco.md)
- [Modelo academico](modelo-academico.md)
- [ADR 004 - RAG com PostgreSQL e pgvector](../adr/004-rag-postgresql-pgvector.md)
- [Estudo - RAG e LangChain](../study-guides/estudo-rag-langchain.md)
