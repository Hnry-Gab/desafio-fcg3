# Perguntas Tecnicas para Apresentacao
<!--
TYPE: knowledge-page
SCOPE: mixed
KEYWORDS: perguntas-tecnicas, apresentação, apresentacao, banca, q-and-a, faq-tecnico, rag, embedding, custos, fastapi, mcp, flutter, whatsapp, segurança, arquitetura
-->
[TOC]

## Resumo rapido

Este arquivo e o ponto de apoio rapido para responder perguntas tecnicas durante uma apresentacao. Cada resposta foi escrita para ter uma versao curta, uma explicacao tecnica e links para aprofundamento dentro da base.

## Metadados

- Tipo: pagina de conhecimento
- Escopo: mixed
- Uso: apoio de apresentacao e banca tecnica
- Estrategia: resposta curta primeiro, detalhes depois

## Keywords

- perguntas-tecnicas
- apresentação
- apresentacao
- banca
- q-and-a
- faq-tecnico
- rag
- embedding
- custos
- fastapi
- mcp
- flutter
- whatsapp
- segurança
- arquitetura

## Como usar em apresentacao

- Se a pergunta for ampla, responda pela **Resposta curta**.
- Se pedirem implementacao, use **Detalhe tecnico**.
- Se questionarem evidencia, cite **Evidencias no projeto**.
- Se perguntarem trade-off, cite **Limites e decisoes**.
- Se o tema for decisao arquitetural, abra o ADR relacionado.

## Perguntas sobre arquitetura geral

### Por que o projeto tem backend, AI Service e MCP separados?

**Resposta curta:** porque cada componente tem uma responsabilidade diferente. O backend e a fonte de regras e dados; o AI Service interpreta linguagem natural; o MCP e a fronteira segura para ferramentas.

**Detalhe tecnico:** o app Flutter fala com FastAPI via JWT. O WhatsApp entra pelo webhook do backend. O backend chama o AI Service para processamento conversacional. Quando o agente precisa agir, ele chama MCP tools; o MCP injeta `student_id` a partir da sessao e chama o backend com `X-Service-Token`.

**Evidencias no projeto:** `backend/src/main.py`, `ai_service/main.py`, `mcp_server/main.py`, `mobile/lib/main.dart`, `docker-compose.yml`.

**Links:** [Arquitetura geral](knowledge/arquitetura-geral.md), [ADR 002](adr/002-mcp-injeta-student-id.md).

### Por que usar Docker Compose?

**Resposta curta:** para subir localmente a stack completa com API, IA, MCP, PostgreSQL/pgvector e Flutter web de forma reprodutivel.

**Detalhe tecnico:** o Compose define `fastapi-app`, `langchain-service`, `mcp-server`, `postgres` e `flutter-web`. O backend executa migration/seed no bootstrap da stack atual, enquanto o README tambem documenta comandos manuais para controle operacional.

**Limites e decisoes:** Compose e adequado para MVP e desenvolvimento. Para producao, seria necessario tratar secrets, logs, escalabilidade, filas e deploy gerenciado.

**Links:** [Infraestrutura local](knowledge/infraestrutura-local.md), [ADR 008](adr/008-docker-compose-local.md).

## Perguntas sobre RAG, embeddings e custos

### O que e RAG e como ele funciona neste projeto?

**Resposta curta:** RAG combina busca em documentos academicos com resposta do LLM. O projeto transforma Markdown em chunks, gera embeddings e busca os trechos mais parecidos no PostgreSQL/pgvector.

**Detalhe tecnico:** `ai_service/ingest.py` processa arquivos em `ai_service/knowledge/`, usa `RecursiveCharacterTextSplitter.from_tiktoken_encoder` com `cl100k_base`, `chunk_size=500` e `overlap=50`, gera embeddings e grava em `knowledge_base_chunks`. Em tempo de pergunta, `ai_service/rag.py` calcula embedding da query e busca ate 3 chunks com `1 - (embedding <=> query_vector) >= threshold`.

**Links:** [AI Service e RAG](knowledge/ai-service-rag.md), [Base de conhecimento RAG](knowledge/base-conhecimento-rag.md), [Custos e escala do RAG](knowledge/rag-cost-scaling.md).

### Como foi configurado o embedding?

**Resposta curta:** o padrao e `text-embedding-3-small` com dimensao 1536, configurado por variaveis de ambiente.

**Detalhe tecnico:** `EMBEDDING_PROVIDER` aceita OpenAI ou OpenRouter; `EMBEDDING_MODEL` define o modelo. A tabela usa `vector(1536)`, entao trocar para um modelo com dimensao diferente exige migration e reingestao.

**Evidencias no projeto:** `ai_service/config.py`, `ai_service/embedding_factory.py`, migrations de pgvector.

### Quantos chunks existem?

**Resposta curta:** a quantidade exata e gerada no momento da ingestao e registrada em `ai_service/knowledge/.last_ingest.json`.

**Detalhe tecnico:** o script imprime `Documents processed`, `Total chunks` e `Chunks by category`. Como chunks dependem do conteudo atual dos Markdown, tamanho e overlap, a resposta correta em apresentacao deve citar o arquivo de auditoria mais recente, nao um numero fixo escrito manualmente.

**Links:** [Base de conhecimento RAG](knowledge/base-conhecimento-rag.md), [Qualidade do RAG](knowledge/rag-quality-evaluation.md).

### Qual e o threshold do RAG?

**Resposta curta:** ele e configuravel por ambiente; o default atual do codigo e `0.45`.

**Detalhe tecnico:** documentos antigos mencionavam `0.75` e planejamento intermediario mencionou `0.60`, mas o codigo atual em `ai_service/config.py` usa `RAG_SIMILARITY_THRESHOLD=0.45` por padrao. Isso deve ser apresentado como calibracao operacional para recuperar queries curtas de WhatsApp contra chunks maiores.

