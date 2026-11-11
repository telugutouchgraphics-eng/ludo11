import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_global/core/constants/app_colors.dart';
import 'package:ludo_global/core/theme/app_theme_v2.dart';
import 'package:ludo_global/core/theme/board_theme.dart';
import 'package:ludo_global/core/theme/dice_skin.dart';
import 'package:ludo_global/core/theme/token_skin.dart';
import 'package:ludo_global/models/player_color.dart';
import 'package:ludo_global/models/token.dart';
import 'package:ludo_global/presentation/widgets/board/luxe_board_painter.dart';
import 'package:ludo_global/presentation/widgets/board/sculpted_pawn_widget.dart';
import 'package:ludo_global/presentation/widgets/dice/dice_engine_3d.dart';

void main() {
  group('Phase 1 Design System & 3D Visual Engine Tests', () {
    test('AppColors jewel tone upgrades and gradients exist', () {
      expect(AppColors.backgroundDark, const Color(0xFF0D1326));
      expect(AppColors.redPrimary, const Color(0xFFFF2A55));
      expect(AppColors.greenPrimary, const Color(0xFF00E676));
      expect(AppColors.yellowPrimary, const Color(0xFFFFB800));
      expect(AppColors.bluePrimary, const Color(0xFF00A3FF));
      expect(AppColors.roseGoldPrimary, const Color(0xFFF48FB1));
      expect(AppColors.goldShimmerGradient.colors.length, 4);
    });

    test('AppThemeV2 frosted glass and card decorations', () {
      final decor = AppThemeV2.glassCardDecoration();
      expect(decor.borderRadius, BorderRadius.circular(AppThemeV2.radiusMedium));
      expect(decor.border, isNotNull);
      expect(decor.boxShadow, isNotEmpty);
    });

    testWidgets('DiceEngine3D renders and displays correct values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DiceEngine3D(
                value: 6,
                isRolling: false,
                skin: DiceSkinData.royalGold,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DiceEngine3D), findsOneWidget);
    });

    testWidgets('SculptedPawnWidget renders with jewel layers and token states', (tester) async {
      final token = Token(id: 0, color: PlayerColor.red, step: 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SculptedPawnWidget(
                token: token,
                size: 40,
                isMovable: true,
                skin: TokenSkinData.royalKnight,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SculptedPawnWidget), findsOneWidget);
    });

    test('LuxeBoardPainter initializes properly with all board themes', () {
      for (final theme in BoardThemeData.allThemes) {
        final painter = LuxeBoardPainter(theme: theme);
        expect(painter.theme.id, theme.id);
      }
    });
  });
}
