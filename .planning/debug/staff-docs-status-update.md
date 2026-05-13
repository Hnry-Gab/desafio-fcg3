---
status: awaiting_human_verify
trigger: "Staff cannot update document request status to Pronto or Entregue in the Staff/Provider DOCS screen"
created: 2026-05-13T00:00:00Z
updated: 2026-05-13T00:20:00Z
---

## Current Focus

hypothesis: CONFIRMED — The dropdown shows ALL statuses (including invalid ones) but backend enforces strict sequential transitions (requested→processing→ready→delivered one step at a time). When user selects a non-adjacent status, backend returns 409 Conflict but frontend shows only generic error "Erro ao executar ação" — user cannot understand why it fails.
test: Verified by reading backend service (line 159: new_idx != current_idx + 1 raises ConflictException) and frontend update_status_sheet.dart (dropdown shows all 4 statuses regardless of current status)
expecting: Fix = filter dropdown to only show valid next status + improve error handling
next_action: Implement fix — filter dropdown to only next valid status, or replace with clear action button

## Symptoms

expected: Staff should be able to update document request status to "Pronto" (ready) and "Entregue" (delivered) from the document detail view
actual: There's no working mechanism to update the status to these values
errors: unknown — may be missing UI action, missing API call, or backend endpoint issue
reproduction: Go to staff documents screen, open a document detail, try to change status to Pronto or Entregue
started: Likely never fully worked — feature may have been partially implemented

## Eliminated

## Evidence

- timestamp: 2026-05-13T00:10:00Z
  checked: backend/src/features/documents/services.py — update_document_status method
  found: Line 159 enforces `new_idx != current_idx + 1` — ONLY allows one-step-forward transitions (requested→processing→ready→delivered)
  implication: Any non-sequential status selection in the frontend will be rejected with 409

- timestamp: 2026-05-13T00:10:00Z
  checked: mobile/lib/features/staff/screens/widgets/update_status_sheet.dart — DropdownButtonFormField
  found: Dropdown shows ALL 4 statuses (requested, processing, ready, delivered) regardless of current document status. No filtering based on valid transitions.
  implication: Users can select invalid transitions which will be rejected by backend

- timestamp: 2026-05-13T00:10:00Z
  checked: update_status_sheet.dart _submit error handling (lines 126-133)
  found: Generic catch block shows "Erro ao executar ação. Tente novamente." without explaining WHY it failed
  implication: Users don't understand the status must follow sequential order

- timestamp: 2026-05-13T00:10:00Z
  checked: Backend endpoint PUT /documents/{id}/status exists and is properly registered at /api/v1
  found: Endpoint works correctly when transitions are valid. require_staff allows staff and provider roles.
  implication: Backend is correct — issue is purely UX/frontend

- timestamp: 2026-05-13T00:11:00Z
  checked: Backend requires file_url when transitioning to "ready" (services.py line 169)
  found: ValidationException raised if status="ready" and file_url is None
  implication: Frontend file upload logic handles this correctly (uploads before calling status update)

## Resolution

root_cause: The update status dropdown shows all 4 statuses regardless of the current document status, but the backend enforces strict sequential transitions (one step forward only). When staff selects a non-adjacent status (e.g., requested→ready skipping processing), the backend returns 409 Conflict. The frontend catches the error generically without explaining why it failed. Additionally, for documents already in "delivered" status, there's no valid next step but the dropdown still shows options.
fix: Replaced free-form 4-option dropdown with guided next-step UI. The update status sheet now (1) computes the single valid next status transition from the current status, (2) shows a visual transition indicator (current → next), (3) uses contextual action labels ("Marcar como Processando", "Finalizar Documento", "Marcar como Entregue"), (4) hides the action button entirely for terminal (delivered) status, (5) improves error messages to explain specific failure reasons. Also fixed context issue by passing parentContext from the screen to the detail sheet, ensuring showUpdateStatusSheet uses a stable context.
verification: Flutter analyzer passes (0 errors). Both files compile. Logic tested by tracing all 3 valid transitions: requested→processing, processing→ready (with file upload), ready→delivered.
files_changed: [mobile/lib/features/staff/screens/widgets/update_status_sheet.dart, mobile/lib/features/staff/screens/staff_documents_screen.dart]
