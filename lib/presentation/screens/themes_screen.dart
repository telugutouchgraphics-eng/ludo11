import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/avatar_frame.dart';
import '../../core/theme/board_theme.dart';
import '../../core/theme/dice_skin.dart';
import '../../core/theme/token_skin.dart';
import '../../models/player_color.dart';
import '../../models/token.dart';
import '../../models/user_profile.dart';
import '../widgets/board/luxe_board_painter.dart';
import '../widgets/board/sculpted_pawn_widget.dart';
import '../widgets/dice/dice_engine_3d.dart';

/// Next-Gen Masterpiece Customization Store & 3D Wardrobe for LUDO1
/// 100% Virtual Goods & Legal Compliance: Zero Real-Money Gambing/Betting
/// Features 4 Categorized Tabs with Interactive 3D Rotation Pedestal Stage
class ThemesScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ThemesScreen({super.key, required this.userProfile});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen>
    with SingleTickerProviderStateMixin {
  late UserProfile _profile;
  late TabController _tabController;

  // Interactive 3D Stage Rotation Angles
  double _stageRotationY = 0.0;
  double _stageRotationX = 0.0;

  @override
  void initState() {
    super.initState();
    _profile = widget.userProfile;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _unlockBoardTheme(BoardThemeData theme) {
    if (_profile.coins < theme.coinCost) {
      _showNotEnoughCoins();
      return;
    }
    SoundService.instance.playCoinClink();
    setState(() {
      _profile.coins -= theme.coinCost;
      _profile.unlockedThemes.add(theme.id);
      _profile.selectedThemeId = theme.id;
      _profile.save();
    });
    _showSuccessMessage('Unlocked & equipped ${theme.name}!');
  }

  void _equipBoardTheme(BoardThemeData theme) {
    SoundService.instance.playTokenMove();
    setState(() {
      _profile.selectedThemeId = theme.id;
      _profile.save();
    });
    _showSuccessMessage('Equipped ${theme.name}!');
  }

  void _unlockDiceSkin(DiceSkinData skin) {
    if (_profile.coins < skin.coinCost) {
      _showNotEnoughCoins();
      return;
    }
    SoundService.instance.playCoinClink();
    setState(() {
      _profile.coins -= skin.coinCost;
      _profile.unlockedDiceSkins.add(skin.id);
      _profile.selectedDiceSkinId = skin.id;
      _profile.save();
    });
    _showSuccessMessage('Unlocked & equipped ${skin.name} Dice!');
  }

  void _equipDiceSkin(DiceSkinData skin) {
    SoundService.instance.playTokenMove();
    setState(() {
      _profile.selectedDiceSkinId = skin.id;
      _profile.save();
    });
    _showSuccessMessage('Equipped ${skin.name} Dice!');
  }

  void _unlockTokenSkin(TokenSkinData skin) {
    if (_profile.coins < skin.coinCost) {
      _showNotEnoughCoins();
      return;
    }
    SoundService.instance.playCoinClink();
    setState(() {
      _profile.coins -= skin.coinCost;
      _profile.unlockedTokenSkins.add(skin.id);
      _profile.selectedTokenSkinId = skin.id;
      _profile.save();
    });
    _showSuccessMessage('Unlocked & equipped ${skin.name} Token!');
  }

  void _equipTokenSkin(TokenSkinData skin) {
    SoundService.instance.playTokenMove();
    setState(() {
      _profile.selectedTokenSkinId = skin.id;
      _profile.save();
    });
    _showSuccessMessage('Equipped ${skin.name} Token!');
  }

  void _unlockAvatarFrame(AvatarFrameData frame) {
    if (_profile.coins < frame.coinCost) {
      _showNotEnoughCoins();
      return;
    }
    SoundService.instance.playCoinClink();
    setState(() {
      _profile.coins -= frame.coinCost;
      _profile.unlockedAvatarFrameIds.add(frame.id);
      _profile.selectedAvatarFrameId = frame.id;
      _profile.save();
    });
    _showSuccessMessage('Unlocked & equipped ${frame.name} Frame!');
  }

  void _equipAvatarFrame(AvatarFrameData frame) {
    SoundService.instance.playTokenMove();
    setState(() {
      _profile.selectedAvatarFrameId = frame.id;
      _profile.save();
    });
    _showSuccessMessage('Equipped ${frame.name} Frame!');
  }

  void _showNotEnoughCoins() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not enough virtual coins! Win matches or spin the lucky wheel.'),
        backgroundColor: AppColors.redPrimary,
      ),
    );
  }

  void _showSuccessMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.greenPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '3D WARDROBE & STORE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 6),
                Text(
                  '${_profile.coins}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.coralPink,
          indicatorWeight: 3,
          labelColor: AppColors.coralPink,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.grid_on_rounded, size: 19), text: 'BOARDS'),
            Tab(icon: Icon(Icons.casino_rounded, size: 19), text: '3D DICE'),
            Tab(icon: Icon(Icons.shield_rounded, size: 19), text: 'TOKENS'),
            Tab(icon: Icon(Icons.face_retouching_natural_rounded, size: 19), text: 'FRAMES'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Interactive 3D Wardrobe Pedestal Stage (Drag to Rotate)
          _build3DStageHero(),

          // Categorized Store Catalog
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBoardsTab(),
                _buildDiceTab(),
                _buildTokensTab(),
                _buildFramesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Interactive 3D Wardrobe Pedestal Stage
  Widget _build3DStageHero() {
    final activeDice = DiceSkinData.allSkins.firstWhere(
      (s) => s.id == _profile.selectedDiceSkinId,
      orElse: () => DiceSkinData.classicIvory,
    );
    final activeToken = TokenSkinData.allSkins.firstWhere(
      (s) => s.id == _profile.selectedTokenSkinId,
      orElse: () => TokenSkinData.classicPawn,
    );
    final activeFrame = AvatarFrameData.allFrames.firstWhere(
      (f) => f.id == _profile.selectedAvatarFrameId,
      orElse: () => AvatarFrameData.classicWreath,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundCard,
            AppColors.backgroundSurface.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.view_in_ar_rounded, color: AppColors.coralPink, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'EQUIPPED 3D STAGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                'Drag to inspect in 3D ↺',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Interactive 3D Touch Rotation Area
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _stageRotationY += details.delta.dx * 0.015;
                _stageRotationX = (_stageRotationX - details.delta.dy * 0.015).clamp(-0.4, 0.4);
              });
            },
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateX(_stageRotationX)
                ..rotateY(_stageRotationY),
              child: Container(
                height: 88,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.coralPink.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coralPink.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 1. Avatar with Active Frame
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: activeFrame.borderGradient,
                            boxShadow: [
                              BoxShadow(color: activeFrame.glowColor, blurRadius: 10),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.backgroundDark,
                              ),
                              child: Center(
                                child: Text(
                                  activeFrame.badgeEmoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeFrame.name,
                          style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // 2. Equipped 3D Dice
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DiceEngine3D(
                          value: 6,
                          skin: activeDice,
                          primaryColor: AppColors.gold,
                          size: 42,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeDice.name,
                          style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // 3. Equipped 3D Token
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SculptedPawnWidget(
                          token: Token(id: 0, color: PlayerColor.red),
                          size: 40,
                          skin: activeToken,
                          isMovable: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeToken.name,
                          style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildBoardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: BoardThemeData.allThemes.length,
      itemBuilder: (context, index) {
        final theme = BoardThemeData.allThemes[index];
        final isUnlocked = _profile.unlockedThemes.contains(theme.id);
        final isEquipped = _profile.selectedThemeId == theme.id;

        return _buildStoreItemCard(
          title: theme.name,
          description: theme.description,
          coinCost: theme.coinCost,
          isUnlocked: isUnlocked,
          isEquipped: isEquipped,
          onEquip: () => _equipBoardTheme(theme),
          onUnlock: () => _unlockBoardTheme(theme),
          previewWidget: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: theme.tableBackground,
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: SizedBox(
                width: 96,
                height: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: LuxeBoardPainter(theme: theme),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: DiceSkinData.allSkins.length,
      itemBuilder: (context, index) {
        final skin = DiceSkinData.allSkins[index];
        final isUnlocked = _profile.unlockedDiceSkins.contains(skin.id);
        final isEquipped = _profile.selectedDiceSkinId == skin.id;

        return _buildStoreItemCard(
          title: skin.name,
          description: skin.description,
          coinCost: skin.coinCost,
          isUnlocked: isUnlocked,
          isEquipped: isEquipped,
          onEquip: () => _equipDiceSkin(skin),
          onUnlock: () => _unlockDiceSkin(skin),
          previewWidget: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.backgroundSurface,
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: DiceEngine3D(
                value: 6,
                skin: skin,
                primaryColor: AppColors.gold,
                size: 54,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTokensTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: TokenSkinData.allSkins.length,
      itemBuilder: (context, index) {
        final skin = TokenSkinData.allSkins[index];
        final isUnlocked = _profile.unlockedTokenSkins.contains(skin.id);
        final isEquipped = _profile.selectedTokenSkinId == skin.id;

        return _buildStoreItemCard(
          title: skin.name,
          description: skin.description,
          coinCost: skin.coinCost,
          isUnlocked: isUnlocked,
          isEquipped: isEquipped,
          onEquip: () => _equipTokenSkin(skin),
          onUnlock: () => _unlockTokenSkin(skin),
          previewWidget: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.backgroundSurface,
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SculptedPawnWidget(
                  token: Token(id: 0, color: PlayerColor.red),
                  size: 40,
                  skin: skin,
                  isMovable: true,
                ),
                SculptedPawnWidget(
                  token: Token(id: 1, color: PlayerColor.green),
                  size: 40,
                  skin: skin,
                  isMovable: true,
                ),
                SculptedPawnWidget(
                  token: Token(id: 2, color: PlayerColor.yellow),
                  size: 40,
                  skin: skin,
                  isMovable: true,
                ),
                SculptedPawnWidget(
                  token: Token(id: 3, color: PlayerColor.blue),
                  size: 40,
                  skin: skin,
                  isMovable: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFramesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: AvatarFrameData.allFrames.length,
      itemBuilder: (context, index) {
        final frame = AvatarFrameData.allFrames[index];
        final isUnlocked = _profile.unlockedAvatarFrameIds.contains(frame.id);
        final isEquipped = _profile.selectedAvatarFrameId == frame.id;

        return _buildStoreItemCard(
          title: frame.name,
          description: frame.description,
          coinCost: frame.coinCost,
          isUnlocked: isUnlocked,
          isEquipped: isEquipped,
          onEquip: () => _equipAvatarFrame(frame),
          onUnlock: () => _unlockAvatarFrame(frame),
          previewWidget: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.backgroundSurface,
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: frame.borderGradient,
                  boxShadow: [
                    BoxShadow(
                      color: frame.glowColor,
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundDark,
                    ),
                    child: Center(
                      child: Text(
                        frame.badgeEmoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreItemCard({
    required String title,
    required String description,
    required int coinCost,
    required bool isUnlocked,
    required bool isEquipped,
    required VoidCallback onEquip,
    required VoidCallback onUnlock,
    required Widget previewWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEquipped
              ? AppColors.coralPink
              : Colors.white.withValues(alpha: 0.12),
          width: isEquipped ? 2.5 : 1.0,
        ),
        boxShadow: isEquipped
            ? [
                BoxShadow(
                  color: AppColors.coralPink.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          previewWidget,
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEquipped)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.coralPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EQUIPPED',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                )
              else if (isUnlocked)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onEquip,
                  child: const Text(
                    'EQUIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warmGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.monetization_on,
                      size: 16, color: Colors.black87),
                  label: Text(
                    '$coinCost',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onPressed: onUnlock,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
