import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../client/models/appointment_model.dart';
import '../../client/screens/client_documents_screen.dart' show buildDownloadUrl;
import '../../../shared/widgets/responsive_container.dart';
import '../providers/staff_schedule_provider.dart';

class StaffAppointmentDetailScreen extends ConsumerWidget {
  final AppointmentModel appointment;

  const StaffAppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Agendamento'),
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do aluno
              _DetailRow(
                label: 'Nome',
                value: appointment.studentName ?? 'Não informado',
              ),
              const SizedBox(height: 16),
              // RA
              _DetailRow(
                label: 'RA',
                value: appointment.studentRa ?? 'Não informado',
              ),
              const SizedBox(height: 16),
              // Data de emissão / criação
              _DetailRow(
                label: 'Data de emissão',
                value: _formatDate(appointment.createdAt),
              ),
              const SizedBox(height: 16),
              // Recurso
              _DetailRow(
                label: 'Recurso',
                value: appointment.resourceName ?? 'Não definido',
              ),
              const SizedBox(height: 16),
              // Status (colored badge)
              Row(
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBackgroundColor(appointment.status, context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(appointment.status),
                      style: TextStyle(
                        color: _statusTextColor(appointment.status, context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Motivo
              _DetailRow(
                label: 'Motivo',
                value: appointment.reason,
              ),
              const SizedBox(height: 16),
              // Authorization file
              if (appointment.hasAuthorization) ...[
                Text(
                  'Documento de Autorização',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(
                        buildDownloadUrl(appointment.authorizationFileUrl!),
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(
                      _extractFileName(appointment.authorizationFileUrl!),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Action buttons
              if (appointment.isUpcoming)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _cancelAction(context, ref),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.error,
                              side: BorderSide(color: colors.error),
                              minimumSize: const Size(0, 48),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmAction(context, ref),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            child: const Text('Confirmar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _noShowAction(context, ref),
                        icon: const Icon(Icons.person_off, size: 18),
                        label: const Text('Marcar Ausente'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade700,
                          side: BorderSide(color: Colors.orange.shade700),
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Agendamento'),
        content: const Text('Confirmar este agendamento com o aluno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(staffScheduleServiceProvider)
            .confirmAppointment(appointment.id);
        ref.invalidate(staffAppointmentsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento confirmado')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao confirmar: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelAction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento? O aluno será notificado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Cancelar Agendamento'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(staffScheduleServiceProvider)
            .cancelAppointment(appointment.id);
        ref.invalidate(staffAppointmentsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento cancelado')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cancelar: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _noShowAction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Marcar Ausente'),
        content: const Text(
          'Confirma que o aluno não compareceu a este agendamento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
            child: const Text('Marcar Ausente'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(staffScheduleServiceProvider)
            .markNoShow(appointment.id);
        ref.invalidate(staffAppointmentsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aluno marcado como ausente')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao marcar ausencia: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  /// Extracts a human-readable filename from the authorization file URL.
  /// The backend stores files as `/uploads/authorizations/{uuid}_{original_name}`.
  String _extractFileName(String url) {
    final segment = url.split('/').last;
    // Strip the leading UUID prefix (36 chars + underscore)
    final underscoreIndex = segment.indexOf('_');
    if (underscoreIndex > 0 && underscoreIndex < segment.length - 1) {
      return segment.substring(underscoreIndex + 1);
    }
    return segment;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

Color _statusBackgroundColor(String status, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = Theme.of(context).colorScheme;
  return switch (status) {
    'scheduled' => isDark
        ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
        : Colors.green.shade100,
    'cancelled' => isDark
        ? colors.error.withValues(alpha: 0.15)
        : Colors.red.shade100,
    'completed' || 'no_show' => isDark
        ? colors.surfaceContainerHigh
        : Colors.grey.shade200,
    _ => isDark ? colors.surfaceContainerHigh : Colors.grey.shade200,
  };
}

Color _statusTextColor(String status, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = Theme.of(context).colorScheme;
  return switch (status) {
    'scheduled' => isDark ? const Color(0xFF81C784) : Colors.green.shade800,
    'cancelled' => isDark ? colors.error : Colors.red.shade800,
    'completed' || 'no_show' => colors.onSurfaceVariant,
    _ => colors.onSurfaceVariant,
  };
}

String _statusLabel(String status) => switch (status) {
      'scheduled' => 'Agendado',
      'cancelled' => 'Cancelado',
      'completed' => 'Concluído',
      'no_show' => 'Ausente',
      _ => status,
    };
