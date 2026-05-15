---
gsd_state_version: 1.0
milestone: v3.0
milestone_name: Correções, Melhorias & Features
status: executing
last_updated: "2026-05-15T05:20:03.843Z"
last_activity: 2026-05-15
progress:
  total_phases: 9
  completed_phases: 5
  total_plans: 41
  completed_plans: 36
  percent: 88
---

# Project State

## Current Position

Phase: 26 (Banner Carousel) — EXECUTING
Plan: 2 of 3
Status: Ready to execute
Last activity: 2026-05-15

## Project Reference

See: .planning/PROJECT.md (updated 2026-05-08)

**Core value:** Aluno envia mensagem no WhatsApp e recebe resposta precisa sobre sua situação acadêmica — com ações concretas executadas em tempo real.
**Current focus:** Phase 26 — Banner Carousel
**Branch:** `feature/notification-details-and-navigation` (from `fix/resource-booking-authorization`)

## Milestones Shipped

| Milestone | Phases | Plans | Shipped |
|-----------|--------|-------|---------|
| v1.0 Backend + AI + MCP | 1-6 | 47 | 2026-05-04 |
| v2.0 Flutter Frontend | 7-17 | 30 | 2026-05-07 |

## v3.0 Phase Overview

| Phase | Name | Group | Parallel With |
|-------|------|-------|---------------|
| 18 | Student UX Corrections | Corrections | Phase 19 |
| 19 | Staff UX Corrections | Corrections | Phase 18 |
| 20 | LangChain Workflow | Improvements | Phases 21, 22 |
| 21 | Roles & Auth Expansion | Improvements | Phases 20, 22 |
| 22 | FCM Push Notifications | Improvements | Phases 20, 21 |
| 23 | New Features | Features | — |
| 24 | UI Polish & Integration | Polish | — (depends on all) |
| 25 | Chatbot Interaction Polish | Improvements | Phase 20 (done) |

## Architecture Constraints (non-negotiable)

- `student_id` is NEVER exposed to the LangChain agent — always injected by MCP Server
- `MCP_SERVICE_TOKEN` only in environment variables, never in source code
- JWT stored in `flutter_secure_storage` — never in plain SharedPreferences
- Role-based route guards — student cannot access staff screens and vice versa
- All API calls use `Authorization: Bearer {token}` header
- Two separate PostgreSQL drivers: `asyncpg` for FastAPI + MCP; `psycopg3` for LangChain service

## Accumulated Context

