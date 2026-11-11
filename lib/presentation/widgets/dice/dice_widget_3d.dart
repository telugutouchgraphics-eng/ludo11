import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/dice_skin.dart';

class ThreeDDiceWidget extends StatefulWidget {
  final int value; // 1..6
  final bool isRolling;
  final double size;
  final Color primaryColor;
  final DiceSkinData skin;
  final VoidCallback? onTap;

  const ThreeDDiceWidget({
    super.key,
    required this.value,
    this.isRolling = false,
    this.size = 56.0,
    this.primaryColor = AppColors.gold,
    this.skin = DiceSkinData.classicIvory,
    this.onTap,
  });

  @override
  State<ThreeDDiceWidget> createState() => _ThreeDDiceWidgetState();
}

class _ThreeDDiceWidgetState extends State<ThreeDDiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant ThreeDDiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _animController.repeat();
    } else if (!widget.isRolling && oldWidget.isRolling) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final double angle =
              widget.isRolling ? _animController.value * 2 * pi * 2 : 0.0;
          final double scale = widget.isRolling
              ? 0.9 + 0.1 * sin(_animController.value * pi * 4)
              : 1.0;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scale, scale, 1.0)
              ..rotateZ(angle * 0.5),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.size * 0.22),
                gradient: widget.skin.bodyGradient,
                boxShadow: [
                  BoxShadow(
                    color: (widget.skin.id == 'classic_ivory'
                            ? widget.primaryColor
                            : widget.skin.glowColor)
                        .withValues(alpha: 0.55),
                    blurRadius: 10,
                    spreadRadius: 1.5,
                    offset: const Offset(0, 4),
                  ),
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: widget.skin.id == 'classic_ivory'
                      ? widget.primaryColor
                      : widget.skin.borderColor,
                  width: 2.2,
                ),
              ),
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _DiceFacePainter(
                  value: widget.value,
                  dotColor: widget.skin.id == 'classic_ivory'
                      ? widget.primaryColor
                      : widget.skin.dotColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  final int value;
  final Color dotColor;

  _DiceFacePainter({required this.value, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width * 0.088;
    final Paint dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final Paint dotShadow = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.fill;

    // Relative coordinates
    final double left = size.width * 0.26;
    final double center = size.width * 0.50;
    final double right = size.width * 0.74;

    final double top = size.height * 0.26;
    final double middle = size.height * 0.50;
    final double bottom = size.height * 0.74;

    void drawPip(double x, double y) {
      // 3D subtle depth shadow
      canvas.drawCircle(Offset(x, y + 1.0), radius, dotShadow);
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
      // Specular shine
      canvas.drawCircle(
        Offset(x - radius * 0.3, y - radius * 0.3),
        radius * 0.35,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }

    switch (value) {
      case 1:
        drawPip(center, middle);
        break;
      case 2:
        drawPip(left, top);
        drawPip(right, bottom);
        break;
      case 3:
        drawPip(left, top);
        drawPip(center, middle);
        drawPip(right, bottom);
        break;
      case 4:
        drawPip(left, top);
        drawPip(right, top);
        drawPip(left, bottom);
        drawPip(right, bottom);
        break;
      case 5:
        drawPip(left, top);
        drawPip(right, top);
        drawPip(center, middle);
        drawPip(left, bottom);
        drawPip(right, bottom);
        break;
      case 6:
        drawPip(left, top);
        drawPip(right, top);
        drawPip(left, middle);
        drawPip(right, middle);
        drawPip(left, bottom);
        drawPip(right, bottom);
        break;
      default:
        drawPip(center, middle);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.dotColor != dotColor;
  }
}
