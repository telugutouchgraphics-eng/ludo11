import 'package:flutter/material.dart';
import '../../../core/theme/board_theme.dart';
import '../../../core/theme/token_skin.dart';
import '../../../logic/ludo_path.dart';
import '../../../models/player.dart';
import '../../../models/token.dart';
import 'luxe_board_painter.dart';
import 'sculpted_pawn_widget.dart';

class LudoBoardWidget extends StatelessWidget {
  final BoardThemeData theme;
  final List<Player> players;
  final List<Token> movableTokens;
  final TokenSkinData tokenSkin;
  final Function(Token) onTokenTap;

  const LudoBoardWidget({
    super.key,
    required this.theme,
    required this.players,
    required this.movableTokens,
    this.tokenSkin = TokenSkinData.classicPawn,
    required this.onTokenTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep board perfectly square, adapting to screen width
        final double boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final double cellSize = boardSize / 15.0;

        // Collect all tokens from active players
        final List<Token> allTokens = [];
        for (var p in players) {
          allTokens.addAll(p.tokens);
        }

        // Calculate overlap groupings to display multi-token stacks neatly
        final Map<String, List<Token>> cellGroups = {};
        for (var token in allTokens) {
          final pos = LudoPath.getTokenPosition(token);
          final key = '${pos.dx.toStringAsFixed(1)}_${pos.dy.toStringAsFixed(1)}';
          cellGroups.putIfAbsent(key, () => []).add(token);
        }

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Base Luxe Vector Board
                CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: LuxeBoardPainter(theme: theme),
                ),

                // Animated Tokens on top of the Board
                ...allTokens.map((token) {
                  final pos = LudoPath.getTokenPosition(token);
                  final key =
                      '${pos.dx.toStringAsFixed(1)}_${pos.dy.toStringAsFixed(1)}';
                  final group = cellGroups[key] ?? [token];
                  final indexInGroup = group.indexOf(token);
                  final totalInGroup = group.length;

                  // Apply neat mini-offsets if multiple tokens occupy the same cell
                  double offsetX = 0.0;
                  double offsetY = 0.0;
                  double tokenScale = 0.85;

                  if (totalInGroup > 1) {
                    tokenScale = 0.65;
                    final double stackShift = cellSize * 0.18;
                    if (indexInGroup == 0) {
                      offsetX = -stackShift;
                      offsetY = -stackShift;
                    } else if (indexInGroup == 1) {
                      offsetX = stackShift;
                      offsetY = stackShift;
                    } else if (indexInGroup == 2) {
                      offsetX = -stackShift;
                      offsetY = stackShift;
                    } else {
                      offsetX = stackShift;
                      offsetY = -stackShift;
                    }
                  }

                  final double left = (pos.dx * cellSize) +
                      (cellSize * (1.0 - tokenScale) / 2) +
                      offsetX;
                  final double top = (pos.dy * cellSize) +
                      (cellSize * (1.0 - tokenScale) / 2) +
                      offsetY;

                  final bool isMovable = movableTokens.contains(token);

                  return AnimatedPositioned(
                    key: ValueKey('token_${token.color}_${token.id}'),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutQuad,
                    left: left,
                    top: top,
                    child: SculptedPawnWidget(
                      token: token,
                      size: cellSize * tokenScale,
                      isMovable: isMovable,
                      skin: tokenSkin,
                      onTap: () => onTokenTap(token),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
