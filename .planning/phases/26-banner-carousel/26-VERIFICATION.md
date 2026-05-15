---
phase: 26-banner-carousel
verified: 2026-05-15T06:00:00Z
status: human_needed
score: 13/13
overrides_applied: 0
human_verification:
  - test: "Open student home screen and verify banner carousel auto-scrolls"
    expected: "Carousel rotates banners every ~4 seconds with smooth 500ms transition"
    why_human: "Auto-scroll timing and animation smoothness cannot be verified statically"
  - test: "Swipe banner carousel manually and verify auto-scroll pauses then resumes"
    expected: "Auto-scroll pauses on swipe, resumes after ~6 seconds idle"
    why_human: "Timer pause/resume behavior requires runtime interaction"
  - test: "Navigate to staff dashboard and tap 'Gerenciar Banners' card"
    expected: "StaffBannerManagementScreen opens with grid of banners or empty state"
    why_human: "Navigation flow and screen rendering requires live app"
  - test: "Upload a banner image via FAB, then check student carousel"
    expected: "Banner appears in management grid immediately and in student carousel after pull-to-refresh"
    why_human: "End-to-end upload + visibility flow requires running backend and app"
  - test: "Toggle banner enable/disable via Switch widget"
    expected: "Badge toggles between 'Ativo'/'Inativo', optimistic update with rollback on error"
    why_human: "Visual state change and optimistic update behavior requires runtime"
  - test: "Delete a banner with confirmation dialog"
    expected: "Dialog appears, confirming removes banner from grid and deletes file on backend"
    why_human: "Confirmation dialog and cascade deletion requires runtime"
---

# Phase 26: Banner Carousel Verification Report

**Phase Goal:** Students see a banner carousel on their home screen; staff/provider can upload, preview, and delete banners from a dedicated management screen
**Verified:** 2026-05-15T06:00:00Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

#### Roadmap Success Criteria (6 truths)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| SC-1 | Student home screen displays an auto-scrolling banner carousel below the greeting card | ✓ VERIFIED | `client_home_screen.dart` L140-155: `BannerCarousel(banners: banners)` inserted between greeting card and summary cards via `bannersAsync.when()`. `banner_carousel.dart` L68: `Timer.periodic(Duration(seconds: 4))` drives auto-scroll with `animateToPage` L71-75. |
| SC-2 | Banners rotate automatically through all enabled banners registered in the system | ✓ VERIFIED | `banner_carousel.dart` L70: `final nextPage = (_currentPage + 1) % widget.banners.length;` implements continuous loop. `banner_provider.dart` L41: GET `/banners` fetches enabled-only banners from public endpoint. `controllers.py` L49: `banner_service.list_banners(db, enabled_only=True)` filters enabled. |
| SC-3 | Staff/provider can access a banner management screen to upload new banners | ✓ VERIFIED | `staff_dashboard_screen.dart` L320: `context.go(RoutePaths.staffBanners)` on "Gerenciar Banners" card. `app_router.dart` L350-355: GoRoute for staffBanners with `StaffBannerManagementScreen`. Screen L98-145: `_pickAndUpload` with `FilePicker.platform.pickFiles` → `bannersProvider.notifier.upload()`. Backend `controllers.py` L72-126: POST `/banners/upload` with content-type + size validation. |
| SC-4 | Staff/provider can delete existing banners from the management screen | ✓ VERIFIED | `staff_banner_management_screen.dart` L300-342: `_handleDelete()` shows `AlertDialog` confirmation, calls `bannersProvider.notifier.delete(banner.id)`. Provider L58-73: optimistic removal + API call. Backend `controllers.py` L152-172: DELETE endpoint removes DB record + file from disk. |
| SC-5 | Banner management screen shows a preview of all currently enabled banners | ✓ VERIFIED | `staff_banner_management_screen.dart` L71-86: `GridView.builder` renders each banner as `_BannerCard` with `Image.network(_buildBannerImageUrl(banner.imageUrl), fit: BoxFit.cover)` L197-199. Staff endpoint GET `/banners/all` returns all banners (enabled + disabled). Badge shows "Ativo"/"Inativo" status. |
| SC-6 | Uploaded banners are immediately visible to all students | ✓ VERIFIED | Upload flow: staff uploads → `bannersProvider.notifier.upload()` → backend creates record (enabled by default) → `ref.invalidateSelf()` refreshes staff list. Student side: `_onRefresh` L39 invalidates `studentBannersProvider` → re-fetches GET `/banners` which returns all enabled. New banner with `is_enabled=True` (default per `services.py` L65) appears after student pull-to-refresh. |

