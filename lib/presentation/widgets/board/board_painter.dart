import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/board_theme.dart';
import '../../../models/player_color.dart';

class BoardPainter extends CustomPainter {
  final BoardThemeData theme;

  BoardPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 15.0;

    // 1. Draw Board Background
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint bgPaint = Paint()..color = theme.boardBackground;
    canvas.drawRect(fullRect, bgPaint);

    // 2. Draw 4 Yards (6x6 cells each)
    _drawYard(canvas, cellSize, 0, 0, PlayerColor.green);
    _drawYard(canvas, cellSize, 9, 0, PlayerColor.yellow);
    _drawYard(canvas, cellSize, 0, 9, PlayerColor.red);
    _drawYard(canvas, cellSize, 9, 9, PlayerColor.blue);

    // 3. Draw Track Grid cells (Columns and Rows)
    _drawTrackGrid(canvas, cellSize);

    // 4. Draw Home Stretches
    _drawHomeStretches(canvas, cellSize);

    // 5. Draw Start Cells
    _drawStartCell(canvas, cellSize, 1, 6, PlayerColor.green);
    _drawStartCell(canvas, cellSize, 8, 1, PlayerColor.yellow);
    _drawStartCell(canvas, cellSize, 13, 8, PlayerColor.blue);
    _drawStartCell(canvas, cellSize, 6, 13, PlayerColor.red);

    // 6. Draw Safe Stars
    _drawSafeStar(canvas, cellSize, 2, 8);  // Left arm safe star
    _drawSafeStar(canvas, cellSize, 6, 2);  // Top arm safe star
    _drawSafeStar(canvas, cellSize, 12, 6); // Right arm safe star
    _drawSafeStar(canvas, cellSize, 8, 12); // Bottom arm safe star

    // 7. Draw Central Home Triangle
    _drawHomeTriangles(canvas, cellSize);

