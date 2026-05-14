import '../../../core/network/dio_client.dart';

class ClassScheduleService {
  final DioClient _client;

  ClassScheduleService({required DioClient client}) : _client = client;

  /// GET /students/{id}/weekly-schedule
  Future<Map<String, dynamic>> getWeeklySchedule(String studentId) async {
    final response =
        await _client.dio.get('/students/$studentId/weekly-schedule');
    return response.data as Map<String, dynamic>;
  }
}
