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
// Tab 2: Horarios (slots management — grouped by resource + date)
// ============================================================================

/// A group of consecutive slots for the same resource on the same date.
class _SlotGroup {
  final String resourceId;
  final String resourceName;
  final String date; // YYYY-MM-DD
  final List<SchedulingSlotModel> slots;

  _SlotGroup({
    required this.resourceId,
    required this.resourceName,
    required this.date,
    required this.slots,
  });

  int get total => slots.length;
  int get available => slots.where((s) => s.isAvailable).length;
  int get booked => total - available;

  String get firstStart => slots.first.startTime;
  String get lastEnd => slots.last.endTime;

  /// Infer slot duration from the first slot
  int get slotDurationMin {
    if (slots.isEmpty) return 0;
    final s = slots.first;
    final startParts = s.startTime.split(':');
    final endParts = s.endTime.split(':');
    final startMin =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return endMin - startMin;
  }

  String get dateFormatted {
    final parts = date.split('-');
    return parts.length == 3
        ? '${parts[2]}/${parts[1]}/${parts[0]}'
        : date;
  }

  bool get isPast {
    final d = DateTime.tryParse(date);
    if (d == null) return false;
    final now = DateTime.now();
    return d.isBefore(DateTime(now.year, now.month, now.day));
  }
}

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
              child: AppSkeletonList(itemCount: 4, itemHeight: 100),
            ),
            error: (error, stack) => ResponsiveContainer(
              padding: const EdgeInsets.all(16),
              child: AppErrorState(
                onRetry: () => ref.invalidate(staffAllSlotsProvider),
              ),
            ),
            data: (slots) {
              final groups = _groupSlots(slots, searchQuery);
              if (groups.isEmpty) {
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
                          itemCount: groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) =>
                              AnimatedEntrance(
                            delay:
                                AppAnimations.getEntranceDelay(index),
                            child:
                                _SlotGroupCard(group: groups[index]),
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

  List<_SlotGroup> _groupSlots(
    List<SchedulingSlotModel> slots,
    String searchQuery,
  ) {
    // Apply search filter first
    var filtered = slots;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = slots.where((s) {
        final name = s.staff?.name.toLowerCase() ?? '';
        return name.contains(q);
      }).toList();
    }

    // Group by resourceId + date
    final map = <String, _SlotGroup>{};
    for (final slot in filtered) {
      final key = '${slot.staff?.id ?? 'unknown'}_${slot.date}';
      if (!map.containsKey(key)) {
        map[key] = _SlotGroup(
          resourceId: slot.staff?.id ?? '',
          resourceName: slot.staff?.name ?? 'Recurso',
          date: slot.date,
          slots: [],
        );
      }
      map[key]!.slots.add(slot);
    }

    // Sort groups by date then resource name
    final groups = map.values.toList()
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.resourceName.compareTo(b.resourceName);
      });

    return groups;
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
// Grouped slot card with occupancy bar and batch actions
// ============================================================================

class _SlotGroupCard extends ConsumerStatefulWidget {
  final _SlotGroup group;

  const _SlotGroupCard({required this.group});

  @override
  ConsumerState<_SlotGroupCard> createState() => _SlotGroupCardState();
}

