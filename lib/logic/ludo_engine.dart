import 'dart:math';
import '../models/player.dart';
import '../models/token.dart';
import 'ludo_path.dart';

enum GamePhase {
  waitingForRoll,
  rollingDice,
  waitingForTokenSelection,
  movingToken,
  gameOver,
}

class MoveResult {
  final bool success;
  final bool capturedOpponent;
  final Token? capturedToken;
  final bool reachedHome;
  final bool getsBonusTurn;

  MoveResult({
    required this.success,
    this.capturedOpponent = false,
    this.capturedToken,
    this.reachedHome = false,
    this.getsBonusTurn = false,
  });
}

class LudoEngine {
  final List<Player> players;
  int currentTurnIndex = 0;
  int diceValue = 1;
  int consecutiveSixes = 0;
  GamePhase phase = GamePhase.waitingForRoll;
  final Random _random = Random();
  final List<Player> leaderboard = [];

  LudoEngine({required this.players});

  Player get currentPlayer => players[currentTurnIndex];

  /// Roll the dice
  int rollDice() {
    diceValue = _random.nextInt(6) + 1;
    if (diceValue == 6) {
      consecutiveSixes++;
    } else {
      consecutiveSixes = 0;
    }
    return diceValue;
  }

  /// Check if 3 consecutive sixes were rolled
  bool hasThreeSixesPenalty() {
    return consecutiveSixes >= 3;
  }

  /// Executes movement for the chosen token
  MoveResult moveToken(Token token) {
    if (!token.canMove(diceValue)) {
      return MoveResult(success: false);
    }

    bool captured = false;
    Token? opponentCaptured;
    bool reachedHome = false;

    if (token.inYard) {
      // Step into track start
      token.step = 0;
    } else {
      token.step += diceValue;
    }

    // Check if reached home
    if (token.isFinished) {
      reachedHome = true;
      if (currentPlayer.hasWon && !leaderboard.contains(currentPlayer)) {
        leaderboard.add(currentPlayer);
      }
    }

    // Check capture on outer track
    if (token.onTrack) {
      final landingIndex = token.globalTrackIndex;
      if (landingIndex != null && !LudoPath.isSafeSpot(landingIndex)) {
        // Search other players for capture
        for (var otherPlayer in players) {
          if (otherPlayer.color == token.color) continue;
          for (var otherToken in otherPlayer.tokens) {
            if (otherToken.onTrack &&
                otherToken.globalTrackIndex == landingIndex) {
              // Captured!
              otherToken.resetToYard();
              captured = true;
              opponentCaptured = otherToken;
              break;
            }
          }
          if (captured) break;
        }
      }
    }

    final getsBonus = (diceValue == 6 && consecutiveSixes < 3) ||
        captured ||
        reachedHome;

    return MoveResult(
      success: true,
      capturedOpponent: captured,
      capturedToken: opponentCaptured,
      reachedHome: reachedHome,
      getsBonusTurn: getsBonus,
    );
  }

  /// Switch turn to next eligible active player
  void nextTurn() {
    consecutiveSixes = 0;
    int attempts = 0;
    do {
      currentTurnIndex = (currentTurnIndex + 1) % players.length;
      attempts++;
    } while (currentPlayer.hasWon && attempts < players.length);

    phase = GamePhase.waitingForRoll;
  }

  bool isGameOver() {
    // If only 1 player remains without winning
    final activePlayers = players.where((p) => !p.hasWon).length;
    return activePlayers <= 1;
  }

  void reset() {
    currentTurnIndex = 0;
    diceValue = 1;
    consecutiveSixes = 0;
    phase = GamePhase.waitingForRoll;
    leaderboard.clear();
    for (var p in players) {
      p.reset();
    }
  }
}
