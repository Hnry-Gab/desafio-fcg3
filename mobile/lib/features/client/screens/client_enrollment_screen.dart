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
import '../providers/enrollment_provider.dart';

class ClientEnrollmentScreen extends ConsumerStatefulWidget {
  final String studentId;

  const ClientEnrollmentScreen({super.key, required this.studentId});

  @override
  ConsumerState<ClientEnrollmentScreen> createState() =>
      _ClientEnrollmentScreenState();
}

class _ClientEnrollmentScreenState
    extends ConsumerState<ClientEnrollmentScreen> {
  final Set<String> _selectedCourseIds = {};
  bool _isSubmitting = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(enrollmentDataProvider(widget.studentId));
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrícula'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutePaths.clientProfile),
        ),
        actions: const [AppBarActions()],
      ),
      body: dataAsync.when(
        loading: () => const ResponsiveContainer(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            AppSkeletonCard(height: 80),
            AppSkeletonCard(height: 300),
          ]),
        ),
        error: (error, stack) => ResponsiveContainer(
          padding: const EdgeInsets.all(20),
          child: AppErrorState(
            onRetry: () =>
                ref.invalidate(enrollmentDataProvider(widget.studentId)),
          ),
        ),
        data: (data) {
          // Pre-select courses from existing draft (IN-02)
          if (!_initialized && data.draftCourseIds.isNotEmpty) {
            _initialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedCourseIds.addAll(data.draftCourseIds);
                });
              }
            });
          }

          final period = data.period;

          if (period == null) {
            return ResponsiveContainer(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: colors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum período de matrícula ativo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aguarde a abertura do próximo período.',
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

          if (data.hasConfirmedEnrollment) {
            return ResponsiveContainer(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade700),
                    const SizedBox(height: 16),
                    Text(
                      'Matrícula já confirmada!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sua matrícula para ${period['semester_year'] ?? ''} já foi confirmada.',
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

          if (data.availableCourses.isEmpty) {
            return ResponsiveContainer(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: colors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma disciplina disponível',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final semesters = data.coursesBySemester.keys.toList()..sort();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ResponsiveContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Draft banner (when resuming a pending enrollment)
                        if (data.hasDraftEnrollment)
                          AnimatedEntrance(
                            delay: AppAnimations.getEntranceDelay(0),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pending_actions,
                                    size: 20,
                                    color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Matrícula pendente de confirmação. Revise as disciplinas e confirme.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Period banner
                        AnimatedEntrance(
                          delay: AppAnimations.getEntranceDelay(data.hasDraftEnrollment ? 1 : 0),
                          child: GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20, color: colors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        period['name']?.toString() ?? 'Período ativo',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.primary,
                                            ),
                                      ),
                                      Text(
                                        'Selecione as disciplinas para ${period['semester_year'] ?? ''}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Selected count badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    '${_selectedCourseIds.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colors.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Courses grouped by semester
                        ...semesters.asMap().entries.map((semEntry) {
                          final semester = semesters[semEntry.key];
                          final courses = data.coursesBySemester[semester]!;

                          return AnimatedEntrance(
                            delay: AppAnimations.getEntranceDelay(1 + semEntry.key),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
                                  child: Text(
                                    '$semester\u00BA Semestre',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.onSurface,
                                        ),
                                  ),
                                ),
                                ...courses.map((course) {
                                  final courseId = course['id'] as String;
                                  final isSelected = _selectedCourseIds.contains(courseId);
                                  final code = course['code'] ?? '';
                                  final name = course['name'] ?? '';
                                  final credits = course['credits'] ?? 0;
                                  final professor = course['professor'] as String?;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                    child: GlassCard(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedCourseIds.remove(courseId);
                                          } else {
                                            _selectedCourseIds.add(courseId);
                                          }
                                        });
                                      },
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: Row(
                                        children: [
                                          // Checkbox
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? colors.primary
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isSelected
                                                    ? colors.primary
                                                    : colors.outlineVariant,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                                                : null,
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          // Course info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: colors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        code,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: colors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$credits cr',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: colors.onSurfaceVariant,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  name,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: colors.onSurface,
                                                      ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (professor != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    professor,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: isDark ? colors.onSurfaceVariant : colors.onSurface.withValues(alpha: 0.5),
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom action bar
              if (_selectedCourseIds.isNotEmpty)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    AppSpacing.md,
                    20,
                    MediaQuery.of(context).padding.bottom + AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : () => _handleEnroll(data),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _isSubmitting
                              ? 'Confirmando...'
                              : 'Confirmar matrícula (${_selectedCourseIds.length} disciplina${_selectedCourseIds.length > 1 ? 's' : ''})',
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

  Future<void> _handleEnroll(EnrollmentScreenData data) async {
    final period = data.period;
    if (period == null) return;

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(enrollmentServiceProvider);
      String enrollmentId;

      if (data.hasDraftEnrollment && data.draftEnrollmentId != null) {
        // Draft exists: update courses on the existing enrollment
        enrollmentId = data.draftEnrollmentId!;
        await service.updateEnrollmentCourses(
          enrollmentId: enrollmentId,
          courseIds: _selectedCourseIds.toList(),
        );
      } else {
        // No enrollment yet: create a new draft
        final periodId = period['id'] as String;
        final enrollment = await service.createEnrollment(
          periodId: periodId,
          courseIds: _selectedCourseIds.toList(),
        );
        enrollmentId = enrollment['id'] as String;
      }

      // Confirm the enrollment
      await service.confirmEnrollment(enrollmentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Matrícula confirmada em ${_selectedCourseIds.length} disciplina${_selectedCourseIds.length > 1 ? 's' : ''}!',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        // Invalidate profile data so it refreshes
        ref.invalidate(enrollmentDataProvider(widget.studentId));
        context.go(RoutePaths.clientProfile);
      }
    } catch (e) {
      // WR-02: Invalidate provider on error so retry gets fresh data
      ref.invalidate(enrollmentDataProvider(widget.studentId));

      if (mounted) {
        // WR-01: Parse specific error codes for user-friendly messages
        final errorStr = e.toString();
        final String errorMsg;
        if (errorStr.contains('MATRICULA_JA_EXISTENTE')) {
          errorMsg = 'Você já possui uma matrícula para este período.';
        } else if (errorStr.contains('PERIODO_MATRICULA_FECHADO')) {
          errorMsg = 'O período de matrícula não está mais ativo.';
        } else if (errorStr.contains('PREREQUISITO_NAO_CUMPRIDO')) {
          errorMsg = 'Pré-requisitos não cumpridos para uma ou mais disciplinas.';
        } else if (errorStr.contains('MATRICULA_JA_CONFIRMADA')) {
          errorMsg = 'Esta matrícula já foi confirmada.';
        } else if (errorStr.contains('OPERACAO_NAO_PERMITIDA')) {
          errorMsg = 'Operação não permitida no estado atual da matrícula.';
        } else {
          errorMsg = 'Erro ao realizar matrícula. Tente novamente.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
