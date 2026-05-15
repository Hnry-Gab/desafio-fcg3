/// Utility to translate MCP action log JSON into user-friendly Portuguese text.
///
/// Converts raw tool names, input parameters and output results from
/// [ActionLogModel] into readable descriptions for the chat UI.
class McpLogFormatter {
  McpLogFormatter._();

  // ─── Tool name → friendly label ─────────────────────────────────────────────

  static const _toolLabels = <String, String>{
    'get_student_info': 'Consultar informacoes do aluno',
    'get_available_courses': 'Listar disciplinas disponiveis',
    'get_grades': 'Consultar notas',
    'get_transcript': 'Consultar historico escolar',
    'request_document': 'Solicitar documento',
    'get_document_status': 'Verificar status do documento',
    'get_available_slots': 'Listar horarios disponiveis',
    'book_appointment': 'Agendar atendimento',
    'cancel_appointment': 'Cancelar agendamento',
    'create_enrollment': 'Criar matricula',
    'confirm_enrollment': 'Confirmar matricula',
    'drop_course': 'Remover disciplina',
    'lock_enrollment': 'Trancar matricula',
    'get_curriculum': 'Consultar grade curricular',
    'get_course_prerequisites': 'Consultar pre-requisitos',
    'get_enrollment_period': 'Consultar periodo de matricula',
  };

  /// Returns a friendly Portuguese label for the given [toolName].
  /// Falls back to humanizing the snake_case name if unknown.
  static String toolLabel(String toolName) {
    return _toolLabels[toolName] ?? _humanize(toolName);
  }

  // ─── Status → friendly label ────────────────────────────────────────────────

