import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/features/client/services/notification_service.dart';

/// A mock DioClient that uses a custom interceptor to capture and respond to requests.
class _MockDioClient extends DioClient {
  final List<RequestOptions> capturedRequests = [];
  dynamic Function(RequestOptions)? onRequest;

  _MockDioClient() : super(storage: const FlutterSecureStorage()) {
    // Clear real interceptors and add our mock one
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        capturedRequests.add(options);
        final response = onRequest?.call(options);
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: response,
        ));
      },
    ));
  }
}

void main() {
  late _MockDioClient mockClient;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    mockClient = _MockDioClient();
  });

  group('NotificationService calls correct API endpoints', () {
    test('getNotifications sends GET /notifications', () async {
      mockClient.onRequest = (options) => [
            {
              'id': 'notif-001',
              'event': 'document_ready',
              'title': 'Documento pronto',
              'body': 'Seu historico esta pronto',
              'data': null,
              'read_at': null,
              'created_at': '2026-05-14T10:00:00.000Z',
            }
          ];

      final service = NotificationService(client: mockClient);
      final notifications = await service.getNotifications();

      expect(mockClient.capturedRequests, hasLength(1));
      expect(mockClient.capturedRequests.first.path, '/notifications');
      expect(mockClient.capturedRequests.first.method, 'GET');
      expect(notifications, hasLength(1));
      expect(notifications.first['id'], 'notif-001');
    });

    test('getNotifications returns empty list when API returns empty', () async {
      mockClient.onRequest = (options) => [];

      final service = NotificationService(client: mockClient);
      final notifications = await service.getNotifications();

      expect(notifications, isEmpty);
    });

    test('getNotifications handles non-list response gracefully', () async {
      mockClient.onRequest = (options) => {'unexpected': 'format'};

      final service = NotificationService(client: mockClient);
      final notifications = await service.getNotifications();

      expect(notifications, isEmpty);
    });

    test('markAsRead sends PUT /notifications/read with notification_ids', () async {
      mockClient.onRequest = (options) => {'updated': 2};

      final service = NotificationService(client: mockClient);
      await service.markAsRead(['id-1', 'id-2']);

      expect(mockClient.capturedRequests, hasLength(1));
      final req = mockClient.capturedRequests.first;
      expect(req.path, '/notifications/read');
      expect(req.method, 'PUT');
      expect(req.data['notification_ids'], ['id-1', 'id-2']);
    });

    test('markAsRead sends single ID correctly', () async {
      mockClient.onRequest = (options) => {'updated': 1};

      final service = NotificationService(client: mockClient);
      await service.markAsRead(['single-id']);

      final req = mockClient.capturedRequests.first;
      expect(req.data['notification_ids'], ['single-id']);
    });

    test('markAllAsRead sends PUT /notifications/read-all', () async {
      mockClient.onRequest = (options) => {'updated': 5};

      final service = NotificationService(client: mockClient);
      await service.markAllAsRead();

      expect(mockClient.capturedRequests, hasLength(1));
      final req = mockClient.capturedRequests.first;
      expect(req.path, '/notifications/read-all');
      expect(req.method, 'PUT');
    });

    test('markAllAsRead sends no body', () async {
      mockClient.onRequest = (options) => {'updated': 0};

      final service = NotificationService(client: mockClient);
      await service.markAllAsRead();

      final req = mockClient.capturedRequests.first;
      expect(req.data, isNull);
    });

    test('multiple sequential calls are all captured', () async {
      mockClient.onRequest = (options) {
        if (options.method == 'GET') return [];
        return {'updated': 1};
      };

      final service = NotificationService(client: mockClient);
      await service.getNotifications();
      await service.markAsRead(['id-1']);
      await service.markAllAsRead();

      expect(mockClient.capturedRequests, hasLength(3));
      expect(mockClient.capturedRequests[0].method, 'GET');
      expect(mockClient.capturedRequests[1].method, 'PUT');
      expect(mockClient.capturedRequests[1].path, '/notifications/read');
      expect(mockClient.capturedRequests[2].method, 'PUT');
      expect(mockClient.capturedRequests[2].path, '/notifications/read-all');
    });
  });
}
