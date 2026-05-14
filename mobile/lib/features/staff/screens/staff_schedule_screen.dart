import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_bar_actions.dart';
import '../../../shared/widgets/app_skeleton_list.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_container.dart';
import '../../../shared/widgets/staff_search_bar.dart';
import '../../client/models/appointment_model.dart';
import '../models/scheduling_slot_model.dart';
import '../providers/staff_resource_provider.dart';
import '../providers/staff_schedule_provider.dart';
import 'widgets/create_slot_sheet.dart';
import 'widgets/edit_slot_sheet.dart';

// ============================================================================
// Main screen with TabBar: Agendamentos | Horarios
// ============================================================================

class StaffScheduleScreen extends ConsumerStatefulWidget {
  const StaffScheduleScreen({super.key});

  @override
  ConsumerState<StaffScheduleScreen> createState() =>
      _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends ConsumerState<StaffScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: const [AppBarActions()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Agendamentos'),
            Tab(text: 'Horarios'),
          ],
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurfaceVariant,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateSlotSheet(context, ref),
        tooltip: 'Novo Slot',
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AppointmentsTab(),
          _SlotsTab(),
        ],
      ),
    );
  }
}

// ============================================================================
// Tab 1: Agendamentos (existing, with added filters)
// ============================================================================

