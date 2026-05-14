// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentProfileServiceHash() =>
    r'e71e5bb56a99d688dbc682ec5c56940a12f155b5';

/// See also [studentProfileService].
@ProviderFor(studentProfileService)
final studentProfileServiceProvider = Provider<StudentProfileService>.internal(
  studentProfileService,
  name: r'studentProfileServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studentProfileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentProfileServiceRef = ProviderRef<StudentProfileService>;
String _$studentProfileHash() => r'cf15f45870001713995c7435f7c6f943772a915b';

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

/// Fetches all data needed for the student profile screen in parallel.
///
/// Copied from [studentProfile].
@ProviderFor(studentProfile)
const studentProfileProvider = StudentProfileFamily();

/// Fetches all data needed for the student profile screen in parallel.
///
/// Copied from [studentProfile].
class StudentProfileFamily extends Family<AsyncValue<StudentProfileData>> {
  /// Fetches all data needed for the student profile screen in parallel.
  ///
  /// Copied from [studentProfile].
  const StudentProfileFamily();

  /// Fetches all data needed for the student profile screen in parallel.
  ///
  /// Copied from [studentProfile].
  StudentProfileProvider call(String studentId) {
    return StudentProfileProvider(studentId);
  }

  @override
  StudentProfileProvider getProviderOverride(
    covariant StudentProfileProvider provider,
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
  String? get name => r'studentProfileProvider';
}

/// Fetches all data needed for the student profile screen in parallel.
///
/// Copied from [studentProfile].
class StudentProfileProvider
    extends AutoDisposeFutureProvider<StudentProfileData> {
  /// Fetches all data needed for the student profile screen in parallel.
  ///
  /// Copied from [studentProfile].
  StudentProfileProvider(String studentId)
    : this._internal(
        (ref) => studentProfile(ref as StudentProfileRef, studentId),
        from: studentProfileProvider,
        name: r'studentProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentProfileHash,
        dependencies: StudentProfileFamily._dependencies,
        allTransitiveDependencies:
            StudentProfileFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentProfileProvider._internal(
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
    FutureOr<StudentProfileData> Function(StudentProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentProfileProvider._internal(
        (ref) => create(ref as StudentProfileRef),
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
  AutoDisposeFutureProviderElement<StudentProfileData> createElement() {
    return _StudentProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentProfileProvider && other.studentId == studentId;
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
mixin StudentProfileRef on AutoDisposeFutureProviderRef<StudentProfileData> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _StudentProfileProviderElement
    extends AutoDisposeFutureProviderElement<StudentProfileData>
    with StudentProfileRef {
  _StudentProfileProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentProfileProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
