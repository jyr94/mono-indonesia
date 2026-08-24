import 'package:flutter/material.dart';
import 'player_character.dart';

class AvatarBadge extends StatelessWidget {
  final String name;
  final String? avatarColor;
  final Color color;
  final double size;
  final bool isOnline;

  const AvatarBadge({
    super.key,
    required this.name,
    this.avatarColor,
    required this.color,
    this.size = 44,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.8), color],
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: PlayerCharacter(
          type: characterTypeFromColor(avatarColor),
          color: color,
          size: size * 0.72,
        ),
      ),
    );
  }
}