#### Plan 01 Must-Have Truths (Backend)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| P1-1 | GET /api/v1/banners returns list of enabled banners ordered by display_order | ✓ VERIFIED | `controllers.py` L40-50: `@banners_router.get("")` calls `list_banners(db, enabled_only=True)`. `services.py` L30-32: `order_by(display_order.asc(), created_at.desc())` with `where(is_enabled.is_(True))`. Wired into `main.py` L138: `app.include_router(banners_router, prefix="/api/v1")`. |
| P1-2 | POST /api/v1/banners/upload creates a new banner from uploaded image file | ✓ VERIFIED | `controllers.py` L72-126: `@banners_router.post("/upload")` with `UploadFile`, validates content_type in `{"image/jpeg", "image/png", "image/webp"}`, enforces 2MB limit, saves to `uploads/banners/{uuid}_{filename}`, creates banner record. Returns 201. |
| P1-3 | PUT /api/v1/banners/{id} toggles is_enabled status | ✓ VERIFIED | `controllers.py` L133-145: `@banners_router.put("/{banner_id}")` accepts `BannerUpdate` body, calls `update_banner`. `services.py` L80-84: partial update — only sets fields that are not None. |
| P1-4 | DELETE /api/v1/banners/{id} removes banner and its file from disk | ✓ VERIFIED | `controllers.py` L152-172: `@banners_router.delete("/{banner_id}")` calls `delete_banner` to get image_url, removes file via `os.remove` (try/except for missing), returns `{"deleted": True}`. |
| P1-5 | Only staff or provider roles can manage banners | ✓ VERIFIED | `controllers.py`: `require_staff(user)` called on all management endpoints — GET `/all` (L63), POST `/upload` (L85), PUT `/{id}` (L141), DELETE `/{id}` (L162). Public GET `""` has no auth dependency. |
| P1-6 | Student-facing GET endpoint returns only enabled banners without authentication requirement filtering | ✓ VERIFIED | `controllers.py` L40-50: `list_enabled_banners` has no `Depends(get_current_user_or_service)` — public endpoint. Passes `enabled_only=True` to filter. |

#### Plan 02 Must-Have Truth (add-on: uploaded banners appear immediately)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| P2-1 | Uploaded banners appear immediately in the grid without manual refresh | ✓ VERIFIED | `banner_management_provider.dart` L31-33: after `upload()`, calls `ref.invalidateSelf()` which triggers re-fetch of all banners. Toggle uses optimistic local state update (L40-44). Delete uses optimistic removal (L61-62). |

