---
status: partial
phase: 26-banner-carousel
source: [26-VERIFICATION.md]
started: 2026-05-15T06:05:00Z
updated: 2026-05-15T06:05:00Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. Carousel Auto-Scroll Behavior

expected: Carousel rotates banners every ~4 seconds with smooth 500ms transition. Continuous loop from last to first banner.
result: [pending]

### 2. Manual Swipe Pause/Resume

expected: Auto-scroll pauses on swipe, resumes after ~6 seconds idle.
result: [pending]

### 3. Staff Banner Upload Flow

expected: Staff dashboard > "Gerenciar Banners" card > FAB > file picker > select image > banner appears in grid immediately with "Banner adicionado" snackbar.
result: [pending]

### 4. Toggle Enable/Disable

expected: Badge toggles between "Ativo"/"Inativo" immediately (optimistic). Reverts on API error.
result: [pending]

### 5. Delete with Confirmation

expected: Dialog shows "Excluir banner?" with Cancel/Excluir buttons. Confirming removes banner from grid and deletes file on server.
result: [pending]

### 6. Edge Cases: 0 and 1 Banner

expected: 0 banners = carousel section invisible (SizedBox.shrink). 1 banner = static image, no animation, no dots.
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0
blocked: 0

## Gaps
