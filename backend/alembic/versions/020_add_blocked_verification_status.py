"""add blocked_verification to mcp_action_logs status constraint

The MCP middleware returns status='blocked_verification' when a mutating tool
call is blocked by the verification gate (D-15/D-21), but the check constraint
on mcp_action_logs.status did not include this value. This caused the logging
INSERT to fail, which propagated as a ToolException and prevented the agent
from receiving the verification instructions.

Revision ID: 020a
Revises: 019a
Create Date: 2026-05-15 00:30:00
"""

from alembic import op

revision = "020a"
down_revision = "019a"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.drop_constraint("ck_mcp_action_logs_status", "mcp_action_logs", type_="check")
    op.create_check_constraint(
        "ck_mcp_action_logs_status",
        "mcp_action_logs",
        "status IN ('success', 'error', 'retry_success', 'blocked_verification')",
    )


def downgrade() -> None:
    op.drop_constraint("ck_mcp_action_logs_status", "mcp_action_logs", type_="check")
    op.create_check_constraint(
        "ck_mcp_action_logs_status",
        "mcp_action_logs",
        "status IN ('success', 'error', 'retry_success')",
    )
