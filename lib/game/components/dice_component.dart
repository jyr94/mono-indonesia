import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// 3D-style dice component using Flame Canvas rendering.
///
/// Phase 1: Drawn with CustomPainter for polished 3D look.
/// Phase 2: Replace with SpriteAnimationComponent using dice sprite sheet.
class DiceComponent extends PositionComponent {
  int _value1 = 1;
  int _value2 = 1;
  bool _isRolling = false;
  double _rollProgress = 0;

  // Random values shown during roll animation
  int _displayVal1 = 1;
  int _displayVal2 = 1;

  late _DieFaceComponent _die1;
  late _DieFaceComponent _die2;

  DiceComponent()
      : super(
          size: Vector2(120, 60),
          anchor: Anchor.center,
          // Center of the screen
          position: Vector2(0, 0),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _die1 = _DieFaceComponent(value: 1, position: Vector2(0, 0));
    _die2 = _DieFaceComponent(value: 1, position: Vector2(65, 0));

    add(_die1);
    add(_die2);

    // Idle subtle float
    add(
      MoveEffect.by(
        Vector2(0, -3),
        EffectController(
          duration: 1.5,
          reverseDuration: 1.5,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Show face values without animation (sync result from server).
  void showResult(int die1, int die2) {
    _value1 = die1;
    _value2 = die2;
    _isRolling = false;
    _die1.setValue(die1);
    _die2.setValue(die2);
  }

  /// Animate rolling then settle on [die1], [die2].
  /// Returns a Future that completes when animation ends.
  Future<void> rollAnimation(int die1, int die2) async {
    _isRolling = true;
    _value1 = die1;
    _value2 = die2;

    final rng = Random();
    const totalDuration = Duration(milliseconds: 900);
    final end = DateTime.now().add(totalDuration);

    // Rapid random face changes
    while (DateTime.now().isBefore(end)) {
      _die1.setValue(rng.nextInt(6) + 1);
      _die2.setValue(rng.nextInt(6) + 1);

      // Wobble effect
      _die1.wobble();
      _die2.wobble();

      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    // Settle on final values
    _die1.setValue(die1);
    _die2.setValue(die2);
    _die1.bounce();
    _die2.bounce();

    await Future<void>.delayed(const Duration(milliseconds: 400));
    _isRolling = false;
  }
}

// ── Single Die Face ───────────────────────────────────────────────────────────

class _DieFaceComponent extends PositionComponent {
  int _value;
  double _wobbleAngle = 0;

  _DieFaceComponent({required int value, required Vector2 position})
      : _value = value,
        super(size: Vector2(52, 52), position: position, anchor: Anchor.topLeft);

  void setValue(int v) {
    _value = v.clamp(1, 6);
  }

  void wobble() {
    final rng = Random();
    _wobbleAngle = (rng.nextDouble() - 0.5) * 0.4;
    add(
      RotateEffect.to(
        _wobbleAngle,
        EffectController(duration: 0.05),
      ),
    );
  }

  void bounce() {
    add(
      MoveEffect.by(
        Vector2(0, -12),
        EffectController(
          duration: 0.15,
          reverseDuration: 0.2,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(10),
    );

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 6, size.x, size.y),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    // Dice body gradient (simulated 3D)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFEEEEEE)],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRRect(rect, bodyPaint);

    // Left edge (3D side)
    final sidePaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x - 5, 3, 5, size.y - 3),
        const Radius.circular(3),
      ),
      sidePaint,
    );

    // Bottom edge
    final bottomPaint = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, size.y - 5, size.x - 3, 5),
        const Radius.circular(3),
      ),
      bottomPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rect, borderPaint);

    // Dots
    _drawDots(canvas, _value);
  }

  void _drawDots(Canvas canvas, int value) {
    final dotPaint = Paint()..color = const Color(0xFFCC0000);
    const r = 5.0;
    final cx = size.x / 2;
    final cy = size.y / 2;
    const off = 14.0;

    final positions = switch (value) {
      1 => [Offset(cx, cy)],
      2 => [Offset(cx - off, cy - off), Offset(cx + off, cy + off)],
      3 => [
          Offset(cx - off, cy - off),
          Offset(cx, cy),
          Offset(cx + off, cy + off)
        ],
      4 => [
          Offset(cx - off, cy - off),
          Offset(cx + off, cy - off),
          Offset(cx - off, cy + off),
          Offset(cx + off, cy + off)
        ],
      5 => [
          Offset(cx - off, cy - off),
          Offset(cx + off, cy - off),
          Offset(cx, cy),
          Offset(cx - off, cy + off),
          Offset(cx + off, cy + off)
        ],
      6 => [
          Offset(cx - off, cy - off),
          Offset(cx + off, cy - off),
          Offset(cx - off, cy),
          Offset(cx + off, cy),
          Offset(cx - off, cy + off),
          Offset(cx + off, cy + off)
        ],
      _ => <Offset>[],
    };

    for (final pos in positions) {
      canvas.drawCircle(pos, r, dotPaint);
    }
  }
}
