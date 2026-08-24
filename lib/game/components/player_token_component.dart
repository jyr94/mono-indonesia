import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../models/player.dart';

/// Renders a player token as an animated Flame component.
///
/// Phase 1: Rendered with CustomPainter (colored circle + initial).
/// Phase 2: Replace [_buildSprite] with SpriteAnimationComponent
///           when character sprite sheets are ready.
class PlayerTokenComponent extends PositionComponent {
  final Player player;
  final int playerIndex;

  // Placeholder circle painter until real sprites arrive
  late _TokenPainter _painter;

  PlayerTokenComponent({
    required this.player,
    required Vector2 tilePosition,
    required this.playerIndex,
  }) : super(
          size: Vector2(28, 28),
          anchor: Anchor.center,
          position: tilePosition,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _painter = _TokenPainter(player: player, playerIndex: playerIndex);
    add(_CustomPainterComponent(painter: _painter, size: size));

    // Idle bobbing animation
    add(
      MoveEffect.by(
        Vector2(0, -4),
        EffectController(
          duration: 0.8,
          reverseDuration: 0.8,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Instantly snap to a new position (no animation).
  void snapToPosition(Vector2 target) {
    position = target;
  }

  /// Walk smoothly through [path] of world positions.
  Future<void> walkPath(List<Vector2> path) async {
    for (final waypoint in path) {
      final dist = position.distanceTo(waypoint);
      final duration = (dist / 300).clamp(0.05, 0.25);
      await add(
        MoveToEffect(
          waypoint,
          EffectController(duration: duration, curve: Curves.easeInOut),
        ),
      );
      await Future<void>.delayed(
        Duration(milliseconds: (duration * 1000 * 0.8).round()),
      );
    }
  }

  /// Play a celebrate bounce animation (used on win/purchase).
  Future<void> celebrate() async {
    await add(
      MoveEffect.by(
        Vector2(0, -20),
        EffectController(
          duration: 0.2,
          reverseDuration: 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  // ── Highlight current player ───────────────────────────────────────────────

  void setActive(bool active) {
    _painter.isActive = active;
  }
}

// ── Placeholder painter ───────────────────────────────────────────────────────

class _TokenPainter {
  final Player player;
  final int playerIndex;
  bool isActive;

  _TokenPainter({
    required this.player,
    required this.playerIndex,
    this.isActive = false,
  });

  static const _colors = [
    Color(0xFFD32F2F), // red
    Color(0xFF1565C0), // blue
    Color(0xFF2E7D32), // green
    Color(0xFFF9A825), // yellow
  ];

  static const _icons = ['K', 'P', 'T', 'S']; // Komodo, Pendekar, Tani, Saudagar

  Color get color => _colors[playerIndex % _colors.length];
  String get initial => _icons[playerIndex % _icons.length];
}

/// Thin wrapper to embed a custom painter as Flame component.
class _CustomPainterComponent extends PositionComponent {
  final _TokenPainter painter;

  _CustomPainterComponent({required this.painter, required Vector2 size})
      : super(size: size);

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final center = Offset(r, r);

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 3), r * 0.9, shadowPaint);

    // Body
    final bodyPaint = Paint()..color = painter.color;
    canvas.drawCircle(center, r, bodyPaint);

    // Active ring
    if (painter.isActive) {
      final ringPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(center, r + 2, ringPaint);
    }

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, r, borderPaint);

    // Initial letter
    final span = TextSpan(
      text: painter.initial,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }
}
