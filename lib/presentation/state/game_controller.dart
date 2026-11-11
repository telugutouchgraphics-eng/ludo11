import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/board_theme.dart';
import '../../core/theme/dice_skin.dart';
import '../../core/theme/token_skin.dart';
import '../../logic/ludo_bot.dart';
import '../../logic/ludo_engine.dart';
import '../../logic/ludo_path.dart';
import '../../logic/mission_manager.dart';
import '../../models/game_mode.dart';
import '../../models/player.dart';
import '../../models/player_color.dart';
import '../../models/token.dart';
import '../../models/user_profile.dart';
import '../widgets/reactions/reaction_model.dart';

class GameController extends ChangeNotifier {
  late LudoEngine engine;
  final GameMode mode;
  final int playerCount;
  final UserProfile userProfile;
  BoardThemeData activeTheme = BoardThemeData.classicRoyal;
  DiceSkinData activeDiceSkin = DiceSkinData.classicIvory;
  TokenSkinData activeTokenSkin = TokenSkinData.classicPawn;

  bool isRolling = false;
  List<Token> movableTokens = [];
  bool isBotThinking = false;
  bool isGameOver = false;
  Player? matchWinner;

  final Map<PlayerColor, ReactionItem> activeReactions = {};
  final Map<PlayerColor, Timer> _reactionTimers = {};

