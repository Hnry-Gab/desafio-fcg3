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

  /// Reorder banners: move item at [oldIndex] to [newIndex].
  /// Updates local state optimistically, then persists display_order via API.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final reordered = List<BannerModel>.from(current);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    // Assign display_order = index for each banner
    final updated = [
      for (int i = 0; i < reordered.length; i++)
        reordered[i].copyWith(displayOrder: i),
    ];

    // Optimistic update
    state = AsyncData(updated);

    try {
      final service = ref.read(bannerServiceProvider);
      // Persist each changed display_order
      await Future.wait([
        for (int i = 0; i < updated.length; i++)
          if (current.indexOf(reordered[i]) != i)
            service.updateOrder(updated[i].id, i),
      ]);
    } catch (_) {
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
