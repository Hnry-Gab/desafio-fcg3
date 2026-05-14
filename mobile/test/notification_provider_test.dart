import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/features/client/providers/notification_provider.dart';
import 'package:frontend/features/client/services/notification_service.dart';

void main() {
  group('ServerNotification model', () {
    test('parses JSON with all fields correctly', () {
      final json = {
        'id': 'notif-001',
        'event': 'document_ready',
        'title': 'Documento pronto',
        'body': 'Seu historico esta pronto',
        'data': '{"document_id": "abc-123"}',
        'read_at': '2026-05-14T20:41:35.215488+00:00',
        'created_at': '2026-05-14T20:41:18.014972+00:00',
      };

      final notification = ServerNotification.fromJson(json);

      expect(notification.id, 'notif-001');
      expect(notification.event, 'document_ready');
      expect(notification.title, 'Documento pronto');
      expect(notification.body, 'Seu historico esta pronto');
      expect(notification.data, contains('document_id'));
      expect(notification.readAt, isNotNull);
      expect(notification.createdAt, isNotNull);
      expect(notification.isRead, isTrue);
    });

    test('parses JSON with null read_at as unread', () {
      final json = {
        'id': 'notif-002',
        'event': 'enrollment_confirmed',
        'title': 'Matrícula confirmada',
        'body': 'Sua matrícula foi confirmada',
        'data': null,
        'read_at': null,
        'created_at': '2026-05-14T20:41:18.014972+00:00',
      };

      final notification = ServerNotification.fromJson(json);

      expect(notification.isRead, isFalse);
      expect(notification.readAt, isNull);
    });

    test('document_ready maps to documentStatus type', () {
      final n = _makeNotification(event: 'document_ready');
      expect(n.type, NotificationType.documentStatus);
    });

    test('appointment_confirmed maps to appointmentReminder type', () {
      final n = _makeNotification(event: 'appointment_confirmed');
      expect(n.type, NotificationType.appointmentReminder);
    });

    test('enrollment_confirmed maps to appointmentReminder type', () {
      final n = _makeNotification(event: 'enrollment_confirmed');
      expect(n.type, NotificationType.appointmentReminder);
    });

    test('unknown event maps to errorAlert type', () {
      final n = _makeNotification(event: 'unknown_event');
      expect(n.type, NotificationType.errorAlert);
    });
  });

  group('NotificationFilter enum', () {
    test('has all, unread, and read values', () {
      expect(NotificationFilter.values, hasLength(3));
      expect(NotificationFilter.values, contains(NotificationFilter.all));
      expect(NotificationFilter.values, contains(NotificationFilter.unread));
      expect(NotificationFilter.values, contains(NotificationFilter.read));
    });
  });

  group('notificationsProvider', () {
    test('returns empty list when service returns empty', () async {
      final container = ProviderContainer(overrides: [
        notificationApiServiceProvider.overrideWithValue(
          _FakeNotificationService(notifications: []),
        ),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(notificationsProvider.future);
      expect(result, isEmpty);
    });

    test('parses and returns ServerNotification list from API', () async {
      final container = ProviderContainer(overrides: [
        notificationApiServiceProvider.overrideWithValue(
          _FakeNotificationService(notifications: [
            {
              'id': 'n-1',
              'event': 'document_ready',
              'title': 'Documento pronto',
              'body': 'Seu historico esta pronto',
              'data': null,
              'read_at': null,
              'created_at': '2026-05-14T10:00:00.000Z',
            },
            {
              'id': 'n-2',
              'event': 'enrollment_confirmed',
              'title': 'Matrícula confirmada',
              'body': 'Sua matrícula foi confirmada com sucesso',
              'data': null,
              'read_at': '2026-05-14T11:00:00.000Z',
              'created_at': '2026-05-14T09:00:00.000Z',
            },
          ]),
        ),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(notificationsProvider.future);
      expect(result, hasLength(2));
      expect(result[0].id, 'n-1');
      expect(result[0].isRead, isFalse);
      expect(result[1].id, 'n-2');
      expect(result[1].isRead, isTrue);
    });
  });

  group('NotificationFilterNotifier', () {
    test('initial state is NotificationFilter.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(notificationFilterNotifierProvider);
      expect(filter, NotificationFilter.all);
    });

    test('setFilter changes state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(notificationFilterNotifierProvider.notifier)
          .setFilter(NotificationFilter.unread);

      expect(container.read(notificationFilterNotifierProvider),
          NotificationFilter.unread);
    });

    test('setFilter cycles through all values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(notificationFilterNotifierProvider.notifier);

      notifier.setFilter(NotificationFilter.read);
      expect(container.read(notificationFilterNotifierProvider),
          NotificationFilter.read);

      notifier.setFilter(NotificationFilter.all);
      expect(container.read(notificationFilterNotifierProvider),
          NotificationFilter.all);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ServerNotification _makeNotification({
  String event = 'document_ready',
  bool read = false,
}) {
  return ServerNotification.fromJson({
    'id': 'test-id',
    'event': event,
    'title': 'Test',
    'body': 'Test body',
    'data': null,
    'read_at': read ? '2026-05-14T10:00:00.000Z' : null,
    'created_at': '2026-05-14T10:00:00.000Z',
  });
}

/// Fake NotificationService that returns canned data without HTTP calls.
class _FakeNotificationService extends NotificationService {
  final List<Map<String, dynamic>> notifications;
  final List<List<String>> markAsReadCalls = [];
  int markAllAsReadCallCount = 0;

  _FakeNotificationService({required this.notifications})
      : super(client: DioClient(storage: const FlutterSecureStorage()));

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async => notifications;

  @override
  Future<void> markAsRead(List<String> notificationIds) async {
    markAsReadCalls.add(notificationIds);
  }

  @override
  Future<void> markAllAsRead() async {
    markAllAsReadCallCount++;
  }
}

/// Base class extracted for testability (mirrors NotificationService interface).
abstract class NotificationServiceBase {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(List<String> notificationIds);
  Future<void> markAllAsRead();
}
