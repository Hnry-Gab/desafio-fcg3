"""Pydantic request/response models for the Documents feature slice.

Shapes match docs/api.md exactly. All fields use snake_case per conventions.
"""

from __future__ import annotations

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Request schemas
# ---------------------------------------------------------------------------

class DocumentCreate(BaseModel):
    """POST /documents — student requests document emission (DOCS-03).

    Per docs/api.md: type is one of transcript, enrollment_proof,
    declaration, certificate.  notes is optional free-text.
    Staff can specify student_id to create on behalf of a student.
    """

    type: Literal["transcript", "enrollment_proof", "declaration", "certificate"]
    notes: str | None = Field(default=None, max_length=1000)
    student_id: UUID | None = Field(default=None, description="Staff-only: target student ID")
    status: Literal["requested", "processing", "ready"] | None = Field(default=None)
    file_url: str | None = Field(default=None, max_length=500)


class DocumentStatusUpdate(BaseModel):
    """PUT /documents/{id}/status — staff updates document status (DOCS-04).

    Status transition: requested → processing → ready → delivered.
    When status is "ready", file_url should be provided.
    """

    status: Literal["processing", "ready", "delivered"]
    file_url: str | None = Field(default=None, max_length=500)


# ---------------------------------------------------------------------------
# Response schemas
# ---------------------------------------------------------------------------

class DocumentResponse(BaseModel):
    """Response for document list items and detail (DOCS-01, DOCS-02)."""

    id: UUID
    student_id: UUID | None = None
    student_name: str | None = None
    student_email: str | None = None
    type: str
    status: str
    file_url: str | None = None
    notes: str | None = None
    requested_at: datetime
    completed_at: datetime | None = None

    model_config = {"from_attributes": True}
