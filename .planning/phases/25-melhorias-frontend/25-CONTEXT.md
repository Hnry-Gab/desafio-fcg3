# Phase 25: Melhorias FrontEnd - Context

**Gathered:** 2026-05-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Fix reported visual and UX problems in the Flutter frontend: pixel overflow, light/dark mode contrast, font sizes, custom favicon replacing Flutter default, Alpha logo adequacy in both modes, standardized date formats, grammar corrections, and removal of the support icon from desktop navigation. This is a correction/polish phase — no new features, no new screens.

</domain>

<decisions>
## Implementation Decisions

### Light Mode Contrast

- **D-01:** Replace light mode `ColorScheme.primary` from `#00E5FF` (1.5:1 contrast on light surface) to `#00695C` (~5.6:1 contrast). This cascades to all text, icons, and badges referencing `colors.primary` in light mode.
- **D-02:** Dark mode primary remains `#00E5FF` unchanged — already has ~14:1 contrast on `#111317` surface.
- **D-03:** `neonTealLight = #00838F` remains as-is for glow effects (Phase 17 decision). The new `#00695C` is specifically for the Material ColorScheme primary in light mode.
- **D-04:** Review all explicit `color: colors.primary` usages in light mode to ensure they now pass WCAG AA 4.5:1 minimum. The ColorScheme change should handle most, but check hardcoded hex values.

### Date Formatting

- **D-05:** Create a shared utility file `mobile/lib/shared/utils/date_utils.dart` with functions: `formatDate`, `formatDateTime`, `formatRelativeTime`. All screens import from this single source.
- **D-06:** No new package dependency — keep manual `padLeft` implementation in the shared utility.
- **D-07:** Year display rule: omit year if the date is in the current year, show full `DD/MM/YYYY` if different year.
- **D-08:** Relative time vocabulary (short form): "agora" (< 1 min), "5m" (minutes), "2h" (hours), "3d" (days).
- **D-09:** Relative-to-absolute threshold: use relative time up to 7 days, then switch to absolute date format (DD/MM or DD/MM/YYYY per D-07).
- **D-10:** Remove all 12+ duplicated `_formatDateTime` / `_formatDate` / `_relativeTime` inline functions from individual screens and replace with shared utility calls.

### Favicon & Web Branding

- **D-11:** Convert the α mark from `mobile/assets/logos/alpha_connect_shortlogo_dark.svg` to PNG favicon/icon at all required sizes: 16x16, 32x32, 192x192, 512x512, and maskable variants.
- **D-12:** Replace all default Flutter icons: `favicon.png`, `Icon-192.png`, `Icon-512.png`, `Icon-maskable-192.png`, `Icon-maskable-512.png`.
- **D-13:** Update `manifest.json`: `name = "Alpha Connect"`, `short_name = "Alpha Connect"`, `description = "Plataforma Acadêmica - Ciência da Computação"`, `theme_color = "#111317"`, `background_color = "#111317"`.
- **D-14:** Update `index.html` meta description to "Alpha Connect - Plataforma Acadêmica".

### Pixel Overflow Fixes

- **D-15:** Fix `staff_dashboard_screen.dart` lines 188-211: "Taxa de Resolução Automatizada" text in Row needs `Expanded` or `Flexible` wrapper to prevent overflow on narrow screens (iPhone SE width).
- **D-16:** Audit all Row widgets with unwrapped Text children for potential overflow — fix any additional instances found. Priority on screens visible at 360dp width.
- **D-17:** OTP code input row (6x SizedBox width: 44 = 264px + spacing) — verify it doesn't overflow on iPhone SE (320dp). If so, reduce SizedBox width or use `Flexible`.

### Support Icon Removal (Desktop)

- **D-18:** Remove the 5th `NavigationRailDestination` ("Suporte") from `client_shell.dart` desktop NavigationRail — it has no handler and is redundant (support accessible via AppBarActions header icon).
- **D-19:** Verify `_onTap` handler in client_shell only handles indices 0-3 (no dead code for index 4 after removal).

### Logo Alpha

- **D-20:** Logo decisions from Phase 17 (D-09 through D-13) are already implemented. Verify logo displays adequately in both light and dark modes at current sizes.
- **D-21:** If any visual issues remain with logo contrast or size in either mode, apply minimal fixes consistent with Phase 17 decisions.

### Grammar & Text Corrections

- **D-22:** Fix grammar error: "Requer Aprovação" — correct capitalization and wording per PT-BR standards throughout the app.
- **D-23:** Scan all user-facing strings for PT-BR grammar issues (accent marks, concordância, spelling).
- **D-24:** Agent has discretion on specific text corrections beyond "Requer Aprovação" — identify and fix obvious grammar/spelling errors found during implementation.

### Font Size Adjustments

- **D-25:** Review all `fontSize: 10` occurrences — this is at the minimum readability threshold. Increase to at least 11 where the text carries meaningful information (not just decorative labels).
- **D-26:** Navigation bar labels at `fontSize: 10` may stay (constrained space), but other status badges and tags should be at least 11–12.

### Agent's Discretion

- Exact overflow fix strategy per screen (Expanded vs Flexible vs maxLines with ellipsis)
- Which specific grammar errors exist beyond "Requer Aprovação"
- Whether `fontSize: 10` nav labels need adjustment (space-constrained)
- Exact PNG conversion approach for favicon (tool choice)
- Any additional light mode contrast issues discovered during `#00695C` integration

