import 'package:flutter/material.dart';

class BoardThemeData {
  final String id;
  final String name;
  final String description;
  final int coinCost; // Virtual coins earned through gameplay/challenges
  final bool isDefault;
  final Color boardBackground;
  final Color trackColor;
  final Color borderColor;
  final LinearGradient tableBackground;

  const BoardThemeData({
    required this.id,
    required this.name,
    required this.description,
    this.coinCost = 0,
    this.isDefault = false,
    required this.boardBackground,
    required this.trackColor,
    required this.borderColor,
    required this.tableBackground,
  });

  static const BoardThemeData classicRoyal = BoardThemeData(
    id: 'classic_royal',
    name: 'Classic Royal',
    description: 'The beloved traditional vibrant Ludo aesthetic',
    isDefault: true,
    boardBackground: Color(0xFFFFFFFF),
    trackColor: Color(0xFFF0F4F8),
    borderColor: Color(0xFF2C3E50),
    tableBackground: LinearGradient(
      colors: [Color(0xFF1E2640), Color(0xFF0F1424)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const BoardThemeData cyberNeon = BoardThemeData(
    id: 'cyber_neon',
    name: 'Cyber Neon',
    description: 'Futuristic glowing neon board with dark sci-fi surface',
    coinCost: 500,
    boardBackground: Color(0xFF131722),
    trackColor: Color(0xFF1E2333),
    borderColor: Color(0xFF00E5FF),
    tableBackground: LinearGradient(
      colors: [Color(0xFF0A0E17), Color(0xFF1A0A2A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const BoardThemeData woodenVintage = BoardThemeData(
    id: 'wooden_vintage',
    name: 'Wooden Vintage',
    description: 'Rustic handcrafted oak wood board with warm tones',
    coinCost: 1000,
    boardBackground: Color(0xFFF5E6CA),
    trackColor: Color(0xFFEAD5B5),
    borderColor: Color(0xFF5D4037),
    tableBackground: LinearGradient(
      colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const BoardThemeData goldenTemple = BoardThemeData(
    id: 'golden_temple',
    name: 'Golden Palace',
    description: 'Majestic gilded board adorned with royal gold ornaments',
    coinCost: 2000,
    boardBackground: Color(0xFFFFF9E6),
    trackColor: Color(0xFFFFF0C2),
    borderColor: Color(0xFFFFB300),
    tableBackground: LinearGradient(
      colors: [Color(0xFF241400), Color(0xFF452B00)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const List<BoardThemeData> allThemes = [
    classicRoyal,
    cyberNeon,
    woodenVintage,
    goldenTemple,
  ];
}
