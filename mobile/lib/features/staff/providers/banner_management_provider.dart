import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../models/banner_model.dart';
import '../services/banner_service.dart';

/// Provides a singleton [BannerService] instance.
final bannerServiceProvider = Provider<BannerService>((ref) {
  final client = ref.watch(dioClientProvider);
  return BannerService(client: client);
});

/// Async notifier that manages the list of ALL banners (staff view).
final bannersProvider =
    AsyncNotifierProvider<BannersNotifier, List<BannerModel>>(
  BannersNotifier.new,
);

class BannersNotifier extends AsyncNotifier<List<BannerModel>> {
  @override
  FutureOr<List<BannerModel>> build() async {
    final service = ref.read(bannerServiceProvider);
    return service.fetchAll();
  }

  /// Upload a new banner image.
  Future<void> upload(Uint8List bytes, String filename, String mimeType) async {
    final service = ref.read(bannerServiceProvider);
    await service.upload(bytes, filename, mimeType);
    ref.invalidateSelf();
  }

  /// Toggle banner enabled/disabled state (optimistic update).
  Future<void> toggle(String id, bool enabled) async {
    // Optimistic update
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        current
            .map((b) => b.id == id ? b.copyWith(isEnabled: enabled) : b)
            .toList(),
      );
    }

    try {
      final service = ref.read(bannerServiceProvider);
      await service.toggleEnabled(id, enabled);
    } catch (_) {
      // Revert on error
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// Delete a banner (remove from local state immediately).
  Future<void> delete(String id) async {
    // Optimistic removal
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.where((b) => b.id != id).toList());
    }

    try {
      final service = ref.read(bannerServiceProvider);
      await service.deleteBanner(id);
    } catch (_) {
      // Revert on error
      ref.invalidateSelf();
      rethrow;
    }
  }
}
