import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/core/theme/dice_skin.dart';
import 'package:ludo_global/core/theme/token_skin.dart';
import 'package:ludo_global/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dice & Token Skins Tests', () {
    test('Default skins are correctly set in UserProfile', () {
      final profile = UserProfile();
      expect(profile.selectedDiceSkinId, 'classic_ivory');
      expect(profile.unlockedDiceSkins, contains('classic_ivory'));
      expect(profile.selectedTokenSkinId, 'classic_pawn');
      expect(profile.unlockedTokenSkins, contains('classic_pawn'));
    });

    test('All dice skins have valid properties', () {
      expect(DiceSkinData.allSkins.length, greaterThanOrEqualTo(4));
      for (var skin in DiceSkinData.allSkins) {
        expect(skin.id.isNotEmpty, isTrue);
        expect(skin.name.isNotEmpty, isTrue);
      }
    });

    test('All token skins have valid properties', () {
      expect(TokenSkinData.allSkins.length, greaterThanOrEqualTo(4));
      for (var skin in TokenSkinData.allSkins) {
        expect(skin.id.isNotEmpty, isTrue);
        expect(skin.name.isNotEmpty, isTrue);
      }
    });
  });
}
