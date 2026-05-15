import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/cache_provider.dart';

part 'banner_provider.g.dart';

/// Lightweight banner model for the student carousel.
///
/// Only contains fields needed for display — decoupled from
/// staff management models (which may have edit/delete concerns).
class BannerItem {
  final String id;
  final String imageUrl;
  final bool isEnabled;
  final int displayOrder;

  const BannerItem({
    required this.id,
    required this.imageUrl,
    required this.isEnabled,
    required this.displayOrder,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      isEnabled: json['is_enabled'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

/// Fetches enabled banners from GET /banners (public endpoint, no auth).
///
/// Returns banners ordered by display_order for the student carousel.
@riverpod
Future<List<BannerItem>> studentBanners(Ref ref) async {
  final client = ref.watch(dioClientProvider);
  final response = await client.dio.get('/banners');
  final List<dynamic> data =
      response.data is List ? response.data as List : [];
  CacheTTL.schedule(ref, 'studentBanners');
  return data
      .map((json) => BannerItem.fromJson(json as Map<String, dynamic>))
      .toList();
}
