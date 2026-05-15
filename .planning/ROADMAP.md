# Roadmap — Desafio FCG3

## Milestones

- **v1.0 Backend + AI + MCP** — Phases 1-6 (shipped 2026-05-04)
- **v2.0 Flutter Frontend** — Phases 7-17 (shipped 2026-05-07)
- 🚧 **v3.0 Correções, Melhorias & Features** — Phases 18-25 (in progress)
  - **Branch:** `gsd/v3.0-group1-corrections-2` (stable baseline, 2026-05-12)

---

## Completed Milestones

<details>
<summary>v1.0 Backend + AI Service + MCP Server (Phases 1-6) — SHIPPED 2026-05-04</summary>

- [x] Phase 1: Foundation & Infrastructure (6/6 plans) — completed 2026-04-09
- [x] Phase 2: Authentication & Security (4/4 plans) — completed 2026-04-10
- [x] Phase 3: Academic Feature Slices (7/7 plans) — completed 2026-04-12
- [x] Phase 4: MCP Server (4/4 plans) — completed 2026-04-14
- [x] Phase 5: AI Service & RAG (4/4 plans) — completed 2026-04-20
- [x] Phase 6: WhatsApp Integration (3/3 plans) — completed 2026-05-04

**Archive:** [v1.0 details in git history]

</details>

<details>
<summary>v2.0 Flutter Frontend (Phases 7-17) — SHIPPED 2026-05-07</summary>

- [x] Phase 7: Flutter Scaffold & Auth (3/3 plans) — completed 2026-05-05
- [x] Phase 8: Client Interface (5/5 plans) — completed 2026-05-05
- [x] Phase 9: Staff Interface (5/5 plans) — completed 2026-05-05
- [x] Phase 10: Cross-Platform Polish (6/6 plans) — completed 2026-05-07
- [x] Phase 11: Alpha Connect Visual Refactoring (1/1 plans) — completed 2026-05-06
- [x] Phase 12: Frontend-Backend Integration (3/3 plans) — completed 2026-05-06
- [x] Phase 13: Resource Allocation (3/3 plans) — completed 2026-05-06
- [x] Phase 14: Human Intervention (2/2 plans) — completed 2026-05-06
- [x] Phase 15: Requirements Traceability Sync (1/1 plans) — completed 2026-05-07
- [x] Phase 16: Auth & Router Tech Debt (1/1 plans) — completed 2026-05-07
- [x] Phase 17: Loading State Polish (1/1 plans) — completed 2026-05-07

**Archive:** [v2.0-ROADMAP.md](./milestones/v2.0-ROADMAP.md)

</details>

---

## 🚧 v3.0 Correções, Melhorias & Features (Active)

**Milestone Goal:** Corrigir navegação e UX quebrados em ambas as visões, completar workflow LangChain, expandir roles para provider, implementar FCM push notifications, e adicionar features novas (cardápio, perfil, grade curricular).

**Parallelization Strategy:**
```
GROUP 1 — Corrections (parallel):
  Phase 18 ──┐
  Phase 19 ──┘── can execute simultaneously

GROUP 2 — Improvements (parallel):
  Phase 20 ──┐
  Phase 21 ──├── can execute simultaneously
  Phase 22 ──┘

GROUP 3 — New Features:
  Phase 23 ──── independent screens (internal parallelism)

GROUP 4 — Polish (depends on all above):
  Phase 24 ──── final integration validation
```

## Phases


- [x] **Phase 18: Student UX Corrections** - Fix navigation, chat UX, documents, notifications on student screens (gap closure)
 (completed 2026-05-09)
- [x] **Phase 19: Staff UX Corrections** - Fix dashboard, agendamentos, chats, intervenção, documentos, recursos, cadastro (gap closure in progress)
 (completed 2026-05-10)
