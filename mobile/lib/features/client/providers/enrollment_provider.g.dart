// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enrollmentServiceHash() => r'2c6371b8f1341267aaf6b2c24485f31bfb77e587';

/// See also [enrollmentService].
@ProviderFor(enrollmentService)
final enrollmentServiceProvider = Provider<EnrollmentService>.internal(
  enrollmentService,
  name: r'enrollmentServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$enrollmentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnrollmentServiceRef = ProviderRef<EnrollmentService>;
String _$enrollmentDataHash() => r'625aaa2602e0c3afc1afd346892334e23b294f65';

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

/// Fetches available courses for enrollment.
///
/// Copied from [enrollmentData].
@ProviderFor(enrollmentData)
const enrollmentDataProvider = EnrollmentDataFamily();

/// Fetches available courses for enrollment.
///
/// Copied from [enrollmentData].
class EnrollmentDataFamily extends Family<AsyncValue<EnrollmentScreenData>> {
  /// Fetches available courses for enrollment.
  ///
  /// Copied from [enrollmentData].
  const EnrollmentDataFamily();

  /// Fetches available courses for enrollment.
  ///
  /// Copied from [enrollmentData].
  EnrollmentDataProvider call(String studentId) {
    return EnrollmentDataProvider(studentId);
  }

  @override
  EnrollmentDataProvider getProviderOverride(
    covariant EnrollmentDataProvider provider,
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
  String? get name => r'enrollmentDataProvider';
}

/// Fetches available courses for enrollment.
///
/// Copied from [enrollmentData].
class EnrollmentDataProvider
    extends AutoDisposeFutureProvider<EnrollmentScreenData> {
  /// Fetches available courses for enrollment.
  ///
  /// Copied from [enrollmentData].
  EnrollmentDataProvider(String studentId)
    : this._internal(
        (ref) => enrollmentData(ref as EnrollmentDataRef, studentId),
        from: enrollmentDataProvider,
        name: r'enrollmentDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$enrollmentDataHash,
        dependencies: EnrollmentDataFamily._dependencies,
        allTransitiveDependencies:
            EnrollmentDataFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  EnrollmentDataProvider._internal(
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
    FutureOr<EnrollmentScreenData> Function(EnrollmentDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EnrollmentDataProvider._internal(
        (ref) => create(ref as EnrollmentDataRef),
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
  AutoDisposeFutureProviderElement<EnrollmentScreenData> createElement() {
    return _EnrollmentDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnrollmentDataProvider && other.studentId == studentId;
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
mixin EnrollmentDataRef on AutoDisposeFutureProviderRef<EnrollmentScreenData> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _EnrollmentDataProviderElement
    extends AutoDisposeFutureProviderElement<EnrollmentScreenData>
    with EnrollmentDataRef {
  _EnrollmentDataProviderElement(super.provider);

  @override
  String get studentId => (origin as EnrollmentDataProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
