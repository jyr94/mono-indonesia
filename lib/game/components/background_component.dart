import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Parallax-style background with multiple layers.
///
/// Phase 1: Drawn with gradient + simple animated shapes.
/// Phase 2: Replace layers with actual PNG assets (bg_sky, bg_mountains, etc.)
class BackgroundComponent extends PositionComponent {
  late _SkyLayer _sky;
  late _IslandLayer _islands;
  late _CloudLayer _clouds;

  BackgroundComponent()
      : super(
          position: Vector2(-600, -500),
          size: Vector2(1200, 1000),
          priority: -10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _sky = _SkyLayer();
    _islands = _IslandLayer();
    _clouds = _CloudLayer();

    add(_sky);
    add(_islands);
    add(_clouds);
  }
}

// ── Sky Layer ──────────────────────────────────────────────────────────────────

class _SkyLayer extends PositionComponent {
  _SkyLayer() : super(size: Vector2(1200, 1000));

  @override
  void render(Canvas canvas) {
    // Gradient sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A6BD0), // Deep sky blue
          Color(0xFF56A5EC), // Mid blue
          Color(0xFF87CEEB), // Sky blue
          Color(0xFF98D8C8), // Horizon teal
        ],
        stops: [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyPaint);

    // Ocean at bottom
    final seaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF26C6DA),
          Color(0xFF00838F),
        ],
      ).createShader(Rect.fromLTWH(0, 750, size.x, 250));
    canvas.drawRect(Rect.fromLTWH(0, 750, size.x, 250), seaPaint);

    // Distant mountain silhouettes
    _drawMountains(canvas);
  }

  void _drawMountains(Canvas canvas) {
    final mountainPaint = Paint()
      ..color = const Color(0xFF2D5A87).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 680);
    path.lineTo(80, 550);
    path.lineTo(160, 620);
    path.lineTo(260, 490);
    path.lineTo(380, 590);
    path.lineTo(480, 520);
    path.lineTo(600, 480);
    path.lineTo(720, 540);
    path.lineTo(840, 500);
    path.lineTo(960, 560);
    path.lineTo(1080, 510);
    path.lineTo(1200, 580);
    path.lineTo(1200, 750);
    path.lineTo(0, 750);
    path.close();
    canvas.drawPath(path, mountainPaint);

    // Nearer mountains
    final mountain2Paint = Paint()
      ..color = const Color(0xFF1A3D5C).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(0, 720);
    path2.lineTo(120, 620);
    path2.lineTo(220, 680);
    path2.lineTo(340, 600);
    path2.lineTo(460, 650);
    path2.lineTo(600, 590);
    path2.lineTo(740, 640);
    path2.lineTo(880, 600);
    path2.lineTo(1000, 660);
    path2.lineTo(1200, 620);
    path2.lineTo(1200, 750);
    path2.lineTo(0, 750);
    path2.close();
    canvas.drawPath(path2, mountain2Paint);
  }
}

// ── Island Layer ───────────────────────────────────────────────────────────────

class _IslandLayer extends PositionComponent {
  _IslandLayer() : super(size: Vector2(1200, 1000));

  @override
  void render(Canvas canvas) {
    _drawIsland(canvas, const Offset(180, 700), 80, 35);
    _drawIsland(canvas, const Offset(900, 710), 100, 40);
    _drawIsland(canvas, const Offset(550, 720), 60, 25);
  }

  void _drawIsland(Canvas canvas, Offset center, double w, double h) {
    // Water base
    final islandPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addOval(Rect.fromCenter(center: center, width: w * 2, height: h));
    canvas.drawPath(path, islandPaint);

    // Beach rim
    final beachPaint = Paint()
      ..color = const Color(0xFFFFF176)
      ..style = PaintingStyle.fill;
    final beachPath = Path()
      ..addOval(Rect.fromCenter(
          center: center + const Offset(5, 3), width: w * 1.6, height: h * 0.7));
    canvas.drawPath(beachPath, beachPaint);

    // Mini palm tree
    _drawPalm(canvas, center - Offset(w * 0.1, h * 0.4));
  }

  void _drawPalm(Canvas canvas, Offset base) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base + const Offset(-5, -25), trunkPaint);

    final leafPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(base + const Offset(-8, -28), 12, leafPaint);
    canvas.drawCircle(base + const Offset(2, -30), 10, leafPaint);
  }
}

// ── Cloud Layer (Animated) ─────────────────────────────────────────────────────

class _CloudLayer extends PositionComponent {
  _CloudLayer() : super(size: Vector2(1200, 1000));

  final List<_CloudData> _clouds = [
    _CloudData(x: 100, y: 80, w: 120, speed: 8),
    _CloudData(x: 350, y: 120, w: 90, speed: 12),
    _CloudData(x: 650, y: 60, w: 150, speed: 7),
    _CloudData(x: 900, y: 100, w: 110, speed: 10),
  ];

  @override
  void update(double dt) {
    super.update(dt);
    for (final c in _clouds) {
      c.x += c.speed * dt;
      if (c.x > 1250) c.x = -150;
    }
  }

  @override
  void render(Canvas canvas) {
    for (final cloud in _clouds) {
      _drawCloud(canvas, Offset(cloud.x, cloud.y), cloud.w);
    }
  }

  void _drawCloud(Canvas canvas, Offset pos, double w) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final h = w * 0.5;

    // Multi-circle cloud shape
    canvas.drawCircle(pos, h * 0.6, cloudPaint);
    canvas.drawCircle(pos + Offset(w * 0.25, h * 0.1), h * 0.45, cloudPaint);
    canvas.drawCircle(pos + Offset(-w * 0.25, h * 0.1), h * 0.4, cloudPaint);
    canvas.drawCircle(pos + Offset(w * 0.5, h * 0.2), h * 0.35, cloudPaint);

    // Flat bottom
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - w * 0.5, pos.dy + h * 0.1, w, h * 0.4),
      cloudPaint,
    );
  }
}

class _CloudData {
  double x;
  double y;
  double w;
  double speed;
  _CloudData({required this.x, required this.y, required this.w, required this.speed});
}
