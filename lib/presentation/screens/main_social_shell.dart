import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme_v2.dart';
import '../../logic/mission_manager.dart';
import '../../models/game_mode.dart';
import '../../models/player_color.dart';
import '../../models/token.dart';
import '../../models/user_profile.dart';
import '../widgets/board/sculpted_pawn_widget.dart';
import '../widgets/dice/dice_engine_3d.dart';
import '../widgets/missions/daily_missions_dialog.dart';
import '../widgets/spin_wheel/lucky_spin_dialog.dart';
import 'direct_chat_screen.dart';
import 'game_screen.dart';
import 'online_room_screen.dart';
import 'profile_screen.dart';
import 'themes_screen.dart';
import '../widgets/social/story_viewer_dialog.dart';

/// Next-Gen Masterpiece Social Gaming Platform for LUDO1
/// 100% Responsive, Zero-Overflow, 2x2 Game Mode Grid Layout
class MainSocialShell extends StatefulWidget {
  final UserProfile userProfile;

  const MainSocialShell({super.key, required this.userProfile});

  @override
  State<MainSocialShell> createState() => _MainSocialShellState();
}

class _MainSocialShellState extends State<MainSocialShell> {
  int _selectedTabIndex = 0;
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.userProfile;
    SoundService.instance.soundEnabled = _profile.soundEnabled;
    SoundService.instance.hapticEnabled = _profile.hapticEnabled;
    _profile.updateDailyStreak();