- [x] **Phase 20: LangChain Workflow** - Complete agent lifecycle, RAG, MCP, defenses, logging (gap closure in progress) (completed 2026-05-09)
- [x] **Phase 21: Roles & Auth Expansion** - Add provider role with hierarchical CRUDs (completed 2026-05-09)
- [x] **Phase 22: FCM Push Notifications** - End-to-end push infrastructure (backend + Flutter) (completed 2026-05-09)
- [ ] **Phase 23: New Features** - Perfil do aluno, campo professor, visualização staff do aluno
- [ ] **Phase 24: UI Polish & Integration** - Splash screen, dashboard metrics, end-to-end coherence
- [x] **Phase 25: Chatbot Interaction Polish** - System prompt rewrite, proactive behavior, tone calibration, hardcoded messages (completed 2026-05-12)
- [ ] **Phase 26: Banner Carousel** - Carrossel de banners no painel do aluno + tela de gestão de banners para staff/provider

## Phase Details

### Phase 18: Student UX Corrections

**Goal**: Student can navigate all screens correctly with proper actions, drawers, and notification management
**Depends on**: Nothing (correction of existing code)
**Requirements**: STUX-01, STUX-02, STUX-03, STUX-04, STUX-05, STUX-06, STUX-07, STUX-08, STUX-09, STUX-10, STUX-11, STUX-12, STUX-13, STUX-14, STUX-15
**Success Criteria** (what must be TRUE):
  1. Student taps quick actions and arrives at the correct destination (agendamentos detail, documents with drawer open)
  2. Student can rename chat sessions, filter by active/inactive, and see them ordered by date
  3. Student can view full document details in a drawer, see type/date on each item, and add documents via drawer
  4. Student notifications show read/unread state, can be filtered, individually marked as read, and bulk-marked
  5. Student accesses support via header icon and views agendamento details via drawer
**Plans:** 7/7 plans complete

Plans:
- [x] 18-01-PLAN.md — Fix home quick actions + add support/notifications to header
- [x] 18-02-PLAN.md — Chat rename, active/inactive filter, date ordering
- [x] 18-03-PLAN.md — Documents type/date display + detail drawer
- [x] 18-04-PLAN.md — Notifications read/unread state + filters + mark-as-read
- [x] 18-05-PLAN.md — Appointment detail drawer + wiring
- [x] 18-06-PLAN.md — GAP: Agendamentos quick action → navigate to resources tab + card onTap
- [x] 18-07-PLAN.md — GAP: Chat rename backend endpoint + Flutter error handling

**UI hint**: yes

### Phase 19: Staff UX Corrections

**Goal**: Staff can manage all operational screens with correct data display, filters, search, and CRUD operations
**Depends on**: Nothing (correction of existing code)
**Requirements**: SFUX-01, SFUX-02, SFUX-03, SFUX-04, SFUX-05, SFUX-06, SFUX-07, SFUX-08, SFUX-09, SFUX-10, SFUX-11, SFUX-12, SFUX-13, SFUX-14, SFUX-15, SFUX-16, SFUX-17, SFUX-18, SFUX-19, SFUX-20, SFUX-21, SFUX-22, SFUX-23, SFUX-24, SFUX-25
**Success Criteria** (what must be TRUE):
  1. Staff dashboard shows truncated metrics and navigates to filtered views (docs pendentes, chats hoje)
  2. Staff agendamentos display correct card info (nome + recurso), support search by RA/nome, and confirm works
  3. Staff chats show tab navigation, student identification (nome + número), and informative header in conversation
  4. Staff intervenção follows visual patterns (drawer, search), shows concluídos tab
  5. Staff documentos have state tabs, type filter, full data view, drawer pattern, and error on missing file
  6. Staff recursos toggle ativar/desativar works and delete option exists
  7. Staff cadastro de alunos is a full CRUD with cards, 3-dot menu, floating add button, expandable details, and search/filters
**Plans:** 9/9 plans complete

Plans:
- [x] 19-01-PLAN.md — Dashboard KPI navigation + nav rename + Ações Rápidas
- [x] 19-02-PLAN.md — Agendamentos card redesign + search + confirm fix
- [x] 19-03-PLAN.md — Unified Chats screen (AI + Intervention merged)
- [x] 19-04-PLAN.md — Documents tabs + type filter + detail sheet
- [x] 19-05-PLAN.md — Resources toggle + delete option
- [x] 19-06-PLAN.md — Cadastro de Alunos full CRUD screen
- [x] 19-07-PLAN.md — GAP: Appointment data + confirm endpoint (Tests 4, 5)
- [x] 19-08-PLAN.md — GAP: Chat student data + intervention closed + resource delete (Tests 6, 7, 11)
- [x] 19-09-PLAN.md — GAP: KPI filter nav + chat tab fix + cadastro field mapping (Tests 2, 6, 12, 13)

