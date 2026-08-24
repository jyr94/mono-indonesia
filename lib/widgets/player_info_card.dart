import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/property.dart';
import '../models/board.dart';

class PlayerInfoCard extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final Board board;
  final VoidCallback? onTap;

  const PlayerInfoCard({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.board,
    this.onTap,
  });

  Color _getPlayerColor() {
    switch (player.avatarColor) {
      case 'red': return const Color(0xFFD32F2F);
      case 'blue': return const Color(0xFF1565C0);
      case 'green': return const Color(0xFF2E7D32);
      case 'yellow': return const Color(0xFFF9A825);
      default: return Colors.grey;
    }
  }

  List<Property> get _ownedProperties => board.getAllPropertiesOwnedBy(player.id);

  @override
  Widget build(BuildContext context) {
    final playerColor = _getPlayerColor();
    final properties = _ownedProperties;
    final isBankrupt = player.isBankrupt;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          gradient: isCurrentPlayer
              ? LinearGradient(colors: [const Color(0xFFFFF8E1), const Color(0xFFFFFDE7)])
              : LinearGradient(colors: [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.85)]),
          borderRadius: BorderRadius.circular(12),
          border: isCurrentPlayer
              ? Border.all(color: playerColor, width: 2.5)
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: isCurrentPlayer
              ? [BoxShadow(color: playerColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Opacity(
          opacity: isBankrupt ? 0.4 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                // Avatar
                Container(width: 22, height: 22,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [playerColor.withValues(alpha: 0.8), playerColor]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: playerColor.withValues(alpha: 0.3), blurRadius: 4)],
                  ),
                  child: Center(child: Text(player.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white))),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(player.name, style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF212121),
                  decoration: isBankrupt ? TextDecoration.lineThrough : null,
                ), overflow: TextOverflow.ellipsis)),
                if (isCurrentPlayer)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: playerColor, borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: playerColor.withValues(alpha: 0.4), blurRadius: 4)]),
                    child: const Text('TURN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                if (isBankrupt) const Icon(Icons.cancel, size: 14, color: Color(0xFFD32F2F)),
                if (player.isInJail) const Icon(Icons.lock, size: 14, color: Color(0xFF1565C0)),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Text('Rp ${player.money}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                  color: player.money < 0 ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32))),
                const Spacer(),
                if (properties.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    ...properties.take(5).map((p) => Container(
                      width: 8, height: 8, margin: const EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        color: propertyColorMap[p.color], borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(color: propertyColorMap[p.color]!.withValues(alpha: 0.4), blurRadius: 2)],
                      ),
                    )),
                    if (properties.length > 5)
                      Padding(padding: const EdgeInsets.only(left: 3),
                        child: Text('+${properties.length - 5}', style: const TextStyle(fontSize: 9, color: Colors.grey))),
                  ]),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