  static String statusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Sucesso';
      case 'error':
        return 'Erro';
      case 'retry_success':
        return 'Sucesso (apos tentativa)';
      default:
        return status;
    }
  }

  // ─── Input params → readable text ──────────────────────────────────────────

  static const _paramLabels = <String, String>{
    'semester_year': 'Semestre',
    'enrollment_period_id': 'Periodo de matricula',
    'course_ids': 'Disciplinas',
    'enrollment_id': 'Matricula',
    'course_id': 'Disciplina',
    'document_id': 'Documento',
    'type': 'Tipo',
    'date_from': 'Data inicio',
    'date_to': 'Data fim',
    'slot_id': 'Horario',
    'reason': 'Motivo',
    'appointment_id': 'Agendamento',
    'student_id': 'Aluno',
  };

  static const _documentTypeLabels = <String, String>{
    'transcript': 'Historico escolar',
    'enrollment_proof': 'Comprovante de matricula',
    'declaration': 'Declaracao',
    'certificate': 'Certificado',
  };

  /// Formats input parameters into a readable multi-line string.
  /// Returns `null` if there are no meaningful parameters.
  static String? formatInput(String toolName, Map<String, dynamic> params) {
    // Filter out null values and student_id (never shown)
    final filtered = Map<String, dynamic>.from(params)
      ..removeWhere((key, value) => value == null || key == 'student_id');

    if (filtered.isEmpty) return null;

    final lines = <String>[];
    for (final entry in filtered.entries) {
      final label = _paramLabels[entry.key] ?? _humanize(entry.key);
      final value = _formatValue(entry.key, entry.value);
      lines.add('$label: $value');
    }
    return lines.join('\n');
  }

  /// Formats output result into a readable summary.
  /// Returns `null` if the output is empty or null.
  static String? formatOutput(String toolName, Map<String, dynamic>? output) {
    if (output == null || output.isEmpty) return null;

    // Check for error responses
    if (output.containsKey('error')) {
      final error = output['error'];
      if (error is Map<String, dynamic>) {
        final code = error['code'] ?? '';
        final message = error['message'] ?? 'Erro desconhecido';
        return 'Erro: $message${code.toString().isNotEmpty ? ' ($code)' : ''}';
      }
      return 'Erro: $error';
    }

    // Check for common response wrappers
    if (output.containsKey('message')) {
      return output['message'].toString();
    }

    // Tool-specific formatting
    return _formatToolOutput(toolName, output);
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  static String _formatValue(String key, dynamic value) {
    if (value is List) {
      if (value.isEmpty) return 'nenhum';
      return '${value.length} item(ns)';
    }
    if (key == 'type' && value is String) {
      return _documentTypeLabels[value] ?? value;
    }
    // Shorten UUIDs for readability
    if (value is String && _isUuid(value)) {
      return value.substring(0, 8);
    }
    return value.toString();
  }

  static String? _formatToolOutput(String toolName, Map<String, dynamic> output) {
    switch (toolName) {
      case 'get_grades':
        return _formatGrades(output);
      case 'get_student_info':
        return _formatStudentInfo(output);
      case 'get_transcript':
        return _formatTranscript(output);
      case 'request_document':
        return _formatDocumentRequest(output);
      case 'get_document_status':
        return _formatDocumentStatus(output);
      case 'create_enrollment':
      case 'confirm_enrollment':
        return _formatEnrollment(output);
      case 'get_available_slots':
        return _formatSlots(output);
      case 'book_appointment':
        return _formatAppointment(output);
      case 'get_available_courses':
        return _formatCourses(output);
      case 'get_curriculum':
        return _formatCurriculum(output);
      case 'get_enrollment_period':
        return _formatEnrollmentPeriod(output);
      default:
        return _formatGenericOutput(output);
    }
  }

  static String? _formatGrades(Map<String, dynamic> output) {
    final data = _extractData(output);
    if (data is List) {
      if (data.isEmpty) return 'Nenhuma nota encontrada.';
      final count = data.length;
      return '$count disciplina(s) com notas registradas.';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatStudentInfo(Map<String, dynamic> output) {
    final data = _extractData(output) ?? output;
    if (data is Map<String, dynamic>) {
      final lines = <String>[];
      if (data['name'] != null) lines.add('Nome: ${data['name']}');
      if (data['current_semester'] != null) {
        lines.add('Periodo: ${data['current_semester']}');
      }
      if (data['cra'] != null) lines.add('CRA: ${data['cra']}');
      if (data['status'] != null) lines.add('Status: ${data['status']}');
      if (data['completed_courses'] != null) {
        lines.add('Disciplinas concluidas: ${data['completed_courses']}');
      }
      if (lines.isNotEmpty) return lines.join('\n');
    }
    return _formatGenericOutput(output);
  }

  static String? _formatTranscript(Map<String, dynamic> output) {
    final data = _extractData(output);
    if (data is List) {
      return 'Historico com ${data.length} disciplina(s).';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatDocumentRequest(Map<String, dynamic> output) {
    final data = _extractData(output) ?? output;
    if (data is Map<String, dynamic>) {
      final status = data['status'] ?? 'solicitado';
      final type = data['type'];
      final typeLabel = type != null
          ? (_documentTypeLabels[type] ?? type.toString())
          : 'Documento';
      return '$typeLabel: $status';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatDocumentStatus(Map<String, dynamic> output) {
    final data = _extractData(output) ?? output;
    if (data is Map<String, dynamic>) {
      final status = data['status'];
      if (status != null) {
        final statusLabels = {
          'requested': 'Solicitado',
          'processing': 'Em processamento',
          'ready': 'Pronto para retirada',
          'delivered': 'Entregue',
        };
        return 'Status: ${statusLabels[status] ?? status}';
      }
    }
    return _formatGenericOutput(output);
  }

  static String? _formatEnrollment(Map<String, dynamic> output) {
    final data = _extractData(output) ?? output;
    if (data is Map<String, dynamic>) {
      final status = data['status'];
      final statusLabels = {
        'draft': 'Rascunho',
        'confirmed': 'Confirmada',
        'cancelled': 'Cancelada',
        'locked': 'Trancada',
      };
      final label = statusLabels[status] ?? status?.toString() ?? '';
      final courses = data['courses'] ?? data['course_ids'];
      if (courses is List) {
        return 'Matricula ($label) com ${courses.length} disciplina(s).';
      }
      if (label.isNotEmpty) return 'Matricula: $label';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatSlots(Map<String, dynamic> output) {
    final data = _extractData(output);
    if (data is List) {
      if (data.isEmpty) return 'Nenhum horario disponivel.';
      return '${data.length} horario(s) disponivel(is).';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatAppointment(Map<String, dynamic> output) {
    final data = _extractData(output) ?? output;
    if (data is Map<String, dynamic>) {
      final date = data['date'] ?? data['scheduled_at'];
      if (date != null) return 'Agendado para: $date';
      return 'Atendimento agendado com sucesso.';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatCourses(Map<String, dynamic> output) {
    final data = _extractData(output);
    if (data is List) {
      if (data.isEmpty) return 'Nenhuma disciplina disponivel.';
      return '${data.length} disciplina(s) disponivel(is).';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatCurriculum(Map<String, dynamic> output) {
    final data = _extractData(output);
    if (data is Map<String, dynamic>) {
      final semesters = data['semesters'];
      if (semesters is List) {
        return 'Grade curricular com ${semesters.length} periodo(s).';
      }
    }
    if (data is List) {
      return 'Grade curricular com ${data.length} disciplina(s).';
    }
    return _formatGenericOutput(output);
  }

  static String? _formatEnrollmentPeriod(Map<String, dynamic> output) {
    final data = _extractData(output) ?? output;
    if (data is Map<String, dynamic>) {
      final name = data['name'] ?? data['semester_year'];
      final startDate = data['start_date'];
      final endDate = data['end_date'];
      final lines = <String>[];
      if (name != null) lines.add('Periodo: $name');
      if (startDate != null && endDate != null) {
        lines.add('De $startDate ate $endDate');
      }
      if (lines.isNotEmpty) return lines.join('\n');
    }
    return _formatGenericOutput(output);
  }

  /// Generic fallback — extracts the most informative fields.
  static String? _formatGenericOutput(Map<String, dynamic> output) {
    final data = _extractData(output) ?? output;

    // If it's a list, show the count
    if (data is List) {
      return '${data.length} resultado(s).';
    }

    if (data is Map<String, dynamic>) {
      // Try common summary fields
      for (final key in ['message', 'status', 'name', 'title', 'description']) {
        if (data[key] != null) {
          return data[key].toString();
        }
      }
      // Show number of fields as last resort
      return '${data.length} campo(s) retornado(s).';
    }

    return data?.toString();
  }

  /// Extracts `data` field from common response wrappers.
  static dynamic _extractData(Map<String, dynamic> output) {
    if (output.containsKey('data')) return output['data'];
    if (output.containsKey('items')) return output['items'];
    if (output.containsKey('results')) return output['results'];
    return null;
  }

  static String _humanize(String snakeCase) {
    return snakeCase
        .replaceAll('_', ' ')
        .replaceFirst(snakeCase[0], snakeCase[0].toUpperCase());
  }

  static bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(value);
  }
}
