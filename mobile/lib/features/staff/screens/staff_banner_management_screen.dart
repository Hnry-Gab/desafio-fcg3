import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
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
import '../models/banner_model.dart';
import '../providers/banner_management_provider.dart';

/// Staff/provider screen for managing banners (upload, toggle, delete, reorder).
///
/// Displays a grid of banner cards with thumbnail, active/inactive badge,
/// Switch toggle, and delete button. Long-press a card to drag and reorder.
/// FAB opens file picker for image upload.
class StaffBannerManagementScreen extends ConsumerWidget {
  const StaffBannerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Banners'),
        actions: const [AppBarActions()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUpload(context, ref),
        tooltip: 'Adicionar Banner',
        child: const Icon(Icons.add),
      ),
      body: bannersAsync.when(
        loading: () => const ResponsiveContainer(
          padding: EdgeInsets.all(16),
          child: AppSkeletonList(itemCount: 4, itemHeight: 180),
        ),
        error: (error, stack) => ResponsiveContainer(
          padding: const EdgeInsets.all(16),
          child: AppErrorState(
            onRetry: () => ref.invalidate(bannersProvider),
          ),
        ),
        data: (banners) {
          if (banners.isEmpty) {
            return const AppEmptyState(
              icon: Icons.photo_library_outlined,
              message: 'Nenhum banner cadastrado',
            );
          }
          return Column(
            children: [
              if (bannersAsync.isRefreshing) const LinearProgressIndicator(),
              // Reorder hint
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator,
                        size: 14, color: colors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Segure e arraste para reordenar',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(bannersProvider);
                    await ref.read(bannersProvider.future);
                  },
                  child: ResponsiveContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: AppSpacing.sm,
                    ),
                    child: _ReorderableBannerGrid(
                      banners: banners,
                      colors: colors,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro: não foi possível ler o arquivo'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    final mimeType = _mimeTypeFromFilename(file.name);

    try {
      await ref.read(bannersProvider.notifier).upload(
            bytes,
            file.name,
            mimeType,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner adicionado')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar banner: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Derive MIME type from file extension.
  static String _mimeTypeFromFilename(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}

/// Builds the full URL for a banner image.
String _buildBannerImageUrl(String imageUrl) {
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  final apiBase = Uri.parse(AppConfig.apiBaseUrl);
  final origin =
      '${apiBase.scheme}://${apiBase.host}${apiBase.hasPort ? ':${apiBase.port}' : ''}';
  return '$origin/uploads/$imageUrl';
}

// ---------------------------------------------------------------------------
// Reorderable banner grid using LongPressDraggable + DragTarget
// ---------------------------------------------------------------------------

class _ReorderableBannerGrid extends ConsumerStatefulWidget {
  final List<BannerModel> banners;
  final ColorScheme colors;

  const _ReorderableBannerGrid({
    required this.banners,
    required this.colors,
  });

  @override
  ConsumerState<_ReorderableBannerGrid> createState() =>
      _ReorderableBannerGridState();
}

class _ReorderableBannerGridState
    extends ConsumerState<_ReorderableBannerGrid> {
  int? _draggedIndex;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const spacing = AppSpacing.md;
        final cardWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;
        final cardHeight = cardWidth / 0.85; // match aspect ratio

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          itemCount: widget.banners.length,
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            final isDragged = _draggedIndex == index;
            final isHovered = _hoveredIndex == index;

            return AnimatedEntrance(
              delay: AppAnimations.getEntranceDelay(index),
              child: DragTarget<int>(
                onWillAcceptWithDetails: (details) {
                  if (details.data != index) {
                    setState(() => _hoveredIndex = index);
                    return true;
                  }
                  return false;
                },
                onLeave: (_) {
                  setState(() => _hoveredIndex = null);
                },
                onAcceptWithDetails: (details) {
                  setState(() => _hoveredIndex = null);
                  ref
                      .read(bannersProvider.notifier)
                      .reorder(details.data, index);
                },
                builder: (context, candidateData, rejectedData) {
                  return LongPressDraggable<int>(
                    data: index,
                    delay: const Duration(milliseconds: 200),
                    hapticFeedbackOnStart: true,
                    onDragStarted: () {
                      setState(() => _draggedIndex = index);
                    },
                    onDragEnd: (_) {
                      setState(() {
                        _draggedIndex = null;
                        _hoveredIndex = null;
                      });
                    },
                    feedback: Material(
                      color: Colors.transparent,
                      elevation: 12,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: Opacity(
                          opacity: 0.9,
                          child: _BannerCard(
                            banner: banner,
                            colors: widget.colors,
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.25,
                      child: _BannerCard(
                        banner: banner,
                        colors: widget.colors,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        border: isHovered
                            ? Border.all(
                                color: widget.colors.primary, width: 2)
                            : null,
                      ),
                      transform: isHovered
                          ? (Matrix4.identity()..scale(0.95, 0.95))
                          : (isDragged
                              ? (Matrix4.identity()..scale(0.95, 0.95))
                              : Matrix4.identity()),
                      transformAlignment: Alignment.center,
                      child: _BannerCard(
                        banner: banner,
                        colors: widget.colors,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Individual banner card
// ---------------------------------------------------------------------------

class _BannerCard extends ConsumerWidget {
  final BannerModel banner;
  final ColorScheme colors;

  const _BannerCard({
    required this.banner,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg),
                topRight: Radius.circular(AppSpacing.radiusLg),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _buildBannerImageUrl(banner.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.surfaceContainerLow,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: colors.onSurfaceVariant,
                        size: 40,
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                  // Drag handle hint at top-right
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Controls row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: banner.isEnabled
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    banner.isEnabled ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: banner.isEnabled ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                // Toggle switch
                SizedBox(
                  height: 28,
                  child: FittedBox(
                    child: Switch(
                      value: banner.isEnabled,
                      onChanged: (value) => _handleToggle(context, ref, value),
                      activeTrackColor: colors.primary,
                    ),
                  ),
                ),
                // Delete button
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    icon: Icon(Icons.delete_outline, color: colors.error),
                    onPressed: () => _handleDelete(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    try {
      await ref.read(bannersProvider.notifier).toggle(banner.id, value);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar estado: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir banner?'),
        content: const Text(
          'Tem certeza que deseja excluir este banner? Esta ação não pode ser desfeita.',
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Excluir'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(bannersProvider.notifier).delete(banner.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banner excluído')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir banner: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
