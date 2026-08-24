import 'package:flutter/material.dart';

class GameActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isPrimary;

  const GameActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  State<GameActionButton> createState() => _GameActionButtonState();
}

class _GameActionButtonState extends State<GameActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final effectiveColor = enabled ? widget.color : Colors.grey.shade600;
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: GestureDetector(
          onTapDown: enabled ? (_) => _pressCtrl.forward() : null,
          onTapUp: enabled
              ? (_) {
                  _pressCtrl.reverse();
                  widget.onTap!();
                }
              : null,
          onTapCancel: enabled ? () => _pressCtrl.reverse() : null,
          child: AnimatedBuilder(
            animation: _pressAnim,
            builder: (context, child) => Transform.scale(
              scale: _pressAnim.value,
              child: child,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: compact ? 68 : 78,
              decoration: BoxDecoration(
                gradient: enabled
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          effectiveColor,
                          effectiveColor.withOpacity(0.75),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade800,
                          Colors.grey.shade900,
                        ],
                      ),
                borderRadius: BorderRadius.circular(10),
                border: widget.isPrimary && enabled
                    ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)
                    : Border.all(color: Colors.white.withOpacity(0.06), width: 1),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: effectiveColor.withOpacity(0.55),
                          blurRadius: widget.isPrimary ? 14 : 8,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 3,
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isPrimary && enabled)
                    _PulsingIcon(
                      icon: widget.icon,
                      size: compact ? 27 : 31,
                    )
                  else
                    Icon(
                      widget.icon,
                      color: enabled ? Colors.white : Colors.white24,
                      size: compact ? (widget.isPrimary ? 27 : 23) : (widget.isPrimary ? 31 : 26),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.isPrimary ? 9.5 : 8.5,
                      fontWeight: widget.isPrimary ? FontWeight.w900 : FontWeight.w700,
                      color: enabled ? Colors.white : Colors.white24,
                      letterSpacing: 0.3,
                      height: 1.2,
                      shadows: enabled
                          ? [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing icon untuk tombol aksi utama yang sedang aktif
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final double size;

  const _PulsingIcon({required this.icon, required this.size});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: _anim.value,
        child: Icon(widget.icon, color: Colors.white, size: widget.size),
      ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  final VoidCallback? onRollDice;
  final VoidCallback? onBuyProperty;
  final VoidCallback? onBuild;
  final VoidCallback? onTrade;
  final VoidCallback? onMortgage;
  final VoidCallback? onChat;
  final VoidCallback? onEndTurn;

  const BottomActionBar({
    super.key,
    this.onRollDice,
    this.onBuyProperty,
    this.onBuild,
    this.onTrade,
    this.onMortgage,
    this.onChat,
    this.onEndTurn,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 5 : 8,
        compact ? 7 : 9,
        compact ? 5 : 8,
        MediaQuery.of(context).padding.bottom + (compact ? 7 : 9),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GameActionButton(
            label: 'LEMPAR\nDADU',
            icon: Icons.casino_rounded,
            color: const Color(0xFF1565C0),
            onTap: onRollDice,
            isPrimary: onRollDice != null,
          ),
          GameActionButton(
            label: 'BELI\nPROPERTI',
            icon: Icons.home_rounded,
            color: const Color(0xFF2E7D32),
            onTap: onBuyProperty,
            isPrimary: onBuyProperty != null,
          ),
          GameActionButton(
            label: 'BANGUN\nGEDUNG',
            icon: Icons.apartment_rounded,
            color: const Color(0xFF6A1B9A),
            onTap: onBuild,
            isPrimary: onBuild != null,
          ),
          GameActionButton(
            label: 'GADAI\nPROPERTI',
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF795548),
            onTap: onMortgage,
            isPrimary: onMortgage != null,
          ),
          GameActionButton(
            label: 'TUKAR\nPROPERTI',
            icon: Icons.swap_horiz_rounded,
            color: const Color(0xFF00695C),
            onTap: onTrade,
            isPrimary: onTrade != null,
          ),
          GameActionButton(
            label: 'INFO\nGAME',
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF424242),
            onTap: onChat,
          ),
        ],
      ),
    );
  }
}
