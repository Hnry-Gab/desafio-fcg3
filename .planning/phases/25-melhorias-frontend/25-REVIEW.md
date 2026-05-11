---
phase: 25-melhorias-frontend
reviewed: 2026-05-11T17:15:00Z
depth: standard
files_reviewed: 12
files_reviewed_list:
  - mobile/lib/shared/utils/date_utils.dart
  - mobile/lib/core/theme/app_colors.dart
  - mobile/lib/core/theme/app_theme.dart
  - mobile/lib/features/client/screens/client_shell.dart
  - mobile/lib/shared/widgets/alpha_connect_logo.dart
  - mobile/web/manifest.json
  - mobile/web/index.html
  - mobile/lib/features/staff/screens/staff_dashboard_screen.dart
  - mobile/lib/features/auth/screens/login_screen.dart
  - mobile/lib/features/client/screens/client_home_screen.dart
  - mobile/lib/features/client/screens/client_chat_screen.dart
  - mobile/lib/features/client/providers/notification_provider.dart
findings:
  critical: 0
  warning: 2
  info: 3
  total: 5
status: issues_found
---

# Phase 25: Code Review Report

**Reviewed:** 2026-05-11T17:15:00Z
**Depth:** standard
**Files Reviewed:** 12 (core files plus sampling of 19+ modified screen files via grep)
**Status:** issues_found

## Summary

Phase 25 implements four plans: light mode WCAG AA contrast fix, favicon/PWA branding, centralized date formatting utility, and overflow/font/grammar fixes across ~30 files. The changes are well-structured and the date_utils refactoring is clean.

Two warnings identified: (1) `formatRelativeTime` produces incorrect output for future timestamps (negative Duration), and (2) several PT-BR accent errors remain unfixed in files outside Plan 04's scope but user-visible. No security issues. No critical bugs.

The core theme, navigation, logo, and web branding changes are all correct and well-implemented.

## Warnings

### WR-01: formatRelativeTime produces misleading output for future timestamps

**File:** `mobile/lib/shared/utils/date_utils.dart:39-48`
**Issue:** When `timestamp` is in the future, `now.difference(timestamp)` produces a negative `Duration`. The `.inMinutes`, `.inHours`, `.inDays` properties return negative values. Since `diff.inMinutes < 1` is true for any negative duration, future timestamps always return `'agora'` — which is arguably acceptable but semantically incorrect (e.g., an appointment 2 hours from now would show "agora" instead of the actual date). The notification_provider.dart creates notifications for upcoming appointments (line 118-126) whose `timestamp` is a future date, and `formatRelativeTime` is used on notification timestamps in `client_notifications_screen.dart:302`.
**Fix:** Guard against negative durations explicitly:
```dart
String formatRelativeTime(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.isNegative) return formatDate(timestamp);

  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays <= 7) return '${diff.inDays}d';

  return formatDate(timestamp);
}
```

### WR-02: Remaining PT-BR accent errors in user-visible strings

**File:** Multiple files (not in Plan 04's explicit scope but user-visible)
**Issue:** Plan 04 fixed `proximo→próximo`, `sessao→sessão`, `acao→ação` but several other missing-accent strings remain:
- `notification_provider.dart:93` — `'disponivel'` → should be `'disponível'`
- `notification_provider.dart:140-142` — `'Historico Escolar'`, `'Comprovante de Matricula'`, `'Declaracao'`
- `document_detail_sheet.dart:140-142` — same three labels
- `document_request_sheet.dart:33-35,120` — same three labels + `'Observacao'`
- `send_document_sheet.dart:209,213,217` — `'Historico Escolar'`, `'Comprovante de Matricula'`, `'Declaracao'`
- `create_slot_sheet.dart:243` — `'Duracao do slot (minutos)'`
- `staff_dashboard_screen.dart:340` — `'Periodo ativo'` → should be `'Período ativo'`
**Fix:** Apply accent corrections: `Historico→Histórico`, `Matricula→Matrícula`, `Declaracao→Declaração`, `disponivel→disponível`, `Observacao→Observação`, `Duracao→Duração`, `Periodo→Período`. These are all user-facing strings displayed in the UI.

## Info

### IN-01: Residual inline `_formatTime` functions not consolidated

**File:** 5 files still contain private `_formatTime(DateTime dt)` methods
**Issue:** The date_utils.dart refactoring consolidated `_formatDate`, `_formatDateTime`, and `_formatRelativeTime` but left `_formatTime` (time-only HH:MM formatting) as inline private methods in 5 widget files: `client_chat_screen.dart:562`, `client_chat_detail_screen.dart:122`, `staff_chat_detail_screen.dart:288+452`, `staff_ai_screen.dart:399`, `staff_intervention_chat_screen.dart:306`. These are identical implementations.
**Fix:** Consider adding a `formatTime(DateTime dt)` function to `date_utils.dart` and replacing the 5 duplicates. Low priority since these are small and unlikely to diverge.

### IN-02: Dead code guard in `_calculateAiRate`

**File:** `mobile/lib/features/staff/screens/staff_dashboard_screen.dart:305-309`
**Issue:** The `if (total == 0) return 0;` check on line 307 can never be true because `total = dashboard.activeChatSessions + 10` always yields at least 10 (activeChatSessions is an int, minimum 0). The mock baseline `+ 10` makes the guard unreachable.
**Fix:** Remove the dead guard or document it as defensive coding for when the mock baseline is removed. Minor — no functional impact.

### IN-03: `_SearchBar` widget is non-functional (no filtering wired)

**File:** `mobile/lib/features/client/screens/client_chat_screen.dart:390-415`
**Issue:** The `_SearchBar` widget renders a text field with "Buscar conversas..." placeholder but has no `onChanged` callback, no controller, and no connection to any search/filter state. It's a visual placeholder with no functionality.
**Fix:** Either wire it to a search provider (like the staff side's `staffChatsSearchProvider`) or add a comment marking it as a future feature.

---

_Reviewed: 2026-05-11T17:15:00Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
