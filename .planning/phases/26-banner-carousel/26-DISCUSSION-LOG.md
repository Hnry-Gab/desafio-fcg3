# Phase 26: Banner Carousel - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-15
**Phase:** 26-Banner Carousel
**Areas discussed:** Comportamento do carrossel, Modelo de dados, Tela de gestão, Permissões

---

## Comportamento do carrossel

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Moderado (4-5s) | Troca a cada 4-5 segundos com transição suave | ✓ |
| Lento (7-8s) | Troca a cada 7-8 segundos | |
| Sem auto-scroll | Banner não roda sozinho | |
| Você decide | Deixa o agente decidir | |

**User's choice:** Moderado (4-5s)

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Auto + swipe manual | Auto-scroll + swipe manual, pausa ao arrastar | ✓ |
| Apenas automático | Só auto-scroll, sem interação do usuário | |

**User's choice:** Auto + swipe manual

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Dots indicadores | Bolinhas abaixo do banner indicando posição | ✓ |
| Sem indicadores | Sem indicador visual | |
| Barra de progresso | Barra que avança com o timer | |

**User's choice:** Dots indicadores

| Option | Description | Selected |
| ------ | ----------- | -------- |
| 1 banner = estático, 0 = esconde seção | Mostra banner único sem animação, esconde se zero | ✓ |
| Placeholder quando vazio | Mostra placeholder genérico se sem banners | |

**User's choice:** 1 banner = estático, 0 = esconde seção

---

## Modelo de dados

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Minimalista | Imagem, flag habilitado, ordem, created_at | ✓ |
| Completo com link e vigência | Imagem + título + link + habilitado + ordem + datas vigência | |
| Intermediário | Imagem + título + habilitado + ordem (sem link/datas) | |

**User's choice:** Minimalista

| Option | Description | Selected |
| ------ | ----------- | -------- |
| JPG/PNG/WebP, 2MB, livre | Aceitar JPG, PNG e WebP. Max 2MB. Aspect ratio livre | ✓ |
| JPG/PNG, 5MB, 16:9 fixo | Aceitar JPG e PNG. Max 5MB. Aspect ratio 16:9 obrigatório | |
| Qualquer formato, 5MB | Aceitar qualquer formato de imagem. Max 5MB | |

**User's choice:** JPG/PNG/WebP, 2MB, livre

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Altura fixa + cover | Altura fixa no carrossel, imagem preenche com BoxFit.cover | ✓ |
| Altura variável | Altura se ajusta à proporção de cada imagem | |
| Você decide | Deixa o agente decidir | |

**User's choice:** Altura fixa + cover

---

## Tela de gestão

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Via Ações Rápidas | Botão em Ações Rápidas no dashboard (pattern Gerenciar Alunos) | ✓ |
| Nova aba no bottom nav | Nova aba no bottom nav do staff/provider | |
| Menu/drawer | Acessível pelo menu 3 pontos ou drawer lateral | |

**User's choice:** Via Ações Rápidas

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Grid de cards + FAB | Grid de cards com thumbnail, badge, FAB para upload | ✓ |
| Lista com thumbnail | Lista vertical com preview pequeno e ações | |
| Preview carrossel + lista | Carrossel preview no topo + lista abaixo | |

**User's choice:** Grid de cards + FAB

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Preview do carrossel no topo | Seção no topo mostrando como aluno vê | |
| Sem preview ao vivo | Grid de cards é suficiente | ✓ |

**User's choice:** Sem preview ao vivo

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Toggle habilitar/desabilitar | Switch toggle no card (pattern de Recursos) | ✓ |
| Só upload e excluir | Sem toggle, todo banner ativo aparece | |

**User's choice:** Toggle habilitar/desabilitar

---

## Permissões

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Staff + Provider | Ambos podem gerenciar banners | ✓ |
| Apenas Provider | Staff só visualiza | |
| Provider full + Staff parcial | Provider tudo; staff só habilita/desabilita | |

**User's choice:** Staff + Provider

---

## Agent's Discretion

- Widget de carrossel (PageView nativo ou pacote externo)
- Altura exata do carrossel
- Animação de transição (fade, slide)
- Estilo dos dots
- Ordem no grid de gestão
- Loading state

## Deferred Ideas

None — discussion stayed within phase scope