**Links:** [ADR 009 - Calibracao do threshold RAG](adr/009-rag-threshold-calibration.md), [Qualidade do RAG](knowledge/rag-quality-evaluation.md).

### Como estimar escalada de custos com o modelo escolhido?

**Resposta curta:** custo cresce em duas frentes: embeddings na ingestao e chamadas LLM por mensagem. Embeddings sao custo eventual; LLM e custo recorrente por interacao.

**Detalhe tecnico:** para estimar, multiplique tokens de documentos por preco de embedding na ingestao; depois multiplique mensagens mensais por tokens de entrada/saida do LLM, incluindo contexto RAG e historico. Como providers mudam preco, a base documenta a formula e nao fixa valores comerciais.

**Links:** [Custos e escala do RAG](knowledge/rag-cost-scaling.md), [ADR 005](adr/005-llm-provider-agnostic.md).

## Perguntas sobre autenticacao e email

### Como voces enviam o email de OTP?

**Resposta curta:** o backend usa Resend para enviar um codigo de 6 digitos por email.

**Detalhe tecnico:** `otp_service.py` gera codigo com `secrets.randbelow`, cria salt, salva apenas `code_hash` e `code_salt`, e envia HTML com Resend se o email existir. O plaintext nao e persistido nem logado.

**Links:** [Auth OTP/JWT detalhado](knowledge/auth-otp-jwt-detalhado.md), [ADR 006](adr/006-otp-email-jwt.md).

### Como o JWT e protegido contra replay de refresh token?

**Resposta curta:** refresh token usa rotacao; quando um refresh e usado, o anterior e marcado como usado e o access token relacionado e invalidado.

**Detalhe tecnico:** o backend armazena sessoes por `jti`, `token_type`, `parent_jti` e `used`. Em refresh, cria novo par e invalida o par antigo para reduzir reutilizacao indevida.

**Links:** [Auth OTP/JWT detalhado](knowledge/auth-otp-jwt-detalhado.md), [Autenticacao e autorizacao](knowledge/autenticacao-autorizacao.md).

## Perguntas sobre MCP e seguranca

### O `student_id` chega ao agente de IA?

**Resposta curta:** nao. O agente nunca recebe `student_id`; ele envia apenas parametros de negocio para ferramentas MCP.

**Detalhe tecnico:** o MCP recebe `x-chat-session-id`, valida a sessao ativa, resolve `student_id` no banco, injeta `X-Student-Id` na chamada ao backend e remove `student_id` dos parametros logados.

**Links:** [MCP sessoes e verificacao](knowledge/mcp-sessoes-verificacao.md), [ADR 002](adr/002-mcp-injeta-student-id.md).

### Como as acoes do agente sao auditadas?

**Resposta curta:** toda chamada MCP vira registro em `mcp_action_logs`.

**Detalhe tecnico:** o middleware grava `chat_session_id`, `tool_name`, `input_params` sanitizado, `output_result`, `latency_ms`, `retry` e `status`. O campo `reasoning` existe, mas no codigo atual e gravado como `None`.

**Links:** [MCP auditoria e retry](knowledge/mcp-auditoria-retry.md).

## Perguntas sobre WhatsApp

### Como o webhook garante resposta rapida?

**Resposta curta:** ele valida, registra e dispara uma tarefa em background, retornando `200 OK` antes de esperar a IA.

**Detalhe tecnico:** o backend valida HMAC com raw body, salva mensagem/sessao e usa processamento assíncrono. Isso evita estourar o tempo de resposta esperado pela WhatsApp Cloud API.

**Links:** [Webhook WhatsApp tecnico](knowledge/webhook-whatsapp-tecnico.md), [ADR 003](adr/003-webhook-whatsapp-assincrono.md).

## Perguntas sobre mobile e Flutter

### Como as rotas do app sao protegidas?

**Resposta curta:** GoRouter redireciona com base no estado de autenticacao e papel do usuario.

**Detalhe tecnico:** nao autenticados vao para login; `student` e bloqueado em `/staff`; `staff/provider` sao bloqueados em `/client`. O backend tambem valida permissoes, entao a UI nao e a unica barreira.

**Links:** [Mobile architecture deep dive](knowledge/mobile-architecture-deep-dive.md), [ADR 007](adr/007-flutter-riverpod-gorouter.md).

### Como o Dio renova token automaticamente?

**Resposta curta:** um `QueuedInterceptor` injeta Bearer token e, em 401, tenta refresh uma vez.

**Detalhe tecnico:** o interceptor usa um Dio separado para `/auth/refresh` para evitar loop de interceptor. Se refresh funciona, grava novos tokens e repete a requisicao original; se falha, apaga tokens.

**Links:** [Mobile auth, Dio e secure storage](knowledge/mobile-auth-dio-secure-storage.md).

## Perguntas sobre testes e evidencias

### Como provar que isso foi testado?

**Resposta curta:** ha suites separadas para backend, AI Service, MCP e mobile.

**Detalhe tecnico:** backend usa pytest; AI e MCP tambem usam pytest; mobile usa `flutter analyze` e `flutter test`. Existem testes para rotas, auth, webhook, RAG, MCP schemas, service token, retry, FCM, telas e guards do app.

**Links:** [Processos e testes](knowledge/processos-testes.md), [Perguntas de estudo](study-guides/perguntas-tecnicas.md).

## Links relacionados

- [Indice global](README.md)
- [Perguntas tecnicas por conhecimento](knowledge/perguntas-tecnicas.md)
- [Perguntas tecnicas sobre decisoes](adr/perguntas-tecnicas.md)
- [Perguntas tecnicas por guia de estudo](study-guides/perguntas-tecnicas.md)
