import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/env_config.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_bar_actions.dart';
import '../../../shared/widgets/app_skeleton_list.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_container.dart';
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import 'widgets/document_detail_sheet.dart';
import 'widgets/document_request_sheet.dart';

/// Builds a full download URL from a relative file path.
/// The backend returns paths like `/uploads/documents/uuid_file.pdf`
/// which need the server origin prepended for download.
String buildDownloadUrl(String relativePath) {
  if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
    return relativePath; // Already absolute
  }
  // Extract server origin from API base URL (strip /api/v1 suffix)
  final apiBase = Uri.parse(AppConfig.apiBaseUrl);
  final origin = '${apiBase.scheme}://${apiBase.host}${apiBase.hasPort ? ':${apiBase.port}' : ''}';
  return '$origin$relativePath';
}

class ClientDocumentsScreen extends ConsumerStatefulWidget {
  const ClientDocumentsScreen({super.key});

  @override
  ConsumerState<ClientDocumentsScreen> createState() =>
      _ClientDocumentsScreenState();
}

class _ClientDocumentsScreenState extends ConsumerState<ClientDocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final autoOpen = ref.read(documentAutoOpenDrawerProvider);
      if (autoOpen) {
        ref.read(documentAutoOpenDrawerProvider.notifier).state = false;
        showDocumentRequestSheet(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(documentFilterProvider);
    final documentsAsync = ref.watch(documentsProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
        actions: const [AppBarActions()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDocumentRequestSheet(context, ref),
        tooltip: 'Solicitar Documento',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Status filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: AppSpacing.sm,
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterTab(
                      label: 'Todos',
                      isSelected: filter == null,
                      onTap: () => ref
                          .read(documentFilterProvider.notifier)
                          .setFilter(null),
                    ),
                    _FilterTab(
                      label: 'Solicitados',
                      isSelected: filter == 'requested',
                      onTap: () => ref
                          .read(documentFilterProvider.notifier)
                          .setFilter(
                              filter == 'requested' ? null : 'requested'),
                    ),
                    _FilterTab(
                      label: 'Processando',
                      isSelected: filter == 'processing',
                      onTap: () => ref
                          .read(documentFilterProvider.notifier)
                          .setFilter(
                              filter == 'processing' ? null : 'processing'),
                    ),
                    _FilterTab(
                      label: 'Prontos',
                      isSelected: filter == 'ready',
                      onTap: () => ref
                          .read(documentFilterProvider.notifier)
                          .setFilter(filter == 'ready' ? null : 'ready'),
                    ),
                    _FilterTab(
                      label: 'Entregues',
                      isSelected: filter == 'delivered',
                      onTap: () => ref
                          .read(documentFilterProvider.notifier)
                          .setFilter(
                              filter == 'delivered' ? null : 'delivered'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Document list
          Expanded(
            child: documentsAsync.when(
              loading: () => const ResponsiveContainer(
                padding: EdgeInsets.all(16),
                child: AppSkeletonList(itemCount: 5, itemHeight: 72),
              ),
              error: (error, stack) => ResponsiveContainer(
                padding: const EdgeInsets.all(16),
                child: AppErrorState(
                  onRetry: () => ref.invalidate(documentsProvider),
                ),
              ),
              data: (documents) {
                final filtered = _applyFilter(documents, filter);
                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.folder_open,
                    message: 'Nenhum documento disponível',
                  );
                }
                return Column(
                  children: [
                    if (documentsAsync.isRefreshing)
                      const LinearProgressIndicator(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(documentsProvider);
                          await ref.read(documentsProvider.future);
                        },
                        child: ResponsiveContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: AppSpacing.sm,
                          ),
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) => AnimatedEntrance(
                              delay: AppAnimations.getEntranceDelay(index),
                              child: _DocumentCard(
                                document: filtered[index],
                                onDownload:
                                    filtered[index].isDownloadable &&
                                            filtered[index].fileUrl != null
                                        ? () =>
                                            _launchDownload(filtered[index].fileUrl!)
                                        : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DocumentModel> _applyFilter(
    List<DocumentModel> documents,
    String? filter,
  ) {
    if (filter == null) return documents;
    return documents.where((d) => d.status == filter).toList();
  }

  Future<void> _launchDownload(String url) async {
    final fullUrl = buildDownloadUrl(url);
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

String _typeLabel(String type) => switch (type) {
      'transcript' => 'Histórico Escolar',
      'enrollment_proof' => 'Comprovante de Matrícula',
      'declaration' => 'Declaração',
      'certificate' => 'Certificado',
      _ => type,
    };

String _statusLabel(String status) => switch (status) {
      'requested' => 'Solicitado',
      'processing' => 'Processando',
      'ready' => 'Pronto',
      'delivered' => 'Entregue',
      _ => status,
    };

class _DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onDownload;

  const _DocumentCard({
    required this.document,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReady = document.status == 'ready';
    final isProcessing = document.status == 'processing';

    return GlassCard(
      onTap: () => showDocumentDetailSheet(context, document),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Document icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Icon(
              Icons.description,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _typeLabel(document.type),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Solicitado em ${_formatDateTime(document.requestedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isReady
                  ? Colors.green.withValues(alpha: isDark ? 0.15 : 0.1)
                  : isProcessing
                      ? Colors.blue.withValues(alpha: isDark ? 0.15 : 0.1)
                      : Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isReady
                    ? Colors.green.withValues(alpha: 0.3)
                    : isProcessing
                        ? Colors.blue.withValues(alpha: 0.3)
                        : Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _statusLabel(document.status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isReady
                    ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                    : isProcessing
                        ? (isDark ? Colors.blue.shade300 : Colors.blue.shade700)
                        : (isDark ? Colors.amber.shade300 : Colors.amber.shade700),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Download button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isReady ? colors.primary : colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: isReady
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              icon: Icon(
                Icons.download,
                size: 20,
                color: isReady ? colors.onPrimary : colors.outlineVariant,
              ),
              onPressed: onDownload,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
