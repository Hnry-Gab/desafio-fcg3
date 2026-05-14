import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A glassmorphism-style card matching the Cyber-Academic design system.
///
/// Features a frosted-glass background with 20px backdrop blur, 5% white fill,
/// 12% white border, and neon outer glow. Adapts to light/dark mode.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.glowColor,
    this.elevation = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Custom glow color. Defaults to neonTeal in dark mode, neonTealLight in light.
  final Color? glowColor;

  /// Glow intensity level: 1 (subtle), 2 (medium), 3 (hero).
  final int elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    // Glow alpha based on elevation level
    final double glowAlpha;
    switch (elevation) {
      case 2:
        glowAlpha = isDark ? 0.15 : 0.25;
      case 3:
        glowAlpha = isDark ? 0.20 : 0.35;
      default:
        glowAlpha = isDark ? 0.08 : 0.075;
    }

    final effectiveGlowColor = glowColor ??
        (isDark ? AppColors.neonTeal : AppColors.neonTealLight);

    final card = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveGlowColor.withValues(alpha: glowAlpha),
                blurRadius: isDark ? 16 : 20,
                spreadRadius: isDark ? 0 : 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}
