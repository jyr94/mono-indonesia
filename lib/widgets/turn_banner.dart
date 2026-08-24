import 'package:flutter/material.dart';

class TurnBanner extends StatelessWidget {
  final String playerName;
  final int timeRemaining;
  final bool isMyTurn;

  const TurnBanner({
    super.key,
    required this.playerName,
    this.timeRemaining = 0,
    this.isMyTurn = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
              top: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            isMyTurn ? 'GILIRAN ANDA!' : 'GILIRAN ${playerName.toUpperCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF212121),
              letterSpacing: 0.4,
            ),
          ),
        ),
        if (timeRemaining > 0)
          Transform.translate(
            offset: const Offset(0, -8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: timeRemaining <= 10
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF424242),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 14,
                    color: timeRemaining <= 10
                        ? Colors.white
                        : const Color(0xFFFFD54F),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(timeRemaining),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
