import 'package:flutter/material.dart';

// 6 characters — one per avatar color
enum PlayerCharacterType { komodo, becak, garuda, kapal, wayang, keris }

PlayerCharacterType characterTypeFromColor(String? avatarColor) {
  return switch (avatarColor) {
    'red'    => PlayerCharacterType.becak,
    'green'  => PlayerCharacterType.garuda,
    'yellow' => PlayerCharacterType.kapal,
    'purple' => PlayerCharacterType.wayang,
    'teal'   => PlayerCharacterType.keris,
    _        => PlayerCharacterType.komodo,
  };
}

IconData characterIcon(PlayerCharacterType type) {
  return switch (type) {
    PlayerCharacterType.komodo => Icons.pets_rounded,
    PlayerCharacterType.becak  => Icons.pedal_bike_rounded,
    PlayerCharacterType.garuda => Icons.flutter_dash_rounded,
    PlayerCharacterType.kapal  => Icons.sailing_rounded,
    PlayerCharacterType.wayang => Icons.theater_comedy_rounded,
    PlayerCharacterType.keris  => Icons.architecture_rounded,
  };
}

String characterName(PlayerCharacterType type) {
  return switch (type) {
    PlayerCharacterType.komodo => 'KOMODO',
    PlayerCharacterType.becak  => 'BECAK',
    PlayerCharacterType.garuda => 'GARUDA',
    PlayerCharacterType.kapal  => 'KAPAL',
    PlayerCharacterType.wayang => 'WAYANG',
    PlayerCharacterType.keris  => 'KERIS',
  };
}

/// Returns the display [Color] for a given avatar color string.
Color avatarColorValue(String? avatarColor) {
  return switch (avatarColor) {
    'red'    => const Color(0xFFD32F2F),
    'blue'   => const Color(0xFF1565C0),
    'green'  => const Color(0xFF2E7D32),
    'yellow' => const Color(0xFFF9A825),
    'purple' => const Color(0xFF6A1B9A),
    'teal'   => const Color(0xFF00695C),
    _        => Colors.grey,
  };
}

class PlayerCharacter extends StatefulWidget {
  final PlayerCharacterType type;
  final Color color;
  final double size;
  final bool showBase;
  final bool highlighted;

  const PlayerCharacter({
    super.key,
    required this.type,
    required this.color,
    required this.size,
    this.showBase = false,
    this.highlighted = false,
  });

  @override
  State<PlayerCharacter> createState() => _PlayerCharacterState();
}

class _PlayerCharacterState extends State<PlayerCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  
  @override
  void initState() {
    super.initState();
    // Animasi "bernapas" (breathing/floating) terus-menerus
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        // Efek melayang perlahan naik-turun
        final floatOffset = widget.showBase ? _ctrl.value * 6.0 : 0.0;
        
        // Aura cahaya berdenyut jika pion ini adalah giliran pemain sekarang
        final glowOpacity = widget.highlighted ? 0.3 + (_ctrl.value * 0.5) : 0.0;
        
        final iconSize = widget.showBase ? widget.size * 0.55 : widget.size * 0.65;
        
        // Desain fisik kristal token (Glassmorphism & 3D look)
        final crystal = Container(
          width: widget.size * 0.9,
          height: widget.showBase ? widget.size * 1.1 : widget.size * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size * 0.45),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.4)!,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              if (widget.highlighted)
                BoxShadow(
                  color: widget.color.withValues(alpha: glowOpacity),
                  blurRadius: widget.size * 0.6,
                  spreadRadius: widget.size * 0.15,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
              // Inner highlight effect
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: -4,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pantulan cahaya di dalam kristal (Glossy reflection)
              Positioned(
                top: widget.size * 0.1,
                left: widget.size * 0.2,
                child: Container(
                  width: widget.size * 0.25,
                  height: widget.size * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Ikon karakter
              Icon(
                characterIcon(widget.type),
                size: iconSize,
                color: Colors.white,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
            ],
          ),
        );
        
        if (!widget.showBase) {
           return Transform.translate(
             offset: Offset(0, -floatOffset),
             child: crystal,
           );
        }

        // Rendering dengan Base shadow (pion di atas papan)
        return SizedBox(
          width: widget.size,
          height: widget.size * 1.4,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bayangan realistis di lantai (mengecil saat token melayang ke atas)
              Positioned(
                bottom: 2 + floatOffset * 0.5,
                child: Container(
                  width: widget.size * 0.65 - (floatOffset * 1.2),
                  height: widget.size * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45 - (_ctrl.value * 0.2)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              // Badan token kristal yang melayang
              Positioned(
                bottom: widget.size * 0.15 + floatOffset,
                child: crystal,
              ),
            ],
          ),
        );
      },
    );
  }
}
