import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/token_skin.dart';
import '../../../models/token.dart';

/// Sculpted 3D Pawn Widget with Multi-Layered Anatomy:
/// Weighted Metallic Pedestal, Glossy Jewel Body, Ambient Drop Shadow,
/// and Continuous Floating Pulse when Movable.
class SculptedPawnWidget extends StatefulWidget {
  final Token token;
  final double size;
  final bool isMovable;
  final TokenSkinData skin;
  final VoidCallback? onTap;

  const SculptedPawnWidget({
    super.key,
    required this.token,
    required this.size,
    this.isMovable = false,
    this.skin = TokenSkinData.classicPawn,
    this.onTap,
  });

  @override
  State<SculptedPawnWidget> createState() => _SculptedPawnWidgetState();
}

class _SculptedPawnWidgetState extends State<SculptedPawnWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (widget.isMovable) {
      _hoverController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SculptedPawnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMovable && !oldWidget.isMovable) {
      _hoverController.repeat(reverse: true);
    } else if (!widget.isMovable && oldWidget.isMovable) {
      _hoverController.stop();
      _hoverController.reset();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.token.color;
    final double size = widget.size;

    return GestureDetector(
      onTap: widget.isMovable ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            final double hoverOffset =
                widget.isMovable ? sin(_hoverController.value * pi) * -4.0 : 0.0;
            final double auraScale =
                widget.isMovable ? 1.05 + (_hoverController.value * 0.15) : 1.0;

            return SizedBox(
              width: size * 1.25,
              height: size * 1.25,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 1. Ground Drop Shadow (Stays anchored to cell base)
                  Positioned(
                    bottom: size * 0.1,
                    child: Container(
                      width: size * 0.82 * (widget.isMovable ? 0.85 : 1.0),
                      height: size * 0.38 * (widget.isMovable ? 0.85 : 1.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: widget.isMovable ? 0.3 : 0.45,
                            ),
                            blurRadius: widget.isMovable ? 6 : 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Pulsing Golden Energy Ring (When Movable)
                  if (widget.isMovable)
                    Positioned(
                      top: hoverOffset,
                      child: Container(
                        width: size * auraScale,
                        height: size * auraScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.8),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.7),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3. 3D Sculpted Pawn Body
                  Positioned(
                    top: hoverOffset,
                    child: Container(
                      width: size * 0.86,
                      height: size * 0.86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.isMovable
                            ? AppColors.goldGradient
                            : widget.skin.rimGradient,
                        border: Border.all(
                          color: widget.isMovable
                              ? AppColors.goldDark
                              : Colors.white70,
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.glowColor,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            offset: const Offset(0, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        // Inner Jewel Core
                        child: Container(
                          width: size * 0.64,
                          height: size * 0.64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(-0.35, -0.35),
                              radius: 0.9,
                              colors: [
                                color.lightColor,
                                color.primaryColor,
                                color.primaryColor.withValues(alpha: 0.85),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: const [0.0, 0.4, 0.75, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              widget.skin.insigniaIcon,
                              color: Colors.white,
                              size: size * 0.34,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Glossy Specular Glint Top Arc
                  Positioned(
                    top: hoverOffset + (size * 0.22),
                    child: Container(
                      width: size * 0.45,
                      height: size * 0.16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.2),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.6),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
