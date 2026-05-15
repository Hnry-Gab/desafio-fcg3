import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_bar_actions.dart';
import '../../../shared/widgets/app_skeleton_card.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_container.dart';
import '../models/staff_dashboard_model.dart';
import '../providers/staff_dashboard_provider.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(staffDashboardProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Gestão'),
        actions: const [AppBarActions()],
      ),
      body: dashboardAsync.when(
        loading: () => const ResponsiveContainer(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              AppSkeletonCard(height: 80),
              AppSkeletonCard(height: 80),
              AppSkeletonCard(height: 80),
            ],
          ),
        ),
        error: (error, stack) => ResponsiveContainer(
          padding: const EdgeInsets.all(16),
          child: AppErrorState(
            onRetry: () => ref.invalidate(staffDashboardProvider),
          ),
        ),
        data: (dashboard) {
          final width = MediaQuery.sizeOf(context).width;
          int crossAxisCount = 2;
          if (AppBreakpoints.isTablet(width)) crossAxisCount = 3;
          if (AppBreakpoints.isDesktop(width)) crossAxisCount = 4;

          return Column(
            children: [
              if (dashboardAsync.isRefreshing) const LinearProgressIndicator(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(staffDashboardProvider);
                    await ref.read(staffDashboardProvider.future);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ResponsiveContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          AnimatedEntrance(
                            delay: AppAnimations.getEntranceDelay(0),
                            child: Text(
                              'Visão estratégica da instituição.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Enrollment Period Banner
                          if (dashboard.enrollmentPeriod != null &&
                              dashboard.enrollmentPeriod!.isActive) ...[
                            AnimatedEntrance(
                              delay: AppAnimations.getEntranceDelay(1),
                              child: _EnrollmentBanner(
                                  period: dashboard.enrollmentPeriod!),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // KPI Grid
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final gap = AppSpacing.md;
                              final childWidth = (constraints.maxWidth -
                                      gap * (crossAxisCount - 1)) /
                                  crossAxisCount;

                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  SizedBox(
                                    width: childWidth,
                                    child: AnimatedEntrance(
                                      delay:
                                          AppAnimations.getEntranceDelay(2),
                                      child: _KpiCard(
                                        icon: Icons.people_outlined,
                                        iconColor: colors.primary,
                                        containerColor:
                                            colors.primaryContainer,
                                        value: dashboard.totalStudents
                                            .toString(),
                                        label: 'Alunos',
                                        onTap: null,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: childWidth,
                                    child: AnimatedEntrance(
                                      delay:
                                          AppAnimations.getEntranceDelay(3),
                                      child: _KpiCard(
                                        icon: Icons.chat_bubble_outlined,
                                        iconColor: colors.secondary,
                                        containerColor:
                                            colors.secondaryContainer,
                                        value: dashboard.activeChatSessions
                                            .toString(),
                                        label: 'Chats Hoje',
                                        onTap: () => context.go(
                                            '${RoutePaths.staffChats}?filter=hoje'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: childWidth,
                                    child: AnimatedEntrance(
                                      delay:
                                          AppAnimations.getEntranceDelay(4),
                                      child: _KpiCard(
                                        icon: Icons.warning_amber_outlined,
                                        iconColor: colors.error,
                                        containerColor:
                                            colors.errorContainer,
                                        value: dashboard.pendingDocuments
                                            .toString(),
                                        label: 'Docs Pendentes',
                                        onTap: () => context.go(
                                            '${RoutePaths.staffDocuments}?filter=pendentes'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: childWidth,
                                    child: AnimatedEntrance(
                                      delay:
                                          AppAnimations.getEntranceDelay(5),
                                      child: _KpiCard(
                                        icon: Icons.calendar_today_outlined,
                                        iconColor: colors.tertiary,
                                        containerColor:
                                            colors.tertiaryContainer,
                                        value: dashboard
                                            .upcomingAppointments
                                            .toString(),
                                        label: 'Agendamentos',
                                        onTap: () => context
                                            .go(RoutePaths.staffSchedule),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // AI Insights section
                          AnimatedEntrance(
                            delay: AppAnimations.getEntranceDelay(5),
                            child: GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.smart_toy,
                                        size: 20, color: colors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Insights de Eficiência IA',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.onSurface,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Taxa de Resolução Automatizada',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurface,
                                          ),
                                    ),
                                    Text(
                                      '${_calculateAiRate(dashboard)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull),
                                  child: LinearProgressIndicator(
                                    value: _calculateAiRate(dashboard) / 100,
                                    minHeight: 8,
                                    backgroundColor: colors.surfaceContainer,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Ações Rápidas section
                          AnimatedEntrance(
                            delay: AppAnimations.getEntranceDelay(6),
                            child: Text(
                              'Ações Rápidas',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AnimatedEntrance(
                            delay: AppAnimations.getEntranceDelay(7),
                            child: GlassCard(
                              onTap: () => context.go(RoutePaths.staffCadastro),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Icon(Icons.people_outlined,
                                      color: colors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Gerenciar Alunos',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Cadastrar, editar e gerenciar alunos',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: colors.onSurfaceVariant),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AnimatedEntrance(
                            delay: AppAnimations.getEntranceDelay(8),
                            child: GlassCard(
                              onTap: () => context.go(RoutePaths.staffBanners),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Icon(Icons.photo_library_outlined,
                                      color: colors.secondary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Gerenciar Banners',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Upload e gerenciamento de banners',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: colors.onSurfaceVariant),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  double _calculateAiRate(StaffDashboardModel dashboard) {
    final total = dashboard.activeChatSessions + 10; // mock baseline
    if (total == 0) return 0;
    return double.parse(((total - 1) / total * 100).clamp(0, 100).toStringAsFixed(1));
  }
}

class _EnrollmentBanner extends StatelessWidget {
  final EnrollmentPeriodInfo period;

  const _EnrollmentBanner({required this.period});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  period.daysRemaining != null
                      ? '${period.daysRemaining} dias restantes'
                      : 'Periodo ativo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              'Ativo',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color containerColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.containerColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // In light mode the theme containers are very dark (e.g. #004D57),
    // so we use a light tint of the icon color instead.
    final effectiveContainerColor = isDark
        ? containerColor
        : iconColor.withValues(alpha: 0.12);

    return GlassCard(
      onTap: onTap,
      glowColor: iconColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveContainerColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
