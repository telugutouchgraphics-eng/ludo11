import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SpinReward {
  final int coins;
  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isJackpot;

  const SpinReward({
    required this.coins,
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
    this.isJackpot = false,
  });
}

class SpinWheelPainter extends CustomPainter {
  final List<SpinReward> rewards;

  const SpinWheelPainter({required this.rewards});

  static const List<SpinReward> defaultRewards = [
    SpinReward(
      coins: 50,
      label: '+50',
      primaryColor: Color(0xFF2E7D32),
      secondaryColor: Color(0xFF66BB6A),
    ),
    SpinReward(
      coins: 100,
      label: '+100',
      primaryColor: Color(0xFF512DA8),
      secondaryColor: Color(0xFF7E57C2),
    ),
    SpinReward(
      coins: 150,
      label: '+150',
      primaryColor: Color(0xFF1565C0),
      secondaryColor: Color(0xFF42A5F5),
    ),
    SpinReward(
      coins: 75,
      label: '+75',
      primaryColor: Color(0xFFE65100),
      secondaryColor: Color(0xFFFFA726),
    ),
    SpinReward(
      coins: 200,
      label: '+200',
      primaryColor: Color(0xFFC2185B),
      secondaryColor: Color(0xFFEC407A),
    ),
    SpinReward(
      coins: 100,
      label: '+100',
      primaryColor: Color(0xFFC62828),
      secondaryColor: Color(0xFFEF5350),
    ),
    SpinReward(
      coins: 250,
      label: '+250',
      primaryColor: Color(0xFF00838F),
      secondaryColor: Color(0xFF26C6DA),
    ),
    SpinReward(
      coins: 500,
      label: '500 👑',
      primaryColor: Color(0xFFFF8F00),
      secondaryColor: Color(0xFFFFD54F),
      isJackpot: true,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final int count = rewards.length;
    final double sweepAngle = 2 * pi / count;

    // Outer Golden Ring with Rim Shadow
    final Paint rimPaint = Paint()
      ..color = AppColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius - 5, rimPaint);

    final Paint innerRim = Paint()
      ..color = AppColors.goldLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 8, innerRim);

    // Draw Slices
    for (int i = 0; i < count; i++) {
      final reward = rewards[i];
      final double startAngle = (i * sweepAngle) - (pi / 2);

      final Path slicePath = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius - 10),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      final Paint slicePaint = Paint()
        ..shader = LinearGradient(
          colors: [reward.primaryColor, reward.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawPath(slicePath, slicePaint);

      // Slice separator lines
      final Paint linePaint = Paint()
        ..color = AppColors.goldLight.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(slicePath, linePaint);

      // Draw Reward Text inside the slice
      canvas.save();
      canvas.translate(center.dx, center.dy);
      final double textAngle = startAngle + (sweepAngle / 2);
      canvas.rotate(textAngle);

      final textSpan = TextSpan(
        text: reward.label,
        style: TextStyle(
          color: reward.isJackpot ? Colors.black : Colors.white,
          fontSize: reward.isJackpot ? 15 : 13,
          fontWeight: FontWeight.w900,
          shadows: reward.isJackpot
              ? []
              : const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Position text along the wedge radius
      textPainter.paint(
        canvas,
        Offset(radius * 0.52, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Outer Decorative Golden Bulbs
    final double bulbRadius = radius - 5;
    for (int i = 0; i < count * 2; i++) {
      final double angle = i * (pi / count);
      final double bx = center.dx + bulbRadius * cos(angle);
      final double by = center.dy + bulbRadius * sin(angle);

      canvas.drawCircle(
        Offset(bx, by),
        3.5,
        Paint()..color = i.isEven ? Colors.white : AppColors.gold,
      );
    }

    // Center Gold Cap
    canvas.drawCircle(
      center,
      22,
      Paint()..color = AppColors.goldDark,
    );
    canvas.drawCircle(
      center,
      18,
      Paint()
        ..shader = AppColors.goldGradient.createShader(
          Rect.fromCircle(center: center, radius: 18),
        ),
    );
    canvas.drawCircle(
      center,
      8,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant SpinWheelPainter oldDelegate) {
    return oldDelegate.rewards != rewards;
  }
}
