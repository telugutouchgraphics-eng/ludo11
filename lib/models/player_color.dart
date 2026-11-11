import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum PlayerColor {
  red,
  green,
  yellow,
  blue;

  String get displayName {
    switch (this) {
      case PlayerColor.red:
        return 'Red';
      case PlayerColor.green:
        return 'Green';
      case PlayerColor.yellow:
        return 'Yellow';
      case PlayerColor.blue:
        return 'Blue';
    }
  }

  Color get primaryColor {
    switch (this) {
      case PlayerColor.red:
        return AppColors.redPrimary;
      case PlayerColor.green:
        return AppColors.greenPrimary;
      case PlayerColor.yellow:
        return AppColors.yellowPrimary;
      case PlayerColor.blue:
        return AppColors.bluePrimary;
    }
  }

  Color get lightColor {
    switch (this) {
      case PlayerColor.red:
        return AppColors.redLight;
      case PlayerColor.green:
        return AppColors.greenLight;
      case PlayerColor.yellow:
        return AppColors.yellowLight;
      case PlayerColor.blue:
        return AppColors.blueLight;
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case PlayerColor.red:
        return AppColors.redGradient;
      case PlayerColor.green:
        return AppColors.greenGradient;
      case PlayerColor.yellow:
        return AppColors.yellowGradient;
      case PlayerColor.blue:
        return AppColors.blueGradient;
    }
  }

  Color get glowColor {
    switch (this) {
      case PlayerColor.red:
        return AppColors.redGlow;
      case PlayerColor.green:
        return AppColors.greenGlow;
      case PlayerColor.yellow:
        return AppColors.yellowGlow;
      case PlayerColor.blue:
        return AppColors.blueGlow;
    }
  }

  /// Global track start offset (0..51)
  int get startTrackIndex {
    switch (this) {
      case PlayerColor.red:
        return 0; // Starts at Red Start (col 6, row 13)
      case PlayerColor.green:
        return 13; // Starts at Green Start (col 1, row 6)
      case PlayerColor.yellow:
        return 26; // Starts at Yellow Start (col 8, row 1)
      case PlayerColor.blue:
        return 39; // Starts at Blue Start (col 13, row 8)
    }
  }
}
