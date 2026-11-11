import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/audio/sound_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_color.dart';
import '../../models/token.dart';
import '../../models/user_profile.dart';
import '../widgets/board/sculpted_pawn_widget.dart';
import '../widgets/dice/dice_engine_3d.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Warm, emotional, premium LUDO1 Animated Splash Screen
/// Features central 3D rolling dice, orbiting tokens, friendly particles, and audio chime
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _soundMuted = false;

  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    final profile = await UserProfile.load();
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('has_completed_onboarding_v2') ?? false;

    if (!_soundMuted) {
      SoundService.instance.playGameStart();
    }

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    if (!hasOnboarded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(userProfile: profile),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userProfile: profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF381534), // Soft Plum
              Color(0xFF1E1738), // Electric Purple Twilight
              AppColors.backgroundDark, // Deep Navy
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Mute Audio Option on Top-Right
              Positioned(
                top: 12,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    _soundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white54,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _soundMuted = !_soundMuted),
                ),
              ),

              // Central Celebratory Hub
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emblem Stage with Orbiting Tokens & 3D Dice
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft Ambient Pulse
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.coralPink.withValues(alpha: 0.35),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),

                          // Central 3D Dice with Specular Highlights
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.warmPeach.withValues(alpha: 0.4), width: 1.5),
                            ),
                            child: const DiceEngine3D(
                              value: 6,
                              primaryColor: AppColors.warmGold,
                              size: 64,
                            ),
                          )
                              .animate()
                              .scale(duration: 800.ms, curve: Curves.easeOutBack)
                              .shimmer(delay: 700.ms, duration: 1000.ms),

                          // Orbiting Token 1: Red (Top Left)
                          Positioned(
                            top: 14,
                            left: 20,
                            child: SculptedPawnWidget(
                              token: Token(id: 0, color: PlayerColor.red),
                              size: 34,
                            ).animate().scale(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutBack),
                          ),

                          // Orbiting Token 2: Green (Top Right)
                          Positioned(
                            top: 14,
                            right: 20,
                            child: SculptedPawnWidget(
                              token: Token(id: 1, color: PlayerColor.green),
                              size: 34,
                            ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutBack),
                          ),

                          // Orbiting Token 3: Yellow (Bottom Right)
                          Positioned(
                            bottom: 14,
                            right: 20,
                            child: SculptedPawnWidget(
                              token: Token(id: 2, color: PlayerColor.yellow),
                              size: 34,
                            ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutBack),
                          ),

                          // Orbiting Token 4: Blue (Bottom Left)
                          Positioned(
                            bottom: 14,
                            left: 20,
                            child: SculptedPawnWidget(
                              token: Token(id: 3, color: PlayerColor.blue),
                              size: 34,
                            ).animate().scale(delay: 600.ms, duration: 500.ms, curve: Curves.easeOutBack),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Brand Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'LUDO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.coralPink, AppColors.softPink],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 350.ms).moveY(begin: 14, end: 0),

                    const SizedBox(height: 6),

                    // Emotional Tagline
                    const Text(
                      'PLAY • CONNECT • CELEBRATE',
                      style: TextStyle(
                        color: AppColors.warmPeach,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.5,
                      ),
                    ).animate().fadeIn(delay: 550.ms),

                    const SizedBox(height: 40),

                    // Friendly Loading Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.coralPink),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Entering LUDO1 Sanctuary...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 750.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
