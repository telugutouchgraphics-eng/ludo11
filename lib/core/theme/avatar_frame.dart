import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AvatarFrameData {
  final String id;
  final String name;
  final String description;
  final int coinCost;
  final bool isDefault;
  final LinearGradient borderGradient;
  final Color glowColor;
  final String badgeEmoji;
  final IconData cornerIcon;

  const AvatarFrameData({
    required this.id,
    required this.name,
    required this.description,
    this.coinCost = 0,
    this.isDefault = false,
    required this.borderGradient,
    required this.glowColor,
    required this.badgeEmoji,
    required this.cornerIcon,
  });

  static const AvatarFrameData classicWreath = AvatarFrameData(
    id: 'classic_wreath',
    name: 'Silver Laurel',
    description: 'Minimalist silver laurel wreath with soft sheen',
    isDefault: true,
    coinCost: 0,
    borderGradient: LinearGradient(
      colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowColor: Color(0x40FFFFFF),
    badgeEmoji: '⭐',
    cornerIcon: Icons.star_rounded,
  );

  static const AvatarFrameData royalGold = AvatarFrameData(
    id: 'royal_gold',
    name: '24K Royal Crown Halo',
    description: 'Imperial polished gold border with gilded crown insignia',
    coinCost: 350,
    borderGradient: AppColors.goldGradient,
    glowColor: AppColors.goldGlow,
    badgeEmoji: '👑',
    cornerIcon: Icons.military_tech_rounded,
  );

  static const AvatarFrameData cosmicNova = AvatarFrameData(
    id: 'cosmic_nova',
    name: 'Cosmic Supernova',
    description: 'Electric violet and neon turquoise nebula aura',
    coinCost: 600,
    borderGradient: LinearGradient(
      colors: [AppColors.electricPurple, AppColors.royalBlue, Color(0xFF00E5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowColor: Color(0x807C4DFF),
    badgeEmoji: '🌌',
    cornerIcon: Icons.auto_awesome_rounded,
  );

  static const AvatarFrameData coralBlossom = AvatarFrameData(
    id: 'coral_blossom',
    name: 'Coral Blossom',
    description: 'Romantic coral pink and warm peach floral shimmer',
    coinCost: 450,
    borderGradient: LinearGradient(
      colors: [AppColors.coralPink, AppColors.warmPeach],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowColor: Color(0x80FF6F61),
    badgeEmoji: '🌸',
    cornerIcon: Icons.favorite_rounded,
  );

  static const AvatarFrameData neonCyber = AvatarFrameData(
    id: 'neon_cyber',
    name: 'Neon Cyberpunk',
    description: 'High-voltage electric green and cyber grid ring',
    coinCost: 750,
    borderGradient: LinearGradient(
      colors: [AppColors.mintGreen, Color(0xFF00FFCC), Color(0xFF0D9488)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    glowColor: Color(0x8000FFCC),
    badgeEmoji: '⚡',
    cornerIcon: Icons.bolt_rounded,
  );

  static const List<AvatarFrameData> allFrames = [
    classicWreath,
    royalGold,
    cosmicNova,
    coralBlossom,
    neonCyber,
  ];
}