**Score:** 13/13 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `backend/src/features/banners/models.py` | Banner SQLAlchemy model | ✓ VERIFIED | 46 lines, `class Banner(Base)`, 6 columns, composite index `idx_banners_enabled_order` |
| `backend/src/features/banners/schemas.py` | BannerResponse + BannerUpdate | ✓ VERIFIED | 33 lines, `BannerResponse` with `from_attributes`, `BannerUpdate` with optional fields |
| `backend/src/features/banners/services.py` | BannerService CRUD | ✓ VERIFIED | 105 lines, 5 methods (list/get/create/update/delete), singleton `banner_service` |
| `backend/src/features/banners/controllers.py` | 5 CRUD endpoints | ✓ VERIFIED | 172 lines, `banners_router` with GET, GET/all, POST/upload, PUT/{id}, DELETE/{id} |
| `backend/src/features/banners/routes.py` | Route registration | ✓ VERIFIED | 13 lines, imports and exports `banners_router` |
| `backend/alembic/versions/021a_create_banners_table.py` | Alembic migration | ✓ VERIFIED | 63 lines, `create_table("banners")`, 6 columns, index, `down_revision = "020a"` |
| `backend/src/features/banners/__init__.py` | Package init | ✓ VERIFIED | Exists |
| `mobile/lib/features/staff/models/banner_model.dart` | BannerModel | ✓ VERIFIED | 47 lines, `class BannerModel` with `fromJson`, `copyWith` |
| `mobile/lib/features/staff/services/banner_service.dart` | API client | ✓ VERIFIED | 62 lines, `class BannerService` with `fetchAll`, `upload`, `toggleEnabled`, `deleteBanner` |
| `mobile/lib/features/staff/providers/banner_management_provider.dart` | Riverpod state | ✓ VERIFIED | 74 lines, `bannersProvider` as `AsyncNotifierProvider`, optimistic updates |
| `mobile/lib/features/staff/screens/staff_banner_management_screen.dart` | Management screen | ✓ VERIFIED | 343 lines, `StaffBannerManagementScreen`, GridView, GlassCard, Switch, delete dialog, FAB |
| `mobile/lib/features/client/providers/banner_provider.dart` | Student banner provider | ✓ VERIFIED | 48 lines, `studentBannersProvider`, `BannerItem` model, GET `/banners` |
| `mobile/lib/features/client/screens/widgets/banner_carousel.dart` | Carousel widget | ✓ VERIFIED | 216 lines, `BannerCarousel`, auto-scroll Timer, PageView, expanding dots, edge cases |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `backend/src/main.py` | `banners_router` | `app.include_router` | ✓ WIRED | L43: import, L138: `include_router(banners_router, prefix="/api/v1")`, L149: `os.makedirs("uploads/banners")` |
| `controllers.py` | `services.py` | `banner_service.method()` | ✓ WIRED | L49: `banner_service.list_banners`, L64: same, L123: `create_banner`, L142: `update_banner`, L163: `delete_banner` |
| `staff_dashboard_screen.dart` | `StaffBannerManagementScreen` | `context.go(RoutePaths.staffBanners)` | ✓ WIRED | L320: `context.go(RoutePaths.staffBanners)` on "Gerenciar Banners" card |
| `app_router.dart` | `StaffBannerManagementScreen` | GoRoute registration | ✓ WIRED | L33: import, L350-355: GoRoute `path: RoutePaths.staffBanners, name: RouteNames.staffBanners` |
| `client_home_screen.dart` | `BannerCarousel` | Widget insertion | ✓ WIRED | L15: import provider, L21: import carousel, L59: `ref.watch(studentBannersProvider)`, L150: `BannerCarousel(banners: banners)` |
| `banner_provider.dart` | `/api/v1/banners` | DioClient GET | ✓ WIRED | L41: `client.dio.get('/banners')` — fetches from public endpoint |
| `route_names.dart` | staffBanners route | Route constants | ✓ WIRED | L31: `RouteNames.staffBanners = 'staff-banners'`, L67: `RoutePaths.staffBanners = '/staff/banners'` |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `banner_carousel.dart` | `banners` (List\<BannerItem\>) | `studentBannersProvider` → GET `/banners` → `banner_service.list_banners(db, enabled_only=True)` → `select(Banner)` DB query | Yes — SQLAlchemy query against banners table | ✓ FLOWING |
| `staff_banner_management_screen.dart` | `bannersAsync` (List\<BannerModel\>) | `bannersProvider` → `BannerService.fetchAll()` → GET `/banners/all` → `banner_service.list_banners(db, enabled_only=False)` → DB query | Yes — SQLAlchemy query | ✓ FLOWING |
| `client_home_screen.dart` | `bannersAsync` | `ref.watch(studentBannersProvider)` → same flow as carousel | Yes — propagated via prop to BannerCarousel | ✓ FLOWING |

### Behavioral Spot-Checks

