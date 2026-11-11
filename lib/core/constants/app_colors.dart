import 'package:flutter/material.dart';

/// Premium, vibrant color palette for Ludo Global
class AppColors {
  // LUDO1 Master Redesign Emotional Palette
  static const Color coralPink = Color(0xFFFF4D6D);
  static const Color electricPurple = Color(0xFF7B2CBF);
  static const Color royalBlue = Color(0xFF2A6F97);
  static const Color warmPeach = Color(0xFFFFB4A2);
  static const Color softLavender = Color(0xFFE0AAFF);

  static const Color creamWhite = Color(0xFFFDFBF7);
  static const Color deepNavy = Color(0xFF0D1326);
  static const Color mintGreen = Color(0xFF2EC4B6);
  static const Color warmGold = Color(0xFFFFB703);
  static const Color softPink = Color(0xFFFF758F);

  // Brand Backgrounds & Surfaces
  static const Color backgroundDark = Color(0xFF0D1326); // Warm Deep Navy
  static const Color backgroundDeepSpace = Color(0xFF080C1A);
  static const Color backgroundCard = Color(0xFF161E38);
  static const Color backgroundSurface = Color(0xFF1F294C);
  static const Color backgroundBoard = Color(0xFFFAF8F5); // Cream Satin
  static const Color glassSurface = Color(0x99192044);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderGold = Color(0x66FFD700);

  // Player Color Themes (Jewel Tone Upgrades)
  // Red (Imperial Ruby)
  static const Color redPrimary = Color(0xFFFF2A55);
  static const Color redLight = Color(0xFFFF607E);
  static const Color redDark = Color(0xFFA50E2D);
  static const Color redGlow = Color(0x66FF2A55);

  // Green (Emerald Jade)
  static const Color greenPrimary = Color(0xFF00E676);
  static const Color greenLight = Color(0xFF69F0AE);
  static const Color greenDark = Color(0xFF00843D);
  static const Color greenGlow = Color(0x6600E676);

  // Yellow (Sunburst Amber)
  static const Color yellowPrimary = Color(0xFFFFB800);
  static const Color yellowLight = Color(0xFFFFE066);
  static const Color yellowDark = Color(0xFFD47A00);
  static const Color yellowGlow = Color(0x66FFB800);

  // Blue (Sapphire Ocean)
  static const Color bluePrimary = Color(0xFF00A3FF);
  static const Color blueLight = Color(0xFF54C5FF);
  static const Color blueDark = Color(0xFF005B9E);
  static const Color blueGlow = Color(0x6600A3FF);

  // Rose Gold (Couples & Romance Duo Mode)
  static const Color roseGoldPrimary = Color(0xFFF48FB1);
  static const Color roseGoldLight = Color(0xFFF8BBD0);
  static const Color roseGoldDark = Color(0xFFC2185B);
  static const Color roseGoldGlow = Color(0x66F48FB1);

  // Premium Gold Accents & Badges
  static const Color goldLight = Color(0xFFFFE082);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFFFA000);
  static const Color goldGlow = Color(0x80FFD700);

  // UI Accents
  static const Color accentNeon = Color(0xFF00F5FF);
  static const Color accentPurple = Color(0xFF7B2CBF);
  static const Color accentPink = Color(0xFFFF2A85);
  static const Color accentCyan = Color(0xFF00E5FF);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white38 = Colors.white38;
  static const Color black = Colors.black;
  static const Color greyTrack = Color(0xFFE2E6F0);
  static const Color greyBorder = Color(0xFFC5CCE0);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFEE58), Color(0xFFFFB300), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient royalPurpleGradient = LinearGradient(
    colors: [Color(0xFF2E1A47), Color(0xFF1B112B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF262C55), Color(0xFF1A1E3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF69F0AE), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFEE58), Color(0xFFF57F17)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF40C4FF), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldShimmerGradient = LinearGradient(
    colors: [Color(0xFFFFF3B0), Color(0xFFFFD700), Color(0xFFD4AF37), Color(0xFFFFF3B0)],
    stops: [0.0, 0.35, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGoldGradient = LinearGradient(
    colors: [Color(0xFFF8BBD0), Color(0xFFF48FB1), Color(0xFFC2185B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
