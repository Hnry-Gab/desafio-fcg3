import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/dio_provider.dart';
import '../services/student_profile_service.dart';

part 'student_profile_provider.g.dart';

@Riverpod(keepAlive: true)
StudentProfileService studentProfileService(Ref ref) {
  final client = ref.watch(dioClientProvider);
  return StudentProfileService(client: client);
}

/// Fetches all data needed for the student profile screen in parallel.
@riverpod
Future<StudentProfileData> studentProfile(Ref ref, String studentId) async {
  final service = ref.watch(studentProfileServiceProvider);

  final results = await Future.wait([
    service.getAcademicSummary(studentId),
    service.getCurrentPeriod(),
    service.getGrades(studentId),
    service.getEnrollments(studentId),
  ]);

  final summary = results[0] as Map<String, dynamic>;
  final period = results[1] as Map<String, dynamic>?;
  final grades = results[2] as List<Map<String, dynamic>>;
  final enrollments = results[3] as List<Map<String, dynamic>>;

  // Filter grades for current semester if period exists
  final currentSemester = period?['semester_year'] as String?;
  final currentGrades = currentSemester != null
      ? grades.where((g) => g['semester_year'] == currentSemester).toList()
      : grades;

  // Find the active enrollment
  final activeEnrollment = enrollments.isNotEmpty
      ? enrollments.firstWhere(
          (e) => e['status'] == 'confirmed' || e['status'] == 'draft',
          orElse: () => enrollments.first,
        )
      : null;

  return StudentProfileData(
    summary: summary,
    period: period,
    currentGrades: currentGrades,
    activeEnrollment: activeEnrollment,
  );
}

class StudentProfileData {
  final Map<String, dynamic> summary;
  final Map<String, dynamic>? period;
  final List<Map<String, dynamic>> currentGrades;
  final Map<String, dynamic>? activeEnrollment;

  StudentProfileData({
    required this.summary,
    this.period,
    required this.currentGrades,
    this.activeEnrollment,
  });
}
