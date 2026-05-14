import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/dio_provider.dart';
import '../services/enrollment_service.dart';

part 'enrollment_provider.g.dart';

@Riverpod(keepAlive: true)
EnrollmentService enrollmentService(Ref ref) {
  final client = ref.watch(dioClientProvider);
  return EnrollmentService(client: client);
}

/// Fetches available courses for enrollment.
@riverpod
Future<EnrollmentScreenData> enrollmentData(Ref ref, String studentId) async {
  final service = ref.watch(enrollmentServiceProvider);

  final results = await Future.wait([
    service.getAvailableCourses(studentId),
    service.getCurrentPeriod(),
    service.getEnrollments(),
  ]);

  final courses = results[0] as List<Map<String, dynamic>>;
  final period = results[1] as Map<String, dynamic>?;
  final enrollments = results[2] as List<Map<String, dynamic>>;

  // Check if there's already a draft or confirmed enrollment for the current period
  final hasDraft = enrollments.any((e) => e['status'] == 'draft');
  final hasConfirmed = enrollments.any((e) => e['status'] == 'confirmed');

  // Group courses by semester
  final Map<int, List<Map<String, dynamic>>> bySemester = {};
  for (final c in courses) {
    final sem = c['semester'] as int? ?? 0;
    bySemester.putIfAbsent(sem, () => []).add(c);
  }

  return EnrollmentScreenData(
    availableCourses: courses,
    coursesBySemester: bySemester,
    period: period,
    hasDraftEnrollment: hasDraft,
    hasConfirmedEnrollment: hasConfirmed,
  );
}

class EnrollmentScreenData {
  final List<Map<String, dynamic>> availableCourses;
  final Map<int, List<Map<String, dynamic>>> coursesBySemester;
  final Map<String, dynamic>? period;
  final bool hasDraftEnrollment;
  final bool hasConfirmedEnrollment;

  EnrollmentScreenData({
    required this.availableCourses,
    required this.coursesBySemester,
    this.period,
    required this.hasDraftEnrollment,
    required this.hasConfirmedEnrollment,
  });
}