</decisions>

<canonical_refs>

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Theme & Colors

- `mobile/lib/core/theme/app_colors.dart` — Color definitions. Lines 9-40: light colors, lines 42-73: dark colors, lines 75-78: neon glow colors. Primary `#00E5FF` to be changed to `#00695C` for light mode only.
- `mobile/lib/core/theme/app_theme.dart` — Full ThemeData for light and dark modes. Font configuration (Montserrat), responsive typography scaling, button/nav font sizes.

### Prior Phase Decisions (Carry Forward)

- `.planning/phases/10-cross-platform-polish/10-CONTEXT.md` — D-16/D-17/D-18 dark mode support, D-19 WCAG AA requirements
- `.planning/phases/17-ui-polish-nav-animations-glows-logo/17-CONTEXT.md` — D-05 through D-08: light mode glow palette; D-09 through D-13: logo decisions

### Target Files (Overflow & Contrast)

- `mobile/lib/features/staff/screens/staff_dashboard_screen.dart` — Lines 188-211: overflow-prone Row
- `mobile/lib/features/client/screens/client_shell.dart` — Lines 87-91: ghost NavigationRailDestination to remove
- `mobile/lib/features/auth/screens/login_screen.dart` — Lines 423-425: OTP row potential overflow

### Date Formatting (Files to Refactor)

- `mobile/lib/features/client/screens/client_home_screen.dart` — `_formatDateTime` (DD/MM HH:MM)
- `mobile/lib/features/client/screens/client_documents_screen.dart` — `_formatDateTime` (DD/MM/YYYY HH:MM)
- `mobile/lib/features/client/screens/client_chat_screen.dart` — `_formatDate` (DD/MM HH:MM)
- `mobile/lib/features/client/screens/client_chat_detail_screen.dart` — `_formatDate`
- `mobile/lib/features/client/screens/client_notifications_screen.dart` — `_formatRelativeTime`
- `mobile/lib/shared/widgets/document_detail_sheet.dart` — `_formatDateTime`
- `mobile/lib/shared/widgets/appointment_detail_sheet.dart` — `_formatDateTime`
- `mobile/lib/features/staff/screens/staff_documents_screen.dart` — `_formatDateTime`, `_formatDate`
- `mobile/lib/features/staff/screens/staff_appointment_detail_screen.dart` — `_formatDate`
- `mobile/lib/features/staff/screens/staff_ai_screen.dart` — `_formatDate`
- `mobile/lib/features/staff/screens/staff_chat_detail_screen.dart` — `_formatDateTime`
- `mobile/lib/features/staff/screens/staff_chats_screen.dart` — `_relativeTime`
- `mobile/lib/features/staff/screens/staff_intervention_screen.dart` — `_relativeTime`

### Favicon & Web

- `mobile/web/favicon.png` — Current default Flutter favicon (replace)
- `mobile/web/icons/` — PWA icon PNGs (replace all 4)
- `mobile/web/manifest.json` — Metadata to update
- `mobile/web/index.html` — Meta description to update
- `mobile/assets/logos/alpha_connect_shortlogo_dark.svg` — Source SVG for favicon conversion

### Logo

- `mobile/lib/shared/widgets/alpha_connect_logo.dart` — Logo widget implementation
- `mobile/assets/logos/` — All SVG assets (6 files)

</canonical_refs>

<code_context>

## Existing Code Insights

### Reusable Assets

- **AppColors** (`core/theme/app_colors.dart`): Static color constants — needs light primary changed from `#00E5FF` to `#00695C`
- **AlphaConnectLogo** (`shared/widgets/alpha_connect_logo.dart`): Theme-adaptive logo widget, 4 SVG variants, brightness detection
- **GlassCard/GlassBottomNav**: Already have `isDark` branching for glow colors (Phase 17)
- **AppBarActions** (`shared/widgets/app_bar_actions.dart`): Contains support icon accessible from header — desktop rail Suporte item is redundant

### Established Patterns

- **Brightness branching**: `Theme.of(context).brightness == Brightness.dark` used across glass widgets — same pattern for any conditional color usage
- **AsyncValue.when()**: All screens use this pattern — skeleton/error/data callbacks standardized
- **Manual date formatting**: `padLeft(2, '0')` on day/month/hour/minute — to be centralized
- **Client-side filtering**: StateNotifier + filtered lists pattern used across staff screens

### Integration Points

- **ColorScheme propagation**: Changing `primary` in `_lightColorScheme` cascades to entire app — single point of change
- **New shared utility**: `mobile/lib/shared/utils/date_utils.dart` — new file alongside existing shared code
- **Favicon replacement**: Direct file replacement in `mobile/web/` directory
- **NavigationRail**: Removing 5th destination in `client_shell.dart` — no other files affected

</code_context>

<specifics>
## Specific Ideas

- Light mode must still feel "cyber-academic" with teal identity — `#00695C` is a deep teal that maintains brand while being readable
- Short form relative timestamps ("5m", "2h", "3d") match the compact, modern UI aesthetic
- Favicon uses the α mark which is distinctive and recognizable even at 16x16
- Dark theme branding for PWA (theme_color `#111317`) because the app's primary identity is the dark cyber-academic aesthetic

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

_Phase: 25-melhorias-frontend_
_Context gathered: 2026-05-11_
