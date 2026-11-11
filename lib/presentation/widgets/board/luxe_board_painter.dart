import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/board_theme.dart';
import '../../../models/player_color.dart';

/// Masterpiece Luxury Ludo Board Painter
/// Featuring Warm Royal Ivory Surface, 24K Gilded Borders,
/// Deep Jewel Courtyards, Embossed Metallic Stars, and Crystalline Vortex.
class LuxeBoardPainter extends CustomPainter {
  final BoardThemeData theme;

  LuxeBoardPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 15.0;
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Board Outer Wooden / Obsidian Base Rim
    final Paint tableShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fullRect, const Radius.circular(20)),
      tableShadowPaint,
    );

    // Base Board Surface (Warm Royal Ivory / Satin)
    final Paint bgPaint = Paint()..color = theme.boardBackground;
    canvas.drawRRect(
      RRect.fromRectAndRadius(fullRect, const Radius.circular(18)),
      bgPaint,
    );

    // Subtle Satin Texture Gradient Overlay
    final Paint satinOverlay = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(fullRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fullRect, const Radius.circular(18)),
      satinOverlay,
    );

    // 2. Draw 4 Jewel Yards (6x6 cells each) with 24K Gold Bevel
    _drawRoyalYard(canvas, cellSize, 0, 0, PlayerColor.green);
    _drawRoyalYard(canvas, cellSize, 9, 0, PlayerColor.yellow);
    _drawRoyalYard(canvas, cellSize, 0, 9, PlayerColor.red);
    _drawRoyalYard(canvas, cellSize, 9, 9, PlayerColor.blue);

    // 3. Draw Track Grid cells (Warm Acrylic Tiles)
    _drawTrackGrid(canvas, cellSize);

    // 4. Draw Illuminated Home Stretches
    _drawHomeStretches(canvas, cellSize);

    // 5. Draw Start Cells with Directional Golden Bevel Arrow
    _drawStartCell(canvas, cellSize, 1, 6, PlayerColor.green, 0); // pointing right
    _drawStartCell(canvas, cellSize, 8, 1, PlayerColor.yellow, pi / 2); // pointing down
    _drawStartCell(canvas, cellSize, 13, 8, PlayerColor.blue, pi); // pointing left
    _drawStartCell(canvas, cellSize, 6, 13, PlayerColor.red, -pi / 2); // pointing up

    // 6. Draw 8-Pointed Embossed Metallic Safe Stars
    _drawSafeStar(canvas, cellSize, 2, 8);  // Left arm safe star
    _drawSafeStar(canvas, cellSize, 6, 2);  // Top arm safe star
    _drawSafeStar(canvas, cellSize, 12, 6); // Right arm safe star
    _drawSafeStar(canvas, cellSize, 8, 12); // Bottom arm safe star

    // 7. Draw Crystalline Central Victory Vortex
    _drawCentralVictoryVortex(canvas, cellSize);

    // 8. Outer 24K Gilded Border Frame
    final Paint outerBorder = Paint()
      ..shader = AppColors.goldGradient.createShader(fullRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(fullRect.deflate(1.75), const Radius.circular(18)),
      outerBorder,
    );
  }

  void _drawRoyalYard(
    Canvas canvas,
    double cellSize,
    int startCol,
    int startRow,
    PlayerColor color,
  ) {
    final double left = startCol * cellSize;
    final double top = startRow * cellSize;
    final double yardSize = 6 * cellSize;
    final Rect yardRect = Rect.fromLTWH(left, top, yardSize, yardSize);

    // Yard Base Jewel Gradient
    final Paint yardPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.lightColor,
          color.primaryColor,
          color.primaryColor.withValues(alpha: 0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(yardRect);
    canvas.drawRect(yardRect, yardPaint);

    // 24K Gold Beveled Rim around Yard
    final Paint yardBorder = Paint()
      ..shader = AppColors.goldGradient.createShader(yardRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(yardRect, yardBorder);

    // Inner Warm Parchment Courtyard Box
    final double innerPadding = cellSize * 0.75;
    final Rect innerRect = Rect.fromLTWH(
      left + innerPadding,
      top + innerPadding,
      yardSize - (innerPadding * 2),
      yardSize - (innerPadding * 2),
    );
    final RRect innerRRect =
        RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.45));

    // Courtyard Fill
    canvas.drawRRect(
      innerRRect,
      Paint()..color = theme.boardBackground,
    );

    // Courtyard Inner Shadow & Bevel Border
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..color = color.primaryColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // 4 Token Pedestal Wells
    final double circleRadius = cellSize * 0.68;
    final List<Offset> centers = [
      Offset(left + 2.0 * cellSize, top + 2.0 * cellSize),
      Offset(left + 4.0 * cellSize, top + 2.0 * cellSize),
      Offset(left + 2.0 * cellSize, top + 4.0 * cellSize),
      Offset(left + 4.0 * cellSize, top + 4.0 * cellSize),
    ];

    for (final center in centers) {
      // Pedestal Drop Shadow
      canvas.drawCircle(
        center,
        circleRadius + 1.5,
        Paint()
          ..color = color.glowColor
          ..style = PaintingStyle.fill,
      );

      // Sunken Pedestal Base
      canvas.drawCircle(
        center,
        circleRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.black.withValues(alpha: 0.1),
              color.primaryColor.withValues(alpha: 0.25),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: circleRadius)),
      );

      // Metallic Ring
      canvas.drawCircle(
        center,
        circleRadius,
        Paint()
          ..color = color.primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  void _drawTrackGrid(Canvas canvas, double cellSize) {
    final Paint cellBorderPaint = Paint()
      ..color = theme.borderColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint cellBgPaint = Paint()..color = theme.trackColor;

    for (int col = 0; col < 15; col++) {
      for (int row = 0; row < 15; row++) {
        // Skip yard zones (6x6 corners) & central home (3x3)
        final bool inGreenYard = col < 6 && row < 6;
        final bool inYellowYard = col >= 9 && row < 6;
        final bool inRedYard = col < 6 && row >= 9;
        final bool inBlueYard = col >= 9 && row >= 9;
        final bool inCenter = (col >= 6 && col <= 8) && (row >= 6 && row <= 8);

        if (!inGreenYard && !inYellowYard && !inRedYard && !inBlueYard && !inCenter) {
          final Rect cellRect = Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          );
          final RRect cellRRect = RRect.fromRectAndRadius(
            cellRect.deflate(0.7),
            const Radius.circular(3.5),
          );

          canvas.drawRRect(cellRRect, cellBgPaint);
          canvas.drawRRect(cellRRect, cellBorderPaint);
        }
      }
    }
  }

  void _drawHomeStretches(Canvas canvas, double cellSize) {
    // Green Home Stretch: (row 7, col 1..5)
    _paintHomeStretchSegment(canvas, cellSize, 1, 5, 7, 7, PlayerColor.green);
    // Yellow Home Stretch: (col 7, row 1..5)
    _paintHomeStretchSegment(canvas, cellSize, 7, 7, 1, 5, PlayerColor.yellow);
    // Blue Home Stretch: (row 7, col 9..13)
    _paintHomeStretchSegment(canvas, cellSize, 9, 13, 7, 7, PlayerColor.blue);
    // Red Home Stretch: (col 7, row 9..13)
    _paintHomeStretchSegment(canvas, cellSize, 7, 7, 9, 13, PlayerColor.red);
  }

  void _paintHomeStretchSegment(
    Canvas canvas,
    double cellSize,
    int minCol,
    int maxCol,
    int minRow,
    int maxRow,
    PlayerColor color,
  ) {
    for (int col = minCol; col <= maxCol; col++) {
      for (int row = minRow; row <= maxRow; row++) {
        final Rect rect = Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize,
          cellSize,
        );
        final RRect rrect = RRect.fromRectAndRadius(
          rect.deflate(0.7),
          const Radius.circular(3.5),
        );

        // Radiant jewel fill
        final Paint stretchPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              color.lightColor,
              color.primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect);

        canvas.drawRRect(rrect, stretchPaint);

        // Subtle chevron direction marker
        final Paint markerPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        final Offset center = rect.center;
        canvas.drawCircle(center, cellSize * 0.15, markerPaint);
      }
    }
  }

  void _drawStartCell(
    Canvas canvas,
    double cellSize,
    int col,
    int row,
    PlayerColor color,
    double arrowAngle,
  ) {
    final Rect rect = Rect.fromLTWH(
      col * cellSize,
      row * cellSize,
      cellSize,
      cellSize,
    );
    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(0.7),
      const Radius.circular(3.5),
    );

    // Glowing Jewel Fill
    canvas.drawRRect(
      rrect,
      Paint()..shader = color.gradient.createShader(rect),
    );

    // Gold Border Highlight
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Directional Arrow pointing to track
    final Offset center = rect.center;
    final double arrowSize = cellSize * 0.28;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(arrowAngle);

    final Path arrowPath = Path()
      ..moveTo(arrowSize * 0.7, 0)
      ..lineTo(-arrowSize * 0.5, -arrowSize * 0.6)
      ..lineTo(-arrowSize * 0.2, 0)
      ..lineTo(-arrowSize * 0.5, arrowSize * 0.6)
      ..close();

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  void _drawSafeStar(Canvas canvas, double cellSize, int col, int row) {
    final Rect rect = Rect.fromLTWH(
      col * cellSize,
      row * cellSize,
      cellSize,
      cellSize,
    );
    final Offset center = rect.center;
    final double radius = cellSize * 0.4;

    // Glowing Ambient Halo behind star
    canvas.drawCircle(
      center,
      radius * 1.15,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // 8-Pointed Star Path
    final Path starPath = Path();
    const int points = 8;
    final double innerRadius = radius * 0.42;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? radius : innerRadius;
      final double angle = (i * pi / points) - (pi / 2);
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    // 24K Gold Fill
    canvas.drawPath(
      starPath,
      Paint()
        ..shader = AppColors.goldGradient.createShader(rect)
        ..style = PaintingStyle.fill,
    );

    // Shiny Specular Star Border
    canvas.drawPath(
      starPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawCentralVictoryVortex(Canvas canvas, double cellSize) {
    final double startX = 6 * cellSize;
    final double startY = 6 * cellSize;
    final double centerDim = 3 * cellSize;
    final Offset center = Offset(startX + centerDim / 2, startY + centerDim / 2);

    final Offset topLeft = Offset(startX, startY);
    final Offset topRight = Offset(startX + centerDim, startY);
    final Offset bottomLeft = Offset(startX, startY + centerDim);
    final Offset bottomRight = Offset(startX + centerDim, startY + centerDim);

    // Green (Left) Triangle
    _drawCrystalTriangle(canvas, topLeft, bottomLeft, center, PlayerColor.green);
    // Yellow (Top) Triangle
    _drawCrystalTriangle(canvas, topLeft, topRight, center, PlayerColor.yellow);
    // Blue (Right) Triangle
    _drawCrystalTriangle(canvas, topRight, bottomRight, center, PlayerColor.blue);
    // Red (Bottom) Triangle
    _drawCrystalTriangle(canvas, bottomLeft, bottomRight, center, PlayerColor.red);

    // Golden Star Crown Centerpiece
    canvas.drawCircle(
      center,
      cellSize * 0.45,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );

    canvas.drawCircle(
      center,
      cellSize * 0.38,
      Paint()
        ..shader = AppColors.goldShimmerGradient.createShader(
          Rect.fromCircle(center: center, radius: cellSize * 0.38),
        ),
    );

    canvas.drawCircle(
      center,
      cellSize * 0.38,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawCrystalTriangle(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Offset p3,
    PlayerColor color,
  ) {
    final Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    final Rect bounds = path.getBounds();
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.lightColor,
          color.primaryColor,
          color.primaryColor.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds);

    canvas.drawPath(path, fillPaint);

    // Crystal Shard Bevel Line
    final Paint bevelPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, bevelPaint);
  }

  @override
  bool shouldRepaint(covariant LuxeBoardPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
