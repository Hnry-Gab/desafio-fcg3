import '../../../core/network/dio_client.dart';

class StudentProfileService {
  final DioClient _client;

  StudentProfileService({required DioClient client}) : _client = client;

  /// GET /students/{id}/academic-summary
  Future<Map<String, dynamic>> getAcademicSummary(String studentId) async {
    final response = await _client.dio.get('/students/$studentId/academic-summary');
    return response.data as Map<String, dynamic>;
  }

  /// GET /students/{id}/grades?semester_year=X
  Future<List<Map<String, dynamic>>> getGrades(String studentId, {String? semesterYear}) async {
    final queryParams = <String, dynamic>{};
    if (semesterYear != null) queryParams['semester_year'] = semesterYear;
    final response = await _client.dio.get(
      '/students/$studentId/grades',
      queryParameters: queryParams,
    );
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

  /// GET /enrollments for a student
  Future<List<Map<String, dynamic>>> getEnrollments(String studentId) async {
    final response = await _client.dio.get(
      '/enrollments',
      queryParameters: {'student_id': studentId},
    );
    final data = response.data;
    final list = data is Map ? (data['data'] as List?) ?? [] : data as List;
    return list.cast<Map<String, dynamic>>();
  }
}
