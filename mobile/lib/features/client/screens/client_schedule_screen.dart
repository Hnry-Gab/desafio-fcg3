import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_bar_actions.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_skeleton_card.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../providers/class_schedule_provider.dart';

/// Weekly class timetable screen.
///
/// Displays the student's enrolled courses organized by day of week
/// in a tabbed view (Mon-Fri). Each class card shows time, professor,
/// room and course description.
///
/// Requirements: GRAD-01, GRAD-02, GRAD-03.
class ClientScheduleScreen extends ConsumerWidget {
  final String? studentId;

  const ClientScheduleScreen({super.key, this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final effectiveId = studentId ??
        (authState is AuthAuthenticated ? authState.user.id : '');

    if (effectiveId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final scheduleAsync = ref.watch(weeklyScheduleProvider(effectiveId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Semanal'),
        actions: const [AppBarActions()],
      ),
      body: scheduleAsync.when(
        loading: () => const ResponsiveContainer(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            AppSkeletonCard(height: 60),
            AppSkeletonCard(height: 120),
            AppSkeletonCard(height: 120),
            AppSkeletonCard(height: 120),
          ]),
        ),
        error: (error, stack) => ResponsiveContainer(
          padding: const EdgeInsets.all(20),
          child: AppErrorState(
            onRetry: () =>
                ref.invalidate(weeklyScheduleProvider(effectiveId)),
          ),
        ),
        data: (schedule) => _ScheduleContent(
          schedule: schedule,
          studentId: effectiveId,
        ),
      ),
    );
  }
}

class _ScheduleContent extends ConsumerStatefulWidget {
  final WeeklyScheduleData schedule;
  final String studentId;

  const _ScheduleContent({
    required this.schedule,
    required this.studentId,
  });

  @override
  ConsumerState<_ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends ConsumerState<_ScheduleContent>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default to today's tab if it's a weekday
    final today = DateTime.now().weekday - 1; // 0=Mon .. 6=Sun
    final tabCount = widget.schedule.days.length;
    final initialIndex = today >= 0 && today < tabCount ? today : 0;
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final days = widget.schedule.days;

    if (days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Nenhuma aula na grade',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Matricule-se em disciplinas para ver sua grade semanal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Day tabs
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            border: Border(
              bottom: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: days.length > 5,
            tabAlignment: days.length > 5 ? TabAlignment.start : TabAlignment.fill,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: days.map((day) {
              final abbr = _dayAbbreviation(day.dayName);
              final count = day.slots.length;
              return Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(abbr),
                    if (count > 0)
                      Text(
                        '$count aula${count > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: days.map((day) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(
                      weeklyScheduleProvider(widget.studentId));
                  await ref.read(
                      weeklyScheduleProvider(widget.studentId).future);
                },
                child: day.slots.isEmpty
                    ? _buildEmptyDay(context, day.dayName)
                    : _buildDaySlots(context, day),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDay(BuildContext context, String dayName) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ResponsiveContainer(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 60),
              Icon(
                Icons.wb_sunny_outlined,
                size: 48,
                color: colors.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sem aulas na $dayName',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySlots(BuildContext context, ScheduleDay day) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ResponsiveContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: day.slots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AnimatedEntrance(
                delay: AppAnimations.getEntranceDelay(index),
                child: _ClassSlotCard(slot: slot),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _dayAbbreviation(String dayName) {
    switch (dayName) {
      case 'Segunda':
        return 'Seg';
      case 'Terça':
        return 'Ter';
      case 'Quarta':
        return 'Qua';
      case 'Quinta':
        return 'Qui';
      case 'Sexta':
        return 'Sex';
      case 'Sábado':
        return 'Sáb';
      case 'Domingo':
        return 'Dom';
      default:
        return dayName.substring(0, 3);
    }
  }
}

class _ClassSlotCard extends StatelessWidget {
  final ScheduleSlot slot;
  const _ClassSlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                Text(
                  slot.startTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 12,
                    color: colors.primary.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  slot.endTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Course info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course code badge + name
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(
                            alpha: isDark ? 0.15 : 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        slot.courseCode,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        slot.courseName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Professor
                if (slot.professor != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outlined,
                        size: 14,
                        color: isDark
                            ? colors.onSurfaceVariant
                            : colors.onSurface.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          slot.professor!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? colors.onSurfaceVariant
                                        : colors.onSurface
                                            .withValues(alpha: 0.55),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                // Room
                if (slot.room != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDark
                            ? colors.onSurfaceVariant
                            : colors.onSurface.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          slot.room!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? colors.onSurfaceVariant
                                        : colors.onSurface
                                            .withValues(alpha: 0.55),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
