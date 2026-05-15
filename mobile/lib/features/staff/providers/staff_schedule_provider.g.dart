// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$staffScheduleServiceHash() =>
    r'9b3a3fb50961ef0cc8380a902ac08e3a0e19c6fe';

/// See also [staffScheduleService].
@ProviderFor(staffScheduleService)
final staffScheduleServiceProvider = Provider<StaffScheduleService>.internal(
  staffScheduleService,
  name: r'staffScheduleServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$staffScheduleServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StaffScheduleServiceRef = ProviderRef<StaffScheduleService>;
String _$staffAppointmentsHash() => r'174f42f3850de38b3d840e06e1a468ad06986f63';

/// See also [staffAppointments].
@ProviderFor(staffAppointments)
final staffAppointmentsProvider =
    AutoDisposeFutureProvider<List<AppointmentModel>>.internal(
      staffAppointments,
      name: r'staffAppointmentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffAppointmentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StaffAppointmentsRef =
    AutoDisposeFutureProviderRef<List<AppointmentModel>>;
String _$staffSlotsHash() => r'cea91160d62ff19e1253bea340898b5684d80159';

/// See also [staffSlots].
@ProviderFor(staffSlots)
final staffSlotsProvider =
    AutoDisposeFutureProvider<List<SchedulingSlotModel>>.internal(
      staffSlots,
      name: r'staffSlotsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffSlotsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StaffSlotsRef = AutoDisposeFutureProviderRef<List<SchedulingSlotModel>>;
String _$staffAllSlotsHash() => r'888b40a6f7ceb8968e0cd9add0f6dc66e59ad304';

/// Provider for ALL slots (available + booked) — used in staff "Horarios" tab
///
/// Copied from [staffAllSlots].
@ProviderFor(staffAllSlots)
final staffAllSlotsProvider =
    AutoDisposeFutureProvider<List<SchedulingSlotModel>>.internal(
      staffAllSlots,
      name: r'staffAllSlotsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffAllSlotsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StaffAllSlotsRef =
    AutoDisposeFutureProviderRef<List<SchedulingSlotModel>>;
String _$staffScheduleFilterHash() =>
    r'2b42f967be1550e1c7d9e1128300a0367aa3b214';

/// See also [StaffScheduleFilter].
@ProviderFor(StaffScheduleFilter)
final staffScheduleFilterProvider =
    AutoDisposeNotifierProvider<StaffScheduleFilter, String?>.internal(
      StaffScheduleFilter.new,
      name: r'staffScheduleFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffScheduleFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StaffScheduleFilter = AutoDisposeNotifier<String?>;
String _$staffScheduleSearchHash() =>
    r'e5a32ce4c1c7c9f9769b29f1ddb59de89b6cc04e';

/// See also [StaffScheduleSearch].
@ProviderFor(StaffScheduleSearch)
final staffScheduleSearchProvider =
    AutoDisposeNotifierProvider<StaffScheduleSearch, String>.internal(
      StaffScheduleSearch.new,
      name: r'staffScheduleSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffScheduleSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StaffScheduleSearch = AutoDisposeNotifier<String>;
String _$staffSlotResourceFilterHash() =>
    r'5184cee1fd4ab2fc945c25c6d4b772373d6c56ff';

/// Filter for slots tab: resource ID
///
/// Copied from [StaffSlotResourceFilter].
@ProviderFor(StaffSlotResourceFilter)
final staffSlotResourceFilterProvider =
    AutoDisposeNotifierProvider<StaffSlotResourceFilter, String?>.internal(
      StaffSlotResourceFilter.new,
      name: r'staffSlotResourceFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffSlotResourceFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StaffSlotResourceFilter = AutoDisposeNotifier<String?>;
String _$staffSlotSearchHash() => r'c127d8348b4bd30b089bc5441e05fb14378c7e7a';

/// Search for slots tab
///
/// Copied from [StaffSlotSearch].
@ProviderFor(StaffSlotSearch)
final staffSlotSearchProvider =
    AutoDisposeNotifierProvider<StaffSlotSearch, String>.internal(
      StaffSlotSearch.new,
      name: r'staffSlotSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$staffSlotSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StaffSlotSearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
