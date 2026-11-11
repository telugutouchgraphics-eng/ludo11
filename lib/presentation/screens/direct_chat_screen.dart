import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_mode.dart';
import '../../models/user_profile.dart';
import 'game_screen.dart';

enum MessageType { text, voice, gameInvite }

class ChatMessage {
  final String id;
  final String sender;
  final bool isMe;
  final MessageType type;
  final String text;
  final String time;
  final int voiceSeconds;
  bool isPlaying;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.isMe,
    required this.type,
    required this.text,
    required this.time,
    this.voiceSeconds = 0,
    this.isPlaying = false,
  });
}

/// Full-Screen Snapchat-Inspired Direct Messaging Experience
/// Featuring Interactive Voice Notes, In-Chat Game Invites, and Social Reactions
class DirectChatScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String friendName;
  final String friendEmoji;
  final Color friendColor;
  final String onlineStatus;

  const DirectChatScreen({
    super.key,
    required this.userProfile,
    required this.friendName,
    required this.friendEmoji,
    required this.friendColor,
    this.onlineStatus = 'Online',
  });

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<ChatMessage> _messages;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();
    _messages = [
      ChatMessage(
        id: '1',
        sender: widget.friendName,
        isMe: false,
        type: MessageType.text,
        text: 'Hey! Ready for our 2v2 Duo match today? 🎲',
        time: '10:14 AM',
      ),
      ChatMessage(
        id: '2',
        sender: widget.userProfile.name,
        isMe: true,
        type: MessageType.text,
        text: 'Yes! Just unlocked the Royal Gold 3D dice. Let\'s play!',
        time: '10:15 AM',
      ),
      ChatMessage(
        id: '3',
        sender: widget.friendName,
        isMe: false,
        type: MessageType.voice,
        text: 'Voice note (0:14)',
        time: '10:16 AM',
        voiceSeconds: 14,
      ),
      ChatMessage(
        id: '4',
        sender: widget.friendName,
        isMe: false,
        type: MessageType.gameInvite,
        text: '${widget.friendName} invited you to a 2v2 Duo Team Battle!',
        time: 'Just now',
      ),
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    SoundService.instance.playTokenMove();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: widget.userProfile.name,
          isMe: true,
          type: MessageType.text,
          text: text,
          time: 'Just now',
        ),
      );
      _textController.clear();
    });

    _scrollToBottom();
  }

  void _sendVoiceNote() {
    SoundService.instance.playTokenMove();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: widget.userProfile.name,
          isMe: true,
          type: MessageType.voice,
          text: 'Voice note (0:0${_recordSeconds.clamp(1, 9)})',
          time: 'Just now',
          voiceSeconds: _recordSeconds > 0 ? _recordSeconds : 4,
        ),
      );
      _isRecording = false;
      _recordSeconds = 0;
    });
    _recordTimer?.cancel();
    _scrollToBottom();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _sendVoiceNote();
    } else {
      SoundService.instance.playDiceRoll();
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() => _recordSeconds++);
      });
    }
  }

  void _togglePlayVoice(ChatMessage msg) {
    SoundService.instance.playTokenMove();
    setState(() {
      msg.isPlaying = !msg.isPlaying;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _launchDuoGame() {
    SoundService.instance.playGameStart();
    Navigator.push(
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

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Report or Block User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Do you want to report ${widget.friendName} for inappropriate behavior or block communications?',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralPink),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.friendName} has been reported. Chat restricted.'),
                  backgroundColor: AppColors.coralPink,
                ),
              );
            },
            child: const Text('Report & Block', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundSurface,
                    border: Border.all(color: widget.friendColor, width: 2),
                  ),
                  child: Center(
                    child: Text(widget.friendEmoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mintGreen,
                    border: Border.all(color: AppColors.backgroundCard, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friendName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.onlineStatus,
                  style: const TextStyle(color: AppColors.warmPeach, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_rounded, color: AppColors.warmGold, size: 24),
            tooltip: 'Invite to Match',
            onPressed: _launchDuoGame,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
            color: AppColors.backgroundCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val == 'report') _showReportDialog();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.coralPink, size: 20),
                    SizedBox(width: 10),
                    Text('Report / Block', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.white60, size: 20),
                    SizedBox(width: 10),
                    Text('Clear Messages', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageItem(msg);
                },
              ),
            ),

            // Recording Indicator Bar
            if (_isRecording)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: AppColors.coralPink.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: AppColors.coralPink, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Recording voice note... 0:0$_recordSeconds',
                      style: const TextStyle(color: AppColors.coralPink, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRecording = false;
                          _recordSeconds = 0;
                        });
                        _recordTimer?.cancel();
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // Bottom Composer
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isMe = msg.isMe;

    if (msg.type == MessageType.gameInvite) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A189A), Color(0xFF7B2CBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warmGold, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricPurple.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.sports_esports_rounded, color: AppColors.warmGold, size: 22),
                SizedBox(width: 8),
                Text('DUO TEAM BATTLE INVITE', style: TextStyle(color: AppColors.warmGold, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _launchDuoGame,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.coralPink, Color(0xFFFF758F)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'JOIN ARENA NOW',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (msg.type == MessageType.voice) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 260),
          decoration: BoxDecoration(
            color: isMe ? AppColors.coralPink : AppColors.backgroundCard,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
            ),
            border: Border.all(color: isMe ? Colors.transparent : Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _togglePlayVoice(msg),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMe ? Colors.white : AppColors.coralPink,
                  ),
                  child: Icon(
                    msg.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: isMe ? AppColors.coralPink : Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Simulated Waveform Bars
              Row(
                children: List.generate(
                  14,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 3,
                    height: 8.0 + (i % 4) * 5.0 * (msg.isPlaying ? 1.3 : 1.0),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.white.withValues(alpha: 0.8) : AppColors.warmPeach,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '0:${msg.voiceSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular Text Message
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.coralPink : AppColors.backgroundCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: Border.all(color: isMe ? Colors.transparent : Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.3),
            ),
            const SizedBox(height: 3),
            Text(
              msg.time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.white38,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          // Emoji Button
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.warmGold, size: 24),
            onPressed: () {
              setState(() {
                _textController.text += '🎯';
              });
            },
          ),
          // Text Input Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Send a message or audio...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Voice Note Mic Button
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
              color: _isRecording ? AppColors.coralPink : AppColors.softLavender,
              size: 26,
            ),
            onPressed: _toggleRecording,
          ),
          // Send Button
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coralPink,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
