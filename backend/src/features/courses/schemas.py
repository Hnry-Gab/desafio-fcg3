"""Pydantic request/response models for the Courses & Curriculum feature slice.

Shapes match docs/api.md exactly (Courses & Curriculum section).
"""

from __future__ import annotations

from datetime import time
from uuid import UUID

from pydantic import BaseModel


# ---------------------------------------------------------------------------
# Course schemas
# ---------------------------------------------------------------------------

class CourseListItem(BaseModel):
    """Item in GET /courses paginated list."""

    id: UUID
    code: str
    name: str
    credits: int
    workload_hours: int
    professor: str | None = None

    model_config = {"from_attributes": True}


class PrerequisiteItem(BaseModel):
    """Direct prerequisite in course detail response."""

    id: UUID
    code: str
    name: str

    model_config = {"from_attributes": True}


class CourseDetail(BaseModel):
    """GET /courses/{id} — course detail with direct prerequisites.

    Matches docs/api.md response shape exactly.
    """

    id: UUID
    code: str
    name: str
    credits: int
    workload_hours: int
    description: str | None
    professor: str | None = None
    prerequisites: list[PrerequisiteItem]

    model_config = {"from_attributes": True}


class PrerequisiteTreeNode(BaseModel):
    """Recursive tree node for GET /courses/{id}/prerequisites (COURSE-03).

    Self-referential: each node has its own prerequisites list.
    Uses Pydantic model_rebuild() for forward reference resolution.
    """

    id: UUID
    code: str
    name: str
    prerequisites: list[PrerequisiteTreeNode] = []

    model_config = {"from_attributes": True}


# Resolve self-referential model
PrerequisiteTreeNode.model_rebuild()


# ---------------------------------------------------------------------------
# Curriculum schemas
# ---------------------------------------------------------------------------

class CurriculumCourseItem(BaseModel):
    """Course within a semester group in curriculum response."""

    id: UUID
    code: str
    name: str
    credits: int
    is_required: bool
    professor: str | None = None

    model_config = {"from_attributes": True}


class SemesterGroup(BaseModel):
    """Semester grouping with its courses."""

    semester: int
    courses: list[CurriculumCourseItem]


class CurriculumResponse(BaseModel):
    """GET /curriculum/active and GET /curriculum/{id} response.

    Matches docs/api.md response shape exactly.
    """

    id: UUID
    name: str
    year: int
    semesters: list[SemesterGroup]

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Weekly schedule schemas (GRAD-01, GRAD-02, GRAD-03)
# ---------------------------------------------------------------------------


class ClassScheduleSlot(BaseModel):
    """Single time slot in the weekly timetable."""

    id: UUID
    course_id: UUID
    course_code: str
    course_name: str
    professor: str | None = None
    description: str | None = None
    day_of_week: int
    start_time: time
    end_time: time
    room: str | None = None

    model_config = {"from_attributes": True}


class WeeklyScheduleDay(BaseModel):
    """All classes for a single day of the week."""

    day_of_week: int
    day_name: str
    slots: list[ClassScheduleSlot]


class WeeklyScheduleResponse(BaseModel):
    """GET /students/{id}/weekly-schedule response.

    Groups enrolled class slots by day of week (GRAD-01).
    Each slot includes professor and description (GRAD-02).
    Only enrolled courses are included (GRAD-03).
    """

    days: list[WeeklyScheduleDay]
