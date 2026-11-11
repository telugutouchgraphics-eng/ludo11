import '../../../models/player_color.dart';

class ReactionItem {
  final String emoji;
  final String text;

  const ReactionItem({required this.emoji, required this.text});

  static const List<ReactionItem> presetReactions = [
    ReactionItem(emoji: '😎', text: 'Nice Move!'),
    ReactionItem(emoji: '😂', text: 'Haha!'),
    ReactionItem(emoji: '🔥', text: 'On Fire!'),
    ReactionItem(emoji: '👑', text: 'King!'),
    ReactionItem(emoji: '😱', text: 'Oops!'),
    ReactionItem(emoji: '👏', text: 'Well Played!'),
    ReactionItem(emoji: '🎯', text: 'Bullseye!'),
    ReactionItem(emoji: '🤞', text: 'Good Luck!'),
  ];
}

class ActiveReaction {
  final String id;
  final PlayerColor playerColor;
  final ReactionItem item;
  final DateTime timestamp;

  ActiveReaction({
    required this.id,
    required this.playerColor,
    required this.item,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
