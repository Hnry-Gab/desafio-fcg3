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

  // Filter enrollments for the current period only (WR-03)
  // Note: GET /enrollments returns semester_year (not enrollment_period_id)
  final currentSemesterYear = period?['semester_year'] as String?;
  final periodEnrollments = currentSemesterYear != null
      ? enrollments.where((e) => e['semester_year'] == currentSemesterYear).toList()
      : enrollments;

  // Check if there's already a draft or confirmed enrollment for the current period
  final hasDraft = periodEnrollments.any((e) => e['status'] == 'draft');
  final hasConfirmed = periodEnrollments.any((e) => e['status'] == 'confirmed');

  // Find the draft enrollment ID if one exists
  final draftEnrollment = hasDraft
      ? periodEnrollments.firstWhere((e) => e['status'] == 'draft')
      : null;
  final draftEnrollmentId = draftEnrollment?['id'] as String?;

  // Group courses by semester
  final Map<int, List<Map<String, dynamic>>> bySemester = {};
  for (final c in courses) {
    final sem = c['semester'] as int? ?? 0;
    bySemester.putIfAbsent(sem, () => []).add(c);
  }

  // Extract course IDs from the draft enrollment for pre-selection (IN-02)
  // Fetch the draft detail to get individual courses
  var draftCourseIds = <String>{};
  if (hasDraft && draftEnrollmentId != null) {
    try {
      final detail = await service.getEnrollmentDetail(draftEnrollmentId);
      final courses_ = detail['courses'] as List<dynamic>? ?? [];
      for (final c in courses_) {
        final cMap = c as Map<String, dynamic>;
        if (cMap['status'] == 'enrolled') {
          final cid = cMap['course_id'] as String?;
          if (cid != null) draftCourseIds.add(cid);
        }
      }
    } catch (_) {
      // If detail fetch fails, proceed without pre-selection
    }
  }

  return EnrollmentScreenData(
    availableCourses: courses,
    coursesBySemester: bySemester,
    period: period,
    hasDraftEnrollment: hasDraft,
    hasConfirmedEnrollment: hasConfirmed,
    draftEnrollmentId: draftEnrollmentId,
    draftCourseIds: draftCourseIds,
  );
}

class EnrollmentScreenData {
  final List<Map<String, dynamic>> availableCourses;
  final Map<int, List<Map<String, dynamic>>> coursesBySemester;
  final Map<String, dynamic>? period;
  final bool hasDraftEnrollment;
  final bool hasConfirmedEnrollment;
  final String? draftEnrollmentId;
  final Set<String> draftCourseIds;

  EnrollmentScreenData({
    required this.availableCourses,
    required this.coursesBySemester,
    this.period,
    required this.hasDraftEnrollment,
    required this.hasConfirmedEnrollment,
    this.draftEnrollmentId,
    this.draftCourseIds = const {},
  });
}
