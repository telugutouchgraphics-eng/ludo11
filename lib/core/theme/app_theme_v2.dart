import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Neo-Luxe Design System & Visual Helpers for LUDO1
class AppThemeV2 {
  // Brand Radii
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 18.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 999.0;

  // Typography Styles
  static const TextStyle heroTitle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  );

  static const TextStyle screenTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
  );

  static const TextStyle sectionHeader = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  static const TextStyle bodyBold = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyRegular = TextStyle(
    color: Colors.white70,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    color: Colors.white54,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static const TextStyle goldBadge = TextStyle(
    color: AppColors.gold,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
  );

  // Glassmorphism Card Decoration
  static BoxDecoration glassCardDecoration({
    double borderRadius = radiusMedium,
    Color? borderColor,
    double borderWidth = 1.2,
    Color? surfaceColor,
  }) {
    return BoxDecoration(
      color: surfaceColor ?? AppColors.glassSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Golden Glow Decoration
  static BoxDecoration goldGlowDecoration({
    double borderRadius = radiusMedium,
  }) {
    return BoxDecoration(
      gradient: AppColors.goldShimmerGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.45),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Ambient Player Glow
  static List<BoxShadow> playerGlow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: 16,
        spreadRadius: 2,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // Helper Widget for Frosted Glass Acrylic Effect
  static Widget frostedGlass({
    required Widget child,
    double borderRadius = radiusMedium,
    Color? borderColor,
    double borderWidth = 1.2,
    Color? surfaceColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: glassCardDecoration(
            borderRadius: borderRadius,
            borderColor: borderColor,
            borderWidth: borderWidth,
            surfaceColor: surfaceColor,
          ),
          child: child,
        ),
      ),
    );
  }
}
