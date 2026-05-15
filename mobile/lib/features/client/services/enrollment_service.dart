import '../../../core/network/dio_client.dart';

class EnrollmentService {
  final DioClient _client;

  EnrollmentService({required DioClient client}) : _client = client;

  /// GET /students/{id}/available-courses
  Future<List<Map<String, dynamic>>> getAvailableCourses(String studentId) async {
    final response = await _client.dio.get('/students/$studentId/available-courses');
    final data = response.data;
    final list = data is Map ? (data['data'] as List?) ?? [] : data as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// GET /enrollment-periods/current
  Future<Map<String, dynamic>?> getCurrentPeriod() async {
    final response = await _client.dio.get('/enrollment-periods/current');
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>?;
    }
    return data as Map<String, dynamic>?;
  }

  /// GET /enrollments (student auto-filtered)
  Future<List<Map<String, dynamic>>> getEnrollments() async {
    final response = await _client.dio.get('/enrollments');
    final data = response.data;
    final list = data is Map ? (data['data'] as List?) ?? [] : data as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// POST /enrollments — create draft enrollment
  Future<Map<String, dynamic>> createEnrollment({
    required String periodId,
    required List<String> courseIds,
  }) async {
    final response = await _client.dio.post('/enrollments', data: {
      'enrollment_period_id': periodId,
      'course_ids': courseIds,
    });
    return response.data as Map<String, dynamic>;
  }

  /// POST /enrollments/{id}/confirm
  Future<Map<String, dynamic>> confirmEnrollment(String enrollmentId) async {
    final response = await _client.dio.post('/enrollments/$enrollmentId/confirm');
    return response.data as Map<String, dynamic>;
  }

  /// PUT /enrollments/{id} — update courses on a draft enrollment
  Future<Map<String, dynamic>> updateEnrollmentCourses({
    required String enrollmentId,
    required List<String> courseIds,
  }) async {
    final response = await _client.dio.put('/enrollments/$enrollmentId', data: {
      'course_ids': courseIds,
    });
    return response.data as Map<String, dynamic>;
  }

  /// GET /enrollments/{id} — enrollment detail with courses
  Future<Map<String, dynamic>> getEnrollmentDetail(String enrollmentId) async {
    final response = await _client.dio.get('/enrollments/$enrollmentId');
    return response.data as Map<String, dynamic>;
  }
}
