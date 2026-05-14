import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/cache_provider.dart';
import '../services/notification_service.dart';

part 'notification_provider.g.dart';

enum NotificationType { documentStatus, appointmentReminder, errorAlert }

enum NotificationFilter { all, unread, read }

// ------------------------------------------------------------------
// Service provider
// ------------------------------------------------------------------

@Riverpod(keepAlive: true)
NotificationService notificationApiService(Ref ref) {
  final client = ref.watch(dioClientProvider);
  return NotificationService(client: client);
}

// ------------------------------------------------------------------
// Server notification model
// ------------------------------------------------------------------

class ServerNotification {
  final String id;
  final String event;
  final String title;
  final String body;
  final String? data;
  final DateTime? readAt;
  final DateTime createdAt;

  const ServerNotification({
    required this.id,
    required this.event,
    required this.title,
    required this.body,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  NotificationType get type => switch (event) {
        'document_ready' => NotificationType.documentStatus,
        'appointment_confirmed' ||
        'appointment_completed' ||
        'appointment_cancelled' ||
        'appointment_no_show' =>
          NotificationType.appointmentReminder,
        'enrollment_confirmed' => NotificationType.appointmentReminder,
        _ => NotificationType.errorAlert,
      };

  IconData get icon => switch (event) {
        'document_ready' => Icons.description,
        'appointment_confirmed' => Icons.access_time,
        'appointment_completed' => Icons.check_circle,
        'appointment_cancelled' => Icons.cancel,
        'appointment_no_show' => Icons.person_off,
        'enrollment_confirmed' => Icons.school,
        _ => Icons.notifications,
      };

  Color get color => switch (event) {
        'document_ready' => Colors.green,
        'appointment_confirmed' => Colors.blue,
        'appointment_completed' => Colors.green,
        'appointment_cancelled' => Colors.red,
        'appointment_no_show' => Colors.orange,
        'enrollment_confirmed' => Colors.orange,
        _ => Colors.grey,
      };

  factory ServerNotification.fromJson(Map<String, dynamic> json) {
    return ServerNotification(
      id: json['id'] as String,
      event: json['event'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as String?,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ------------------------------------------------------------------
// Notifications list provider (fetches from API)
// ------------------------------------------------------------------

@riverpod
Future<List<ServerNotification>> notifications(Ref ref) async {
  final service = ref.watch(notificationApiServiceProvider);
  final rawList = await service.getNotifications();
  CacheTTL.schedule(ref, 'notifications');
  return rawList.map((json) => ServerNotification.fromJson(json)).toList();
}

// ------------------------------------------------------------------
// Filter notifier
// ------------------------------------------------------------------

@riverpod
class NotificationFilterNotifier extends _$NotificationFilterNotifier {
  @override
  NotificationFilter build() => NotificationFilter.all;

  void setFilter(NotificationFilter filter) => state = filter;
}

// ------------------------------------------------------------------
// Mark-as-read actions (calls API then refreshes list)
// ------------------------------------------------------------------

@riverpod
class NotificationActions extends _$NotificationActions {
  @override
  void build() {}

  Future<void> markAsRead(String notificationId) async {
    final service = ref.read(notificationApiServiceProvider);
    await service.markAsRead([notificationId]);
    ref.invalidate(notificationsProvider);
  }

  Future<void> markMultipleAsRead(List<String> notificationIds) async {
    final service = ref.read(notificationApiServiceProvider);
    await service.markAsRead(notificationIds);
    ref.invalidate(notificationsProvider);
  }

  Future<void> markAllAsRead() async {
    final service = ref.read(notificationApiServiceProvider);
    await service.markAllAsRead();
    ref.invalidate(notificationsProvider);
  }
}
