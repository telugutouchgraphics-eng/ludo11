import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/mission_manager.dart';
import '../../../models/daily_mission.dart';
import '../../../models/user_profile.dart';
import '../custom_game_button.dart';

class DailyMissionsDialog extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onUpdated;

  const DailyMissionsDialog({
    super.key,
    required this.userProfile,
    required this.onUpdated,
  });

  @override
  State<DailyMissionsDialog> createState() => _DailyMissionsDialogState();
}

class _DailyMissionsDialogState extends State<DailyMissionsDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _claim(DailyMission mission) {
    final success =
        MissionManager.instance.claimReward(mission, widget.userProfile);
    if (success) {
      SoundService.instance.playVictory();
      _confettiController.play();
      widget.onUpdated();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final missions = MissionManager.instance.missions;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [AppColors.gold, AppColors.accentNeon, Colors.white],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_rounded,
                            color: AppColors.gold, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'DAILY MISSIONS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Mission Cards
                ...missions.map((mission) => _buildMissionCard(mission)),

                const SizedBox(height: 16),
                CustomGameButton(
                  text: 'CLOSE',
                  gradient: AppColors.cardGradient,
                  height: 46,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(DailyMission mission) {
    final isDone = mission.isCompleted;
    final isClaimed = mission.isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone && !isClaimed
              ? AppColors.gold
              : Colors.white.withValues(alpha: 0.1),
          width: isDone && !isClaimed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mission.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppColors.gold, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    '+${mission.rewardCoins}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.bolt,
                      color: AppColors.accentNeon, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    '+${mission.rewardXp}',
                    style: const TextStyle(
                      color: AppColors.accentNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            mission.description,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: mission.progressPercentage,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? AppColors.greenPrimary : AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mission.currentProgress} / ${mission.target}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isClaimed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'CLAIMED',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isDone)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _claim(mission),
                  child: const Text(
                    'CLAIM',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