**UI hint**: yes

### Phase 20: LangChain Workflow

**Goal**: WhatsApp chatbot handles complete conversation lifecycle with RAG, MCP tools, security defenses, and structured logging
**Depends on**: Nothing (backend/AI service, independent of Flutter)
**Requirements**: LANG-01, LANG-02, LANG-03, LANG-04, LANG-05, LANG-06, LANG-07, LANG-08, LANG-09, LANG-10, LANG-11, LANG-12, LANG-13, LANG-14
**Success Criteria** (what must be TRUE):
  1. Student receives welcome message when starting WhatsApp conversation and goodbye message when session ends (timeout or farewell)
  2. Agent answers academic questions from knowledge base (RAG) and executes actions via MCP tools with correct student context
  3. Off-scope questions receive polite redirection; media messages receive creative rejection; failures trigger human intervention
  4. Prompt injection attempts are detected and neutralized without disrupting legitimate conversation
  5. Staff can see RAG debug info (chunks, scores) in chat logs; system logs capture full LangChain decision traceability
**Plans:** 11/11 plans complete

Plans:
- [x] 20-01-PLAN.md — System prompt + Alpha persona + off-scope + media enhancement
- [x] 20-02-PLAN.md — RAG observability (rag_logs table) + LangSmith tracing
- [x] 20-03-PLAN.md — RAG ingest on Docker bootstrap
- [x] 20-04-PLAN.md — Lazy OTP strategy + webhook flow modification
- [x] 20-05-PLAN.md — Prompt injection defense (4 layers)
- [x] 20-06-PLAN.md — Session lifecycle (welcome/goodbye/idle timeout)
- [x] 20-07-PLAN.md — Gap closure: stale OTP reset + farewell accent normalization
- [x] 20-08-PLAN.md — Gap closure: plain-text formatting + personalized welcome name
- [x] 20-09-PLAN.md — Gap closure: welcome name fix + farewell detection threshold
- [x] 20-10-PLAN.md — Gap closure: stale OTP timezone crash fix + test repair
- [x] 20-11-PLAN.md — Gap closure: MCP verification gate + system prompt lazy OTP + verification_state propagation

### Phase 21: Roles & Auth Expansion

**Goal**: Provider role exists with hierarchical management — provider manages staff, staff manages students — with dedicated Flutter screens
**Depends on**: Nothing (auth layer extension, independent)
**Requirements**: ROLE-01, ROLE-02, ROLE-03, ROLE-04, ROLE-05, ROLE-06, ROLE-07
**Success Criteria** (what must be TRUE):
  1. JWT token includes provider role; provider can log in and see provider-specific navigation
  2. Provider can CRUD staff members (cadastrar, editar, ativar/desativar, remover) with required fields
  3. Staff can CRUD students (cadastrar, editar, ativar/desativar, remover) with required fields
  4. Provider screen has 2 tabs (staff + aluno) with separate CRUD interfaces
**Plans:** 4/4 plans complete

Plans:
- [x] 21-01-PLAN.md — Backend migration + auth expansion (provider role, new columns, require_provider)
- [x] 21-02-PLAN.md — Staff CRUD endpoints (5 routes, provider-only)
- [x] 21-03-PLAN.md — Flutter navigation expansion (6th tab, UserModel, router guards)
- [x] 21-04-PLAN.md — Flutter staff management UI (list, form, CRUD operations)

**UI hint**: yes

### Phase 22: FCM Push Notifications

**Goal**: Students receive push notifications on their phone for key academic events, with tap-to-navigate functionality
**Depends on**: Nothing (can begin infrastructure in parallel; event triggers wire into existing services)
**Requirements**: FCM-01, FCM-02, FCM-03, FCM-04, FCM-05, FCM-06, FCM-07, FCM-08
**Success Criteria** (what must be TRUE):
  1. Flutter app registers FCM token on login and refreshes it automatically; backend stores tokens per device
  2. Push notification appears in phone notification bar when document is ready, enrollment confirmed, appointment confirmed, or new chat message received
  3. Notifications display correctly in both foreground and background states
  4. Tapping a notification navigates the user to the relevant screen in the app
