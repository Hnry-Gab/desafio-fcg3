import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/banner_provider.dart'; // BannerItem model

/// Auto-scrolling banner carousel for the student home screen.
///
/// Behavior per design decisions:
/// - D-01: Auto-scrolls every 4 seconds with smooth 500ms transition
/// - D-02: Manual swipe pauses auto-scroll; resumes after 6 seconds idle
/// - D-03: Dot indicators below carousel (expanding-dot pattern)
/// - D-04: 0 banners = invisible; 1 banner = static, no animation/dots
/// - D-05: Continuous loop from last banner back to first
/// - D-08: Fixed height, BoxFit.cover
class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  int _currentPage = 0;

  /// Constructs the full image URL from the relative banner path.
  ///
  /// The API base URL includes `/api/v1` (e.g. `http://host:8000/api/v1`),
  /// but uploads are served at `/uploads/` (e.g. `http://host:8000/uploads/banners/file.jpg`).
  /// We strip the `/api/v1` suffix to get the server root.
  String _buildImageUrl(String relativeImageUrl) {
    String baseUrl = AppConfig.apiBaseUrl;
    // Strip trailing /api/v1 or /api/v1/ to get server root
    final apiSuffix = '/api/v1';
    if (baseUrl.endsWith(apiSuffix)) {
      baseUrl = baseUrl.substring(0, baseUrl.length - apiSuffix.length);
    } else if (baseUrl.endsWith('$apiSuffix/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - apiSuffix.length - 1);
    }
    return '$baseUrl/uploads/$relativeImageUrl';
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.banners.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _onManualSwipe() {
    // Pause auto-scroll on user interaction
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    // Resume after 6 seconds idle
    _resumeTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && widget.banners.length > 1) {
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;

    // D-04: 0 banners = invisible
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // D-04: 1 banner = static display without animation or dots
    if (banners.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: _buildBannerImage(banners.first, colors, isDark),
        ),
      );
    }

    // Multiple banners: PageView with auto-scroll and dots
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: SizedBox(
            height: 180,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  // User-initiated drag
                  _onManualSwipe();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return _buildBannerImage(banners[index], colors, isDark);
                },
              ),
            ),
          ),
        ),
        // D-03: Dot indicators
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final isActive = _currentPage == i;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? colors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerImage(
    BannerItem banner,
    ColorScheme colors,
    bool isDark,
  ) {
    final imageUrl = _buildImageUrl(banner.imageUrl);
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 180,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: isDark
              ? colors.surfaceContainerHighest
              : colors.surfaceContainerLow,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: isDark
              ? colors.surfaceContainerHighest
              : colors.surfaceContainerLow,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }
}
