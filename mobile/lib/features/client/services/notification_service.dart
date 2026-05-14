import '../../../core/network/dio_client.dart';

class NotificationService {
  final DioClient _client;

  NotificationService({required DioClient client}) : _client = client;

  /// GET /notifications — list all notifications for current student
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _client.dio.get('/notifications');
    final data = response.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  /// PUT /notifications/read — mark specific notifications as read
  Future<void> markAsRead(List<String> notificationIds) async {
    await _client.dio.put('/notifications/read', data: {
      'notification_ids': notificationIds,
    });
  }

  /// PUT /notifications/read-all — mark all notifications as read
  Future<void> markAllAsRead() async {
    await _client.dio.put('/notifications/read-all');
  }
}