**Plans:** 4/4 plans complete

Plans:
- [x] 22-01-PLAN.md — Backend FCM infrastructure (token CRUD + notification service)
- [x] 22-02-PLAN.md — Flutter Firebase setup + FCM token lifecycle management
- [x] 22-03-PLAN.md — Backend event triggers + unit tests
- [x] 22-04-PLAN.md — Flutter notification handlers + deep-link navigation
- [x] 22-05 — Server-side notification persistence (notifications table, REST endpoints, Flutter API integration, badge indicator)

**UI hint**: yes

### Phase 23: New Features

**Goal**: Students can view their academic profile; staff/provider can view student details; courses include professor info; students can view weekly class timetable
**Depends on**: Nothing (independent screens with new backend endpoints)
**Requirements**: PROF-01, PROF-02, PERF-01, PERF-02, PERF-03, STDET-01, STDET-02, GRAD-01, GRAD-02, GRAD-03
**Success Criteria** (what must be TRUE):
  1. Course model includes professor field; seed data populates professors; grades/curriculum endpoints return professor
  2. Student can tap greeting card on home screen to open profile with personal data, academic summary, and current semester grades
  3. Staff/provider can tap any student in cadastro/gestão to see full student detail (same structure as student profile)
  4. Profile screen shows: avatar, name, email, RA, phone, semester, enrollment year, status, CRA, progress, grades with professor
  5. Student can view weekly class schedule in a tabbed calendar view (Mon-Fri); each slot shows time, professor, room; only enrolled courses shown
  6. Grade tab in bottom nav provides direct access to weekly timetable
  7. Grade cards on profile/detail screens show schedule summary (day/time) per course
**Plans**: Complete
**Branch**: `feature/weekly-class-schedule`

Plans:
- [x] 23-01 — Backend: professor field on Course model + migration + schemas + seed
- [x] 23-02 — Frontend: student profile screen + provider + route + home card + bottom nav tab
- [x] 23-03 — Frontend: enrollment screen + staff student detail + integration
- [x] 23-04 — Weekly class schedule (class_schedules table + timetable screen + Grade tab + schedule summary in grade cards)

**UI hint**: yes

### Phase 24: UI Polish & Integration

**Goal**: Application presents a polished, cohesive experience with custom splash screen and consistent navigation after all corrections
**Depends on**: Phases 18, 19, 20, 21, 22, 23 (final validation layer)
**Requirements**: UIPOL-01, UIPOL-02, UIPOL-03
**Success Criteria** (what must be TRUE):
  1. App launches with custom Alpha Connect splash screen (not default Flutter splash)
  2. Staff/provider dashboard displays additional relevant metrics
  3. End-to-end navigation is coherent — every screen reachable, every action completes, no dead ends
**Plans**: TBD
**UI hint**: yes

### Phase 25: Chatbot Interaction Polish

**Goal**: Alpha chatbot delivers warm, proactive, human-like interactions that generate genuine connection with students — not just functional answers
**Depends on**: Phase 20 (LangChain Workflow must be complete — it is)
**Requirements**: CHAT-01, CHAT-02, CHAT-03, CHAT-04, CHAT-05, CHAT-06, CHAT-07, CHAT-08, CHAT-09, CHAT-10, CHAT-11, CHAT-12, CHAT-13, CHAT-14, CHAT-15, CHAT-16, CHAT-17, CHAT-18, CHAT-19, CHAT-20, CHAT-21, CHAT-22, CHAT-23
**Success Criteria** (what must be TRUE):
  1. Students perceive the chatbot as helpful and personable (not robotic or cold)
  2. Chatbot proactively suggests related actions and alerts about pending items
  3. All hardcoded messages (idle, farewell, escalation, media) match the Alpha persona tone
  4. Conversation starters and goodbyes feel natural and personalized
  5. Knowledge base is expanded to cover all available academic topics
**Plans:** 3/3 plans complete

Plans:
- [x] 25-01-PLAN.md — System prompt rewrite + LLM temperature/model config
- [x] 25-02-PLAN.md — Hardcoded messages + welcome injection polish
- [x] 25-03-PLAN.md — Knowledge base expansion (CATEGORY_MAP)