class _SlotGroupCardState extends ConsumerState<_SlotGroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final g = widget.group;

    // Occupancy ratio
    final ratio = g.total > 0 ? g.booked / g.total : 0.0;

    // Colors
    final greenFg =
        isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final blueFg =
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);
    final greyFg = colors.onSurfaceVariant;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header row: resource name + menu ----
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.resourceName,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${g.dateFormatted}  ${g.firstStart} - ${g.lastEnd}',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                    ),
                  ],
                ),
              ),
              if (!g.isPast)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: Icon(Icons.more_vert,
                      color: colors.onSurfaceVariant),
                  onSelected: (action) =>
                      _onGroupAction(context, action),
                  itemBuilder: (_) => [
                    if (g.available > 0)
                      PopupMenuItem(
                        value: 'delete_available',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep,
                                size: 18,
                                color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text('Excluir disponiveis (${g.available})',
                                style: TextStyle(
                                    color: Colors.orange.shade700)),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever,
                              size: 18, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text('Excluir todos (${g.total})',
                              style: TextStyle(
                                  color: Colors.red.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ---- Stats row ----
          Row(
            children: [
              Text(
                '${g.total} slots de ${g.slotDurationMin}min',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
              ),
              const Spacer(),
              // Available count
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: greenFg.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${g.available} livre${g.available != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: greenFg,
                  ),
                ),
              ),
              if (g.booked > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: blueFg.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${g.booked} reservado${g.booked != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: blueFg,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ---- Occupancy bar ----
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: greenFg.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  g.isPast ? greyFg : blueFg,
                ),
              ),
            ),
          ),

          // ---- Expand/collapse details ----
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? 'Ocultar detalhes' : 'Ver detalhes',
                    style:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: colors.primary,
                  ),
                ],
              ),
            ),
          ),

          // ---- Expanded individual slots ----
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: g.slots
                    .map((slot) => _SlotDetailRow(
                          slot: slot,
                          isPast: g.isPast,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _onGroupAction(BuildContext context, String action) {
    switch (action) {
      case 'delete_available':
        _batchDelete(context, onlyAvailable: true);
        break;
      case 'delete_all':
        _batchDelete(context, onlyAvailable: false);
        break;
    }
  }

  Future<void> _batchDelete(
    BuildContext context, {
    required bool onlyAvailable,
  }) async {
    final g = widget.group;
    final label = onlyAvailable
        ? '${g.available} horario(s) disponivel(is)'
        : 'todos os ${g.total} horario(s)${g.booked > 0 ? ' (${g.booked} reservado(s) serao cancelados)' : ''}';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Horarios'),
        content: Text(
          'Excluir $label de ${g.resourceName} em ${g.dateFormatted}?',
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
        final result = await ref
            .read(staffScheduleServiceProvider)
            .batchDeleteSlots(
              resourceId: g.resourceId,
              date: g.date,
              onlyAvailable: onlyAvailable,
            );
        ref.invalidate(staffAllSlotsProvider);
        ref.invalidate(staffSlotsProvider);
        ref.invalidate(staffAppointmentsProvider);
        if (context.mounted) {
          final deleted = result['deleted_slots'] ?? 0;
          final cancelled = result['cancelled_appointments'] ?? 0;
          var msg = '$deleted horario(s) excluido(s)';
          if (cancelled > 0) {
            msg += ', $cancelled agendamento(s) cancelado(s)';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

// ============================================================================
// Individual slot row inside expanded group
// ============================================================================

class _SlotDetailRow extends ConsumerWidget {
  final SchedulingSlotModel slot;
  final bool isPast;

  const _SlotDetailRow({
    required this.slot,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isAvailable = slot.isAvailable;
    final Color dotColor;
    final String label;

    if (isPast && isAvailable) {
      dotColor = colors.onSurfaceVariant;
      label = 'Expirado';
    } else if (isAvailable) {
      dotColor =
          isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      label = 'Disponivel';
    } else {
      dotColor =
          isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);
      label = 'Reservado';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${slot.startTime} - ${slot.endTime}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dotColor,
                  fontSize: 11,
                ),
          ),
          const Spacer(),
          // Individual slot actions (edit/delete) only for available+non-past
          if (isAvailable && !isPast)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => showEditSlotSheet(context, ref, slot),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.edit,
                        size: 16, color: colors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _deleteSlot(context, ref),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close,
                        size: 16, color: colors.error),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _deleteSlot(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Horario'),
        content: Text(
          'Excluir o horario ${slot.startTime} - ${slot.endTime}?',
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
            const SnackBar(
                content: Text('Horario excluido com sucesso')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
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