    // 8. Outer Board Border
    final Paint borderPaint = Paint()
      ..color = theme.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(fullRect, borderPaint);
  }

  void _drawYard(
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

    // Outer Yard Fill
    final Paint yardPaint = Paint()
      ..shader = color.gradient.createShader(yardRect);
    canvas.drawRect(yardRect, yardPaint);

    // Yard Inner White Box with Rounded corners
    final double innerPadding = cellSize * 0.8;
    final Rect innerRect = Rect.fromLTWH(
      left + innerPadding,
      top + innerPadding,
      yardSize - (innerPadding * 2),
      yardSize - (innerPadding * 2),
    );
    final Paint innerPaint = Paint()..color = theme.boardBackground;
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.5)),
      innerPaint,
    );

    // Inner Border
    final Paint innerBorder = Paint()
      ..color = color.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.5)),
      innerBorder,
    );

    // 4 Token circles inside yard
    final double circleRadius = cellSize * 0.65;
    final List<Offset> centers = [
      Offset(left + 2.0 * cellSize, top + 2.0 * cellSize),
      Offset(left + 4.0 * cellSize, top + 2.0 * cellSize),
      Offset(left + 2.0 * cellSize, top + 4.0 * cellSize),
      Offset(left + 4.0 * cellSize, top + 4.0 * cellSize),
    ];

    for (final center in centers) {
      // Glow / Shadow ring
      canvas.drawCircle(
        center,
        circleRadius + 2.0,
        Paint()
          ..color = color.glowColor
          ..style = PaintingStyle.fill,
      );
      // Colored Circle
      canvas.drawCircle(
        center,
        circleRadius,
        Paint()
          ..shader = color.gradient.createShader(
            Rect.fromCircle(center: center, radius: circleRadius),
          ),
      );
      // Inner subtle highlight
      canvas.drawCircle(
        center,
        circleRadius * 0.5,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }

    // Yard Outer Border
    final Paint yardBorderPaint = Paint()
      ..color = theme.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(yardRect, yardBorderPaint);
  }

  void _drawTrackGrid(Canvas canvas, double cellSize) {
    final Paint gridLinePaint = Paint()
      ..color = theme.borderColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Track cell areas:
    // Top arm: cols 6..8, rows 0..5
    // Bottom arm: cols 6..8, rows 9..14
    // Left arm: cols 0..5, rows 6..8
    // Right arm: cols 9..14, rows 6..8
    for (int col = 0; col < 15; col++) {
      for (int row = 0; row < 15; row++) {
        final bool isYard = (col < 6 && row < 6) ||
            (col > 8 && row < 6) ||
            (col < 6 && row > 8) ||
            (col > 8 && row > 8);
        final bool isCenter = (col >= 6 && col <= 8) && (row >= 6 && row <= 8);

        if (!isYard && !isCenter) {
          final Rect cellRect = Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          );
          canvas.drawRect(cellRect, gridLinePaint);
        }
      }
    }
  }

  void _drawHomeStretches(Canvas canvas, double cellSize) {
    // Green Home Stretch: cols 1..5, row 7
    for (int c = 1; c <= 5; c++) {
      _drawFilledCell(canvas, cellSize, c, 7, PlayerColor.green);
    }
    // Yellow Home Stretch: col 7, rows 1..5
    for (int r = 1; r <= 5; r++) {
      _drawFilledCell(canvas, cellSize, 7, r, PlayerColor.yellow);
    }
    // Blue Home Stretch: cols 9..13, row 7
    for (int c = 9; c <= 13; c++) {
      _drawFilledCell(canvas, cellSize, c, 7, PlayerColor.blue);
    }
    // Red Home Stretch: col 7, rows 9..13
    for (int r = 9; r <= 13; r++) {
      _drawFilledCell(canvas, cellSize, 7, r, PlayerColor.red);
    }
  }

  void _drawStartCell(
    Canvas canvas,
    double cellSize,
    int col,
    int row,
    PlayerColor color,
  ) {
    _drawFilledCell(canvas, cellSize, col, row, color);

    // Draw an elegant arrow pointing into track
    final double cx = (col + 0.5) * cellSize;
    final double cy = (row + 0.5) * cellSize;
    final double arrowSize = cellSize * 0.3;

    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();
    if (color == PlayerColor.green) {
      // Points right
      path.moveTo(cx - arrowSize * 0.6, cy - arrowSize);
      path.lineTo(cx + arrowSize * 0.8, cy);
      path.lineTo(cx - arrowSize * 0.6, cy + arrowSize);
    } else if (color == PlayerColor.yellow) {
      // Points down
      path.moveTo(cx - arrowSize, cy - arrowSize * 0.6);
      path.lineTo(cx, cy + arrowSize * 0.8);
      path.lineTo(cx + arrowSize, cy - arrowSize * 0.6);
    } else if (color == PlayerColor.blue) {
      // Points left
      path.moveTo(cx + arrowSize * 0.6, cy - arrowSize);
      path.lineTo(cx - arrowSize * 0.8, cy);
      path.lineTo(cx + arrowSize * 0.6, cy + arrowSize);
    } else {
      // Points up (Red)
      path.moveTo(cx - arrowSize, cy + arrowSize * 0.6);
      path.lineTo(cx, cy - arrowSize * 0.8);
      path.lineTo(cx + arrowSize, cy + arrowSize * 0.6);
    }
    path.close();
    canvas.drawPath(path, arrowPaint);
  }

  void _drawFilledCell(
    Canvas canvas,
    double cellSize,
    int col,
    int row,
    PlayerColor color,
  ) {
    final Rect rect = Rect.fromLTWH(
      col * cellSize,
      row * cellSize,
      cellSize,
      cellSize,
    );
    final Paint fill = Paint()..shader = color.gradient.createShader(rect);
    canvas.drawRect(rect, fill);

    final Paint border = Paint()
      ..color = theme.borderColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, border);
  }

  void _drawSafeStar(Canvas canvas, double cellSize, int col, int row) {
    final double cx = (col + 0.5) * cellSize;
    final double cy = (row + 0.5) * cellSize;
    final double outerR = cellSize * 0.40;
    final double innerR = outerR * 0.45;

    final Path starPath = Path();
    for (int i = 0; i < 5; i++) {
      final double outerAngle = -pi / 2 + (i * 2 * pi / 5);
      final double innerAngle = outerAngle + pi / 5;

      final double ox = cx + outerR * cos(outerAngle);
      final double oy = cy + outerR * sin(outerAngle);
      if (i == 0) {
        starPath.moveTo(ox, oy);
      } else {
        starPath.lineTo(ox, oy);
      }

      final double ix = cx + innerR * cos(innerAngle);
      final double iy = cy + innerR * sin(innerAngle);
      starPath.lineTo(ix, iy);
    }
    starPath.close();

    // Golden Star Fill & Outline
    canvas.drawPath(
      starPath,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      starPath,
      Paint()
        ..color = AppColors.goldDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawHomeTriangles(Canvas canvas, double cellSize) {
    final double centerLeft = 6 * cellSize;
    final double centerTop = 6 * cellSize;
    final double centerSize = 3 * cellSize;

    final Offset center = Offset(
      centerLeft + centerSize / 2,
      centerTop + centerSize / 2,
    );
    final Offset topLeft = Offset(centerLeft, centerTop);
    final Offset topRight = Offset(centerLeft + centerSize, centerTop);
    final Offset bottomLeft = Offset(centerLeft, centerTop + centerSize);
    final Offset bottomRight = Offset(
      centerLeft + centerSize,
      centerTop + centerSize,
    );

    // Left Triangle: Green
    final Path greenPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      greenPath,
      Paint()..shader = PlayerColor.green.gradient.createShader(greenPath.getBounds()),
    );

    // Top Triangle: Yellow
    final Path yellowPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      yellowPath,
      Paint()..shader = PlayerColor.yellow.gradient.createShader(yellowPath.getBounds()),
    );

    // Right Triangle: Blue
    final Path bluePath = Path()
      ..moveTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      bluePath,
      Paint()..shader = PlayerColor.blue.gradient.createShader(bluePath.getBounds()),
    );

    // Bottom Triangle: Red
    final Path redPath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      redPath,
      Paint()..shader = PlayerColor.red.gradient.createShader(redPath.getBounds()),
    );

    // Center Golden Circle Emblem
    final Paint centerCirclePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, cellSize * 0.45, centerCirclePaint);

    final Paint centerRingPaint = Paint()
      ..color = AppColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, cellSize * 0.45, centerRingPaint);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
