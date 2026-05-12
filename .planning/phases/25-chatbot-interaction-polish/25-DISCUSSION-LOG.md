# Phase 25: Chatbot Interaction Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-11
**Phase:** 25-chatbot-interaction-polish
**Areas discussed:** Tom de Voz, Proatividade, Emojis, Formato, Boas-vindas, Despedida, Inatividade, Escalação, Frustração, Erros, LLM Config, Knowledge Base

---

## Tom de Voz

| Option | Description | Selected |
| --- | --- | --- |
| Amigável e acolhedor | Como um colega mais experiente: próximo, caloroso, usa 'você', demonstra interesse genuíno | ✓ |
| Profissional mas empático | Mantém tratamento por 'você' mas com mais distância | |
| Descontraído e jovem | Pode usar expressões como 'show', 'massa', 'partiu ver' | |

**User's choice:** Amigável e acolhedor
**Notes:** None — clear selection

---

## Proatividade

| Option | Description | Selected |
| --- | --- | --- |
| Sugerir próximos passos | Após responder, sugere ações relacionadas | |
| Alertar sobre pendências | Na saudação ou quando relevante, mencionar pendências | |
| Ambos | Combina sugestões + alertas de pendências | ✓ |

**User's choice:** Ambos
**Notes:** None

---

## Emojis

| Option | Description | Selected |
| --- | --- | --- |
| Sem emojis | Texto limpo, profissional e discreto | |
| Emojis mínimos | Poucos e funcionais (✅, 📚, 📄, 👋). Máximo 1-2 por mensagem | ✓ |
| Emojis moderados | Usa com frequência para deixar visual e leve | |

**User's choice:** Emojis mínimos
**Notes:** None

---

## Formato de Resposta

| Option | Description | Selected |
| --- | --- | --- |
| Conciso | Respostas curtas, máximo 3-4 linhas | |
| Detalhado | Explicações mais completas, 6-8 linhas | |
| Adaptativo | Varia: curtas para simples, longas só quando necessário | ✓ |

**User's choice:** Adaptativo
**Notes:** None

---

## Saudação (Sessão Nova)

| Option | Description | Selected |
| --- | --- | --- |
| Personalizada com contexto | Saudação calorosa + menção proativa de pendências via get_student_info | ✓ |
| Calorosa mas genérica | Saudação com nome mas sem consultar dados | |
| Diferenciada (1a vez vs retorno) | Primeira sessão shows apresentação; retorno vai direto ao ponto | |

**User's choice:** Personalizada com contexto
**Notes:** None

---

## Despedida

| Option | Description | Selected |
| --- | --- | --- |
| Calorosa com incentivo | Despedida com nome + convite para voltar + "Bons estudos!" | ✓ |
| Curta e profissional | Simples: "Até mais! Estou à disposição quando precisar." | |

**User's choice:** Calorosa com incentivo
**Notes:** None

---

## Mensagens de Inatividade

| Option | Description | Selected |
| --- | --- | --- |
| Contextual | Menciona o que estavam fazendo + pergunta se quer continuar | ✓ |
| Genérico | Mantém mensagem atual genérica | |

**User's choice:** Contextual
**Notes:** Implementação pode requerer que idle_monitor receba último tópico da conversa

---

## Escalação para Humano

| Option | Description | Selected |
| --- | --- | --- |
| Empática com contexto | Validar pedido + demonstrar cuidado na transferência | ✓ |
| Direta | Apenas informar que vai transferir | |

**User's choice:** Empática com contexto
**Notes:** None

---

## Frustração / Reclamação

| Option | Description | Selected |
| --- | --- | --- |
| Validar e resolver | Reconhecer sentimento antes de resolver o problema | ✓ |
| Apenas resolver | Ir direto para solução sem reconhecer sentimento | |

**User's choice:** Validar e resolver
**Notes:** None

---

## Erros de Ferramenta

| Option | Description | Selected |
| --- | --- | --- |
| Transparente e retry | Informar de forma leve que houve problema e tentar de novo | ✓ |
| Silencioso | Esconder erro e tentar de novo sem informar | |

**User's choice:** Transparente e retry
**Notes:** None

---

## LLM Temperature

| Option | Description | Selected |
| --- | --- | --- |
| 0.7 | Mais natural e variado, menos robótico | ✓ |
| 0.5 | Meio-termo | |
| Default | Sem definir (1.0 no GPT) | |

**User's choice:** 0.7
**Notes:** None

---

## Knowledge Base Expansion

| Option | Description | Selected |
| --- | --- | --- |
| Expandir para todos | Ingerir todos os 19 arquivos existentes | ✓ |
| Manter os 6 atuais | Não precisa mais contexto por agora | |

**User's choice:** Expandir para todos
**Notes:** None

---

## Agent's Discretion

- Formulação exata das frases
- Escolha de qual pendência mencionar
- Quando oferecer sugestões
- Variações nas saudações/despedidas

## Deferred Ideas

- Few-shot examples no prompt (avaliar impacto em latência)
- Métricas de satisfação (pertence a phase de analytics)
- Personalidade adaptativa por período (complexidade futura)
- Respostas contextuais pra mídia (scope creep — whisper)
