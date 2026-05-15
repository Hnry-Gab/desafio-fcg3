import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/alpha_connect_logo.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_bar_actions.dart';
import '../../../shared/widgets/app_skeleton_card.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../providers/banner_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/document_provider.dart';
import '../providers/appointment_provider.dart';
import '../models/chat_session_model.dart';
import '../models/appointment_model.dart';
import 'widgets/banner_carousel.dart';


String _formatDateTime(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(chatSessionsProvider);
    ref.invalidate(documentsProvider);
    ref.invalidate(appointmentsProvider);
    ref.invalidate(studentBannersProvider);
    await Future.wait([
      ref.read(chatSessionsProvider.future),
      ref.read(documentsProvider.future),
      ref.read(appointmentsProvider.future),
      ref.read(studentBannersProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState is AuthAuthenticated ? authState.user.name : '';
    final userEmail = authState is AuthAuthenticated ? authState.user.email : '';
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chatSessionsAsync = ref.watch(chatSessionsProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final bannersAsync = ref.watch(studentBannersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alpha Connect'),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: const AlphaConnectLogo(size: 36),
        ),
        actions: const [AppBarActions()],
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting — tap to open profile
                AnimatedEntrance(
                  delay: AppAnimations.getEntranceDelay(0),
                  child: GlassCard(
                    onTap: () => context.go(
                      RoutePaths.clientProfile,
                      extra: {
                        'studentId': userId,
                        'studentName': userName,
                        'studentEmail': userEmail,
                      },
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colors.primary.withValues(alpha: isDark ? 0.3 : 0.12),
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 20,
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
                                'Olá, $userName!',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Toque para ver seu perfil acadêmico',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.55),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Banner carousel (BNNR-01: below greeting card)
                bannersAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (banners) => banners.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            AnimatedEntrance(
                              delay: AppAnimations.getEntranceDelay(1),
                              child: BannerCarousel(banners: banners),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                ),

                // Summary cards grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AnimatedEntrance(
                              delay: AppAnimations.getEntranceDelay(2),
                              child: _buildChatSummaryCard(
                                  context, chatSessionsAsync, colors),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AnimatedEntrance(
                              delay: AppAnimations.getEntranceDelay(3),
                              child: _buildAppointmentSummaryCard(
                                  context, appointmentsAsync, colors),
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        AnimatedEntrance(
                          delay: AppAnimations.getEntranceDelay(2),
                          child: _buildChatSummaryCard(
                              context, chatSessionsAsync, colors),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AnimatedEntrance(
                          delay: AppAnimations.getEntranceDelay(3),
                          child: _buildAppointmentSummaryCard(
                              context, appointmentsAsync, colors),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick Actions
                AnimatedEntrance(
                  delay: AppAnimations.getEntranceDelay(4),
                  child: Text(
                    'Ações Rápidas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildQuickActions(context, ref, appointmentsAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatSummaryCard(
    BuildContext context,
    AsyncValue<List<ChatSessionModel>> asyncValue,
    ColorScheme colors,
  ) {
    return asyncValue.when(
      loading: () => const AppSkeletonCard(height: 140),
      error: (_, __) => _SummaryGlassCard(
        icon: Icons.smart_toy_outlined,
        iconBgColor: colors.primaryContainer,
        iconColor: colors.onPrimaryContainer,
        title: 'Chatbot Alpha',
        subtitle: 'Assistente Virtual',
        bottomLabel: 'Última interação:',
        bottomValue: 'Erro ao carregar',
        onTap: () => context.go(RoutePaths.clientChat),
      ),
      data: (sessions) {
        String lastTime;
        if (sessions.isEmpty) {
          lastTime = 'Nenhuma';
        } else {
          lastTime = _formatDateTime(sessions.first.startedAt);
        }
        return _SummaryGlassCard(
          icon: Icons.smart_toy_outlined,
          iconBgColor: colors.primaryContainer,
          iconColor: colors.onPrimaryContainer,
          title: 'Chatbot Alpha',
          subtitle: 'Assistente Virtual',
          bottomLabel: 'Última interação:',
          bottomValue: lastTime,
          onTap: () => context.go(RoutePaths.clientChat),
        );
      },
    );
  }

  Widget _buildAppointmentSummaryCard(
    BuildContext context,
    AsyncValue<List<AppointmentModel>> asyncValue,
    ColorScheme colors,
  ) {
    return asyncValue.when(
      loading: () => const AppSkeletonCard(height: 140),
      error: (_, __) => _SummaryGlassCard(
        icon: Icons.calendar_today,
        iconBgColor: colors.secondaryContainer,
        iconColor: colors.onSecondaryContainer,
        title: 'Agendamentos',
        subtitle: 'Próximos Eventos',
        bottomLabel: 'Próximo:',
        bottomValue: 'Erro ao carregar',
        onTap: () => context.go('${RoutePaths.clientResources}?tab=1'),
      ),
      data: (appointments) {
        final upcoming = appointments.where((a) => a.isUpcoming).toList();
        String nextTime;
        if (upcoming.isEmpty) {
          nextTime = 'Sem agendamentos';
        } else {
          final next = upcoming.first;
          nextTime = '${next.slotDate ?? ''} ${next.slotStartTime ?? ''}'.trim();
          if (nextTime.isEmpty) nextTime = 'Agendado';
        }
        return _SummaryGlassCard(
          icon: Icons.calendar_today,
          iconBgColor: colors.secondaryContainer,
          iconColor: colors.onSecondaryContainer,
          title: 'Agendamentos',
          subtitle: 'Próximos Eventos',
          bottomLabel: 'Próximo:',
          bottomValue: nextTime,
          onTap: () => context.go('${RoutePaths.clientResources}?tab=1'),
        );
      },
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppointmentModel>> appointmentsAsync,
  ) {
    final colors = Theme.of(context).colorScheme;

    final actions = [
      _QuickAction(
        label: 'Solicitar documentos',
        icon: Icons.description_outlined,
        color: colors.primary,
        onTap: () {
          ref.read(documentAutoOpenDrawerProvider.notifier).state = true;
          context.go(RoutePaths.clientDocuments);
        },
      ),
      _QuickAction(
        label: 'Matricular em disciplinas',
        icon: Icons.school_outlined,
        color: colors.secondary,
        onTap: () {
          final authState = ref.read(authProvider);
          if (authState is AuthAuthenticated) {
            context.go(
              RoutePaths.clientEnrollment,
              extra: {'studentId': authState.user.id},
            );
          }
        },
      ),
      _QuickAction(
        label: 'Grade semanal de aulas',
        icon: Icons.calendar_month_outlined,
        color: colors.tertiary,
        onTap: () {
          final authState = ref.read(authProvider);
          if (authState is AuthAuthenticated) {
            context.go(
              RoutePaths.clientSchedule,
              extra: {'studentId': authState.user.id},
            );
          }
        },
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.2,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return AnimatedEntrance(
          delay: AppAnimations.getEntranceDelay(5 + index),
          child: GlassCard(
            onTap: action.onTap,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(action.icon, size: 20, color: action.color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

}

class _SummaryGlassCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String bottomLabel;
  final String bottomValue;
  final VoidCallback? onTap;

  const _SummaryGlassCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.bottomLabel,
    required this.bottomValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    bottomLabel,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ),
                Flexible(
                  child: Text(
                    bottomValue,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