Step 7b: SKIPPED (requires running backend server and Flutter app — no runnable entry points available in static analysis)

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| BNNR-01 | 26-01, 26-03 | Painel do aluno exibe carrossel de banners abaixo do card de saudacao com rolagem automatica | ✓ SATISFIED | `client_home_screen.dart` L140-155: carousel below greeting card. `banner_carousel.dart` L68: 4s auto-scroll |
| BNNR-02 | 26-01, 26-03 | Carrossel passa automaticamente por todos os banners habilitados no sistema | ✓ SATISFIED | `banner_carousel.dart` L70: modulo loop through all banners. `banner_provider.dart` fetches enabled banners |
| BNNR-03 | 26-01, 26-02 | Staff/provider acessa tela de gestao de banners para upload de novos banners | ✓ SATISFIED | Dashboard card L320 → StaffBannerManagementScreen → FAB upload with FilePicker |
| BNNR-04 | 26-01, 26-02 | Staff/provider pode excluir banners existentes da tela de gestao | ✓ SATISFIED | `_handleDelete` L300-342 with confirmation dialog → API DELETE endpoint |
| BNNR-05 | 26-01, 26-02 | Tela de gestao exibe preview dos banners habilitados | ✓ SATISFIED | GridView of GlassCards with Image.network thumbnails; GET `/banners/all` returns all banners |
| BNNR-06 | 26-01, 26-02, 26-03 | Banners enviados ficam imediatamente visiveis para todos os alunos | ✓ SATISFIED | Upload creates with `is_enabled=True` default; student refresh invalidates `studentBannersProvider`; GET `/banners` returns enabled |

**All 6 BNNR requirements SATISFIED.** No orphaned requirements.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | No TODO/FIXME/PLACEHOLDER in any banner-related file | — | — |
| — | — | No stub implementations found | — | — |
| — | — | No console.log-only handlers | — | — |

**Clean scan — no anti-patterns detected in phase 26 files.**

### Human Verification Required

### 1. Carousel Auto-Scroll Behavior
**Test:** Open student home screen with 2+ enabled banners
**Expected:** Carousel auto-scrolls every ~4 seconds with smooth 500ms easeInOut transition. Continuous loop: last → first banner seamlessly.
**Why human:** Timer-driven animation timing and visual smoothness cannot be verified statically

### 2. Manual Swipe Pause/Resume
**Test:** Swipe the carousel manually during auto-scroll
**Expected:** Auto-scroll pauses immediately. After ~6 seconds of no interaction, auto-scroll resumes.
**Why human:** User interaction → timer cancellation → delayed restart requires runtime behavior

### 3. Staff Banner Upload Flow
**Test:** Navigate to staff dashboard → tap "Gerenciar Banners" → tap FAB → select image → upload
**Expected:** File picker opens with JPG/PNG/WebP filter. After selection, banner appears in grid immediately. "Banner adicionado" snackbar shown.
**Why human:** End-to-end upload flow with file picker, API call, and UI update requires running app + backend

### 4. Toggle Enable/Disable
**Test:** Toggle Switch on a banner card in management screen
**Expected:** Badge changes "Ativo" ↔ "Inativo" immediately (optimistic). If API fails, reverts.
**Why human:** Optimistic state update and error rollback are runtime behaviors

### 5. Delete with Confirmation
**Test:** Tap delete icon on banner card → confirm in dialog
**Expected:** Dialog shows "Excluir banner?" with Cancel/Excluir buttons. Confirming removes banner from grid and deletes file on server.
**Why human:** Dialog flow and cascade deletion require runtime

### 6. Edge Cases: 0 and 1 Banner
**Test:** Test carousel with 0 banners and with exactly 1 banner
**Expected:** 0 banners = carousel section invisible (SizedBox.shrink). 1 banner = static image, no animation, no dots.
**Why human:** Visual rendering of edge cases requires live app

### Gaps Summary

No gaps found. All 13 must-have truths verified across 3 plans. All 6 BNNR requirements satisfied. All 13 artifacts exist, are substantive, and are properly wired. Data flows trace from DB queries through API endpoints to Flutter widgets. No anti-patterns detected.

**Status is `human_needed` because the phase produces UI with runtime behaviors (auto-scroll timing, swipe gestures, optimistic state updates, file upload flow) that require manual testing to fully validate.**

---

_Verified: 2026-05-15T06:00:00Z_
_Verifier: the agent (gsd-verifier)_
