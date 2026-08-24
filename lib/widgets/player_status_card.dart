import 'package:flutter/material.dart';
import '../models/player.dart';
import 'avatar_badge.dart';
import 'player_character.dart';

class PlayerStatusCard extends StatefulWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isLeft;
  final List<Color> propertyColors;

  const PlayerStatusCard({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    this.isLeft = true,
    this.propertyColors = const [],
  });

  @override
  State<PlayerStatusCard> createState() => _PlayerStatusCardState();
}

class _PlayerStatusCardState extends State<PlayerStatusCard> {
  int _oldMoney = 0;

  @override
  void initState() {
    super.initState();
    _oldMoney = widget.player.money;
  }

  @override
  void didUpdateWidget(PlayerStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player.money != widget.player.money) {
      _oldMoney = oldWidget.player.money;
    }
  }

  Color get _playerColor {
    return switch (widget.player.avatarColor) {
      'red'    => const Color(0xFFD32F2F),
      'blue'   => const Color(0xFF1565C0),
      'green'  => const Color(0xFF2E7D32),
      'yellow' => const Color(0xFFF9A825),
      'purple' => const Color(0xFF6A1B9A),
      'teal'   => const Color(0xFF00695C),
      _        => Colors.grey,
    };
  }

  String _formatBalance(int amount) {
    final raw = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return 'IDR ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final c = _playerColor;
    final token = characterName(characterTypeFromColor(widget.player.avatarColor));

    return Opacity(
      opacity: widget.player.isBankrupt ? 0.4 : 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 190;
          final avatarSize = compact ? 52.0 : 58.0;
          final avatar = AvatarBadge(
            name: widget.player.name,
            avatarColor: widget.player.avatarColor,
            color: c,
            size: avatarSize,
          );

          return PulsingGlowBorder(
            active: widget.isCurrentPlayer && !widget.player.isBankrupt,
            color: const Color(0xFFFFD54F),
            child: Container(
              height: compact ? 60 : 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: widget.isLeft ? Alignment.centerLeft : Alignment.centerRight,
                  end: widget.isLeft ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [
                    c.withValues(alpha: 0.85),
                    c,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: widget.isCurrentPlayer
                    ? Border.all(color: const Color(0xFFFFE082), width: 3)
                    : Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: c.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 4,
                    left: widget.isLeft ? -10 : null,
                    right: widget.isLeft ? null : -10,
                    child: avatar,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: widget.isLeft ? avatarSize - 4 : 10,
                      right: widget.isLeft ? 10 : avatarSize - 4,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: widget.isLeft
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.player.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: compact ? 10 : 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '($token)',
                                style: TextStyle(
                                  fontSize: compact ? 8 : 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withOpacity(0.78),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 7 : 9,
                            vertical: compact ? 3 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TweenAnimationBuilder<int>(
                            tween: IntTween(begin: _oldMoney, end: widget.player.money),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, value, child) {
                              return Text(
                                _formatBalance(value),
                                style: TextStyle(
                                  fontSize: compact ? 11 : 13,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFFD54F),
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.propertyColors.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              children: widget.propertyColors.map((c) => Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
                                ),
                              )).toList(),
                            ),
                          ),
                        if (widget.player.isInJail)
                          const Text(
                            '🔒 PENJARA',
                            style: TextStyle(fontSize: 9, color: Colors.white70),
                          ),
                        if (widget.player.jailFreeCards > 0)
                          Text(
                            '🎟️ ×${widget.player.jailFreeCards}',
                            style: const TextStyle(fontSize: 9, color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                  if (widget.isCurrentPlayer && !widget.player.isBankrupt)
                    Positioned(
                      top: -5,
                      right: widget.isLeft ? 8 : null,
                      left: widget.isLeft ? null : 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD54F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x99FFB300), blurRadius: 5),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PulsingGlowBorder extends StatefulWidget {
  final Widget child;
  final bool active;
  final Color color;

  const PulsingGlowBorder({super.key, required this.child, required this.active, required this.color});

  @override
  State<PulsingGlowBorder> createState() => _PulsingGlowBorderState();
}

class _PulsingGlowBorderState extends State<PulsingGlowBorder> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _glow = Tween<double>(begin: 1.0, end: 4.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulsingGlowBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5),
                blurRadius: _glow.value * 3.5,
                spreadRadius: _glow.value * 0.8,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
