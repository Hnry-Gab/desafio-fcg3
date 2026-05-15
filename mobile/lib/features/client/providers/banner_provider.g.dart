// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentBannersHash() => r'802faf166e71be430cbf9274ec0effff00fdb44a';

/// Fetches enabled banners from GET /banners (public endpoint, no auth).
///
/// Returns banners ordered by display_order for the student carousel.
///
/// Copied from [studentBanners].
@ProviderFor(studentBanners)
final studentBannersProvider =
    AutoDisposeFutureProvider<List<BannerItem>>.internal(
      studentBanners,
      name: r'studentBannersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentBannersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentBannersRef = AutoDisposeFutureProviderRef<List<BannerItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
