---
phase: 26
fixed_at: 2026-05-15T19:05:00Z
review_path: .planning/phases/26-banner-carousel/26-REVIEW.md
iteration: 1
findings_in_scope: 4
fixed: 4
skipped: 0
status: all_fixed
---

# Phase 26: Code Review Fix Report

**Fixed at:** 2026-05-15T19:05:00Z
**Source review:** .planning/phases/26-banner-carousel/26-REVIEW.md
**Iteration:** 1

**Summary:**

- Findings in scope: 4
- Fixed: 4
- Skipped: 0

## Fixed Issues

### CR-01: Path Traversal via Unsanitized Filename in Upload

**Files modified:** `backend/src/features/banners/controllers.py`
**Commit:** 89864ff
**Applied fix:** Added `PurePosixPath(file.filename or "upload").name` to strip directory components from uploaded filenames, preventing `../../` path traversal. Added defense-in-depth check that verifies the resolved file path stays within `UPLOAD_DIR` using `os.path.realpath()`, raising HTTP 400 with `INVALID_FILENAME` if the check fails. Also imported `asyncio` and `PurePosixPath` at the module level.

### WR-03: `file.content_type` Can Be Spoofed by Client

**Files modified:** `backend/src/features/banners/controllers.py`
**Commit:** 8b6e4cc
**Applied fix:** Added `_MAGIC_BYTES` dictionary mapping file signature bytes to MIME types (JPEG `\xff\xd8\xff`, PNG `\x89PNG`, WebP `RIFF`) and a `_validate_image_magic()` helper function. The upload handler now validates the actual file content's magic bytes after the size check and before writing to disk. Rejects files with unrecognized signatures with HTTP 400 and `INVALID_FILE_TYPE` error code. This prevents Content-Type header spoofing (e.g., uploading HTML/SVG as `image/jpeg`).

### WR-01: Synchronous File I/O in Async Route Handler

**Files modified:** `backend/src/features/banners/controllers.py`
**Commit:** fe85fc5
**Applied fix:** Replaced synchronous `open(file_path, "wb") / f.write(content)` with `asyncio.get_running_loop().run_in_executor(None, _write_file)` to avoid blocking the event loop during disk writes. Used a local `_write_file()` closure to encapsulate the blocking I/O. Chose `run_in_executor` over `aiofiles` since `aiofiles` is not in the project's `requirements.txt`.

### WR-02: Synchronous File Deletion in Async Route Handler

**Files modified:** `backend/src/features/banners/controllers.py`
**Commit:** 6e19190
**Applied fix:** Replaced synchronous `os.remove(...)` with `asyncio.get_running_loop().run_in_executor(None, os.remove, path)` to prevent blocking the event loop. Narrowed the exception handler from broad `OSError` (which silently swallows permission denied, disk errors, etc.) to `FileNotFoundError` only, which is the specific acceptable case (file already deleted).

---

_Fixed: 2026-05-15T19:05:00Z_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 1_
