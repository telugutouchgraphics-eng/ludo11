import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/player_color.dart';
import '../models/token.dart';

class LudoPath {
  /// The 52 track cell coordinates on a 15x15 grid (x: 0..14 col, y: 0..14 row)
  /// Starting with Red start at index 0 (col 6, row 13) moving clockwise
  static const List<Offset> trackCoordinates = [
    Offset(6, 13), // 0: Red Start
    Offset(6, 12), // 1
    Offset(6, 11), // 2
    Offset(6, 10), // 3
    Offset(6, 9),  // 4
    Offset(5, 8),  // 5
    Offset(4, 8),  // 6
    Offset(3, 8),  // 7
    Offset(2, 8),  // 8: Safe Star
    Offset(1, 8),  // 9
    Offset(0, 8),  // 10
    Offset(0, 7),  // 11: Turn
    Offset(0, 6),  // 12
    Offset(1, 6),  // 13: Green Start
    Offset(2, 6),  // 14
    Offset(3, 6),  // 15
    Offset(4, 6),  // 16
    Offset(5, 6),  // 17
    Offset(6, 5),  // 18
    Offset(6, 4),  // 19
    Offset(6, 3),  // 20
    Offset(6, 2),  // 21: Safe Star
    Offset(6, 1),  // 22
    Offset(6, 0),  // 23
    Offset(7, 0),  // 24: Turn
    Offset(8, 0),  // 25
    Offset(8, 1),  // 26: Yellow Start
    Offset(8, 2),  // 27
    Offset(8, 3),  // 28
    Offset(8, 4),  // 29
    Offset(8, 5),  // 30
    Offset(9, 6),  // 31
    Offset(10, 6), // 32
    Offset(11, 6), // 33
    Offset(12, 6), // 34: Safe Star
    Offset(13, 6), // 35
    Offset(14, 6), // 36
    Offset(14, 7), // 37: Turn
    Offset(14, 8), // 38
    Offset(13, 8), // 39: Blue Start
    Offset(12, 8), // 40
    Offset(11, 8), // 41
    Offset(10, 8), // 42
    Offset(9, 8),  // 43
    Offset(8, 9),  // 44
    Offset(8, 10), // 45
    Offset(8, 11), // 46
    Offset(8, 12), // 47: Safe Star
    Offset(8, 13), // 48
    Offset(8, 14), // 49
    Offset(7, 14), // 50: Turn
    Offset(6, 14), // 51
  ];

  /// Home stretch 5 cells for each color leading to center (7, 7)
  static const Map<PlayerColor, List<Offset>> homeStretchCoordinates = {
    PlayerColor.red: [
      Offset(7, 13),
      Offset(7, 12),
      Offset(7, 11),
      Offset(7, 10),
      Offset(7, 9),
    ],
    PlayerColor.green: [
      Offset(1, 7),
      Offset(2, 7),
      Offset(3, 7),
      Offset(4, 7),
      Offset(5, 7),
    ],
    PlayerColor.yellow: [
      Offset(7, 1),
      Offset(7, 2),
      Offset(7, 3),
      Offset(7, 4),
      Offset(7, 5),
    ],
    PlayerColor.blue: [
      Offset(13, 7),
      Offset(12, 7),
      Offset(11, 7),
      Offset(10, 7),
      Offset(9, 7),
    ],
  };

  /// Home center coordinate for all finished tokens
  static const Offset homeCenter = Offset(7, 7);

  /// 4 Token resting slots in each yard (top-left, top-right, bottom-left, bottom-right)
  static const Map<PlayerColor, List<Offset>> yardPositions = {
    PlayerColor.red: [
      Offset(1.5, 10.5),
      Offset(3.5, 10.5),
      Offset(1.5, 12.5),
      Offset(3.5, 12.5),
    ],
    PlayerColor.green: [
      Offset(1.5, 1.5),
      Offset(3.5, 1.5),
      Offset(1.5, 3.5),
      Offset(3.5, 3.5),
    ],
    PlayerColor.yellow: [
      Offset(10.5, 1.5),
      Offset(12.5, 1.5),
      Offset(10.5, 3.5),
      Offset(12.5, 3.5),
    ],
    PlayerColor.blue: [
      Offset(10.5, 10.5),
      Offset(12.5, 10.5),
      Offset(10.5, 12.5),
      Offset(12.5, 12.5),
    ],
  };

  /// Returns grid position (x, y) on 15x15 grid for any given token
  static Offset getTokenPosition(Token token) {
    if (token.inYard) {
      return yardPositions[token.color]![token.id];
    }
    if (token.isFinished) {
      // Offset slightly per token inside home center
      switch (token.color) {
        case PlayerColor.red:
          return const Offset(7.0, 7.6);
        case PlayerColor.green:
          return const Offset(6.4, 7.0);
        case PlayerColor.yellow:
          return const Offset(7.0, 6.4);
        case PlayerColor.blue:
          return const Offset(7.6, 7.0);
      }
    }
    if (token.inHomeStretch) {
      final index = token.step - 51; // 0..4
      return homeStretchCoordinates[token.color]![index];
    }
    // On outer track
    final globalIdx = token.globalTrackIndex;
    if (globalIdx != null && globalIdx >= 0 && globalIdx < 52) {
      return trackCoordinates[globalIdx];
    }
    return yardPositions[token.color]![token.id];
  }

  /// Checks if a global track index is a designated safe spot
  static bool isSafeSpot(int globalTrackIndex) {
    return AppConstants.safePositions.contains(globalTrackIndex);
  }
}
