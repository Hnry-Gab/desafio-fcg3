---
status: awaiting_human_verify
trigger: "Student DOCS screen filters are insufficient — should match staff view with per-state filters"
created: 2026-05-13T00:00:00Z
updated: 2026-05-13T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED — Student documents screen only has 3 tabs (Ver todos, Pendentes, Prontos) while staff has 5 (Todos, Solicitado, Processando, Prontos, Entregue)
test: Direct code comparison confirms gap
expecting: N/A — root cause confirmed
next_action: Implement fix — add per-state filter tabs matching staff view

## Symptoms

expected: Student documents screen should have filter tabs for each document status: Todos, Solicitados, Processando, Prontos, Entregues (matching the staff view pattern)
actual: The student documents screen has too few filter options — likely only basic ones
errors: No error — just missing filter functionality
reproduction: Go to student documents screen, observe limited filter tabs
started: Original implementation didn't include per-state filters for the student view

## Eliminated

## Evidence

- timestamp: 2026-05-13T00:01:00Z
  checked: client_documents_screen.dart filter tabs (lines 84-106)
  found: Only 3 tabs — "Ver todos" (null), "Pendentes" ('pending'), "Prontos" ('ready')
  implication: Missing individual status tabs for 'requested', 'processing', 'delivered'

- timestamp: 2026-05-13T00:01:00Z
  checked: staff_documents_screen.dart filter tabs (lines 86-124)
  found: 5 tabs — "Todos", "Solicitado" (requested), "Processando" (processing), "Prontos" (ready), "Entregue" (delivered)
  implication: Staff has complete per-state filters; student screen should match

- timestamp: 2026-05-13T00:01:00Z
  checked: document_provider.dart DocumentFilter notifier (lines 24-30)
  found: Provider already supports arbitrary string? filter — no provider changes needed
  implication: Fix is purely in the screen file — update tabs and filter logic

- timestamp: 2026-05-13T00:01:00Z
  checked: _applyFilter in client screen (lines 176-188)
  found: Logic only handles null, 'pending' (isPending = requested OR processing), and 'ready'
  implication: Need to update filter logic to handle each individual status

## Resolution

root_cause: Client documents screen was implemented with only 3 simplified filters (Todos/Pendentes/Prontos) instead of per-state filters matching the staff view (Todos/Solicitados/Processando/Prontos/Entregues)
fix: Update filter tabs to show all 5 states and update _applyFilter to use direct status comparison
verification: flutter analyze passes (0 errors); filter tabs now match staff pattern with 5 states; _applyFilter simplified to direct status comparison
files_changed: [mobile/lib/features/client/screens/client_documents_screen.dart]
