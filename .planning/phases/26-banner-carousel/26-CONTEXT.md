# Phase 26: Banner Carousel - Context

**Gathered:** 2026-05-15
**Status:** Ready for planning

<domain>
## Phase Boundary

Students see an auto-scrolling banner carousel on their home screen displaying banners registered by staff/provider. Staff and provider can access a dedicated banner management screen to upload, delete, enable/disable, and preview banners. All enabled banners are immediately visible to all students.

</domain>

<decisions>
## Implementation Decisions

### Comportamento do carrossel

- **D-01:** Auto-scroll moderado (4-5 segundos) com transição suave entre banners
- **D-02:** Suporte a swipe manual — ao arrastar, auto-scroll pausa e retoma após alguns segundos
- **D-03:** Dots indicadores de posição abaixo do carrossel (padrão de mercado)
- **D-04:** 1 banner habilitado = exibição estática sem animação nem dots; 0 banners = seção inteira fica invisível
- **D-05:** Carrossel faz loop contínuo (volta ao primeiro banner após o último)

### Modelo de dados

- **D-06:** Modelo minimalista: imagem (URL do arquivo), flag `is_enabled`, campo `display_order` (int), `created_at`, `updated_at`
- **D-07:** Formatos aceitos: JPG, PNG, WebP. Tamanho máximo: 2MB. Aspect ratio livre
- **D-08:** Altura fixa no carrossel com `BoxFit.cover` — visual consistente independente da proporção da imagem

### Tela de gestão

- **D-09:** Acesso via card "Gerenciar Banners" na seção Ações Rápidas do dashboard staff/provider (não é nova aba no bottom nav)
- **D-10:** Layout: grid de cards com thumbnail do banner, badge habilitado/desabilitado, botão excluir. FAB (+) para upload (consistente com pattern de Cadastro de Alunos)
- **D-11:** Sem preview ao vivo do carrossel no topo da tela — o grid de cards é suficiente
- **D-12:** Toggle Switch direto no card para habilitar/desabilitar banners sem excluir (pattern existente em Recursos com `_ResourceCard`)

### Permissões

- **D-13:** Tanto staff quanto provider podem gerenciar banners (upload, excluir, habilitar/desabilitar)

### Agent's Discretion

- Implementação exata do widget de carrossel (PageView nativo ou pacote externo como `smooth_page_indicator`)
- Exact height value for the carousel (e.g., 160px, 180px, 200px)
- Animação de transição entre banners (fade, slide)
- Estilo visual dos dots indicadores (cor, tamanho)
- Ordem de exibição no grid de gestão (por data de criação, por ordem, etc.)
- Loading state enquanto imagens carregam

</decisions>

<canonical_refs>

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Student home screen
- `mobile/lib/features/client/screens/client_home_screen.dart` — Tela onde o carrossel será inserido (entre greeting card e summary cards)
- `mobile/lib/features/client/screens/widgets/` — Widgets compartilhados da interface do aluno

### Upload patterns (reuse)
- `mobile/lib/features/client/screens/widgets/booking_flow_sheet.dart` — FilePicker + upload pattern (withData: true, MultipartFile.fromBytes)
- `mobile/lib/features/client/services/resource_booking_service.dart` — Service layer upload example
- `backend/src/features/documents/controllers.py` — Backend upload endpoint pattern (UploadFile, UUID prefix, size validation)
- `backend/src/features/appointments/controllers.py` — Authorization upload endpoint (content type validation)

### Staff/Provider navigation
- `mobile/lib/core/router/app_router.dart` — Router configuration for new screens
- `mobile/lib/core/router/route_names.dart` — Route names/paths registration
- `mobile/lib/features/staff/screens/staff_dashboard_screen.dart` — "Ações Rápidas" section where "Gerenciar Banners" card will be added
- `mobile/lib/features/staff/screens/staff_shell.dart` — Staff shell navigation structure

### Toggle pattern (reuse)
- `mobile/lib/features/staff/screens/staff_resources_screen.dart` — `_ResourceCard` with Switch toggle + PopupMenu (delete, enable/disable)

### Static file serving
- `backend/src/main.py` — StaticFiles mount at `/uploads`, directory creation pattern

### Feature slice pattern
- `backend/src/features/notifications/` — Canonical example of feature slice structure (controllers, models, schemas, services, routes)

### Alembic migrations
- `backend/alembic/versions/020_add_blocked_verification_status.py` — Latest migration (next: 021a)

</canonical_refs>

<code_context>

## Existing Code Insights

### Reusable Assets

- **FilePicker + MultipartFile.fromBytes**: Upload pattern pronto para cross-platform (web + mobile). Usado em booking_flow_sheet.dart e resource_booking_service.dart
- **GlassCard**: Componente de card com glassmorphism usado em toda a interface — usar para cards do grid de gestão
- **AnimatedEntrance**: Widget de animação de entrada para seções — carrossel deve usar com delay index
- **StaticFiles mount**: `/uploads` já serve arquivos — basta criar `uploads/banners/` no startup
- **Switch toggle pattern**: `_ResourceCard` em staff_resources_screen.dart já implementa toggle enable/disable

### Established Patterns

- **Feature slice**: `controllers.py` + `models.py` + `schemas.py` + `services.py` + `routes.py` em `backend/src/features/banners/`
- **Riverpod providers**: StateNotifierProvider para estado reativo (fetch + cache de banners)
- **GoRouter + _fadeThroughPage**: Padrão de registro de novas telas no router
- **RefreshIndicator**: Pull-to-refresh no home screen — bannerProvider deve ser adicionado ao _onRefresh()
- **UUID prefix naming**: Uploads salvos como `{uuid4}_{filename}` para evitar colisões

### Integration Points

- **Student home screen**: Inserir carrossel entre greeting card (line ~133) e summary cards (line ~135) em client_home_screen.dart
- **Staff dashboard**: Adicionar card "Gerenciar Banners" na seção Ações Rápidas (staff_dashboard_screen.dart line ~258)
- **Provider dashboard**: Mesmo card de Ações Rápidas (provider_home_screen.dart ou equivalente)
- **Backend main.py**: `app.include_router(banners_router, prefix="/api/v1")` + `os.makedirs("uploads/banners", exist_ok=True)`
- **Alembic**: Migration 021a cria tabela `banners`

</code_context>

<specifics>
## Specific Ideas

- Carrossel posicionado logo abaixo do card de saudação do aluno — é o primeiro conteúdo visual após o greeting
- Grid de gestão segue o mesmo pattern visual de Cadastro de Alunos (FAB, cards, ações)
- Toggle habilitar/desabilitar segue pattern de Recursos (Switch direto no card)
- Acesso via Ações Rápidas, não bottom nav — mantém o nav limpo

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

_Phase: 26-banner-carousel_
_Context gathered: 2026-05-15_
