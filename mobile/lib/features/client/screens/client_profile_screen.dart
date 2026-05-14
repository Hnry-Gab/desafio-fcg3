import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_bar_actions.dart';
import '../../../shared/widgets/app_skeleton_card.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../providers/student_profile_provider.dart';

/// Reusable student profile screen. Used by both client (own profile) and
/// staff (viewing a student's profile). Pass [studentId], [studentName],
/// and [studentEmail] to populate the header without an extra API call.
class StudentProfileScreen extends ConsumerWidget {
  final String? studentId;
  final String? studentName;
  final String? studentEmail;
  final bool isStaffView;

  const StudentProfileScreen({
    super.key,
    this.studentId,
    this.studentName,
    this.studentEmail,
    this.isStaffView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve user data: use provided params or fall back to auth state
    final authState = ref.watch(authProvider);
    final effectiveId = studentId ?? (authState is AuthAuthenticated ? authState.user.id : '');
    final effectiveName = studentName ?? (authState is AuthAuthenticated ? authState.user.name : '');
    final effectiveEmail = studentEmail ?? (authState is AuthAuthenticated ? authState.user.email : '');

    if (effectiveId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileAsync = ref.watch(studentProfileProvider(effectiveId));
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isStaffView ? 'Detalhes do Aluno' : 'Meu Perfil'),
        automaticallyImplyLeading: isStaffView,
        leading: isStaffView
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        actions: const [AppBarActions()],
      ),
      body: profileAsync.when(
        loading: () => const ResponsiveContainer(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            AppSkeletonCard(height: 180),
            AppSkeletonCard(height: 120),
            AppSkeletonCard(height: 200),
          ]),
        ),
        error: (error, stack) => ResponsiveContainer(
          padding: const EdgeInsets.all(20),
          child: AppErrorState(
            onRetry: () => ref.invalidate(studentProfileProvider(effectiveId)),
          ),
        ),
        data: (profile) {
          final summary = profile.summary;
          final period = profile.period;
          final grades = profile.currentGrades;

          final semester = summary['semester'] ?? 1;
          final completedCourses = summary['completed_courses'] ?? 0;
          final totalCourses = summary['total_courses'] ?? 1;
          final gpa = (summary['gpa'] ?? 0.0).toDouble();
          final status = summary['status'] ?? 'active';
          final progress = totalCourses > 0 ? completedCourses / totalCourses : 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentProfileProvider(effectiveId));
              await ref.read(studentProfileProvider(effectiveId).future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Section 1: Personal Data ===
                    AnimatedEntrance(
                      delay: AppAnimations.getEntranceDelay(0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: colors.primary.withValues(alpha: isDark ? 0.3 : 0.12),
                              child: Text(
                                effectiveName.isNotEmpty ? effectiveName[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              effectiveName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              effectiveEmail,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.6),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Status badge + semester
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatusBadge(status: status),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                    border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    '$semester\u00BA Semestre',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // === Section 2: Academic Summary ===
                    AnimatedEntrance(
                      delay: AppAnimations.getEntranceDelay(1),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.school_outlined, size: 20, color: colors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Resumo Acadêmico',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Period info
                            if (period != null) ...[
                              _InfoRow(
                                label: 'Período',
                                value: period['name']?.toString() ?? period['semester_year']?.toString() ?? '—',
                              ),
                            ],
                            // CRA
                            _InfoRow(
                              label: 'CRA (Coeficiente)',
                              value: gpa.toStringAsFixed(2),
                              valueColor: gpa >= 7.0
                                  ? Colors.green.shade700
                                  : gpa >= 5.0
                                      ? Colors.amber.shade700
                                      : colors.error,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            // Progress bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progresso do Curso',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.6),
                                      ),
                                ),
                                Text(
                                  '$completedCourses/$totalCourses disciplinas',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              child: LinearProgressIndicator(
                                value: progress,
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

                    // === Section 3: Current Semester Grades ===
                    AnimatedEntrance(
                      delay: AppAnimations.getEntranceDelay(2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
                            child: Text(
                              period != null
                                  ? 'Disciplinas — ${period['semester_year'] ?? ''}'
                                  : 'Disciplinas',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                            ),
                          ),
                          if (grades.isEmpty)
                            GlassCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Center(
                                child: Text(
                                  'Nenhuma disciplina encontrada',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            )
                          else
                            ...grades.asMap().entries.map((entry) {
                              final index = entry.key;
                              final grade = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: AnimatedEntrance(
                                  delay: AppAnimations.getEntranceDelay(3 + index),
                                  child: _GradeCard(grade: grade),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    // === Enrollment button ===
                    if (!isStaffView)
                      AnimatedEntrance(
                        delay: AppAnimations.getEntranceDelay(4),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => context.push(
                              RoutePaths.clientEnrollment,
                              extra: {'studentId': effectiveId},
                            ),
                            icon: const Icon(Icons.school_outlined),
                            label: const Text('Matricular em Disciplinas'),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case 'active':
        bgColor = Colors.green.withValues(alpha: isDark ? 0.15 : 0.1);
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
        label = 'Ativo';
      case 'inactive':
        bgColor = Colors.red.withValues(alpha: isDark ? 0.15 : 0.1);
        textColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
        label = 'Inativo';
      case 'graduated':
        bgColor = Colors.blue.withValues(alpha: isDark ? 0.15 : 0.1);
        textColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
        label = 'Formado';
      default:
        bgColor = Colors.grey.withValues(alpha: isDark ? 0.15 : 0.1);
        textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? colors.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final Map<String, dynamic> grade;
  const _GradeCard({required this.grade});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final course = grade['course'] as Map<String, dynamic>? ?? {};
    final code = course['code'] ?? '';
    final name = course['name'] ?? '';
    final professor = course['professor'] as String?;
    final status = grade['status'] ?? 'in_progress';
    final grade1 = grade['grade_1'];
    final grade2 = grade['grade_2'];
    final gradeFinal = grade['grade_final'];

    final statusLabel = switch (status) {
      'in_progress' => 'Em andamento',
      'approved' => 'Aprovado',
      'failed' => 'Reprovado',
      'locked' => 'Trancado',
      _ => status,
    };

    final Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'failed':
        statusColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'locked':
        statusColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
      default:
        statusColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  code,
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
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (professor != null) ...[
            const SizedBox(height: 4),
            Text(
              professor,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.55),
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _GradePill(label: 'N1', value: grade1),
              const SizedBox(width: 8),
              _GradePill(label: 'N2', value: grade2),
              const SizedBox(width: 8),
              _GradePill(label: 'Final', value: gradeFinal, isFinal: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradePill extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isFinal;
  const _GradePill({required this.label, this.value, this.isFinal = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayValue = value != null ? (value as num).toStringAsFixed(1) : '—';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFinal && value != null
            ? colors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isFinal && value != null ? colors.primary : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
