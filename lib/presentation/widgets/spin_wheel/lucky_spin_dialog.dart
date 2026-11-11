import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_profile.dart';
import '../custom_game_button.dart';
import 'spin_wheel_painter.dart';

class LuckySpinDialog extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onClaimed;

  const LuckySpinDialog({
    super.key,
    required this.userProfile,
    required this.onClaimed,
  });

  @override
  State<LuckySpinDialog> createState() => _LuckySpinDialogState();
}

class _LuckySpinDialogState extends State<LuckySpinDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  late ConfettiController _confettiController;

  final List<SpinReward> _rewards = SpinWheelPainter.defaultRewards;
  bool _isSpinning = false;
  SpinReward? _wonReward;
  double _currentAngle = 0.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || !widget.userProfile.canSpinToday) return;

    setState(() {
      _isSpinning = true;
      _wonReward = null;
    });

    SoundService.instance.playDiceRoll();

    // Pick winning slice randomly
    final int winIndex = _random.nextInt(_rewards.length);
    final selectedReward = _rewards[winIndex];

    // Calculate rotation angle to align chosen wedge with top pointer (-pi/2)
    final double sweep = 2 * pi / _rewards.length;
    // Each slice center is at winIndex * sweep + sweep / 2 - pi / 2
    // To bring this to pointer at top (-pi / 2), we rotate the wheel
    final double targetSliceAngle = (winIndex * sweep) + (sweep / 2);
    final double extraSpins = (5 + _random.nextInt(3)) * 2 * pi;
    final double totalTarget =
        _currentAngle + extraSpins + (2 * pi - targetSliceAngle);

    _animation = Tween<double>(begin: _currentAngle, end: totalTarget).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCirc,
      ),
    );

    _animController.forward(from: 0.0).then((_) {
      _currentAngle = totalTarget % (2 * pi);
      setState(() {
        _isSpinning = false;
        _wonReward = selectedReward;
      });

      widget.userProfile.claimSpinReward(selectedReward.coins);
      widget.onClaimed();

      SoundService.instance.playVictory();
      _confettiController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = widget.userProfile.canSpinToday;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.gold,
                AppColors.accentNeon,
                AppColors.redPrimary,
                AppColors.greenPrimary,
                Colors.purple,
              ],
            ),
          ),

          // Main Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 24,
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
                        Icon(Icons.stars_rounded,
                            color: AppColors.gold, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'DAILY LUCKY SPIN',
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

                const SizedBox(height: 4),

                // Streak pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Colors.orangeAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Day ${widget.userProfile.loginStreak} Streak Bonus',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // The Wheel & Pointer
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Wheel
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          final angle =
                              _isSpinning ? _animation.value : _currentAngle;
                          return Transform.rotate(
                            angle: angle,
                            child: const CustomPaint(
                              size: Size(240, 240),
                              painter: SpinWheelPainter(
                                rewards: SpinWheelPainter.defaultRewards,
                              ),
                            ),
                          );
                        },
                      ),

                      // Top Golden Pointer
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 24,
                          height: 32,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: _WheelPointerPainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Won Reward Announcement
                if (_wonReward != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gold, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on,
                              color: AppColors.gold, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'You Won +${_wonReward!.coins} Coins!',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Action Button
                if (canSpin && _wonReward == null)
                  CustomGameButton(
                    text: _isSpinning ? 'SPINNING...' : 'SPIN FOR FREE',
                    icon: Icons.refresh_rounded,
                    gradient: AppColors.goldGradient,
                    onPressed: _spin,
                  )
                else
                  CustomGameButton(
                    text: _wonReward != null ? 'CLAIM & CLOSE' : 'COME BACK TOMORROW',
                    icon: Icons.check_circle_rounded,
                    gradient: _wonReward != null
                        ? AppColors.greenGradient
                        : AppColors.cardGradient,
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final Paint fill = Paint()..color = AppColors.gold;
    final Paint border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