- v1.0 + v2.0 shipped: 17 phases, 77 plans, ~35,907 LOC
- Flutter uses Riverpod + GoRouter + Dio with QueuedInterceptor
- Glassmorphism UI (Alpha Connect) with Plus Jakarta Sans + Inter
- Docker 5-service stack (fastapi:8000, langchain:8001, mcp:8002, postgres:5432, flutter-web:3000)
- DEV_MASTER_OTP bypass available for dev/testing
- v3.0 phases designed for maximum parallel execution within groups
- **18-01:** StateProvider pattern for cross-screen drawer auto-open (documentAutoOpenDrawerProvider)
- **18-01:** AppBarActions contains support + notifications icons in header (support_agent_outlined, notifications_outlined)
- **18-01:** Bottom nav reduced to 4 items (Início, Chat, Docs, Recursos) — Avisos moved to header
- **18-02:** Chat sessions: rename via long-press, filter tabs (Todas/Ativas/Inativas), date ordering label
- **18-02:** GlassCard now supports onLongPress for contextual actions
- **18-02:** ChatFilterNotifier pattern for client-side filtering (no extra API call)
- **18-03:** Document cards show date+time (DD/MM/YYYY HH:MM), tap opens detail bottom sheet
- **18-03:** showDocumentDetailSheet pattern with _DetailRow for key-value display in sheets
- **18-04:** Notifications: read/unread state via server-side `notifications` table (replaced client-side SharedPreferences)
- **18-04:** Filter tabs (Todas/Não lidas/Lidas) and "Visualizar todos" bulk mark-as-read
- **18-04:** Individual notification marked as read only on direct tap (not on scroll/view)
- **22-05:** Notification persistence: Alembic 019a `notifications` table with `read_at` column
- **22-05:** 3 REST endpoints: GET /notifications, PUT /notifications/read, PUT /notifications/read-all
- **22-05:** send_push now persists notification row before dispatching FCM (even if FCM disabled)
- **22-05:** Flutter NotificationService + notificationsProvider + NotificationActions (API-driven)
- **22-05:** Unread badge (Badge widget) on bell icon in AppBarActions, count from notificationsProvider
- **22-05:** 44 new tests: 24 backend (persistence + endpoints + IDOR) + 20 Flutter (service + provider + model)
- **staff-schedule:** TabBar refactor: Agenda screen split into Agendamentos (appointments) + Horarios (slots) sub-tabs
- **staff-schedule:** 5 new backend endpoints: GET /scheduling/slots/all, PUT /scheduling/slots/{id}, DELETE /scheduling/slots/{id}, DELETE /scheduling/slots/batch, PUT /appointments/{id}/no-show
- **staff-schedule:** Slots grouped by resource+date: compact card with occupancy bar (LinearProgressIndicator), livres/reservados badges, expandable detail rows
- **staff-schedule:** Batch delete: only_available flag deletes free slots or all slots (cancelling associated appointments)
- **staff-schedule:** Appointment filters expanded: added Concluidos and Ausentes tabs (was Todos/Agendados/Cancelados)
- **staff-schedule:** "Marcar Ausente" button on appointment detail screen (scheduled -> no_show transition)
- **staff-schedule:** Edit slot sheet (edit_slot_sheet.dart) for individual slot date/time editing
- **staff-schedule:** SlotUpdate schema uses Optional[] instead of `X | None` to avoid Pydantic+__future__ annotations runtime eval error
- **auth-fix:** DioClient Content-Type changed from hardcoded `headers:` to `contentType: Headers.jsonContentType` — prevents interference with multipart FormData uploads
- **auth-fix:** FilePicker uses `withData: true` to load file bytes in memory (required for web platform)
- **auth-fix:** `uploadAuthorization` uses `MultipartFile.fromBytes` with explicit MIME type (via `http_parser MediaType`) instead of `fromFile` — cross-platform (web has no filesystem)
- **auth-fix:** Upload error handled separately from booking error — slot not lost if upload fails
- **auth-fix:** Provider role (D-04) added to cancel/confirm/no-show permission checks in `services.py` (was only "staff", now "staff" or "provider")
- **auth-fix:** `AppointmentModel` extended with `authorizationFileUrl` field + `hasAuthorization` getter
- **auth-fix:** Staff appointment detail screen shows authorization doc with download button via `url_launcher` + `buildDownloadUrl`
- **notif-detail:** 3 new NotificationEvent values: `appointment_cancelled`, `appointment_completed`, `appointment_no_show`
- **notif-detail:** Notification body now includes resource name, date, and time (e.g., "Seu agendamento para Quadra Poliesportiva em 2026-05-14 08:00 foi cancelado")
- **notif-detail:** Cancel, confirm, and no-show endpoints now dispatch FCM notifications via `asyncio.create_task`
- **notif-detail:** `notify_appointment_confirmed` renamed to "Agendamento criado" (was "Agendamento confirmado") to differentiate from staff confirm
- **notif-detail:** New `_appointment_detail()` helper builds human-readable detail fragment for all appointment notification bodies
- **notif-detail:** NotificationRouter routes all `appointment_*` events to `/client/resources?tab=1` (Meus Agendamentos) instead of `/client/support`
- **notif-detail:** notification_provider.dart: distinct icons (check_circle/cancel/person_off) and colors (green/red/orange) per appointment event
- **notif-detail:** notification_handler_provider.dart: invalidates `appointmentsProvider` on all 4 appointment event types
- **notif-detail:** Notification tap navigates via `context.go(NotificationRouter.routeFor(...))` for all events (not just appointment_confirmed)
- **18-05:** showAppointmentDetailSheet: reusable appointment detail bottom sheet widget
- **18-05:** Refactored home screen inline sheet to use shared widget (DRY)
- **18-05:** onDetailTap pattern: combined mark-as-read + open detail on notification tap
- **19-01:** Bottom nav tab "Intervenção" renamed to "Chats" (chat_bubble icon) at position 2
- **19-01:** staffChats route temporarily points to StaffAiScreen (Plan 03 will replace)
- **19-01:** staffCadastro route placeholder (Plan 06 will implement)
- **19-01:** KPI cards use query params for pre-applied filters (?filter=hoje, ?filter=pendentes)
- **19-01:** "Ações Rápidas" section on dashboard with Gerenciar Alunos button
- **19-02:** StaffSearchBar reusable widget in shared/widgets for staff screens
- **19-02:** Appointment cards redesigned: CircleAvatar + studentName (title) + resourceName (subtitle)
- **19-02:** AppointmentModel extended with studentName, studentRa, resourceName nullable fields
- **19-02:** StaffScheduleSearch provider for client-side filtering by name/RA
- **19-02:** Detail screen shows Nome, RA, Data emissão, Recurso, Status badge, Motivo
- **19-02:** Confirm/cancel actions with try/catch error handling and colored SnackBar
- **19-03:** StaffChatsScreen: unified 4-tab screen (Todos/Pendentes/Em atendimento/Concluídos) merging AI + intervention
- **19-03:** StaffChatsSearch provider for client-side search by name/RA/phone
- **19-03:** Router /staff/chats now points to StaffChatsScreen (replaced StaffAiScreen placeholder)
- **19-03:** Chat detail header shows studentName, RA, session date+status with surfaceContainerLow bg
- **19-03:** ChatSessionModel extended with studentName, studentRa nullable fields
- **19-04:** Document tabs corrected: Todos | Processando | Prontos (not Pendentes)
- **19-04:** StaffDocumentTypeFilter provider for secondary type-based filtering pills
- **19-04:** Detail bottom sheet on document card tap with action buttons
- **19-04:** Query param ?filter=pendentes maps to 'processing' status
- **19-04:** Error SnackBar (colorScheme.error) prevents finalization without file attached
- **19-05:** _ResourceCard converted to ConsumerWidget for direct ref access (toggle/delete)
- **19-05:** Switch widget replaces static availability dot for toggle ativar/desativar
- **19-05:** PopupMenu has Editar + dynamic Ativar/Desativar + Deletar (with confirmation dialog)
- **19-06:** StaffCadastroScreen: full CRUD with ExpansionTile cards, status dots (green/red), FAB + form sheet
- **19-06:** StaffStudentModel + StaffCadastroService (5 CRUD methods) + provider with filter/search
- **19-06:** Router updated: /staff/cadastro now points to StaffCadastroScreen (was placeholder)
- **18-06:** Agendamentos quick action navigates to /client/resources?tab=1 (not modal)
- **18-06:** _AppointmentCard GlassCard has onTap → showAppointmentDetailSheet
- **18-06:** ClientResourcesScreen accepts initialTabIndex param from query param ?tab=N
- **18-07:** PUT /chat-sessions/{id} rename endpoint with name column, IDOR ownership check, Alembic 014a migration
- **18-07:** Flutter Salvar handler try/catch with red error SnackBar on rename failure
- **19-07:** AppointmentListItem extended with student_name, student_ra, resource_name (Optional[str])
- **19-07:** joinedload(Appointment.student) added to list_appointments query
- **19-07:** PUT /appointments/{id}/confirm endpoint (staff-only, scheduled → completed)
- **19-08:** ChatSessionResponse extended with student_name, student_ra (from joined Student via selectinload)
- **19-08:** Intervention query includes closed sessions (for Concluídos tab)
- **19-08:** Resource is_deleted column for true soft-delete (distinct from is_available toggle), DELETE returns 204
- **19-08:** Alembic 015a migration adds is_deleted to resources table
- **19-09:** initialFilter constructor param pattern replaces GoRouterState.of(context) async reads
- **19-09:** Concluídos tab uses 'closed' only (phantom 'resolved' removed)
- **19-09:** StaffStudentModel @JsonKey maps ra→registration_number, semester as int (not String)
- **19-09:** Backend StudentListItem includes phone field
- **19-09:** Cadastro form removes address/campus (don't exist in DB), sends registration_number/semester
- **25-01:** System prompt rewritten: warm Alpha persona, emoji set (👋✅📚📄🙏📅 only), WhatsApp formatting (*bold*, _italic_), adaptive response length, proactivity, frustration empathy
- **25-01:** LLM temperature=0.7 injected in all 3 providers (OpenAI, Gemini, OpenRouter), default model gpt-4o-mini
- **25-02:** Welcome injection differentiates first-time vs returning students, both call get_student_info proactively
- **25-02:** All hardcoded messages rewritten: idle follow-up contextual, goodbye warm with 📚, escalation empathetic with 🙏, session close personalized
- **25-02:** Verification flow auto-transitions to awaiting_email when agent requests it; post-OTP auto-dispatches to agent to resume pending action
- **25-03:** CATEGORY_MAP expanded 6→18 files; Alembic 016a migration expands category CHECK constraint
- **25-fix:** MCP api_client wraps list responses as {"items": [...]}, tool errors instruct LLM not to retry
- **25-fix:** Session locks dict uses timestamps + periodic stale cleanup (WR-01), load_chat_history wrapped in asyncio.to_thread (WR-04)
- **25-review:** Code review: 9 findings (1 critical, 5 warning, 3 info). 4 fixed, 2 deferred. Automated tests: 46/49 (94%)
- **26-01:** Banner feature slice: Banner model (image_url, is_enabled, display_order), Alembic 021a migration, BannerService singleton, 5 REST endpoints
- **26-01:** GET /banners is public (no auth) for student carousel; GET /banners/all is staff-only
- **26-01:** POST /banners/upload validates content-type (jpeg/png/webp) and enforces 2MB limit; UUID-prefix filenames

### Quick Tasks Completed

| #   | Description | Date | Commit | Directory |
| --- | ----------- | ---- | ------ | --------- |
| 260511-92x | Reorganizar navegacao staff/provider: remover placeholder, tabs provider, seed provider | 2026-05-11 | 912f013 | [260511-92x-reorganizar-navegacao-staff-provider-rem](./quick/260511-92x-reorganizar-navegacao-staff-provider-rem/) |
| 260513-c97 | Traduzir logs MCP de JSON para texto amigavel na tela de chat (staff e student view) | 2026-05-13 | 9e0b1a3 | [260513-c97-traduzir-logs-mcp-de-json-para-texto-ami](./quick/260513-c97-traduzir-logs-mcp-de-json-para-texto-ami/) |
| 260514-ui | Fix UI contrast, status colors, filter tabs, login validation | 2026-05-14 | a4dce4d | — |

### Branch Consolidation Log

| Date | Source Branch | Target Branch | PR | Description |
| ---- | ------------- | ------------- | -- | ----------- |
| 2026-05-12 | fix/frontend | gsd/v3.0-group1-corrections | #14 | Cyber-Academic visual redesign (Phases 15-17), navegacao, logo, animacoes, tema light/dark |
| 2026-05-12 | feature/improve-chatbot-ux | gsd/v3.0-group1-corrections | #15 | Phase 25 chatbot interaction polish, persona rewrite, WhatsApp formatting, knowledge base expansion |
| 2026-05-12 | gsd/v3.0-group1-corrections | gsd/v3.0-group1-corrections-2 | — | New stable baseline branch for continued development |
| 2026-05-14 | gsd/v3.0-group1-corrections-2 | feature/student-profile-screen | — | Phase 23: Student profile + professor field + staff student detail |
| 2026-05-14 | fix/enrollment-draft-flow | feat/notifications-backend-persistence | — | Notification read status persisted server-side (notifications table + REST API + Flutter) |
| 2026-05-14 | feat/notifications-backend-persistence | feature/staff-schedule-tabs | — | Staff schedule management: TabBar, grouped slots, batch delete, no-show, slot CRUD |
| 2026-05-14 | feature/staff-schedule-tabs | fix/resource-booking-authorization | — | Fix authorization upload (bytes+MIME), provider D-04 role on actions, staff authorization download |
| 2026-05-14 | fix/resource-booking-authorization | feature/notification-details-and-navigation | — | Descriptive notifications with resource/date/time, 3 new events, correct navigation to Meus Agendamentos |

## Session Continuity

To resume work: read this file, then `.planning/ROADMAP.md` for phase details.

**Parallel execution guidance:**

- Group 1 (Phases 18-19): Start with `/gsd-plan-phase 18` or `/gsd-plan-phase 19` — both are independent
- Group 2 (Phases 20-22): After Group 1, any of these can start in any order
- Group 3 (Phase 23): After Group 2, plan and execute new features
- Group 4 (Phase 24): Only after all above are complete
