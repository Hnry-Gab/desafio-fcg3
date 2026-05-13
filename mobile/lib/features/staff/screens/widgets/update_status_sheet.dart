import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../client/models/document_model.dart';
import '../../providers/staff_document_provider.dart';

/// Status lifecycle order — mirrors backend _STATUS_ORDER
const _statusOrder = ['requested', 'processing', 'ready', 'delivered'];

/// Human-readable labels for each status
String _statusLabel(String status) => switch (status) {
      'requested' => 'Solicitado',
      'processing' => 'Processando',
      'ready' => 'Pronto',
      'delivered' => 'Entregue',
      _ => status,
    };

/// Returns the next valid status in the lifecycle, or null if terminal.
String? _nextStatus(String currentStatus) {
  final idx = _statusOrder.indexOf(currentStatus);
  if (idx < 0 || idx >= _statusOrder.length - 1) return null;
  return _statusOrder[idx + 1];
}

/// Shows the update status bottom sheet for a document.
void showUpdateStatusSheet(
    BuildContext context, WidgetRef ref, DocumentModel document) {
  final next = _nextStatus(document.status);

  if (next == null) {
    // Terminal status — no further transitions possible
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este documento já está no status final (Entregue).'),
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _UpdateStatusSheet(
      document: document,
      targetStatus: next,
    ),
  );
}

class _UpdateStatusSheet extends ConsumerStatefulWidget {
  final DocumentModel document;
  final String targetStatus;

  const _UpdateStatusSheet({
    required this.document,
    required this.targetStatus,
  });

  @override
  ConsumerState<_UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends ConsumerState<_UpdateStatusSheet> {
  String? _pickedFilePath;
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  bool _isLoading = false;

  bool get _requiresFile => widget.targetStatus == 'ready';

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg'],
      withData: kIsWeb,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      // Validate max 10MB
      if (file.size > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo excede o tamanho máximo de 10MB'),
            ),
          );
        }
        return;
      }
      setState(() {
        _pickedFilePath = kIsWeb ? null : file.path;
        _pickedFileName = file.name;
        _pickedFileBytes = file.bytes;
      });
    }
  }

  Future<void> _submit() async {
    // Validate: file required when setting status to 'ready'
    final hasFile = _pickedFilePath != null || _pickedFileBytes != null;
    if (_requiresFile && !hasFile && widget.document.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Anexe o arquivo antes de finalizar o documento'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(staffDocumentServiceProvider);
      String? uploadedUrl;

      // If status is 'ready' and file is picked, upload first
      if (_requiresFile && hasFile) {
        if (_pickedFileBytes != null && kIsWeb) {
          uploadedUrl = await service.uploadFileBytes(
            _pickedFileBytes!,
            _pickedFileName!,
          );
        } else if (_pickedFilePath != null) {
          uploadedUrl = await service.uploadFile(
            _pickedFilePath!,
            _pickedFileName!,
          );
        }
      }

      // Update document status
      await service.updateDocumentStatus(
        widget.document.id,
        status: widget.targetStatus,
        fileUrl: uploadedUrl,
      );

      ref.invalidate(staffDocumentsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status atualizado para ${_statusLabel(widget.targetStatus)}!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = _parseErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _parseErrorMessage(Object error) {
    if (error is Exception) {
      final str = error.toString();
      // Try to extract meaningful message from DioException response
      if (str.contains('TRANSICAO_STATUS_INVALIDA')) {
        return 'Transição de status inválida. O status deve seguir a ordem: Solicitado → Processando → Pronto → Entregue.';
      }
      if (str.contains('file_url')) {
        return 'É necessário anexar um arquivo para finalizar o documento.';
      }
      if (str.contains('403') || str.contains('FORBIDDEN')) {
        return 'Você não tem permissão para esta ação.';
      }
    }
    return 'Erro ao atualizar status. Tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Atualizar Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Status transition info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _StatusChip(
                      label: _statusLabel(widget.document.status),
                      color: colors.outline,
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_forward, color: colors.outline, size: 20),
                    const SizedBox(width: 12),
                    _StatusChip(
                      label: _statusLabel(widget.targetStatus),
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // File picker (when transitioning to 'ready')
              if (_requiresFile) ...[
                Text(
                  'Anexar documento finalizado:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                if (widget.document.fileUrl != null && _pickedFileName == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Arquivo existente será mantido',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(_pickedFileName ?? 'Selecionar arquivo (PDF, PNG, JPG)'),
                ),
                const SizedBox(height: 20),
              ],
              // Submit button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_actionLabel(widget.targetStatus)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(String status) => switch (status) {
        'processing' => 'Marcar como Processando',
        'ready' => 'Finalizar Documento',
        'delivered' => 'Marcar como Entregue',
        _ => 'Atualizar Status',
      };
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
