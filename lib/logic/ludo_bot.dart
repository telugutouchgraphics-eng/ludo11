import '../models/player.dart';
import '../models/token.dart';
import 'ludo_path.dart';

class LudoBot {
  /// Evaluates all eligible tokens and chooses the best strategic move
  static Token chooseBestToken({
    required Player botPlayer,
    required List<Player> allPlayers,
    required int diceValue,
  }) {
    final movableTokens = botPlayer.getMovableTokens(diceValue);
    if (movableTokens.isEmpty) {
      throw Exception('No movable tokens available for bot');
    }
    if (movableTokens.length == 1) {
      return movableTokens.first;
    }

    Token bestToken = movableTokens.first;
    double maxScore = -9999.0;

    for (var token in movableTokens) {
      double score = 0.0;

      // 1. Can reach home? (Finish token)
      if (token.step + diceValue == 56) {
        score += 500.0;
      }

      // 2. Can move out of yard on rolling a 6
      if (token.inYard && diceValue == 6) {
        // High priority to bring pieces into play
        score += 200.0;
      }

      // 3. Can capture an opponent?
      if (!token.inYard) {
        final futureStep = token.step + diceValue;
        if (futureStep <= 50) {
          final futureGlobalIndex =
              (token.color.startTrackIndex + futureStep) % 52;
          if (!LudoPath.isSafeSpot(futureGlobalIndex)) {
            for (var other in allPlayers) {
              if (other.color == token.color) continue;
              for (var otherToken in other.tokens) {
                if (otherToken.onTrack &&
                    otherToken.globalTrackIndex == futureGlobalIndex) {
                  // Capture opportunity!
                  score += 350.0;
                  break;
                }
              }
            }
          } else {
            // Landing on safe spot is great
            score += 80.0;
          }
        }
      }

      // 4. Moving inside home stretch
      if (token.step + diceValue >= 51) {
        score += 100.0 + (token.step * 2);
      }

      // 5. Prefer advancing tokens closer to home
      if (!token.inYard) {
        score += token.step * 1.5;
      }

      if (score > maxScore) {
        maxScore = score;
        bestToken = token;
      }
    }

    return bestToken;
  }
}
