import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_mode.dart';
import '../../models/user_profile.dart';
import '../widgets/custom_game_button.dart';
import 'game_screen.dart';

class OnlineRoomScreen extends StatefulWidget {
  final UserProfile userProfile;

  const OnlineRoomScreen({super.key, required this.userProfile});

  @override
  State<OnlineRoomScreen> createState() => _OnlineRoomScreenState();
}

class _OnlineRoomScreenState extends State<OnlineRoomScreen> {
  bool _isCreating = true; // true = create room, false = join room
  String _roomCode = '';
  final TextEditingController _joinCodeController = TextEditingController();
  List<String> _playerNames = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateRoomCode();
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  void _generateRoomCode() {
    final code = (100000 + _random.nextInt(900000)).toString();
    setState(() {
      _roomCode = code;
      _playerNames = [
        widget.userProfile.name,
        'Waiting for player...',
        'Waiting for player...',
        'Waiting for player...',
      ];
    });
  }

  void _fillEmptyWithBots() {
    setState(() {
      if (_playerNames[1].startsWith('Waiting')) _playerNames[1] = 'Cyber Green (AI)';
      if (_playerNames[2].startsWith('Waiting')) _playerNames[2] = 'Robo Gold (AI)';
      if (_playerNames[3].startsWith('Waiting')) _playerNames[3] = 'Titan Blue (AI)';
    });
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: _roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room Code copied to clipboard! Share it with friends.'),
        backgroundColor: AppColors.greenPrimary,
      ),
    );
  }

  void _startGame() {
    _fillEmptyWithBots();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          mode: GameMode.vsComputer,
          playerCount: 4,
          userProfile: widget.userProfile,
        ),
      ),
    );
  }

  void _joinWithCode() {
    final code = _joinCodeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit room code.'),
          backgroundColor: AppColors.redPrimary,
        ),
      );
      return;
    }

    _startGame();
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
          'ONLINE PRIVATE ROOMS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCreating = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _isCreating ? AppColors.goldGradient : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'CREATE ROOM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isCreating ? Colors.black87 : Colors.white70,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCreating = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: !_isCreating ? AppColors.goldGradient : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'JOIN ROOM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isCreating ? Colors.black87 : Colors.white70,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_isCreating) _buildCreateRoomSection() else _buildJoinRoomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRoomSection() {
    return Column(
      children: [
        // Room Code Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gold, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.25),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'YOUR PRIVATE ROOM CODE',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _roomCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        color: AppColors.gold, size: 26),
                    onPressed: _copyRoomCode,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Player Slots Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PLAYERS IN LOBBY (4 SLOTS)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              _buildPlayerSlot(0, _playerNames[0], AppColors.redPrimary, isHost: true),
              _buildPlayerSlot(1, _playerNames[1], AppColors.greenPrimary),
              _buildPlayerSlot(2, _playerNames[2], AppColors.yellowPrimary),
              _buildPlayerSlot(3, _playerNames[3], AppColors.bluePrimary),
            ],
          ),
        ),

        const SizedBox(height: 24),

        CustomGameButton(
          text: 'START GAME',
          icon: Icons.play_arrow_rounded,
          gradient: AppColors.greenGradient,
          onPressed: _startGame,
        ),
      ],
    );
  }

  Widget _buildJoinRoomSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              const Icon(Icons.meeting_room_rounded,
                  color: AppColors.gold, size: 48),
              const SizedBox(height: 12),
              const Text(
                'ENTER 6-DIGIT ROOM CODE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ask your friend for their room code to join',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _joinCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.backgroundSurface,
                  hintText: '000000',
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        CustomGameButton(
          text: 'JOIN ARENA',
          icon: Icons.login_rounded,
          gradient: AppColors.goldGradient,
          onPressed: _joinWithCode,
        ),
      ],
    );
  }

  Widget _buildPlayerSlot(int index, String name, Color color, {bool isHost = false}) {
    final isWaiting = name.startsWith('Waiting');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWaiting ? Colors.white10 : color.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWaiting ? Colors.white12 : color,
            ),
            child: Icon(
              isHost
                  ? Icons.star_rounded
                  : (isWaiting ? Icons.person_outline : Icons.person),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(
              color: isWaiting ? Colors.white38 : Colors.white,
              fontWeight: isWaiting ? FontWeight.normal : FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          if (isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'HOST',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
