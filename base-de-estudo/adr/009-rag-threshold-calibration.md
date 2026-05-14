# ADR 009 - Calibracao do Threshold RAG
<!--
TYPE: adr
SCOPE: rag
KEYWORDS: adr, rag, threshold, calibracao, calibração, similaridade, pgvector, recall, precision, whatsapp, embeddings
-->
[TOC]

## Resumo rapido

O threshold do RAG e configuravel e o default atual do codigo e `0.45`. Essa calibracao reconhece que perguntas curtas de WhatsApp podem ter similaridade menor contra chunks academicos mais longos.

## Keywords

- adr
- rag
- threshold
- calibracao
- calibração
- similaridade
- pgvector
- recall
- precision
- whatsapp
- embeddings

## Metadados

- Status: aceito no codigo atual
- Data: 2026-05-14
- Autores: equipe do projeto Desafio FCG3
- Evidencias: `ai_service/config.py`, `ai_service/rag.py`, `.planning/ADR-001-rag-threshold.md`, `docs/backup/chatbot.md`

## Contexto

Documentos antigos citavam threshold `0.75` e planejamento intermediario mencionou `0.60`. O codigo atual usa `RAG_SIMILARITY_THRESHOLD` com default `0.45`. A divergencia precisa ser explicada para evitar resposta contraditoria em apresentacao.

## Opcoes consideradas

| Opcao | Pros | Contras |
|---|---|---|
| Threshold alto, como `0.75` | Alta precisao quando encontra | Muitos falsos negativos para perguntas curtas |
| Threshold intermediario, como `0.60` | Equilibrio inicial | Pode ainda perder queries pouco literais |
| Threshold configuravel com default `0.45` | Melhor recall operacional no codigo atual | Pode recuperar chunks menos precisos |

## Decisao

Manter threshold configuravel por ambiente e documentar que o default atual do codigo e `0.45`. Para apresentacao, a resposta deve enfatizar configurabilidade e calibracao empirica, nao tratar o valor como constante definitiva.

## Consequencias

- Positivas: melhora chance de recuperar contexto em mensagens curtas de WhatsApp.
- Positivas: permite ajustar por ambiente sem alterar codigo.
- Negativas: exige avaliacao de qualidade para evitar contexto irrelevante.
- Negativas: docs antigos devem ser tratados como historico, nao fonte canônica.

## Links relacionados

- [AI Service e RAG](../knowledge/ai-service-rag.md)
- [Base de conhecimento RAG](../knowledge/base-conhecimento-rag.md)
- [Qualidade do RAG](../knowledge/rag-quality-evaluation.md)
- [Custos e escala do RAG](../knowledge/rag-cost-scaling.md)
