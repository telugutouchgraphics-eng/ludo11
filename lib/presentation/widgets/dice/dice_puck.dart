import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/dice_skin.dart';
import '../../../models/player.dart';
import 'dice_engine_3d.dart';

class DicePuck extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;
  final int diceValue;
  final bool isRolling;
  final bool canRoll;
  final DiceSkinData diceSkin;
  final VoidCallback onRoll;

  const DicePuck({
    super.key,
    required this.player,
    required this.isCurrentTurn,
    required this.diceValue,
    required this.isRolling,
    required this.canRoll,
    this.diceSkin = DiceSkinData.classicIvory,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    final color = player.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentTurn ? color.primaryColor : Colors.white12,
          width: isCurrentTurn ? 2.5 : 1.0,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: color.glowColor,
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player Avatar with Level/Bot badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: color.gradient,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    player.isBot ? Icons.smart_toy_rounded : Icons.person_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              if (player.isBot)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.gold, width: 1),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),

          // Player Name & Finished Tokens Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.name,
                style: TextStyle(
                  color: isCurrentTurn ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight:
                      isCurrentTurn ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      index < player.finishedTokensCount
                          ? Icons.stars_rounded
                          : Icons.circle,
                      size: 10,
                      color: index < player.finishedTokensCount
                          ? AppColors.gold
                          : color.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // Tactile 3D Dice Box
          DiceEngine3D(
            value: diceValue,
            isRolling: isRolling && isCurrentTurn,
            primaryColor: color.primaryColor,
            skin: diceSkin,
            size: 46,
            onTap: canRoll ? onRoll : null,
          ),
        ],
      ),
    );
  }
}