**Canonical refs:** `ai_service/prompts/system_prompt.txt`, `ai_service/agent.py`, `backend/src/features/webhook/background.py`, `backend/src/features/webhook/idle_monitor.py`, `ai_service/knowledge/`

### Phase 26: Banner Carousel

**Goal**: Students see a banner carousel on their home screen; staff/provider can upload, preview, and delete banners from a dedicated management screen
**Depends on**: Nothing (independent feature)
**Requirements**: BNNR-01, BNNR-02, BNNR-03, BNNR-04, BNNR-05, BNNR-06
**Success Criteria** (what must be TRUE):
  1. Student home screen displays an auto-scrolling banner carousel below the greeting card
  2. Banners rotate automatically through all enabled banners registered in the system
  3. Staff/provider can access a banner management screen to upload new banners
  4. Staff/provider can delete existing banners from the management screen
  5. Banner management screen shows a preview of all currently enabled banners
  6. Uploaded banners are immediately visible to all students
**Plans:** 1/3 plans executed

Plans:
- [x] 26-01-PLAN.md — Backend feature slice (model, migration, CRUD endpoints, file upload)
- [ ] 26-02-PLAN.md — Flutter banner management screen (staff/provider grid, toggle, delete, upload)
- [ ] 26-03-PLAN.md — Flutter student banner carousel (auto-scroll, swipe, dots, home screen integration)

**Branch**: `feature/banner-carousel`
**UI hint**: yes

---

## Progress

**Execution Order:**
- Group 1 (Corrections): Phase 18 ∥ Phase 19 (parallel)
- Group 2 (Improvements): Phase 20 ∥ Phase 21 ∥ Phase 22 (parallel)
- Group 3 (New Features): Phase 23 (internal parallelism across 3 sub-features)
- Group 4 (Polish): Phase 24 (after all above)

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 18. Student UX Corrections | v3.0 | 7/7 | Complete    | 2026-05-09 |
| 19. Staff UX Corrections | v3.0 | 9/9 | Complete    | 2026-05-10 |
| 20. LangChain Workflow | v3.0 | 11/11 | Complete   | 2026-05-09 |
| 21. Roles & Auth Expansion | v3.0 | 4/4 | Complete   | 2026-05-09 |
| 22. FCM Push Notifications | v3.0 | 5/5 | Complete    | 2026-05-14 |
| 23. New Features | v3.0 | 3/4 | In progress | - |
| 24. UI Polish & Integration | v3.0 | 0/TBD | Not started | - |
| 25. Chatbot Interaction Polish | v3.0 | 3/3 | Complete | 2026-05-12 |
| 26. Banner Carousel | v3.0 | 1/3 | In Progress|  |

---

**Total project:** 26 phases across 3 milestones.

### Branch History

| Branch | Base | Created | Purpose |
|--------|------|---------|---------|
| `gsd/v3.0-group1-corrections` | `development` | — | Group 1-2 corrections + improvements execution |
| `gsd/v3.0-group1-corrections-2` | `gsd/v3.0-group1-corrections` | 2026-05-12 | Stable baseline with visual redesign + chatbot polish merged |
| `feature/student-profile-screen` | `gsd/v3.0-group1-corrections-2` | 2026-05-14 | Phase 23: Student profile + professor field + staff student detail |
| `feat/notifications-backend-persistence` | `fix/enrollment-draft-flow` | 2026-05-14 | Notification read status persisted server-side (replaced SharedPreferences with PostgreSQL) |
| `feature/staff-schedule-tabs` | `feat/notifications-backend-persistence` | 2026-05-14 | Staff schedule management: TabBar, grouped slots with occupancy bar, batch delete, no-show, slot CRUD |
| `fix/resource-booking-authorization` | `feature/staff-schedule-tabs` | 2026-05-14 | Fix resource booking authorization upload, provider 403 on appointment actions, staff authorization doc download |
| `feature/notification-details-and-navigation` | `fix/resource-booking-authorization` | 2026-05-14 | Descriptive notifications with resource/date/time, new events (cancelled/completed/no-show), correct navigation to Meus Agendamentos |
| `feature/banner-carousel` | `feature/notification-details-and-navigation` | 2026-05-15 | Phase 26: Banner carousel on student home + staff/provider banner management |
