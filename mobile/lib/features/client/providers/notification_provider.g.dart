// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationApiServiceHash() =>
    r'a346d170315a43b4b6f26973b0d1fe52d61e9427';

/// See also [notificationApiService].
@ProviderFor(notificationApiService)
final notificationApiServiceProvider = Provider<NotificationService>.internal(
  notificationApiService,
  name: r'notificationApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationApiServiceRef = ProviderRef<NotificationService>;
String _$notificationsHash() => r'a8b615cf4b550c74884226e8e5cdcf5262d6d3a3';

/// See also [notifications].
@ProviderFor(notifications)
final notificationsProvider =
    AutoDisposeFutureProvider<List<ServerNotification>>.internal(
      notifications,
      name: r'notificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsRef =
    AutoDisposeFutureProviderRef<List<ServerNotification>>;
String _$notificationFilterNotifierHash() =>
    r'db59c3bb1ae13493d81a7ce44162d5d96bf86ce5';

/// See also [NotificationFilterNotifier].
@ProviderFor(NotificationFilterNotifier)
final notificationFilterNotifierProvider =
    AutoDisposeNotifierProvider<
      NotificationFilterNotifier,
      NotificationFilter
    >.internal(
      NotificationFilterNotifier.new,
      name: r'notificationFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationFilterNotifier = AutoDisposeNotifier<NotificationFilter>;
String _$notificationActionsHash() =>
    r'a5d8c20552ad66ad6a5be4ea86c6c7cd3c9bd12a';

/// See also [NotificationActions].
@ProviderFor(NotificationActions)
final notificationActionsProvider =
    AutoDisposeNotifierProvider<NotificationActions, void>.internal(
      NotificationActions.new,
      name: r'notificationActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
