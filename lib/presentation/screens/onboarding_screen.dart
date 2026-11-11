import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_profile.dart';
import 'main_social_shell.dart';

/// 3 Beautiful Onboarding Screens introducing LUDO1
/// "Play Together", "Meet Your People", "Make Every Moment Fun"
class OnboardingScreen extends StatefulWidget {
  final UserProfile userProfile;

  const OnboardingScreen({super.key, required this.userProfile});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'badge': 'CASUAL & JOYFUL',
      'title': 'Play Together',
      'subtitle':
          'Experience traditional Ludo reimagined with tactile 3D dice, sculpted tokens, and seamless private rooms.',
      'icon': Icons.casino_rounded,
      'gradient': const LinearGradient(
        colors: [AppColors.coralPink, AppColors.warmPeach],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'chips': ['4-Player Classic', 'Fast Duel', 'Private VIP Rooms'],
    },
    {
      'badge': 'FRIENDSHIP & COMMUNITY',
      'title': 'Meet Your People',
      'subtitle':
          'Discover cheerful companions, share playful voice notes and reactions, and celebrate friendly victories.',
      'icon': Icons.people_alt_rounded,
      'gradient': const LinearGradient(
        colors: [AppColors.electricPurple, AppColors.softLavender],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'chips': ['Voice Notes', 'Custom Stickers', 'Online Status'],
    },
    {
      'badge': 'TOGETHERNESS & LOVE',
      'title': 'Make Every Moment Fun',
      'subtitle':
          'Pair up in Couples & Best Friends 2v2 Duo battles, unlock gorgeous cosmetics, and make every game memorable.',
      'icon': Icons.favorite_rounded,
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF3366), AppColors.warmGold],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'chips': ['Couples 2v2 Mode', 'Wardrobe Skins', 'Zero Real-Money'],
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding_v2', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainSocialShell(userProfile: widget.userProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.coralPink.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.casino_rounded, color: AppColors.coralPink, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'LUDO1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Central Visual Hero
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: page['gradient'] as LinearGradient,
                            boxShadow: [
                              BoxShadow(
                                color: (page['gradient'] as LinearGradient).colors.first.withValues(alpha: 0.4),
                                blurRadius: 36,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              page['icon'] as IconData,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Friendly Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            page['badge'] as String,
                            style: const TextStyle(
                              color: AppColors.warmPeach,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Heading
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Feature Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: (page['chips'] as List<String>).map((chip) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                chip,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Get Started Action
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.coralPink : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.coralPink, Color(0xFFFF758F)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coralPink.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Safety & Legal Guarantee Notice
                  const Text(
                    '100% Free Casual Gaming • Zero Gambling • Safe for Friends & Couples',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
