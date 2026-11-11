import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_mode.dart';
import '../../models/player.dart';
import '../../models/player_color.dart';
import '../../models/user_profile.dart';
import '../state/game_controller.dart';
import '../widgets/board/ludo_board_widget.dart';
import '../widgets/dice/dice_engine_3d.dart';
import '../widgets/reactions/floating_reaction_bubble.dart';
import '../widgets/reactions/reaction_model.dart';
import '../widgets/reactions/reaction_picker_sheet.dart';
import '../widgets/victory_dialog.dart';

/// Masterpiece Responsive GameScreen (100% Overflow-Free)
/// Player Pods dynamically scale with Expanded containers and fit any screen size.
class GameScreen extends StatefulWidget {
  final GameMode mode;
  final int playerCount;
  final UserProfile userProfile;

  const GameScreen({
    super.key,
    required this.mode,
    required this.playerCount,
    required this.userProfile,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameController _controller;
  late AnimationController _turnTimerController;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      mode: widget.mode,
      playerCount: widget.playerCount,
      userProfile: widget.userProfile,
    );
    _controller.addListener(_onStateChanged);

    _turnTimerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  void _onStateChanged() {
    if (_controller.isGameOver && mounted) {
      final winner = _controller.matchWinner ?? _controller.engine.players.first;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => VictoryDialog(
          winner: winner,
          leaderboard: _controller.engine.leaderboard,
          earnedCoins: winner.isBot ? 30 : 150,
          earnedXp: winner.isBot ? 20 : 75,
          onPlayAgain: () {
            Navigator.pop(context);
            _controller.restartGame();
          },
          onHome: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _turnTimerController.dispose();
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  Player? _getPlayerByColor(PlayerColor color) {
    try {
      return _controller.engine.players.firstWhere((p) => p.color == color);
    } catch (_) {
      return null;
    }
  }

  void _openReactionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ReactionPickerSheet(
        onSelected: (ReactionItem reaction) {
          final human = _controller.engine.players.firstWhere(
            (p) => !p.isBot,
            orElse: () => _controller.currentPlayer,
          );
          _controller.sendReaction(human.color, reaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _controller.activeTheme;

    final greenPlayer = _getPlayerByColor(PlayerColor.green);
    final yellowPlayer = _getPlayerByColor(PlayerColor.yellow);
    final redPlayer = _getPlayerByColor(PlayerColor.red);
    final bluePlayer = _getPlayerByColor(PlayerColor.blue);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.tableBackground),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Sleek Glass Header Bar
              _buildHeader(),

              // 2. Slim Golden Turn Status Prompt
              _buildStatusPrompt(),

              // 3. The 100% Responsive Arena Centerpiece
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Player Area (Centered in 2P, Split in 4P)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _buildTopPlayerArea(greenPlayer, yellowPlayer),
                        ),

                        const SizedBox(height: 10),

                        // Masterpiece Luxe Ludo Board
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: LudoBoardWidget(
                            theme: theme,
                            players: _controller.engine.players,
                            movableTokens: _controller.movableTokens,
                            tokenSkin: _controller.activeTokenSkin,
                            onTokenTap: _controller.selectToken,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Bottom Player Area (Centered in 2P, Split in 4P)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _buildBottomPlayerArea(redPlayer, bluePlayer),
                        ),

                        const SizedBox(height: 12),

                        // Instant In-Game Social Reactions Tray
                        _buildQuickSocialReactionTray(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Instant In-Game Social Reactions Tray
  Widget _buildQuickSocialReactionTray() {
    final emojis = ['❤️', '🔥', '🎯', '😂', '👑', '⚡'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: emojis.map((e) {
          return GestureDetector(
            onTap: () {
              SoundService.instance.playTokenMove();
              _controller.sendReaction(
                _controller.currentPlayer.color,
                ReactionItem(emoji: e, text: ''),
              );
            },
            child: Text(e, style: const TextStyle(fontSize: 22)),
          );
        }).toList(),
      ),
    );
  }

  // Header Bar
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              widget.mode.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_rounded,
              color: AppColors.gold,
              size: 22,
            ),
            tooltip: 'Reactions',
            onPressed: _openReactionPicker,
          ),
          IconButton(
            icon: Icon(
              SoundService.instance.soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: AppColors.gold,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                SoundService.instance.soundEnabled =
                    !SoundService.instance.soundEnabled;
                widget.userProfile.soundEnabled =
                    SoundService.instance.soundEnabled;
                widget.userProfile.save();
              });
            },
          ),
        ],
      ),
    );
  }

  // Status Prompt Banner
  Widget _buildStatusPrompt() {
    final color = _controller.currentPlayer.color;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.glowColor,
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        _getStatusMessage(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Top Player Area (Balanced for 2P or 4P)
  Widget _buildTopPlayerArea(Player? green, Player? yellow) {
    if (green != null && yellow != null) {
      return Row(
        children: [
          Expanded(child: _buildPlayerPod(green, isLeft: true)),
          const SizedBox(width: 10),
          Expanded(child: _buildPlayerPod(yellow, isLeft: false)),
        ],
      );
    }
    final singlePlayer = green ?? yellow;
    if (singlePlayer == null) return const SizedBox.shrink();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: _buildPlayerPod(singlePlayer, isLeft: true, isCentered: true),
      ),
    );
  }

  // Bottom Player Area (Balanced for 2P or 4P)
  Widget _buildBottomPlayerArea(Player? red, Player? blue) {
    if (red != null && blue != null) {
      return Row(
        children: [
          Expanded(child: _buildPlayerPod(red, isLeft: true)),
          const SizedBox(width: 10),
          Expanded(child: _buildPlayerPod(blue, isLeft: false)),
        ],
      );
    }
    final singlePlayer = red ?? blue;
    if (singlePlayer == null) return const SizedBox.shrink();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: _buildPlayerPod(singlePlayer, isLeft: true, isCentered: true),
      ),
    );
  }

  // 100% Overflow-Free Gaming Player Podium with Tactile 3D Dice
  Widget _buildPlayerPod(Player player, {required bool isLeft, bool isCentered = false}) {
    final isCurrentTurn = _controller.currentPlayer == player;
    final color = player.color;
    final reaction = _controller.activeReactions[player.color];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCurrentTurn ? AppColors.gold : Colors.white12,
              width: isCurrentTurn ? 2.0 : 1.0,
            ),
            boxShadow: isCurrentTurn
                ? [
                    BoxShadow(
                      color: color.glowColor.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: isCentered ? MainAxisSize.min : MainAxisSize.max,
            children: isLeft || isCentered
                ? [
                    _buildAvatarWithTimer(player, isCurrentTurn),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: isCentered ? 0 : 1,
                      child: Container(
                        constraints: isCentered ? const BoxConstraints(minWidth: 100, maxWidth: 140) : null,
                        child: _buildPlayerNameColumn(player, isCurrentTurn),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildDiceSection(player, isCurrentTurn),
                  ]
                : [
                    _buildDiceSection(player, isCurrentTurn),
                    const SizedBox(width: 10),
                    Expanded(child: _buildPlayerNameColumn(player, isCurrentTurn)),
                    const SizedBox(width: 10),
                    _buildAvatarWithTimer(player, isCurrentTurn),
                  ],
          ),
        ),

        // Floating Reaction Bubble
        if (reaction != null)
          Positioned(
            top: -24,
            left: isLeft ? 10 : null,
            right: !isLeft ? 10 : null,
            child: FloatingReactionBubble(
              key: ValueKey('${player.color}_${reaction.emoji}_${reaction.text}'),
              item: reaction,
            ),
          ),
      ],
    );
  }

  // Avatar with Animated Turn Timer Ring
  Widget _buildAvatarWithTimer(Player player, bool isCurrentTurn) {
    final color = player.color;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isCurrentTurn)
          RotationTransition(
            turns: _turnTimerController,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold,
                  width: 2.5,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: color.gradient,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.primaryColor.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              player.isBot ? Icons.smart_toy_rounded : Icons.person_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // Player Name & Finished Stars Column
  Widget _buildPlayerNameColumn(Player player, bool isCurrentTurn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isCurrentTurn ? Colors.white : Colors.white70,
            fontWeight: isCurrentTurn ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                i < player.finishedTokensCount ? Icons.star_rounded : Icons.circle,
                color: i < player.finishedTokensCount
                    ? AppColors.gold
                    : player.color.primaryColor.withValues(alpha: 0.35),
                size: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Tactile 3D Dice Section (Enlarged to 46px for True 3D Fidelity)
  Widget _buildDiceSection(Player player, bool isCurrentTurn) {
    final canRoll = _controller.canCurrentPlayerRoll && isCurrentTurn;
    return DiceEngine3D(
      value: isCurrentTurn ? _controller.diceValue : 1,
      isRolling: _controller.isRolling && isCurrentTurn,
      primaryColor: player.color.primaryColor,
      skin: _controller.activeDiceSkin,
      size: 46,
      onTap: canRoll ? _controller.rollDice : null,
    );
  }

  String _getStatusMessage() {
    if (_controller.isBotThinking) {
      return '${_controller.currentPlayer.name} is thinking...';
    }
    if (_controller.isRolling) {
      return 'Rolling 3D dice...';
    }
    if (_controller.movableTokens.isNotEmpty) {
      return '${_controller.currentPlayer.name}, tap a token to move!';
    }
    if (_controller.canCurrentPlayerRoll) {
      return 'Your turn! Tap the 3D dice to roll.';
    }
    return "${_controller.currentPlayer.name}'s turn";
  }
}
