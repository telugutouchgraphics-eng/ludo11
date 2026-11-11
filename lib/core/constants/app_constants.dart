/// Game rules constants and timing
class AppConstants {
  static const int totalTrackSteps = 52;
  static const int homeStretchLength = 5;
  static const int targetHomePosition = 56; // 0..50 (track), 51..55 (home stretch), 56 (inside home center)
  static const int tokensPerPlayer = 4;

  // Safe global track positions (0-indexed on the 52-cell perimeter)
  // Red start: 0, Green start: 13, Yellow start: 26, Blue start: 39
  // Star safe spots: 8, 21, 34, 47
  static const List<int> safePositions = [0, 8, 13, 21, 26, 34, 39, 47];

  // Timing
  static const Duration diceRollDuration = Duration(milliseconds: 600);
  static const Duration tokenMoveDuration = Duration(milliseconds: 200);
  static const Duration botThinkingDuration = Duration(milliseconds: 650);
}