  void sendReaction(PlayerColor color, ReactionItem item) {
    activeReactions[color] = item;
    _reactionTimers[color]?.cancel();
    notifyListeners();

    _reactionTimers[color] = Timer(const Duration(milliseconds: 2500), () {
      activeReactions.remove(color);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    for (final timer in _reactionTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  GameController({
    required this.mode,
    required this.playerCount,
    required this.userProfile,
  }) {
    _initTheme();
    _initPlayers();
  }

  void _initTheme() {
    activeTheme = BoardThemeData.allThemes.firstWhere(
      (t) => t.id == userProfile.selectedThemeId,
      orElse: () => BoardThemeData.classicRoyal,
    );
    activeDiceSkin = DiceSkinData.allSkins.firstWhere(
      (d) => d.id == userProfile.selectedDiceSkinId,
      orElse: () => DiceSkinData.classicIvory,
    );
    activeTokenSkin = TokenSkinData.allSkins.firstWhere(
      (t) => t.id == userProfile.selectedTokenSkinId,
      orElse: () => TokenSkinData.classicPawn,
    );
  }

  void _initPlayers() {
    final List<Player> players = [];
    final colors = [
      PlayerColor.red,
      PlayerColor.green,
      PlayerColor.yellow,
      PlayerColor.blue,
    ];

    if (mode == GameMode.vsComputer) {
      // 1 Human (Red) + 1 or 3 Bots
      players.add(Player(
        id: 'p1',
        name: userProfile.name,
        color: PlayerColor.red,
        isBot: false,
      ));

      if (playerCount == 2) {
        // Red vs Yellow (opposite sides)
        players.add(Player(
          id: 'bot_yellow',
          name: 'Robo Gold',
          color: PlayerColor.yellow,
          isBot: true,
        ));
      } else {
        // 4 Players: Red vs Green, Yellow, Blue
        players.add(Player(
          id: 'bot_green',
          name: 'Cyber Green',
          color: PlayerColor.green,
          isBot: true,
        ));
        players.add(Player(
          id: 'bot_yellow',
          name: 'Robo Gold',
          color: PlayerColor.yellow,
          isBot: true,
        ));
        players.add(Player(
          id: 'bot_blue',
          name: 'Titan Blue',
          color: PlayerColor.blue,
          isBot: true,
        ));
      }
    } else {
      // Pass & Play (Local Human Players)
      for (int i = 0; i < playerCount; i++) {
        players.add(Player(
          id: 'human_${i + 1}',
          name: 'Player ${i + 1}',
          color: colors[i],
          isBot: false,
        ));
      }
    }

    engine = LudoEngine(players: players);
  }

  Player get currentPlayer => engine.currentPlayer;
  int get diceValue => engine.diceValue;

  bool get canCurrentPlayerRoll {
    if (isRolling || isBotThinking || isGameOver) return false;
    if (engine.phase != GamePhase.waitingForRoll) return false;
    return !currentPlayer.isBot;
  }

  /// Roll Dice
  Future<void> rollDice() async {
    if (isRolling || isBotThinking || isGameOver) return;

    isRolling = true;
    engine.phase = GamePhase.rollingDice;
    notifyListeners();

    SoundService.instance.playDiceRoll();

    // Rolling animation time
    await Future.delayed(AppConstants.diceRollDuration);

    engine.rollDice();
    isRolling = false;

    // Track daily mission for rolling 6
    if (diceValue == 6) {
      MissionManager.instance.trackSixRoll();
    }

    // Check 3 consecutive sixes penalty
    if (engine.hasThreeSixesPenalty()) {
      _passTurnAfterDelay();
      return;
    }

    // Check movable tokens
    movableTokens = currentPlayer.getMovableTokens(diceValue);

    if (movableTokens.isEmpty) {
      // No tokens can move, pass turn
      _passTurnAfterDelay();
    } else if (movableTokens.length == 1) {
      // Exactly 1 movable token
      if (currentPlayer.isBot) {
        // Bot moves automatically
        await Future.delayed(const Duration(milliseconds: 300));
        await selectToken(movableTokens.first);
      } else {
        // Human: enable tap on that token (or auto move if desired)
        engine.phase = GamePhase.waitingForTokenSelection;
        notifyListeners();
      }
    } else {
      // Multiple movable tokens
      if (currentPlayer.isBot) {
        await Future.delayed(const Duration(milliseconds: 400));
        final chosen = LudoBot.chooseBestToken(
          botPlayer: currentPlayer,
          allPlayers: engine.players,
          diceValue: diceValue,
        );
        await selectToken(chosen);
      } else {
        engine.phase = GamePhase.waitingForTokenSelection;
        notifyListeners();
      }
    }
  }

  /// Execute move on chosen token
  Future<void> selectToken(Token token) async {
    if (isGameOver) return;
    if (!token.canMove(diceValue)) return;

    movableTokens = [];
    engine.phase = GamePhase.movingToken;
    notifyListeners();

    SoundService.instance.playTokenMove();

    // Execute move
    final result = engine.moveToken(token);
    notifyListeners();

    // Safe cell chime
    if (token.onTrack &&
        token.globalTrackIndex != null &&
        LudoPath.isSafeSpot(token.globalTrackIndex!)) {
      SoundService.instance.playSafeCellEntry();
    }

    // Check special events
    if (result.capturedOpponent) {
      SoundService.instance.playTokenCapture();
      MissionManager.instance.trackTokenCapture();
      if (!currentPlayer.isBot) {
        userProfile.recordCapture();
      } else {
        sendReaction(currentPlayer.color, const ReactionItem(emoji: '😎', text: 'Gotcha!'));
      }
    }

    if (result.reachedHome) {
      SoundService.instance.playTokenHome();
      if (currentPlayer.isBot) {
        sendReaction(currentPlayer.color, const ReactionItem(emoji: '🔥', text: 'On Fire!'));
      }
    }

    // Check if player won
    if (currentPlayer.hasWon) {
      matchWinner ??= currentPlayer;
      if (!currentPlayer.isBot) {
        MissionManager.instance.trackMatchWin();
      }

      if (engine.isGameOver() || engine.players.length == 2) {
        _handleGameOver();
        return;
      }
    }

    // Wait before next action
    await Future.delayed(const Duration(milliseconds: 350));

    if (result.getsBonusTurn && !currentPlayer.hasWon) {
      // Bonus turn for 6, capture, or reaching home!
      engine.phase = GamePhase.waitingForRoll;
      notifyListeners();
      _triggerBotIfNeeded();
    } else {
      // Pass turn to next player
      engine.nextTurn();
      notifyListeners();
      _triggerBotIfNeeded();
    }
  }

  void _passTurnAfterDelay() {
    engine.phase = GamePhase.movingToken;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (isGameOver) return;
      engine.nextTurn();
      notifyListeners();
      _triggerBotIfNeeded();
    });
  }

  void _triggerBotIfNeeded() {
    if (isGameOver) return;
    if (currentPlayer.isBot) {
      isBotThinking = true;
      notifyListeners();

      Future.delayed(AppConstants.botThinkingDuration, () {
        if (isGameOver) return;
        isBotThinking = false;
        rollDice();
      });
    }
  }

  void _handleGameOver() {
    isGameOver = true;
    engine.phase = GamePhase.gameOver;
    SoundService.instance.playVictory();

    final bool humanWon = matchWinner != null && !matchWinner!.isBot;
    if (humanWon) {
      userProfile.addWin(rewardCoins: 150, rewardXp: 75);
    } else {
      userProfile.addLoss(consolationCoins: 30, consolationXp: 20);
    }

    notifyListeners();
  }

  void restartGame() {
    isRolling = false;
    movableTokens = [];
    isBotThinking = false;
    isGameOver = false;
    matchWinner = null;
    engine.reset();
    notifyListeners();
  }
}
