import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/dice_skin.dart';

/// Next-Generation Tactile 3D Dice with Isometric Multi-Face Projection,
/// Specular Lighting, Tumble Physics, and Dynamic Altitude Shadows.
class DiceEngine3D extends StatefulWidget {
  final int value; // 1..6
  final bool isRolling;
  final double size;
  final Color primaryColor;
  final DiceSkinData skin;
  final VoidCallback? onTap;

  const DiceEngine3D({
    super.key,
    required this.value,
    this.isRolling = false,
    this.size = 56.0,
    this.primaryColor = AppColors.gold,
    this.skin = DiceSkinData.classicIvory,
    this.onTap,
  });

  @override
  State<DiceEngine3D> createState() => _DiceEngine3DState();
}

class _DiceEngine3DState extends State<DiceEngine3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _displayValue = 1;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _animController.addListener(() {
      if (widget.isRolling && mounted) {
        setState(() {
          // Rapidly scramble faces during roll
          _displayValue = 1 + _random.nextInt(6);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant DiceEngine3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      HapticFeedback.lightImpact();
      _animController.repeat();
    } else if (!widget.isRolling && oldWidget.isRolling) {
      _animController.stop();
      _animController.reset();
      setState(() {
        _displayValue = widget.value;
      });
      HapticFeedback.mediumImpact();
    } else if (!widget.isRolling) {
      _displayValue = widget.value;
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
      onTap: () {
        if (widget.onTap != null) {
          SoundService.instance.playDiceRoll();
          widget.onTap!();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final double t = _animController.value;
          final double hopHeight = widget.isRolling ? sin(t * pi * 3) * 14.0 : 0.0;
          final double rotX = widget.isRolling ? sin(t * 2 * pi) * 0.45 : 0.0;
          final double rotY = widget.isRolling ? cos(t * 2 * pi) * 0.45 : 0.0;
          final double rotZ = widget.isRolling ? t * 2 * pi : 0.0;

          final double shadowScale = widget.isRolling
              ? 0.7 + 0.3 * (1.0 - (hopHeight / 14.0).abs())
              : 1.0;
          final double shadowOpacity = widget.isRolling
              ? 0.2 + 0.25 * (1.0 - (hopHeight / 14.0).abs())
              : 0.45;

          return SizedBox(
            width: widget.size * 1.3,
            height: widget.size * 1.3,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Dynamic Ground Drop Shadow (Scales with altitude)
                Positioned(
                  bottom: widget.size * 0.08,
                  child: Container(
                    width: widget.size * 0.85 * shadowScale,
                    height: widget.size * 0.35 * shadowScale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: shadowOpacity),
                          blurRadius: 8 + (hopHeight * 0.5),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. 3D Beveled Cube Body with Perspective Rotation
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002) // Perspective depth
                    ..multiply(Matrix4.translationValues(0.0, -hopHeight, 0.0))
                    ..rotateX(rotX)
                    ..rotateY(rotY)
                    ..rotateZ(rotZ * 0.3),
                  child: _buildDiceCube(widget.size, _displayValue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiceCube(double size, int value) {
    final skin = widget.skin;
    final double radius = size * 0.22;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: skin.bodyGradient,
        border: Border.all(
          color: skin.borderColor,
          width: 1.6,
        ),
        boxShadow: [
          // Specular Top-Left Bevel Highlight
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            offset: const Offset(-1.5, -1.5),
            blurRadius: 2,
          ),
          // Deep Bottom-Right Shadow Bevel
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(3.5, 4.5),
            blurRadius: 6,
          ),
          // Skin Ambient Glow
          BoxShadow(
            color: skin.glowColor,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Stack(
          children: [
            // Internal Cylindrical Specular Glint
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size * 0.42,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Pips Custom Canvas Drawing
            CustomPaint(
              size: Size(size, size),
              painter: _DicePipPainter(
                value: value,
                dotColor: skin.dotColor,
                primaryColor: widget.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canvas Painter for Jewel & Metallic Inset Pips
class _DicePipPainter extends CustomPainter {
  final int value;
  final Color dotColor;
  final Color primaryColor;

  _DicePipPainter({
    required this.value,
    required this.dotColor,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double pipRadius = size.width * 0.095;
    final double left = size.width * 0.26;
    final double center = size.width * 0.50;
    final double right = size.width * 0.74;
    final double top = size.height * 0.26;
    final double mid = size.height * 0.50;
    final double bottom = size.height * 0.74;

    switch (value) {
      case 1:
        // Large central jewel dot
        _drawInsetPip(canvas, Offset(center, mid), pipRadius * 1.35, isFeatured: true);
        break;
      case 2:
        _drawInsetPip(canvas, Offset(left, top), pipRadius);
        _drawInsetPip(canvas, Offset(right, bottom), pipRadius);
        break;
      case 3:
        _drawInsetPip(canvas, Offset(left, top), pipRadius);
        _drawInsetPip(canvas, Offset(center, mid), pipRadius);
        _drawInsetPip(canvas, Offset(right, bottom), pipRadius);
        break;
      case 4:
        _drawInsetPip(canvas, Offset(left, top), pipRadius);
        _drawInsetPip(canvas, Offset(right, top), pipRadius);
        _drawInsetPip(canvas, Offset(left, bottom), pipRadius);
        _drawInsetPip(canvas, Offset(right, bottom), pipRadius);
        break;
      case 5:
        _drawInsetPip(canvas, Offset(left, top), pipRadius);
        _drawInsetPip(canvas, Offset(right, top), pipRadius);
        _drawInsetPip(canvas, Offset(center, mid), pipRadius, isFeatured: true);
        _drawInsetPip(canvas, Offset(left, bottom), pipRadius);
        _drawInsetPip(canvas, Offset(right, bottom), pipRadius);
        break;
      case 6:
        _drawInsetPip(canvas, Offset(left, top), pipRadius, isFeatured: true);
        _drawInsetPip(canvas, Offset(right, top), pipRadius, isFeatured: true);
        _drawInsetPip(canvas, Offset(left, mid), pipRadius, isFeatured: true);
        _drawInsetPip(canvas, Offset(right, mid), pipRadius, isFeatured: true);
        _drawInsetPip(canvas, Offset(left, bottom), pipRadius, isFeatured: true);
        _drawInsetPip(canvas, Offset(right, bottom), pipRadius, isFeatured: true);
        break;
    }
  }

  void _drawInsetPip(Canvas canvas, Offset offset, double radius, {bool isFeatured = false}) {
    // 1. Inset Rim Ambient Occlusion
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawCircle(offset.translate(0.5, 0.8), radius, shadowPaint);

    // 2. 3D Pip Fill with Spherical Radial Gradient
    final Rect pipRect = Rect.fromCircle(center: offset, radius: radius);
    final Color baseColor = isFeatured ? primaryColor : dotColor;

    final Paint pipPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.9,
        colors: [
          Colors.white,
          baseColor,
          baseColor.withValues(alpha: 0.85),
          Colors.black.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.3, 0.75, 1.0],
      ).createShader(pipRect);

    canvas.drawCircle(offset, radius, pipPaint);

    // 3. Specular Glint Highlight on Top-Left
    final Paint glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(
      offset.translate(-radius * 0.32, -radius * 0.32),
      radius * 0.28,
      glintPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DicePipPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.primaryColor != primaryColor;
  }
}
