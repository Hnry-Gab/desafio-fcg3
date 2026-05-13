---
status: awaiting_human_verify
trigger: "In the Staff/Provider CADASTRO screen, trying to register a new user/student generates an error because the backend expects a 'msg' field that the frontend doesn't send."
created: 2026-05-13T00:00:00Z
updated: 2026-05-13T00:00:00Z
---

## Current Focus

hypothesis: The form's _submit() method omits `registration_number` from the POST body; backend's StudentCreate schema requires it → Pydantic returns 422 with `{"msg": "Field required"}` in the detail array
test: Compare form data map keys vs StudentCreate required fields
expecting: `registration_number` is missing from form submission data
next_action: Fix the _submit() method to include `registration_number` from `_raCtrl`

## Symptoms

expected: Staff should be able to register a new student through the cadastro form
actual: Registration fails with an error about a missing "msg" field (Pydantic 422 validation error)
errors: Backend expects "registration_number" field that frontend doesn't include in the request body. Pydantic's 422 response contains `{"msg": "Field required", "loc": ["body", "registration_number"]}`
reproduction: Go to Staff Cadastro screen, fill in the form, submit — 422 error occurs
started: Since StaffCadastroScreen was implemented (field was never included in _submit())

## Eliminated

(none — root cause found on first pass)

## Evidence

- timestamp: 2026-05-13
  checked: _submit() method in staff_cadastro_screen.dart (lines 615-643)
  found: Form builds data map with keys 'name', 'email', 'phone' (optional), 'semester' (optional). The `_raCtrl` controller IS defined (line 591) and populated from `widget.student?.ra` but is NEVER included in the submitted data map.
  implication: `registration_number` is always missing from POST /students body

- timestamp: 2026-05-13
  checked: Backend StudentCreate schema (students/schemas.py line 28)
  found: `registration_number: str = Field(..., min_length=1, max_length=20)` — required field with no default
  implication: Without `registration_number`, Pydantic rejects the request with 422 containing `{"msg": "Field required", "loc": ["body", "registration_number"]}`

- timestamp: 2026-05-13
  checked: StaffStudentModel (staff_student_model.dart line 11-12)
  found: Model has `@JsonKey(name: 'registration_number') final String? ra;` — correctly maps `ra` ↔ `registration_number`
  implication: The model knows the correct JSON key; the form just forgot to include it in the submission

- timestamp: 2026-05-13
  checked: Prior debug session (cadastro-fields-missing.md)
  found: Previously diagnosed same root field mismatch — fix was listed as "(pending)"
  implication: This is the same underlying issue — never fully fixed

## Resolution

root_cause: The `_submit()` method in `staff_cadastro_screen.dart` (line 619-628) builds the request body without including `registration_number` from `_raCtrl`. Since `StudentCreate` on the backend requires `registration_number`, Pydantic returns a 422 validation error with `msg: "Field required"` — which the user sees as "backend expects a msg field."
fix: (1) Added `registration_number` from `_raCtrl` to the submitted data map in `_submit()`. (2) Made RA field visible in create mode (was hidden behind `if (isEdit)`). (3) Added required validator for RA in create mode. (4) In edit mode, RA remains read-only.
verification: `dart analyze` passes with no errors. Form now sends `registration_number` matching backend's `StudentCreate` required field.
files_changed: [mobile/lib/features/staff/screens/staff_cadastro_screen.dart]