class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(staffScheduleFilterProvider);
    final searchQuery = ref.watch(staffScheduleSearchProvider);
    final appointmentsAsync = ref.watch(staffAppointmentsProvider);
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        StaffSearchBar(
          hintText: 'Buscar por nome ou RA...',
          onChanged: (q) =>
              ref.read(staffScheduleSearchProvider.notifier).setQuery(q),
        ),
        // Filter tabs
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
                        .read(staffScheduleFilterProvider.notifier)
                        .setFilter(null),
                  ),
                  _FilterTab(
                    label: 'Agendados',
                    isSelected: filter == 'scheduled',
                    onTap: () => ref
                        .read(staffScheduleFilterProvider.notifier)
                        .setFilter(
                            filter == 'scheduled' ? null : 'scheduled'),
                  ),
                  _FilterTab(
                    label: 'Concluidos',
                    isSelected: filter == 'completed',
                    onTap: () => ref
                        .read(staffScheduleFilterProvider.notifier)
                        .setFilter(
                            filter == 'completed' ? null : 'completed'),
                  ),
                  _FilterTab(
                    label: 'Cancelados',
                    isSelected: filter == 'cancelled',
                    onTap: () => ref
                        .read(staffScheduleFilterProvider.notifier)
                        .setFilter(
                            filter == 'cancelled' ? null : 'cancelled'),
                  ),
                  _FilterTab(
                    label: 'Ausentes',
                    isSelected: filter == 'no_show',
                    onTap: () => ref
                        .read(staffScheduleFilterProvider.notifier)
                        .setFilter(
                            filter == 'no_show' ? null : 'no_show'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: appointmentsAsync.when(
            loading: () => const ResponsiveContainer(
              padding: EdgeInsets.all(16),
              child: AppSkeletonList(itemCount: 5, itemHeight: 72),
            ),
            error: (error, stack) => ResponsiveContainer(
              padding: const EdgeInsets.all(16),
              child: AppErrorState(
                onRetry: () => ref.invalidate(staffAppointmentsProvider),
              ),
            ),
            data: (appointments) {
              final filtered =
                  _applyFilter(appointments, filter, searchQuery);
              if (filtered.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.calendar_today,
                  message: 'Nenhum agendamento',
                );
              }
              return Column(
                children: [
                  if (appointmentsAsync.isRefreshing)
                    const LinearProgressIndicator(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(staffAppointmentsProvider);
                        await ref.read(staffAppointmentsProvider.future);
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
                            delay:
                                AppAnimations.getEntranceDelay(index),
                            child: _AppointmentCard(
                              appointment: filtered[index],
                              onTap: () => context.push(
                                '/staff/schedule/${filtered[index].id}',
                                extra: filtered[index],
                              ),
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
    );
  }

  List<AppointmentModel> _applyFilter(
    List<AppointmentModel> appointments,
    String? filter,
    String searchQuery,
  ) {
    var result = appointments;

    if (filter != null) {
      result = result.where((a) => a.status == filter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((a) {
        final nameMatch =
            a.studentName?.toLowerCase().contains(query) ?? false;
        final raMatch = a.studentRa?.contains(query) ?? false;
        return nameMatch || raMatch;
      }).toList();
    }

    return result;
  }
}

// ============================================================================
// Tab 2: Horarios (slots management)
// ============================================================================

class _SlotsTab extends ConsumerWidget {
  const _SlotsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(staffAllSlotsProvider);
    final searchQuery = ref.watch(staffSlotSearchProvider);

    return Column(
      children: [
        // Resource filter dropdown
        Padding(
          padding: const EdgeInsets.fromLTRB(20, AppSpacing.sm, 20, 0),
          child: _ResourceFilterDropdown(),
        ),
        // Search bar
        StaffSearchBar(
          hintText: 'Buscar por recurso...',
          onChanged: (q) =>
              ref.read(staffSlotSearchProvider.notifier).setQuery(q),
        ),
        Expanded(
          child: slotsAsync.when(
            loading: () => const ResponsiveContainer(
              padding: EdgeInsets.all(16),
              child: AppSkeletonList(itemCount: 5, itemHeight: 72),
            ),
            error: (error, stack) => ResponsiveContainer(
              padding: const EdgeInsets.all(16),
              child: AppErrorState(
                onRetry: () => ref.invalidate(staffAllSlotsProvider),
              ),
            ),
            data: (slots) {
              final filtered = _applySearch(slots, searchQuery);
              if (filtered.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.access_time,
                  message: 'Nenhum horario encontrado',
                );
              }
              return Column(
                children: [
                  if (slotsAsync.isRefreshing)
                    const LinearProgressIndicator(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(staffAllSlotsProvider);
                        await ref.read(staffAllSlotsProvider.future);
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
                          itemBuilder: (context, index) =>
                              AnimatedEntrance(
                            delay:
                                AppAnimations.getEntranceDelay(index),
                            child: _SlotCard(slot: filtered[index]),
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
    );
  }

  List<SchedulingSlotModel> _applySearch(
    List<SchedulingSlotModel> slots,
    String query,
  ) {
    if (query.isEmpty) return slots;
    final q = query.toLowerCase();
    return slots.where((s) {
      final resourceName = s.staff?.name.toLowerCase() ?? '';
      return resourceName.contains(q);
    }).toList();
  }
}

// ============================================================================
// Resource filter dropdown for Slots tab
// ============================================================================

class _ResourceFilterDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(staffResourcesProvider);
    final selectedId = ref.watch(staffSlotResourceFilterProvider);

    return resourcesAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox.shrink(),
      data: (resources) {
        final available = resources.where((r) => r.isAvailable).toList();
        return DropdownButtonFormField<String?>(
          decoration: const InputDecoration(
            labelText: 'Filtrar por recurso',
            prefixIcon: Icon(Icons.filter_list),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: selectedId,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos os recursos'),
            ),
            ...available.map((r) => DropdownMenuItem<String?>(
                  value: r.id,
                  child: Text(r.name),
                )),
          ],
          onChanged: (value) {
            ref
                .read(staffSlotResourceFilterProvider.notifier)
                .setResourceId(value);
            ref.invalidate(staffAllSlotsProvider);
          },
        );
      },
    );
  }
}

// ============================================================================
// Slot card with status indicator and actions
// ============================================================================

class _SlotCard extends ConsumerWidget {
  final SchedulingSlotModel slot;

  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final slotDate = DateTime.tryParse(slot.date);
    final isPast = slotDate != null && slotDate.isBefore(DateTime(now.year, now.month, now.day));

    // Status: available, booked, or past
    final String statusLabel;
    final Color statusBg;
    final Color statusFg;

    if (isPast && slot.isAvailable) {
      statusLabel = 'Expirado';
      statusBg = isDark
          ? colors.surfaceContainerHigh
          : Colors.grey.shade200;
      statusFg = colors.onSurfaceVariant;
    } else if (slot.isAvailable) {
      statusLabel = 'Disponivel';
      statusBg = isDark
          ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
          : const Color(0xFF4CAF50).withValues(alpha: 0.1);
      statusFg = isDark
          ? const Color(0xFF81C784)
          : const Color(0xFF2E7D32);
    } else {
      statusLabel = 'Reservado';
      statusBg = isDark
          ? const Color(0xFF2196F3).withValues(alpha: 0.15)
          : const Color(0xFF2196F3).withValues(alpha: 0.1);
      statusFg = isDark
          ? const Color(0xFF64B5F6)
          : const Color(0xFF1565C0);
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Time icon with color
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              slot.isAvailable ? Icons.access_time : Icons.event_busy,
              color: statusFg,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Slot info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.staff?.name ?? 'Recurso',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatSlotDateTime(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: statusFg.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusFg,
              ),
            ),
          ),
          // Actions (only for available, non-past slots)
          if (slot.isAvailable && !isPast) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: Icon(Icons.more_vert, color: colors.onSurfaceVariant),
              onSelected: (action) => _onAction(context, ref, action),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Excluir',
                          style: TextStyle(color: Colors.red.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatSlotDateTime() {
    final dateParts = slot.date.split('-');
    final dateStr = dateParts.length == 3
        ? '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}'
        : slot.date;
    return '$dateStr  ${slot.startTime} - ${slot.endTime}';
  }

  void _onAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        showEditSlotSheet(context, ref, slot);
        break;
      case 'delete':
        _confirmDelete(context, ref);
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Horario'),
        content: const Text(
          'Tem certeza que deseja excluir este horario? Esta acao nao pode ser desfeita.',
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
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref.read(staffScheduleServiceProvider).deleteSlot(slot.id);
        ref.invalidate(staffAllSlotsProvider);
        ref.invalidate(staffSlotsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Horario excluido com sucesso')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir horario: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

// ============================================================================
// Shared widgets
// ============================================================================

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
          color: isSelected
              ? colors.surfaceContainerLowest
              : Colors.transparent,
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
                color:
                    isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

String _statusLabel(String status) => switch (status) {
      'scheduled' => 'Agendado',
      'cancelled' => 'Cancelado',
      'completed' => 'Concluido',
      'no_show' => 'Ausente',
      _ => status,
    };

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusStyle = _getStatusStyle(appointment.status, isDark, colors);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.primaryContainer,
            child: Text(
              appointment.studentName?[0].toUpperCase() ?? '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.studentName ?? 'Aluno',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.resourceName ?? 'Recurso nao definido',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _buildDateTimeText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant
                            .withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusStyle.bg,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: statusStyle.fg.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              _statusLabel(appointment.status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusStyle.fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildDateTimeText() {
    final parts = <String>[];
    if (appointment.slotDate != null) parts.add(appointment.slotDate!);
    if (appointment.slotStartTime != null) {
      parts.add(appointment.slotStartTime!);
    }
    return parts.isEmpty ? 'Data nao definida' : parts.join(' ');
  }
}

// Status colors helper
({Color bg, Color fg}) _getStatusStyle(
  String status,
  bool isDark,
  ColorScheme colors,
) {
  return switch (status) {
    'scheduled' => (
      bg: isDark
          ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
          : const Color(0xFF4CAF50).withValues(alpha: 0.1),
      fg: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
    ),
    'completed' => (
      bg: isDark
          ? const Color(0xFF2196F3).withValues(alpha: 0.15)
          : const Color(0xFF2196F3).withValues(alpha: 0.1),
      fg: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0),
    ),
    'cancelled' => (
      bg: isDark
          ? colors.error.withValues(alpha: 0.15)
          : colors.error.withValues(alpha: 0.1),
      fg: isDark ? colors.error : colors.error,
    ),
    'no_show' => (
      bg: isDark
          ? Colors.orange.withValues(alpha: 0.15)
          : Colors.orange.withValues(alpha: 0.1),
      fg: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
    ),
    _ => (
      bg: isDark ? colors.surfaceContainerHigh : Colors.grey.shade200,
      fg: colors.onSurfaceVariant,
    ),
  };
}
