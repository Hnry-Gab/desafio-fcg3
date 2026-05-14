---
phase: 23-new-features
reviewed: 2026-05-14T04:05:00Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - backend/src/features/enrollment/services.py
  - mobile/lib/features/client/providers/enrollment_provider.dart
  - mobile/lib/features/client/screens/client_enrollment_screen.dart
  - mobile/lib/features/client/services/enrollment_service.dart
findings:
  critical: 0
  warning: 3
  info: 2
  total: 5
status: issues_found
---

# Phase 23: Code Review Report

**Reviewed:** 2026-05-14T04:05:00Z
**Depth:** standard
**Files Reviewed:** 4
**Status:** issues_found

## Summary

Reviewed the enrollment draft flow fix across backend and frontend. The core changes are sound:

- **Backend** (`services.py`): The `flush()` between delete and insert in `update_enrollment_courses` correctly prevents the `UniqueConstraint("enrollment_id", "course_id")` violation. Good fix.
- **Frontend provider** (`enrollment_provider.dart`): The `draftEnrollmentId` field is properly extracted and threaded through. Clean implementation.
- **Frontend screen** (`client_enrollment_screen.dart`): The branching logic (update+confirm for draft, create+confirm for new) is correct. Navigation from `push` to `go` and back button to profile are appropriate.
- **Frontend service** (`enrollment_service.dart`): The `updateEnrollmentCourses` method correctly calls `PUT /enrollments/{id}`.

Three warnings identified around error handling robustness, a potential race condition on the frontend, and a missing error handling path for the `updateEnrollmentCourses` call.

## Warnings

### WR-01: Error message for update failure incorrectly suggests "already enrolled"

**File:** `mobile/lib/features/client/screens/client_enrollment_screen.dart:436`
**Issue:** The catch block checks for `409` in the error string to display "Voce ja possui uma matricula para este periodo." However, when the code takes the `hasDraftEnrollment` branch (update+confirm), a 409 error from `updateEnrollmentCourses` could be `OPERACAO_NAO_PERMITIDA` (e.g., enrollment status changed between load and submit) rather than `MATRICULA_JA_EXISTENTE`. Displaying "you already have an enrollment" is misleading in that case. Additionally, the `confirmEnrollment` call can also return 409 with `MATRICULA_JA_CONFIRMADA` or `PERIODO_MATRICULA_FECHADO`, both of which would be inaccurately described.

**Fix:** Parse the specific error code from the response body rather than just checking for HTTP 409:
```dart
} catch (e) {
  if (mounted) {
    String errorMsg = 'Erro ao realizar matricula. Tente novamente.';
    final errorStr = e.toString();
    if (errorStr.contains('MATRICULA_JA_EXISTENTE') || errorStr.contains('MATRICULA_JA_CONFIRMADA')) {
      errorMsg = 'Voce ja possui uma matricula confirmada para este periodo.';
    } else if (errorStr.contains('PERIODO_MATRICULA_FECHADO')) {
      errorMsg = 'O periodo de matricula nao esta mais ativo.';
    } else if (errorStr.contains('PREREQUISITO_NAO_CUMPRIDO')) {
      errorMsg = 'Existem pre-requisitos nao cumpridos para as disciplinas selecionadas.';
    } else if (errorStr.contains('OPERACAO_NAO_PERMITIDA')) {
      errorMsg = 'Esta matricula nao pode mais ser modificada. Tente novamente.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMsg), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }
}
```

### WR-02: Race condition between update and confirm can leave enrollment in inconsistent state

**File:** `mobile/lib/features/client/screens/client_enrollment_screen.dart:401-419`
**Issue:** The `_handleEnroll` method performs two sequential API calls: first `updateEnrollmentCourses` (or `createEnrollment`), then `confirmEnrollment`. If the first succeeds but the second fails (e.g., network timeout, period closed between calls), the enrollment is left in draft state with updated courses but no confirmation. The user sees an error snackbar and the screen state resets, but the draft is now silently modified. On retry, the `hasDraftEnrollment` check from the stale provider data may not reflect the updated courses, and the user might re-submit different course selections without realizing the previous update persisted.

**Fix:** Invalidate the provider on error so the next attempt fetches fresh state:
```dart
} catch (e) {
  if (mounted) {
    // Invalidate to fetch fresh state in case partial operations succeeded
    ref.invalidate(enrollmentDataProvider(widget.studentId));
    // ... show error snackbar ...
  }
}
```

### WR-03: `getEnrollments` does not filter by current period, `hasDraftEnrollment` may match wrong period

**File:** `mobile/lib/features/client/providers/enrollment_provider.dart:30-37`
**Issue:** `getEnrollments()` calls `GET /enrollments` without a `semester_year` filter. The provider then checks `enrollments.any((e) => e['status'] == 'draft')` across ALL enrollment periods. If a student has a stale draft from a previous semester (unlikely but possible if periods overlap or data isn't cleaned), the code would detect `hasDraftEnrollment = true` and attempt to update courses on the wrong enrollment. The `draftEnrollmentId` would point to an enrollment for the wrong period, and `confirmEnrollment` would fail with `PERIODO_MATRICULA_FECHADO` (since the old period is no longer active).

**Fix:** Filter enrollments by the current period's `semester_year` or `enrollment_period_id`:
```dart
final enrollments = results[2] as List<Map<String, dynamic>>;
final periodId = period?['id'];

// Only consider enrollments for the current period
final currentPeriodEnrollments = periodId != null
    ? enrollments.where((e) => e['enrollment_period_id'] == periodId).toList()
    : <Map<String, dynamic>>[];

final hasDraft = currentPeriodEnrollments.any((e) => e['status'] == 'draft');
final hasConfirmed = currentPeriodEnrollments.any((e) => e['status'] == 'confirmed');
final draftEnrollment = hasDraft
    ? currentPeriodEnrollments.firstWhere((e) => e['status'] == 'draft')
    : null;
```

Alternatively, pass `semester_year` as a query parameter in the `getEnrollments` call.

## Info

### IN-01: Unused import — `Any` imported but not used in services.py

**File:** `backend/src/features/enrollment/services.py:12`
**Issue:** `from typing import Any` is imported but `Any` is never used in the file.
**Fix:** Remove the unused import:
```python
from typing import Any  # remove this line
```

### IN-02: `_selectedCourseIds` not pre-populated when editing a draft enrollment

**File:** `mobile/lib/features/client/screens/client_enrollment_screen.dart:27`
**Issue:** When a draft enrollment exists, `_selectedCourseIds` starts empty. The user sees the course selection screen without their previously-selected courses pre-checked. This is a UX gap rather than a bug — the flow still works because the user must actively select courses before submitting — but it means editing a draft doesn't show the current draft state.
**Fix:** Pre-populate `_selectedCourseIds` from the draft enrollment's courses when `hasDraftEnrollment` is true. This would require either fetching the draft enrollment detail (with its course list) in the provider, or including course IDs in the enrollment list response.

---

_Reviewed: 2026-05-14T04:05:00Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
