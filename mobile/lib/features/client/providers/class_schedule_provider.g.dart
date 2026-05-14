// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classScheduleServiceHash() =>
    r'679267d067c64f29dcd1a97198afa0c0c5627751';

/// See also [classScheduleService].
@ProviderFor(classScheduleService)
final classScheduleServiceProvider = Provider<ClassScheduleService>.internal(
  classScheduleService,
  name: r'classScheduleServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$classScheduleServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClassScheduleServiceRef = ProviderRef<ClassScheduleService>;
String _$weeklyScheduleHash() => r'5b7c1d1478fc6f0461b456aa4704d44af16a675b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetches the weekly class schedule for a student.
///
/// Copied from [weeklySchedule].
@ProviderFor(weeklySchedule)
const weeklyScheduleProvider = WeeklyScheduleFamily();

/// Fetches the weekly class schedule for a student.
///
/// Copied from [weeklySchedule].
class WeeklyScheduleFamily extends Family<AsyncValue<WeeklyScheduleData>> {
  /// Fetches the weekly class schedule for a student.
  ///
  /// Copied from [weeklySchedule].
  const WeeklyScheduleFamily();

  /// Fetches the weekly class schedule for a student.
  ///
  /// Copied from [weeklySchedule].
  WeeklyScheduleProvider call(String studentId) {
    return WeeklyScheduleProvider(studentId);
  }

  @override
  WeeklyScheduleProvider getProviderOverride(
    covariant WeeklyScheduleProvider provider,
  ) {
    return call(provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weeklyScheduleProvider';
}

/// Fetches the weekly class schedule for a student.
///
/// Copied from [weeklySchedule].
class WeeklyScheduleProvider
    extends AutoDisposeFutureProvider<WeeklyScheduleData> {
  /// Fetches the weekly class schedule for a student.
  ///
  /// Copied from [weeklySchedule].
  WeeklyScheduleProvider(String studentId)
    : this._internal(
        (ref) => weeklySchedule(ref as WeeklyScheduleRef, studentId),
        from: weeklyScheduleProvider,
        name: r'weeklyScheduleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weeklyScheduleHash,
        dependencies: WeeklyScheduleFamily._dependencies,
        allTransitiveDependencies:
            WeeklyScheduleFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  WeeklyScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final String studentId;

  @override
  Override overrideWith(
    FutureOr<WeeklyScheduleData> Function(WeeklyScheduleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeeklyScheduleProvider._internal(
        (ref) => create(ref as WeeklyScheduleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WeeklyScheduleData> createElement() {
    return _WeeklyScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyScheduleProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeeklyScheduleRef on AutoDisposeFutureProviderRef<WeeklyScheduleData> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _WeeklyScheduleProviderElement
    extends AutoDisposeFutureProviderElement<WeeklyScheduleData>
    with WeeklyScheduleRef {
  _WeeklyScheduleProviderElement(super.provider);

  @override
  String get studentId => (origin as WeeklyScheduleProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
