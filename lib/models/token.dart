import '../core/constants/app_constants.dart';
import 'player_color.dart';

enum TokenState { inYard, onTrack, inHomeStretch, finished }

class Token {
  final int id; // 0..3
  final PlayerColor color;
  int step; // -1 = inYard, 0 = start, 1..50 = onTrack, 51..55 = home stretch, 56 = finished

  Token({
    required this.id,
    required this.color,
    this.step = -1,
  });

  bool get inYard => step == -1;
  bool get isFinished => step == AppConstants.targetHomePosition;
  bool get onTrack => step >= 0 && step <= 50;
  bool get inHomeStretch => step >= 51 && step <= 55;

  TokenState get state {
    if (inYard) return TokenState.inYard;
    if (isFinished) return TokenState.finished;
    if (inHomeStretch) return TokenState.inHomeStretch;
    return TokenState.onTrack;
  }

  /// Calculates global track index (0..51) if on outer track
  int? get globalTrackIndex {
    if (step < 0 || step > 50) return null;
    return (color.startTrackIndex + step) % AppConstants.totalTrackSteps;
  }

  /// Whether this token can move with the given dice roll
  bool canMove(int diceValue) {
    if (isFinished) return false;
    if (inYard) {
      return diceValue == 6;
    }
    return (step + diceValue) <= AppConstants.targetHomePosition;
  }

  void resetToYard() {
    step = -1;
  }

  Token copyWith({int? step}) {
    return Token(
      id: id,
      color: color,
      step: step ?? this.step,
    );
  }
}
