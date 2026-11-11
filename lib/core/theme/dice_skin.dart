import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DiceSkinData {
  final String id;
  final String name;
  final String description;
  final int coinCost;
  final bool isDefault;
  final LinearGradient bodyGradient;
  final Color dotColor;
  final Color borderColor;
  final Color glowColor;

  const DiceSkinData({
    required this.id,
    required this.name,
    required this.description,
    this.coinCost = 0,
    this.isDefault = false,
    required this.bodyGradient,
    required this.dotColor,
    required this.borderColor,
    required this.glowColor,
  });

  static const DiceSkinData classicIvory = DiceSkinData(
    id: 'classic_ivory',
    name: 'Classic Ivory',
    description: 'Clean glossy white dice with player color pips',
    isDefault: true,
    bodyGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFE9EDF5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dotColor: Colors.black87,
    borderColor: Color(0xFFC5CCE0),
    glowColor: Color(0x66C5CCE0),
  );

  static const DiceSkinData royalGold = DiceSkinData(
    id: 'royal_gold',
    name: 'Royal Gold',
    description: 'Gleaming 24K solid gold dice with ruby red pips',
    coinCost: 400,
    bodyGradient: LinearGradient(
      colors: [Color(0xFFFFEE58), Color(0xFFFFB300), Color(0xFFFF8F00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dotColor: Color(0xFFB71C1C),
    borderColor: Color(0xFFFFD700),
    glowColor: AppColors.goldGlow,
  );

  static const DiceSkinData cyberNeon = DiceSkinData(
    id: 'cyber_neon',
    name: 'Cyber Neon',
    description: 'Futuristic obsidian cube with glowing cyan pips',
    coinCost: 700,
    bodyGradient: LinearGradient(
      colors: [Color(0xFF1E2640), Color(0xFF0F1424)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dotColor: Color(0xFF00E5FF),
    borderColor: Color(0xFF00E5FF),
    glowColor: Color(0x8000E5FF),
  );

  static const DiceSkinData rubyDragon = DiceSkinData(
    id: 'ruby_dragon',
    name: 'Ruby Dragon',
    description: 'Fiery crimson crystal dice with glowing golden pips',
    coinCost: 1000,
    bodyGradient: LinearGradient(
      colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dotColor: AppColors.gold,
    borderColor: Color(0xFFFF5252),
    glowColor: Color(0x80FF5252),
  );

  static const List<DiceSkinData> allSkins = [
    classicIvory,
    royalGold,
    cyberNeon,
    rubyDragon,
  ];
}
