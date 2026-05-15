---
phase: 26-banner-carousel
reviewed: 2026-05-15T18:30:00Z
depth: standard
files_reviewed: 18
files_reviewed_list:
  - backend/src/features/banners/__init__.py
  - backend/src/features/banners/models.py
  - backend/src/features/banners/schemas.py
  - backend/src/features/banners/services.py
  - backend/src/features/banners/controllers.py
  - backend/src/features/banners/routes.py
  - backend/alembic/versions/021a_create_banners_table.py
  - backend/src/main.py
  - mobile/lib/features/staff/models/banner_model.dart
  - mobile/lib/features/staff/services/banner_service.dart
  - mobile/lib/features/staff/providers/banner_management_provider.dart
  - mobile/lib/features/staff/screens/staff_banner_management_screen.dart
  - mobile/lib/features/client/providers/banner_provider.dart
  - mobile/lib/features/client/screens/widgets/banner_carousel.dart
  - mobile/lib/features/staff/screens/staff_dashboard_screen.dart
  - mobile/lib/core/router/route_names.dart
  - mobile/lib/core/router/app_router.dart
  - mobile/lib/features/client/screens/client_home_screen.dart
findings:
  critical: 1
  warning: 3
  info: 2
  total: 6
status: issues_found
---

# Phase 26: Code Review Report — Banner Carousel

**Reviewed:** 2026-05-15T18:30:00Z
**Depth:** standard
**Files Reviewed:** 18
**Status:** issues_found

## Summary

Phase 26 adds a complete banner carousel feature: backend CRUD with file upload, staff management screen, and student-facing auto-scrolling carousel. The code is well-structured and follows project conventions (vertical slices, `require_staff` auth, Pydantic schemas, Riverpod providers). The Alembic migration is clean. The mobile code has good UX patterns (optimistic updates, confirmation dialogs, error handling).

However, there is one critical **path traversal vulnerability** in the file upload endpoint, plus a few moderate issues around filename handling and synchronous I/O in an async context.

## Critical Issues

### CR-01: Path Traversal via Unsanitized Filename in Upload

**File:** `backend/src/features/banners/controllers.py:115`
**Issue:** The filename from the uploaded file is used directly in the saved path without sanitization. While the UUID prefix prevents collisions, a malicious client can craft a filename containing `../` sequences (e.g., `../../../etc/cron.d/evil`) that escape the `uploads/banners/` directory. `os.path.join(UPLOAD_DIR, safe_filename)` does NOT prevent this — if `safe_filename` contains path separators, `os.path.join` resolves them.

Example attack: uploading with filename `../../src/main.py` would produce `safe_filename = "uuid_../../src/main.py"` and `os.path.join("uploads/banners", "uuid_../../src/main.py")` resolves to `uploads/src/main.py`, overwriting source code.

**Fix:**
```python
import os
from pathlib import PurePosixPath

# Save file with UUID prefix — sanitize original filename
file_id = str(uuid_mod.uuid4())
# Extract only the basename to prevent path traversal (../../ etc.)
original_name = PurePosixPath(file.filename or "upload").name
safe_filename = f"{file_id}_{original_name}"
file_path = os.path.join(UPLOAD_DIR, safe_filename)

# Defense-in-depth: verify resolved path stays inside UPLOAD_DIR
resolved = os.path.realpath(file_path)
if not resolved.startswith(os.path.realpath(UPLOAD_DIR)):
    raise HTTPException(status_code=400, detail={
        "error": {"code": "INVALID_FILENAME", "message": "Invalid filename"}
    })
```

## Warnings

### WR-01: Synchronous File I/O in Async Route Handler

**File:** `backend/src/features/banners/controllers.py:118-119`
**Issue:** The upload endpoint is `async def` but calls `open(file_path, "wb")` and `f.write(content)` synchronously. This blocks the entire event loop for the duration of the disk write. For a 2MB file on a slow disk, this can stall all concurrent requests.

**Fix:** Use `aiofiles` or run in executor:
```python
import aiofiles

async with aiofiles.open(file_path, "wb") as f:
    await f.write(content)
```
Or if `aiofiles` is not a dependency:
```python
import asyncio
loop = asyncio.get_running_loop()
await loop.run_in_executor(None, _write_file, file_path, content)
```

### WR-02: Synchronous File Deletion in Async Route Handler

**File:** `backend/src/features/banners/controllers.py:168`
**Issue:** `os.remove(...)` is a blocking call inside an `async def` handler. Same event-loop-blocking concern as WR-01. Additionally, the bare `except OSError: pass` silently swallows all OS errors (permission denied, disk full on journaling, etc.), not just "file not found".

**Fix:**
```python
import asyncio

try:
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, os.remove, os.path.join("uploads", image_url))
except FileNotFoundError:
    pass  # File already removed — acceptable
```

### WR-03: `file.content_type` Can Be Spoofed by Client

**File:** `backend/src/features/banners/controllers.py:88`
**Issue:** Content-type validation relies solely on the `Content-Type` header from the multipart upload, which the client fully controls. A malicious user could upload an HTML file (for stored XSS via the static file server) or an SVG with embedded JavaScript while claiming `image/jpeg`. Since the file is served via `StaticFiles` (line 150 of `main.py`), the browser may sniff the actual content type.

**Fix:** Validate the file's magic bytes (file signature) in addition to the declared content-type:
```python
MAGIC_BYTES = {
    b'\xff\xd8\xff': "image/jpeg",
    b'\x89PNG': "image/png",
    b'RIFF': "image/webp",  # WebP starts with RIFF
}

def _validate_magic(content: bytes) -> bool:
    for magic in MAGIC_BYTES:
        if content[:len(magic)] == magic:
            return True
    return False

# In the handler, after reading content:
if not _validate_magic(content):
    raise HTTPException(status_code=400, ...)
```

## Info

### IN-01: `file.filename` Could Be None

**File:** `backend/src/features/banners/controllers.py:115`
**Issue:** Per the `UploadFile` spec, `file.filename` can be `None` if no filename was provided. The f-string `f"{file_id}_{file.filename}"` would produce `"uuid_None"` as the filename, which is technically valid but produces a poor file name.

**Fix:**
```python
original_name = file.filename or "upload.bin"
safe_filename = f"{file_id}_{original_name}"
```

### IN-02: Carousel PageView Does Not Implement True Infinite Loop

**File:** `mobile/lib/features/client/screens/widgets/banner_carousel.dart:138`
**Issue:** The `PageView.builder` uses `itemCount: banners.length`, so the user cannot swipe continuously from the last page back to the first (design doc says "D-05: Continuous loop from last banner back to first"). The auto-scroll code (line 70) wraps the index with `%`, but `animateToPage` cannot animate from page N-1 back to page 0 — it will scroll backwards through all pages instead of looping forward. This is a cosmetic/UX issue, not a crash.

**Fix:** For a true infinite carousel, either set `itemCount` to a very large number and use modular indexing, or use a package like `infinite_carousel` / implement a custom PageView with viewport fraction tricks.

---

_Reviewed: 2026-05-15T18:30:00Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
