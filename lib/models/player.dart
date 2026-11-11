import 'player_color.dart';
import 'token.dart';

class Player {
  final String id;
  final String name;
  final PlayerColor color;
  final bool isBot;
  final String avatar;
  final List<Token> tokens;

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.isBot = false,
    this.avatar = 'avatar_1',
    List<Token>? tokens,
  }) : tokens = tokens ??
            List.generate(
              4,
              (index) => Token(id: index, color: color),
            );

  int get finishedTokensCount =>
      tokens.where((token) => token.isFinished).length;

  bool get hasWon => finishedTokensCount == 4;

  bool hasMovableToken(int diceValue) {
    return tokens.any((token) => token.canMove(diceValue));
  }

  List<Token> getMovableTokens(int diceValue) {
    return tokens.where((token) => token.canMove(diceValue)).toList();
  }

  void reset() {
    for (var token in tokens) {
      token.resetToYard();
    }
  }
}
