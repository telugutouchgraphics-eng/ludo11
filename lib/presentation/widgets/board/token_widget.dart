import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/token_skin.dart';
import '../../../models/token.dart';

class TokenWidget extends StatelessWidget {
  final Token token;
  final double size;
  final bool isMovable;
  final TokenSkinData skin;
  final VoidCallback? onTap;

  const TokenWidget({
    super.key,
    required this.token,
    required this.size,
    this.isMovable = false,
    this.skin = TokenSkinData.classicPawn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = token.color;

    return GestureDetector(
      onTap: isMovable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Pulsing Ring if Movable
              if (isMovable)
                Container(
                  width: size * 1.15,
                  height: size * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // Token Base Drop Shadow
              Container(
                width: size * 0.88,
                height: size * 0.88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),

              // Outer Golden / Metallic Rim
              Container(
                width: size * 0.85,
                height: size * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isMovable
                      ? AppColors.goldGradient
                      : skin.rimGradient,
                  border: Border.all(
                    color: isMovable ? AppColors.goldDark : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
              ),

              // Primary Player Color Body
              Container(
                width: size * 0.65,
                height: size * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: color.gradient,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.2,
                  ),
                ),
              ),

              // 3D Glass / Dome Highlight
              Positioned(
                top: size * 0.22,
                left: size * 0.26,
                child: Container(
                  width: size * 0.22,
                  height: size * 0.14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(size * 0.22, size * 0.14),
                    ),
                  ),
                ),
              ),

              // Center Crown, Shield, or Arrow Icon
              if (isMovable)
                Icon(
                  skin.insigniaIcon,
                  color: Colors.white,
                  size: size * 0.35,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
