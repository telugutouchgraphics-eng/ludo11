import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/core/audio/sound_service.dart';
import 'package:ludo_global/core/theme/avatar_frame.dart';
import 'package:ludo_global/models/user_profile.dart';
import 'package:ludo_global/presentation/screens/themes_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('Phase 4 Audio Engine Suite Tests', () {
    test('SoundService triggers all game audio events safely', () {
      final sound = SoundService.instance;
      expect(sound.soundEnabled, isTrue);

      // Verify no exceptions thrown across all Section 4 events
      sound.playGameStart();
      sound.playDiceRoll();
      sound.playTokenMove();
      sound.playSafeCellEntry();
      sound.playTokenCapture();
      sound.playTokenHome();
      sound.playVictory();
      sound.playNotification();
      sound.playCoinClink();
      sound.playReaction();

      // Test toggle mute
      sound.toggleMute();
      expect(sound.soundEnabled, isFalse);
      sound.toggleMute();
      expect(sound.soundEnabled, isTrue);
    });

    test('AvatarFrameData contains expected catalog', () {
      expect(AvatarFrameData.allFrames.length, 5);
      expect(AvatarFrameData.classicWreath.coinCost, 0);
      expect(AvatarFrameData.royalGold.coinCost, 350);
      expect(AvatarFrameData.cosmicNova.coinCost, 600);
    });
  });

  group('ThemesScreen 3D Wardrobe Widget Tests', () {
    testWidgets('ThemesScreen renders 4 tabs and 3D stage hero', (WidgetTester tester) async {
      final profile = UserProfile(
        name: 'Alex',
        coins: 1000,
        level: 1,
        xp: 0,
      );

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: ThemesScreen(userProfile: profile),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Verify Screen Header and 4 Tabs
      expect(find.text('3D WARDROBE & STORE'), findsOneWidget);
      expect(find.text('BOARDS'), findsOneWidget);
      expect(find.text('3D DICE'), findsOneWidget);
      expect(find.text('TOKENS'), findsOneWidget);
      expect(find.text('FRAMES'), findsOneWidget);

      // Verify 3D Stage Hero
      expect(find.text('EQUIPPED 3D STAGE'), findsOneWidget);
      expect(find.text('Drag to inspect in 3D ↺'), findsOneWidget);

      // Tap on FRAMES tab
      await tester.tap(find.text('FRAMES'));
      await tester.pump(const Duration(milliseconds: 600));

      // Verify avatar frames are displayed
      expect(find.text('Silver Laurel'), findsOneWidget);
      await tester.drag(find.text('Silver Laurel'), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('24K Royal Crown Halo'), findsOneWidget);
    });
  });
}
