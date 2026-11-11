import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/logic/mission_manager.dart';
import 'package:ludo_global/models/daily_mission.dart';
import 'package:ludo_global/models/user_profile.dart';
import 'package:ludo_global/presentation/widgets/reactions/reaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Daily Missions & Achievements Tests', () {
    test('MissionManager initializes with default daily missions', () async {
      final manager = MissionManager.instance;
      await manager.init();

      expect(manager.missions.length, 3);
      expect(manager.missions.any((m) => m.type == MissionType.rollSix), isTrue);
      expect(manager.missions.any((m) => m.type == MissionType.captureToken), isTrue);
      expect(manager.missions.any((m) => m.type == MissionType.winMatch), isTrue);
    });

    test('Tracking mission progress and completion', () async {
      final manager = MissionManager.instance;
      await manager.init();

      final sixMission = manager.missions.firstWhere((m) => m.type == MissionType.rollSix);
      expect(sixMission.isCompleted, isFalse);
      expect(sixMission.currentProgress, 0);

      // Track 3 rolls of six
      manager.trackSixRoll();
      manager.trackSixRoll();
      manager.trackSixRoll();

      expect(sixMission.currentProgress, 3);
      expect(sixMission.isCompleted, isTrue);
      expect(sixMission.isClaimed, isFalse);
      expect(manager.unclaimedCount, greaterThanOrEqualTo(1));
    });

    test('Claiming mission rewards awards coins and XP to UserProfile', () async {
      final manager = MissionManager.instance;
      await manager.init();

      final profile = UserProfile(coins: 100, xp: 50);
      final winMission = manager.missions.firstWhere((m) => m.type == MissionType.winMatch);

      // Advance and complete mission
      manager.trackMatchWin();
      expect(winMission.isCompleted, isTrue);

      final success = manager.claimReward(winMission, profile);
      expect(success, isTrue);
      expect(winMission.isClaimed, isTrue);
      expect(profile.coins, 100 + winMission.rewardCoins);
      expect(profile.xp, 50 + winMission.rewardXp);

      // Cannot claim again
      final secondClaim = manager.claimReward(winMission, profile);
      expect(secondClaim, isFalse);
    });
  });

  group('Quick Reactions & Safe Chat Tests', () {
    test('Preset reactions are safe and non-empty', () {
      expect(ReactionItem.presetReactions.length, greaterThanOrEqualTo(6));
      for (final r in ReactionItem.presetReactions) {
        expect(r.emoji.isNotEmpty, isTrue);
        expect(r.text.isNotEmpty, isTrue);
      }
    });
  });
}
