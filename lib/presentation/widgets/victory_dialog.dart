import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/player.dart';
import 'custom_game_button.dart';

class VictoryDialog extends StatefulWidget {
  final Player winner;
  final List<Player> leaderboard;
  final int earnedCoins;
  final int earnedXp;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const VictoryDialog({
    super.key,
    required this.winner,
    required this.leaderboard,
    required this.earnedCoins,
    required this.earnedXp,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti blaster
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.gold,
                AppColors.redPrimary,
                AppColors.greenPrimary,
                AppColors.bluePrimary,
                AppColors.yellowPrimary,
              ],
            ),
          ),

          // Main Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy / Crown Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Victory Header
                const Text(
                  'VICTORY!',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.winner.name} won the match!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                // Rewards pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: AppColors.gold, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.earnedCoins} Coins',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.bolt,
                          color: AppColors.accentNeon, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.earnedXp} XP',
                        style: const TextStyle(
                          color: AppColors.accentNeon,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                CustomGameButton(
                  text: 'PLAY AGAIN',
                  icon: Icons.replay_rounded,
                  gradient: AppColors.greenGradient,
                  onPressed: widget.onPlayAgain,
                ),
                const SizedBox(height: 12),
                CustomGameButton(
                  text: 'MAIN MENU',
                  icon: Icons.home_rounded,
                  gradient: AppColors.blueGradient,
                  onPressed: widget.onHome,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
