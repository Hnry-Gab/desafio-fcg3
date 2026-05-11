"""Route handlers for the Documents feature slice.

5 endpoints covering all DOCS-* requirements:

Student-facing (dual-auth for MCP access):
- POST /documents — create document request (DOCS-03)
- GET /documents — list documents with type/status filters (DOCS-01)
- GET /documents/{id} — document detail with file_url (DOCS-02)

Staff:
- PUT /documents/{id}/status — update status and attach file URL (DOCS-04)
- POST /documents/upload — staff file upload (DOCS-05)
"""

from __future__ import annotations

import os
import uuid as uuid_mod
from uuid import UUID

from fastapi import APIRouter, Depends, Query, UploadFile, File, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database import get_db_session
from src.shared.dependencies import (
    UserContext,
    check_ownership,
    get_current_user_or_service,
    require_staff,
)
from src.shared.pagination import PaginationParams, paginated_response

from src.features.documents.schemas import (
    DocumentCreate,
    DocumentResponse,
    DocumentStatusUpdate,
)
from src.features.documents.services import document_service


documents_router = APIRouter(
    prefix="/documents",
    tags=["documents"],
)


# ------------------------------------------------------------------
# DOCS-03: POST /documents — MCP-accessible
# ------------------------------------------------------------------

@documents_router.post("", response_model=DocumentResponse, status_code=201)
async def create_document(
    data: DocumentCreate,
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> DocumentResponse:
    """Create document request.

    Students: student_id always from authenticated user context (IDOR-safe).
    Staff: can specify student_id in body to create on behalf of a student.
    Accepts X-Service-Token for MCP access.
    """
    # Staff can specify a target student_id; students always use their own
    target_student_id = user.id
    if user.role == "staff" and data.student_id is not None:
        target_student_id = data.student_id

    document = await document_service.create_document_request(
        db, student_id=target_student_id, data=data,
    )
    await db.commit()
    return DocumentResponse.model_validate(document)


# ------------------------------------------------------------------
# DOCS-01: GET /documents — dual-auth
# ------------------------------------------------------------------

@documents_router.get("", response_model=None)
async def list_documents(
    params: PaginationParams = Depends(),
    student_id: UUID | None = Query(default=None, description="Filter by student ID"),
    type: str | None = Query(default=None, description="Filter by document type"),
    status: str | None = Query(default=None, description="Filter by status"),
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """List documents with pagination and filters (DOCS-01).

    T-03-24: Students are auto-filtered to their own documents (IDOR-safe).
    Staff can view all or filter by student_id.
    """
    # IDOR-safe: force student/service to see only their own documents
    effective_student_id = student_id
    if user.role != "staff":
        effective_student_id = user.id

    items, total = await document_service.list_documents(
        db,
        params,
        student_id=effective_student_id,
        type=type,
        status=status,
        include_student=(user.role == "staff"),
    )

    data = []
    for item in items:
        doc_dict = DocumentResponse.model_validate(item).model_dump()
        # Enrich with student info for staff view
        if user.role == "staff" and item.student:
            doc_dict["student_name"] = item.student.name
            doc_dict["student_email"] = item.student.email
            doc_dict["student_id"] = str(item.student_id)
        data.append(doc_dict)
    return paginated_response(data, total, params)


# ------------------------------------------------------------------
# DOCS-02: GET /documents/{id} — MCP-accessible
# ------------------------------------------------------------------

@documents_router.get("/{document_id}", response_model=DocumentResponse)
async def get_document(
    document_id: UUID,
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> DocumentResponse:
    """Get document detail with file_url when status=ready (DOCS-02).

    T-03-24: check_ownership for students/service — only own documents.
    Accepts X-Service-Token for MCP access.
    """
    document = await document_service.get_document(db, document_id)
    check_ownership(document.student_id, user)
    return DocumentResponse.model_validate(document)


# ------------------------------------------------------------------
# DOCS-04: PUT /documents/{id}/status — staff only
# ------------------------------------------------------------------

@documents_router.put("/{document_id}/status", response_model=DocumentResponse)
async def update_document_status(
    document_id: UUID,
    data: DocumentStatusUpdate,
    user: UserContext = Depends(get_current_user_or_service),
    db: AsyncSession = Depends(get_db_session),
) -> DocumentResponse:
    """Update document status and optionally attach file URL (DOCS-04).

    T-03-25: Status transition validation prevents backwards movement.
    Staff only — students cannot change document status.
    """
    require_staff(user)

    document = await document_service.update_document_status(
        db, document_id=document_id, data=data,
    )
    await db.commit()
    return DocumentResponse.model_validate(document)


# ------------------------------------------------------------------
# DOCS-05: POST /documents/upload — staff file upload
# ------------------------------------------------------------------

UPLOAD_DIR = "uploads/documents"
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_EXTENSIONS = {".pdf", ".png", ".jpg", ".jpeg"}


@documents_router.post("/upload")
async def upload_document(
    file: UploadFile = File(...),
    user: UserContext = Depends(get_current_user_or_service),
) -> dict:
    """Upload a document file (staff only).

    T-09-08: Validates file extension server-side (ALLOWED_EXTENSIONS).
    T-09-09: Validates max file size (10MB) to prevent DoS.
    Uses uuid prefix in filename to prevent path traversal.
    """
    require_staff(user)

    # Validate extension
    ext = os.path.splitext(file.filename or "")[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail={
                "error": {
                    "code": "INVALID_FILE_TYPE",
                    "message": f"Allowed types: PDF, PNG, JPG. Got: {ext}",
                }
            },
        )

    # Read and validate size
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail={
                "error": {
                    "code": "FILE_TOO_LARGE",
                    "message": "Maximum file size is 10MB",
                }
            },
        )

    # Save file with uuid prefix to prevent naming collisions and path traversal
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    file_id = str(uuid_mod.uuid4())
    safe_filename = f"{file_id}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, safe_filename)

    with open(file_path, "wb") as f:
        f.write(content)

    return {
        "url": f"/uploads/documents/{safe_filename}",
        "filename": file.filename,
    }
