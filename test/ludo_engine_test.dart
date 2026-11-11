import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/logic/ludo_engine.dart';
import 'package:ludo_global/logic/ludo_path.dart';
import 'package:ludo_global/models/player.dart';
import 'package:ludo_global/models/player_color.dart';

void main() {
  group('Ludo Game Engine Tests', () {
    late LudoEngine engine;
    late Player p1;
    late Player p2;

    setUp(() {
      p1 = Player(id: '1', name: 'Player Red', color: PlayerColor.red);
      p2 = Player(id: '2', name: 'Player Yellow', color: PlayerColor.yellow);
      engine = LudoEngine(players: [p1, p2]);
    });

    test('Tokens start in yard with step = -1', () {
      for (var token in p1.tokens) {
        expect(token.inYard, isTrue);
        expect(token.step, -1);
      }
    });

    test('Token cannot move out of yard with non-6 roll', () {
      expect(p1.tokens[0].canMove(3), isFalse);
      expect(p1.tokens[0].canMove(1), isFalse);
      expect(p1.tokens[0].canMove(5), isFalse);
    });

    test('Token moves out of yard to step 0 on roll of 6', () {
      expect(p1.tokens[0].canMove(6), isTrue);
      engine.diceValue = 6;
      final result = engine.moveToken(p1.tokens[0]);

      expect(result.success, isTrue);
      expect(p1.tokens[0].step, 0);
      expect(p1.tokens[0].inYard, isFalse);
      expect(p1.tokens[0].onTrack, isTrue);
      expect(p1.tokens[0].globalTrackIndex, 0); // Red start
      expect(result.getsBonusTurn, isTrue);
    });

    test('Safe spots are correctly identified', () {
      expect(LudoPath.isSafeSpot(0), isTrue);  // Red start
      expect(LudoPath.isSafeSpot(13), isTrue); // Green start
      expect(LudoPath.isSafeSpot(26), isTrue); // Yellow start
      expect(LudoPath.isSafeSpot(39), isTrue); // Blue start
      expect(LudoPath.isSafeSpot(8), isTrue);  // Star
      expect(LudoPath.isSafeSpot(21), isTrue); // Star
      expect(LudoPath.isSafeSpot(34), isTrue); // Star
      expect(LudoPath.isSafeSpot(47), isTrue); // Star
      expect(LudoPath.isSafeSpot(1), isFalse); // Normal spot
    });

    test('Tokens advance correctly on track', () {
      p1.tokens[0].step = 0; // On Red start (global 0)
      engine.diceValue = 4;
      final result = engine.moveToken(p1.tokens[0]);

      expect(result.success, isTrue);
      expect(p1.tokens[0].step, 4);
      expect(p1.tokens[0].globalTrackIndex, 4);
    });

    test('Capture works on non-safe track spot', () {
      // Red starts at 0. Suppose Red token is at step 3 -> global 3
      p1.tokens[0].step = 3;

      // Yellow starts at global 26.
      // If Yellow token is at global 3 (step: (3 - 26 + 52) = 29)
      p2.tokens[0].step = 29;
      expect(p2.tokens[0].globalTrackIndex, 3);

      // Red rolls 2 and reaches step 5 -> global 5
      // Instead, put Yellow token at global 5
      p2.tokens[0].step = 31; // (26 + 31) % 52 = 57 % 52 = 5
      expect(p2.tokens[0].globalTrackIndex, 5);

      engine.diceValue = 2;
      final result = engine.moveToken(p1.tokens[0]); // Moves to step 5 (global 5)

      expect(result.success, isTrue);
      expect(result.capturedOpponent, isTrue);
      expect(p2.tokens[0].inYard, isTrue); // Sent back to yard
      expect(p2.tokens[0].step, -1);
      expect(result.getsBonusTurn, isTrue); // Bonus turn awarded
    });

    test('Safe spot prevents capture', () {
      // Safe spot index 8
      p1.tokens[0].step = 4; // global 4
      p2.tokens[0].step = 34; // (26 + 34) % 52 = 60 % 52 = 8 (Safe Star spot!)
      expect(p2.tokens[0].globalTrackIndex, 8);

      engine.diceValue = 4;
      final result = engine.moveToken(p1.tokens[0]); // Moves to step 8 (global 8)

      expect(result.success, isTrue);
      expect(result.capturedOpponent, isFalse);
      expect(p2.tokens[0].inYard, isFalse); // Not captured because it is a safe spot!
      expect(p2.tokens[0].globalTrackIndex, 8);
    });

    test('Reaching home finishes token and awards bonus turn', () {
      p1.tokens[0].step = 52;
      engine.diceValue = 4;
      final result = engine.moveToken(p1.tokens[0]);

      expect(result.success, isTrue);
      expect(p1.tokens[0].step, 56);
      expect(p1.tokens[0].isFinished, isTrue);
      expect(result.reachedHome, isTrue);
      expect(result.getsBonusTurn, isTrue);
    });
  });
}
