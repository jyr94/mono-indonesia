import 'package:flutter/material.dart';
import 'player_character.dart';

class PlayerTokenWidget extends StatelessWidget {
  final String playerName;
  final String? avatarColor;
  final Color color;
  final bool isCurrentPlayer;
  final bool isMoving;
  final double size;

  const PlayerTokenWidget({
    super.key,
    required this.playerName,
    this.avatarColor,
    required this.color,
    this.isCurrentPlayer = false,
    this.isMoving = false,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final token = Semantics(
      label:
          '$playerName, ${characterName(characterTypeFromColor(avatarColor))}',
      child: PlayerCharacter(
        type: characterTypeFromColor(avatarColor),
        color: color,
        size: size,
        showBase: true,
        highlighted: isCurrentPlayer,
      ),
    );

    if (!isMoving) return token;

    return TweenAnimationBuilder<double>(
      key: ValueKey('$playerName-$isMoving'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final lift = 10 * (1 - value);
        return Transform.translate(
          offset: Offset(0, -lift),
          child: Transform.scale(scale: 0.72 + (value * 0.28), child: child),
        );
      },
      child: token,
    );
  }
}
