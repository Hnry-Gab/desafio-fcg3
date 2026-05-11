import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';

/// Standard app bar actions (support + theme toggle + logout) used across all screens.
///
/// Keeps the UI consistent and avoids duplicating logic.
/// Support and Notification icons only show for student (client) role.
class AppBarActions extends ConsumerWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final isStudent =
        authState is AuthAuthenticated && authState.user.isStudent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isStudent) ...[
          IconButton(
            icon: Icon(Icons.support_agent_outlined, color: colors.primary),
            onPressed: () => GoRouter.of(context).go(RoutePaths.clientSupport),
            tooltip: 'Suporte',
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: colors.primary),
            onPressed: () =>
                GoRouter.of(context).go(RoutePaths.clientNotifications),
            tooltip: 'Notificações',
          ),
        ],
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: colors.primary,
          ),
          onPressed: () {
            // Toggle based on actual current brightness, not ThemeMode
            final next = isDark ? ThemeMode.light : ThemeMode.dark;
            ref.read(themeModeNotifierProvider.notifier).setThemeMode(next);
          },
          tooltip: 'Alternar tema',
        ),
        IconButton(
          icon: Icon(Icons.logout, color: colors.error),
          onPressed: () => ref.read(authProvider.notifier).logout(),
          tooltip: 'Sair',
        ),
      ],
    );
  }
}
