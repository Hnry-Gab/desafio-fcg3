# Phase 25: Melhorias FrontEnd - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-11
**Phase:** 25-melhorias-frontend
**Areas discussed:** Light mode contrast strategy, Date formatting standard, Favicon & web branding

---

## Light Mode Contrast Strategy

### Q1: How should we fix the light mode contrast issue?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Darker primary in light mode | Use #00838F (or similar dark teal) as ColorScheme.primary for light mode. All text/icons using colors.primary automatically become readable. | ✓ |
| Keep #00E5FF, selective overrides | Keep #00E5FF as ColorScheme.primary but override text/icon colors to onSurface or a custom readable teal where contrast matters. | |
| Split: bright for decoration, dark for text | Two-tier: #00E5FF for decorative elements and #006064 for text/icons. | |

**User's choice:** Darker primary in light mode (Recommended)
**Notes:** Clean approach — ColorScheme propagation handles most cases automatically.

### Q2: Which specific shade for the light mode primary?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| #00838F (existing neonTealLight) | Already defined in app_colors.dart. ~4.7:1 contrast — just passes WCAG AA. | |
| #00695C (darker, more contrast) | ~5.6:1 contrast. More breathing room above WCAG AA minimum. Material teal-800. | ✓ |
| You decide (agent discretion) | Agent picks within WCAG-compliant range. | |

**User's choice:** #00695C (darker, more contrast)
**Notes:** Provides comfortable margin above minimum WCAG AA threshold.

---

## Date Formatting Standard

### Q1: How should date formatting be standardized?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Shared utility, no new package | Create shared date_utils.dart with formatDate, formatDateTime, formatRelativeTime. Manual padLeft implementation kept. | ✓ |
| Add intl package with DateFormat | Add `intl` package, use DateFormat with pt_BR locale. Cleaner code, adds dependency. | |
| Fix in-place, no extraction | Keep functions per-screen but unify vocabulary/format. | |

**User's choice:** Shared utility, no new package (Recommended)
**Notes:** Avoids new dependency while centralizing logic.

### Q2: When should dates show the year?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Always show year (DD/MM/YYYY) | No ambiguity, explicit year. Longer but clear. | |
| Omit year if current year | Saves space for recent dates. Show full if different year. | ✓ |
| You decide | Agent decides based on context. | |

**User's choice:** Omit year if current year
**Notes:** Space-efficient for recent dates which are the majority.

### Q3: Vocabulary for relative timestamps?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| "há X min/h/dias" (formal PT-BR) | Formal Portuguese with preposition. Consistent with formal UI text. | |
| Short form (5m, 2h, 3d) | Compact, no preposition. Fits tight spaces. | ✓ |
| Relative <24h, then absolute | Only use relative within 24h. | |

**User's choice:** Short form (5m, 2h, 3d)
**Notes:** Matches the compact, modern UI aesthetic of the app.

### Q4: When should relative time switch to absolute date?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Relative up to 7 days | "5m", "2h", "3d", "7d", then absolute date. | ✓ |
| Relative up to 24h only | Relative only within same day. | |
| You decide | Agent decides threshold. | |

**User's choice:** Relative up to 7 days (Recommended)
**Notes:** 7 days gives good coverage for "recent activity" context.

---

## Favicon & Web Branding

### Q1: What should the favicon/PWA icon be?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Alpha mark (α) from existing SVG | Convert α mark from short_logo SVG to PNGs at all sizes. Clean, recognizable. | ✓ |
| New custom icon design | Design new simplified icon. Requires new asset. | |
| You decide | Agent picks best approach. | |

**User's choice:** Alpha mark (α) from existing SVG (Recommended)
**Notes:** Leverages existing brand asset, recognizable at small sizes.

### Q2: What theme_color and description for manifest.json?

| Option | Description | Selected |
| ------ | ----------- | -------- |
| Dark theme branding | theme_color=#111317, background_color=#111317, name="Alpha Connect", description="Plataforma Acadêmica - Ciência da Computação" | ✓ |
| Light theme branding | theme_color=#00695C, background_color=#F5F5F7, name="Alpha Connect" | |
| You decide | Agent picks colors and text. | |

**User's choice:** Dark theme branding (Recommended)
**Notes:** App's primary identity is the dark cyber-academic aesthetic.

---

## Agent's Discretion

- Exact overflow fix strategy per screen (Expanded vs Flexible vs maxLines)
- Which specific grammar errors exist beyond "Requer Aprovação"
- Whether fontSize: 10 nav labels need adjustment
- PNG conversion approach for favicon
- Additional light mode contrast issues discovered during implementation

## Deferred Ideas

None — discussion stayed within phase scope.
