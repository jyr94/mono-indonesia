import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Manages all particle effects in the game world.
///
/// Coin rain, confetti, and build effects are spawned here.
/// Phase 2: Replace with Flame Lottie / sprite particles.
class ParticleManager extends Component {
  final Random _rng = Random();

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Rain coins from above a position (property purchase, passing GO).
  void spawnCoinRain(Vector2 origin) {
    for (int i = 0; i < 12; i++) {
      _spawnCoin(origin);
    }
  }

  /// Colorful confetti explosion (player wins).
  void spawnConfetti(Vector2 origin) {
    for (int i = 0; i < 30; i++) {
      _spawnConfetti(origin);
    }
  }

  /// Dust puff when building a house/hotel.
  void spawnBuildEffect(Vector2 tilePos) {
    for (int i = 0; i < 8; i++) {
      _spawnDust(tilePos);
    }
  }

  // ── Internal emitters ─────────────────────────────────────────────────────

  void _spawnCoin(Vector2 origin) {
    final angle = _rng.nextDouble() * pi * 2;
    final speed = 60 + _rng.nextDouble() * 120;
    final vx = cos(angle) * speed * 0.4;
    final vy = -speed;

    final particle = ParticleSystemComponent(
      position: origin + Vector2(_rng.nextDouble() * 60 - 30, 0),
      particle: AcceleratedParticle(
        acceleration: Vector2(0, 250),
        speed: Vector2(vx, vy),
        child: CircleParticle(
          radius: 5 + _rng.nextDouble() * 3,
          paint: Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.fill,
        ),
      ),
    );
    add(particle);
  }

  void _spawnConfetti(Vector2 origin) {
    const colors = [
      Color(0xFFFFD700),
      Color(0xFFE53935),
      Color(0xFF43A047),
      Color(0xFF1E88E5),
      Color(0xFFFB8C00),
      Colors.white,
    ];

    final angle = _rng.nextDouble() * pi * 2;
    final speed = 100 + _rng.nextDouble() * 200;

    final particle = ParticleSystemComponent(
      position: origin,
      particle: AcceleratedParticle(
        acceleration: Vector2(0, 180),
        speed: Vector2(cos(angle) * speed, sin(angle) * speed - 150),
        child: CircleParticle(
          radius: 4 + _rng.nextDouble() * 5,
          paint: Paint()
            ..color = colors[_rng.nextInt(colors.length)]
            ..style = PaintingStyle.fill,
        ),
      ),
    );
    add(particle);
  }

  void _spawnDust(Vector2 origin) {
    final angle = _rng.nextDouble() * pi * 2;
    final speed = 30 + _rng.nextDouble() * 60;

    final particle = ParticleSystemComponent(
      position: origin,
      particle: AcceleratedParticle(
        acceleration: Vector2(0, 40),
        speed: Vector2(cos(angle) * speed, sin(angle) * speed - 40),
        child: CircleParticle(
          radius: 3 + _rng.nextDouble() * 4,
          paint: Paint()
            ..color = const Color(0xFFBCAAA4).withValues(alpha: 0.6)
            ..style = PaintingStyle.fill,
        ),
      ),
    );
    add(particle);
  }
}