    MissionManager.instance.init().then((_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_profile.canSpinToday && mounted) {
        _openLuckySpin();
      }
    });
  }

  void _openLuckySpin() {
    showDialog(
      context: context,
      builder: (_) => LuckySpinDialog(
        userProfile: _profile,
        onClaimed: () => setState(() {}),
      ),
    );
  }

  void _openDailyMissions() {
    showDialog(
      context: context,
      builder: (_) => DailyMissionsDialog(
        userProfile: _profile,
        onUpdated: () => setState(() {}),
      ),
    );
  }

  void _openOnlineRooms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineRoomScreen(userProfile: _profile),
      ),
    ).then((_) => setState(() {}));
  }

  void _launchGame(GameMode mode, int playerCount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          mode: mode,
          playerCount: playerCount,
          userProfile: _profile,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _showPlayerCountPicker(GameMode mode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppThemeV2.frostedGlass(
          borderRadius: 28,
          borderColor: AppColors.gold.withValues(alpha: 0.5),
          surfaceColor: AppColors.backgroundCard.withValues(alpha: 0.96),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SELECT PLAYERS (${mode.title.toUpperCase()})',
                style: AppThemeV2.sectionHeader.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCountOption(
                    title: '2 Players',
                    subtitle: 'Head-to-Head Duel',
                    icon: Icons.person_rounded,
                    gradient: AppColors.redGradient,
                    onTap: () {
                      Navigator.pop(context);
                      _launchGame(mode, 2);
                    },
                  ),
                  _buildCountOption(
                    title: '4 Players',
                    subtitle: 'Classic Arena Battle',
                    icon: Icons.groups_rounded,
                    gradient: AppColors.goldGradient,
                    onTap: () {
                      Navigator.pop(context);
                      _launchGame(mode, 4);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 135,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppThemeV2.bodyBold),
            const SizedBox(height: 4),
            Text(subtitle, style: AppThemeV2.caption),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Royal Midnight Navy Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.6),
                radius: 1.3,
                colors: [
                  Color(0xFF161B40),
                  Color(0xFF0C0F26),
                  AppColors.backgroundDark,
                ],
              ),
            ),
          ),

          // Main Tab Content
          SafeArea(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildHomeTab(),
                _buildPlayTab(),
                _buildFriendsTab(),
                _buildChatsTab(),
                _buildProfileTab(),
              ],
            ),
          ),

          // Production 5-Tab Bottom Dock
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: _buildCleanBottomDock(),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // TAB 0: FLAGSHIP HOME SCREEN
  // ====================================================
  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // 1. Personalized Greeting Top Bar
        _buildHomeHeader(),

        const SizedBox(height: 18),

        // 2. Friends Online Horizontal Scrolling Row
        _buildFriendsOnlineSection(),

        const SizedBox(height: 20),

        // 3. Play Together Primary Action Cards
        _buildPlayTogetherSection(),

        const SizedBox(height: 20),

        // 4. Special Moments (Duo Events & Weekly Challenges)
        _buildSpecialMomentsSection(),

        const SizedBox(height: 20),

        // 5. Continue Your Journey (Quests & Spin)
        _buildContinueJourneySection(),
      ],
    );
  }

  // Home Header (Greeting, Level & Non-Redeemable Coins)
  Widget _buildHomeHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedTabIndex = 4),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.coralPink, AppColors.softPink],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coralPink.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.warmGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_profile.level}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, ${_profile.name}! 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Who\'s joining your game today?',
                style: TextStyle(
                  color: AppColors.warmPeach,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Non-Redeemable Game Currency Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.warmGold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.warmGold, size: 18),
              const SizedBox(width: 6),
              Text(
                '${_profile.coins}',
                style: const TextStyle(
                  color: AppColors.warmGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Friends Online Horizontal Row
  Widget _buildFriendsOnlineSection() {
    final friends = [
      {'name': 'Priya', 'status': 'In Match', 'emoji': '💖', 'color': AppColors.roseGoldPrimary},
      {'name': 'Rahul K.', 'status': 'Online', 'emoji': '⚡', 'color': AppColors.greenPrimary},
      {'name': 'Ananya S.', 'status': 'Online', 'emoji': '🌸', 'color': AppColors.bluePrimary},
      {'name': 'Vikram 99', 'status': 'Ready', 'emoji': '🔥', 'color': AppColors.warmGold},
      {'name': 'Aryan V.', 'status': 'In Lobby', 'emoji': '🚀', 'color': AppColors.coralPink},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.circle, color: AppColors.mintGreen, size: 9),
                SizedBox(width: 8),
                Text(
                  'FRIENDS ONLINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 2),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppColors.coralPink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: friends.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final f = friends[index];
              final ringColor = f['color'] as Color;

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      SoundService.instance.playTokenMove();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DirectChatScreen(
                            userProfile: _profile,
                            friendName: f['name'] as String,
                            friendEmoji: f['emoji'] as String,
                            friendColor: ringColor,
                            onlineStatus: f['status'] as String,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.backgroundCard,
                            border: Border.all(color: ringColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: ringColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              f['emoji'] as String,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mintGreen,
                            border: Border.all(color: AppColors.backgroundDark, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    f['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invited ${f['name']} to play!'),
                          backgroundColor: AppColors.backgroundCard,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.coralPink.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.coralPink.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: const Text(
                        'Invite',
                        style: TextStyle(
                          color: AppColors.coralPink,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Play Together 2 Primary Action Cards
  Widget _buildPlayTogetherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PLAY TOGETHER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 1: Play with Friends
            Expanded(
              child: GestureDetector(
                onTap: _openOnlineRooms,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: 135,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A189A), Color(0xFF7B2CBF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricPurple.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Play with Friends',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Create or join VIP rooms',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Find Players
            Expanded(
              child: GestureDetector(
                onTap: () => _showPlayerCountPicker(GameMode.vsComputer),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: 135,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE63946), Color(0xFFFF4D6D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coralPink.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(Icons.public_rounded, color: Colors.white, size: 24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Find Players',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Quick online matchmaking',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Special Moments
  Widget _buildSpecialMomentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SPECIAL MOMENTS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _launchGame(GameMode.vsComputer, 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A102E), Color(0xFF2E1033)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.roseGoldPrimary.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.roseGoldPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.roseGoldPrimary, width: 1.5),
                  ),
                  child: const Center(
                    child: Text('💖', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Couples & Duo 2v2 Arena',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Team up with your favorite person • Double XP',
                        style: TextStyle(
                          color: AppColors.warmPeach,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Continue Your Journey
  Widget _buildContinueJourneySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTINUE YOUR JOURNEY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRewardCard(
                title: 'LUCKY SPIN',
                subtitle: _profile.canSpinToday ? 'FREE SPIN' : 'Claimed',
                icon: Icons.casino_rounded,
                isHighlight: _profile.canSpinToday,
                onTap: _openLuckySpin,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRewardCard(
                title: 'DAILY QUESTS',
                subtitle: MissionManager.instance.unclaimedCount > 0
                    ? '${MissionManager.instance.unclaimedCount} UNCLAIMED'
                    : 'Active',
                icon: Icons.workspace_premium_rounded,
                isHighlight: MissionManager.instance.unclaimedCount > 0,
                onTap: _openDailyMissions,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ====================================================
  // TAB 1: GAME ARENA MODES (PLAY)
  // ====================================================
  Widget _buildPlayTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // 1. Prestigious Top Bar
        _buildRoyalTopBar(),

        const SizedBox(height: 14),

        // 2. Active Stories & Squad Bar (Snapchat & Discord Inspired)
        _buildStoriesReel(),

        const SizedBox(height: 14),

        // 3. Iconic Game Emblem Banner
        _buildIconicGameBanner(),

        const SizedBox(height: 20),

        // 3. Section Title
        const Row(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.gold, size: 18),
            SizedBox(width: 8),
            Text(
              'SELECT GAME MODE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 4. Responsive 2x2 Grid of Game Modes (ZERO OVERFLOW!)
        Row(
          children: [
            Expanded(
              child: _buildModeGridTile(
                title: 'PLAY ONLINE',
                subtitle: 'Rapid Match',
                badge: 'LIVE',
                badgeColor: AppColors.greenPrimary,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.public_rounded,
                onTap: () => _showPlayerCountPicker(GameMode.vsComputer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModeGridTile(
                title: 'WITH FRIENDS',
                subtitle: 'VIP Room',
                badge: 'ROOM',
                badgeColor: AppColors.gold,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A1C71), Color(0xFF6B1170)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.groups_rounded,
                onTap: _openOnlineRooms,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildModeGridTile(
                title: 'VS COMPUTER',
                subtitle: 'Smart AI Bots',
                badge: 'OFFLINE',
                badgeColor: Colors.blueAccent,
                gradient: const LinearGradient(
                  colors: [Color(0xFF134E5E), Color(0xFF2A7B68)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.smart_toy_rounded,
                onTap: () => _showPlayerCountPicker(GameMode.vsComputer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModeGridTile(
                title: 'COUPLES 2v2',
                subtitle: 'Duo Team Battle',
                badge: 'DUO',
                badgeColor: AppColors.roseGoldPrimary,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A2387), Color(0xFFB52B65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.favorite_rounded,
                onTap: () => _launchGame(GameMode.vsComputer, 4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 5. Daily Rewards Row (Spin & Missions)
        Row(
          children: [
            Expanded(
              child: _buildRewardCard(
                title: 'LUCKY SPIN',
                subtitle: _profile.canSpinToday ? 'FREE SPIN' : 'Claimed',
                icon: Icons.casino_rounded,
                isHighlight: _profile.canSpinToday,
                onTap: _openLuckySpin,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRewardCard(
                title: 'DAILY QUESTS',
                subtitle: MissionManager.instance.unclaimedCount > 0
                    ? '${MissionManager.instance.unclaimedCount} UNCLAIMED'
                    : 'Active',
                icon: Icons.workspace_premium_rounded,
                isHighlight: MissionManager.instance.unclaimedCount > 0,
                onTap: _openDailyMissions,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 6. Live Tournament & Championship Card (Fills Dead Space with Prestige)
        _buildLiveTournamentCard(),
      ],
    );
  }

  // Active Social Stories Reel (Snapchat / Instagram Inspired)
  Widget _buildStoriesReel() {
    final stories = [
      {'name': 'Your Story', 'emoji': '➕', 'isUser': true, 'ring': AppColors.warmGold, 'caption': ''},
      {'name': 'Priya (Duo)', 'emoji': '💖', 'isUser': false, 'ring': AppColors.roseGoldPrimary, 'caption': 'Hit a 3x Sixes roll streak with my duo partner! 🎲💖'},
      {'name': 'Rahul K.', 'emoji': '⚡', 'isUser': false, 'ring': AppColors.greenPrimary, 'caption': 'Won the 4-Player Arena Battle in under 12 minutes! ⚡'},
      {'name': 'Ananya S.', 'emoji': '🌸', 'isUser': false, 'ring': AppColors.bluePrimary, 'caption': 'Just unlocked the Crystal Rose pawn token! 🌸'},
      {'name': 'Vikram 99', 'emoji': '🔥', 'isUser': false, 'ring': AppColors.warmGold, 'caption': 'Captured 4 tokens in a single turn! GG! 🔥'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final s = stories[index];
          final isUser = s['isUser'] as bool;
          final ringColor = s['ring'] as Color;

          return GestureDetector(
            onTap: () {
              if (isUser) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Story Studio: Share a match highlight!'),
                    backgroundColor: AppColors.backgroundCard,
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => StoryViewerDialog(
                    userName: s['name'] as String,
                    userEmoji: s['emoji'] as String,
                    userRingColor: ringColor,
                    storyCaption: s['caption'] as String,
                  ),
                );
              }
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: ringColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundSurface,
                    ),
                    child: Center(
                      child: Text(
                        s['emoji'] as String,
                        style: TextStyle(fontSize: isUser ? 20 : 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s['name'] as String,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Live Tournament Card
  Widget _buildLiveTournamentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1235), Color(0xFF131733)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.goldShimmerGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.black87, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'GLOBAL LEAGUE',
                      style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                    ),
                    SizedBox(width: 8),
                    Text('• 04h 22m LEFT', style: TextStyle(color: AppColors.greenPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  'Top 1% Duo Grandmaster Championship',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text('Compete for exclusive avatars & 3D dice', style: TextStyle(color: Colors.white54, fontSize: 10.5)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
        ],
      ),
    );
  }

  // Royal Top Bar
  Widget _buildRoyalTopBar() {
    return Row(
      children: [
        // User Crest
        GestureDetector(
          onTap: () => setState(() => _selectedTabIndex = 3),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldShimmerGradient,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.black87, size: 26),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_profile.name, style: AppThemeV2.bodyBold.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold, width: 0.8),
                    ),
                    child: Text('LEVEL ${_profile.level}', style: AppThemeV2.goldBadge.copyWith(fontSize: 9)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Virtual Coins Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_profile.coins}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Iconic Game Banner
  Widget _buildIconicGameBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C194D), Color(0xFF1B224E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.goldShimmerGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.casino_rounded, color: Colors.black87, size: 32),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LUDO GLOBAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'The King of Board Games',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2x2 Grid Mode Tile (100% Overflow-Safe)
  Widget _buildModeGridTile({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor, width: 0.8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // Reward Card
  Widget _buildRewardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isHighlight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlight ? AppColors.gold : Colors.white12,
            width: isHighlight ? 1.5 : 1.0,
          ),
          boxShadow: isHighlight
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isHighlight ? AppColors.gold : Colors.white70, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isHighlight ? AppColors.gold : Colors.white54,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
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

  // ====================================================
  // TAB 2: FRIENDS & DUO
  // ====================================================
  Widget _buildFriendsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        const Text('FRIENDS & DUO', style: AppThemeV2.heroTitle),
        const SizedBox(height: 4),
        const Text('Connect, pair with duo partner, and invite to match', style: AppThemeV2.caption),
        const SizedBox(height: 16),

        // Friend Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.white54, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search player name or ID...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Couple Duo Spotlight Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A102E), Color(0xFF26102A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.roseGoldPrimary.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: AppColors.roseGoldPrimary, size: 20),
                      SizedBox(width: 8),
                      Text('COUPLE DUO STATUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('ACTIVE', style: TextStyle(color: AppColors.roseGoldLight, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSimpleDuoUser(_profile.name, '👑'),
                  const Icon(Icons.link_rounded, color: AppColors.roseGoldPrimary, size: 26),
                  _buildSimpleDuoUser('Priya (Partner)', '💖'),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _launchGame(GameMode.vsComputer, 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.roseGoldPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('INVITE DUO TO 2v2 MATCH', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Friend Requests Pending
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundSurface),
                child: const Center(child: Text('🚀', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aryan V.', style: AppThemeV2.bodyBold),
                    Text('Wants to be your ludo buddy', style: AppThemeV2.caption),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Accepted Aryan V.\'s request!'), backgroundColor: AppColors.greenPrimary),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Accept', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text('ONLINE FRIENDS (3)', style: AppThemeV2.sectionHeader),
        const SizedBox(height: 12),
        _buildCleanFriendRow('Rahul K.', 'Ready to play', '⚡'),
        _buildCleanFriendRow('Ananya S.', 'Online', '🌸'),
        _buildCleanFriendRow('Vikram 99', 'In Match', '🔥'),

        const SizedBox(height: 20),

        const Text('SUGGESTED PLAYERS', style: AppThemeV2.sectionHeader),
        const SizedBox(height: 12),
        _buildCleanFriendRow('Kavya M.', 'Level 4 Ludo Queen', '👑'),
        _buildCleanFriendRow('Sameer T.', 'Level 6 Dice Roller', '🎲'),
      ],
    );
  }

  Widget _buildSimpleDuoUser(String name, String emoji) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundCard),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildCleanFriendRow(String name, String status, String emoji, {Color color = AppColors.coralPink}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              SoundService.instance.playTokenMove();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DirectChatScreen(
                    userProfile: _profile,
                    friendName: name,
                    friendEmoji: emoji,
                    friendColor: color,
                    onlineStatus: status,
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundSurface),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                SoundService.instance.playTokenMove();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DirectChatScreen(
                      userProfile: _profile,
                      friendName: name,
                      friendEmoji: emoji,
                      friendColor: color,
                      onlineStatus: status,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppThemeV2.bodyBold),
                  Text(status, style: AppThemeV2.caption),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.coralPink, size: 20),
            onPressed: () {
              SoundService.instance.playTokenMove();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DirectChatScreen(
                    userProfile: _profile,
                    friendName: name,
                    friendEmoji: emoji,
                    friendColor: color,
                    onlineStatus: status,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.gold, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Match invite sent to $name!'), backgroundColor: AppColors.greenPrimary),
              );
            },
          ),
        ],
      ),
    );
  }

  // ====================================================
  // TAB 3: CHATS & MESSAGES
  // ====================================================
  Widget _buildChatsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        const Text('MESSAGES', style: AppThemeV2.heroTitle),
        const SizedBox(height: 4),
        const Text('Direct messaging and voice notes with friends', style: AppThemeV2.caption),
        const SizedBox(height: 16),

        // Featured Interactive Voice Note Player Card
        GestureDetector(
          onTap: () {
            SoundService.instance.playTokenMove();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DirectChatScreen(
                  userProfile: _profile,
                  friendName: 'Priya',
                  friendEmoji: '💖',
                  friendColor: AppColors.roseGoldPrimary,
                  onlineStatus: 'Active Now',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B1534), Color(0xFF1E1735)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.roseGoldPrimary.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('💖 Priya (Couple Duo)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Spacer(),
                    Text('Just now', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.roseGoldPrimary,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.black87, size: 24),
                    ),
                    const SizedBox(width: 12),
                    // Audio Waveform Simulator
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          20,
                          (index) => Container(
                            width: 3,
                            height: 10 + (index % 5) * 4.0,
                            decoration: BoxDecoration(
                              color: index < 8 ? AppColors.roseGoldLight : Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('0:14', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _buildCleanChatTile('Rahul K.', 'Haha nice move! Let\'s play again 😂', '⚡', '1h ago', color: AppColors.mintGreen),
        _buildCleanChatTile('Ananya S.', 'Sent a sticker 🎯', '🌸', '3h ago', color: AppColors.royalBlue),
        _buildCleanChatTile('Vikram 99', 'GG! Next time in Duo battle ⚔️', '🔥', 'Yesterday', color: AppColors.warmGold),

        const SizedBox(height: 16),

        // Instant Reaction Tray Preview
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('❤️', style: TextStyle(fontSize: 22)),
              Text('🔥', style: TextStyle(fontSize: 22)),
              Text('🎯', style: TextStyle(fontSize: 22)),
              Text('😂', style: TextStyle(fontSize: 22)),
              Text('👑', style: TextStyle(fontSize: 22)),
              Text('⚡', style: TextStyle(fontSize: 22)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCleanChatTile(String name, String lastMsg, String emoji, String time, {Color color = AppColors.coralPink}) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playTokenMove();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DirectChatScreen(
              userProfile: _profile,
              friendName: name,
              friendEmoji: emoji,
              friendColor: color,
              onlineStatus: 'Online',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundSurface),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: AppThemeV2.bodyBold),
                      Text(time, style: AppThemeV2.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(lastMsg, style: AppThemeV2.bodyRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // TAB 4: PROFILE & WARDROBE
  // ====================================================
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('PROFILE', style: AppThemeV2.heroTitle),
            IconButton(
              icon: const Icon(Icons.palette_rounded, color: AppColors.gold),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ThemesScreen(userProfile: _profile)),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Clean Avatar Card
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldShimmerGradient,
            ),
            child: const Icon(Icons.person, color: Colors.black87, size: 48),
          ),
        ),

        const SizedBox(height: 12),
        Center(child: Text(_profile.name, style: AppThemeV2.heroTitle.copyWith(fontSize: 20))),
        Center(child: Text('Level ${_profile.level} Grandmaster', style: AppThemeV2.goldBadge)),

        const SizedBox(height: 20),

        // Clean Stats Matrix
        Row(
          children: [
            Expanded(child: _buildCleanStat('MATCHES', '${_profile.matchesPlayed}')),
            const SizedBox(width: 12),
            Expanded(child: _buildCleanStat('WINS', '${_profile.matchesWon}')),
            const SizedBox(width: 12),
            Expanded(child: _buildCleanStat('CAPTURES', '${_profile.totalCaptures}')),
          ],
        ),

        const SizedBox(height: 20),

        // Equipped 3D Wardrobe Showcase
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.checkroom_rounded, color: AppColors.gold, size: 18),
                  SizedBox(width: 8),
                  Text('ACTIVE 3D WARDROBE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWardrobePreview('3D DICE', DiceEngine3D(value: 6, primaryColor: AppColors.gold, size: 42)),
                  _buildWardrobePreview('3D TOKEN', SculptedPawnWidget(token: Token(id: 0, color: PlayerColor.red), size: 38, isMovable: true)),
                  _buildWardrobePreview('LUXE BOARD', Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFCF9F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gold, width: 1.5)), child: const Icon(Icons.grid_on_rounded, color: Colors.black87, size: 24))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Customization & Settings Action
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ThemesScreen(userProfile: _profile)),
            ).then((_) => setState(() {}));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
            ),
            child: const Center(
              child: Text(
                'THEMES & SKINS WARDROBE',
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen(userProfile: _profile)),
            ).then((_) => setState(() {}));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(
              child: Text(
                'EDIT PROFILE & PRIVACY',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWardrobePreview(String title, Widget preview) {
    return Column(
      children: [
        SizedBox(width: 48, height: 48, child: Center(child: preview)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildCleanStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: AppThemeV2.sectionHeader.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: AppThemeV2.caption),
        ],
      ),
    );
  }

  // ====================================================
  // PRODUCTION 5-TAB BOTTOM NAVIGATION
  // ====================================================
  Widget _buildCleanBottomDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockTab(0, Icons.home_rounded, 'Home'),
          _buildDockTab(1, Icons.casino_rounded, 'Play'),
          _buildDockTab(2, Icons.people_alt_rounded, 'Friends'),
          _buildDockTab(3, Icons.chat_bubble_rounded, 'Chats'),
          _buildDockTab(4, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDockTab(int index, IconData icon, String label) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        SoundService.instance.playTokenMove();
        setState(() => _selectedTabIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coralPink.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.coralPink, width: 1.2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.coralPink : Colors.white54,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
