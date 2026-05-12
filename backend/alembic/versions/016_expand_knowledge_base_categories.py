"""expand knowledge_base_chunks category constraint for Phase 25

Revision ID: 016a
Revises: 015a
Create Date: 2026-05-12 00:00:01
"""

from alembic import op

revision = "016a"
down_revision = "015a"
branch_labels = None
depends_on = None

NEW_CATEGORIES = (
    "'regras_matricula', 'faq', 'curriculo', 'documentos', 'agendamento', 'regulamento', "
    "'atividades_complementares', 'bolsas_auxilios', 'canais_atendimento', 'corpo_docente', "
    "'mobilidade_academica', 'equivalencia_matrizes', 'grade_horaria', "
    "'infraestrutura_laboratorios', 'manual_estagio', 'manual_tcc_plagio', "
    "'projetos_extensao', 'sla_atendimento_digital'"
)

OLD_CATEGORIES = (
    "'regras_matricula', 'faq', 'curriculo', 'documentos', 'agendamento', 'regulamento'"
)


def upgrade() -> None:
    op.drop_constraint(
        "ck_knowledge_base_chunks_category",
        "knowledge_base_chunks",
        type_="check",
    )
    op.execute(
        f"ALTER TABLE knowledge_base_chunks "
        f"ADD CONSTRAINT ck_knowledge_base_chunks_category "
        f"CHECK (category IN ({NEW_CATEGORIES}))"
    )


def downgrade() -> None:
    op.drop_constraint(
        "ck_knowledge_base_chunks_category",
        "knowledge_base_chunks",
        type_="check",
    )
    op.execute(
        f"ALTER TABLE knowledge_base_chunks "
        f"ADD CONSTRAINT ck_knowledge_base_chunks_category "
        f"CHECK (category IN ({OLD_CATEGORIES}))"
    )
