import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Daily Lucky Spin & Streak Tests', () {
    test('User can spin today when lastSpinDate is null', () {
      final profile = UserProfile(coins: 500);
      expect(profile.canSpinToday, isTrue);
    });

    test('Claiming spin reward awards coins and sets lastSpinDate to today', () {
      final profile = UserProfile(coins: 500);
      expect(profile.canSpinToday, isTrue);

      profile.claimSpinReward(150);

      expect(profile.coins, 650);
      expect(profile.canSpinToday, isFalse);
    });

    test('Daily streak increments on consecutive days', () {
      final profile = UserProfile(loginStreak: 1);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      profile.lastLoginDate =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      profile.updateDailyStreak();

      expect(profile.loginStreak, 2);
    });

    test('Daily streak resets if more than 1 day skipped', () {
      final profile = UserProfile(loginStreak: 5);
      final oldDate = DateTime.now().subtract(const Duration(days: 3));
      profile.lastLoginDate =
          '${oldDate.year}-${oldDate.month.toString().padLeft(2, '0')}-${oldDate.day.toString().padLeft(2, '0')}';

      profile.updateDailyStreak();

      expect(profile.loginStreak, 1);
    });
  });
}
