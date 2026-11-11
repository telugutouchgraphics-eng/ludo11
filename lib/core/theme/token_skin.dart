import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TokenSkinData {
  final String id;
  final String name;
  final String description;
  final int coinCost;
  final bool isDefault;
  final IconData insigniaIcon;
  final LinearGradient rimGradient;
  final Color glowColor;

  const TokenSkinData({
    required this.id,
    required this.name,
    required this.description,
    this.coinCost = 0,
    this.isDefault = false,
    required this.insigniaIcon,
    required this.rimGradient,
    required this.glowColor,
  });

  static const TokenSkinData classicPawn = TokenSkinData(
    id: 'classic_pawn',
    name: 'Classic Pawn',
    description: 'Traditional royal pawn with silver metallic rim',
    isDefault: true,
    insigniaIcon: Icons.arrow_upward_rounded,
    rimGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFC0C0C0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowColor: Color(0x66FFFFFF),
  );

  static const TokenSkinData royalKnight = TokenSkinData(
    id: 'royal_knight',
    name: 'Royal Knight',
    description: 'Armored knight shield with 24K gilded rim',
    coinCost: 350,
    insigniaIcon: Icons.shield_rounded,
    rimGradient: AppColors.goldGradient,
    glowColor: AppColors.goldGlow,
  );

  static const TokenSkinData imperialCrown = TokenSkinData(
    id: 'imperial_crown',
    name: 'Imperial Crown',
    description: 'Majestic monarch crown with diamond luster',
    coinCost: 650,
    insigniaIcon: Icons.military_tech_rounded,
    rimGradient: LinearGradient(
      colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowColor: Color(0x8000E5FF),
  );

  static const TokenSkinData blazingStar = TokenSkinData(
    id: 'blazing_star',
    name: 'Blazing Star',
    description: 'Heroic celestial star with blazing solar aura',
    coinCost: 900,
    insigniaIcon: Icons.star_rounded,
    rimGradient: LinearGradient(
      colors: [Color(0xFFFFD54F), Color(0xFFFF3D00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowColor: Color(0x80FF9100),
  );

  static const List<TokenSkinData> allSkins = [
    classicPawn,
    royalKnight,
    imperialCrown,
    blazingStar,
  ];
}
