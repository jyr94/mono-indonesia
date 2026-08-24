import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/game_engine.dart';
import '../../models/tile.dart';
import '../../models/property.dart';

/// Isometric 2.5D board rendered as a Flame PositionComponent.
///
/// Coordinate system: board center at world (0, 0).
/// Each tile is [_tileSize] × [_tileSize] in screen units.
///
/// Tile layout (40 tiles):
///   Bottom row  : 0–10  (left → right)
///   Right column: 11–19 (bottom → top)
///   Top row     : 20–30 (right → left)
///   Left column : 31–39 (top → bottom)
class BoardComponent extends PositionComponent {
  final Function(int tileIndex) onTileTap;
  GameEngine engine;

  static const double _tileSize = 60.0;
  static const double _cornerSize = 90.0;
  static const int _sideTiles = 9;

  // Total board side length: 2 corners + 9 side tiles
  static const double _boardSide = _cornerSize * 2 + _tileSize * _sideTiles;

  // Isometric transform factors
  static const double _isoAngleX = -0.5; // radians tilt
  static const double _isoScale = 0.85;

  final List<_TileRect> _tileRects = [];
  late RectangleComponent _boardBase;

  BoardComponent({
    required this.engine,
    required this.onTileTap,
  }) : super(
          anchor: Anchor.center,
          size: Vector2(_boardSide + 200, _boardSide + 200),
          position: Vector2.zero(),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildBoardBase();
    _buildTileRects();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  @override
  // ignore: overridden_fields
  Vector2 get center => position;

  /// Get world-space position of a tile center (for token placement).
  Vector2 tileWorldPosition(int tileIndex) {
    if (tileIndex < 0 || tileIndex >= _tileRects.length) {
      return Vector2.zero();
    }
    final rect = _tileRects[tileIndex];
    final localCenter = Vector2(
      rect.x + rect.w / 2,
      rect.y + rect.h / 2,
    );
    return _applyIsometricTransform(localCenter);
  }

  /// Ordered list of world positions from [from] to [to] for walk animation.
  List<Vector2> pathPositions(int from, int to) {
    final path = <int>[];
    int cur = from;
    const total = 40;
    while (cur != to) {
      cur = (cur + 1) % total;
      path.add(cur);
    }
    return path.map(tileWorldPosition).toList();
  }

  /// Called when GameEngine state changes — redraws tile highlights.
  void refresh(GameEngine newEngine) {
    engine = newEngine;
    // Future: update tile overlay colors based on ownership
  }

  // ── Build board ────────────────────────────────────────────────────────────

  void _buildBoardBase() {
    final base = RectangleComponent(
      size: Vector2(_boardSide, _boardSide),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF4E7C3F),
    );
    add(base);

    // Board inner surface
    final inner = RectangleComponent(
      size: Vector2(_boardSide - 14, _boardSide - 14),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE8F5E9),
    );
    add(inner);

    // Center label (placeholder until center art asset is ready)
    final centerArea = RectangleComponent(
      size: Vector2(
        _boardSide - _cornerSize * 2 - 4,
        _boardSide - _cornerSize * 2 - 4,
      ),
      anchor: Anchor.center,
      paint: Paint()
        ..color = const Color(0xFFA8D5A2)
        ..style = PaintingStyle.fill,
    );
    add(centerArea);
  }

  void _buildTileRects() {
    _tileRects.clear();

    final half = _boardSide / 2;

    // Pre-compute positions in local "flat board" coordinates
    // Origin at board top-left corner

    for (int i = 0; i < 40; i++) {
      _tileRects.add(_computeTileRect(i, half));
    }

    // Add tap targets
    for (int i = 0; i < _tileRects.length; i++) {
      final rect = _tileRects[i];
      final tapTarget = _TileHitbox(
        tileIndex: i,
        rect: rect,
        onTap: onTileTap,
        tileColor: _tileColor(engine.board.getTile(i)),
        engine: engine,
      );
      add(tapTarget);
    }
  }

  _TileRect _computeTileRect(int index, double half) {
    double x, y, w, h;

    if (index == 0) {
      // Bottom-left corner (GO)
      x = -half;
      y = half - _cornerSize;
      w = h = _cornerSize;
    } else if (index <= 9) {
      // Bottom row, left→right
      x = -half + _cornerSize + (index - 1) * _tileSize;
      y = half - _cornerSize;
      w = _tileSize;
      h = _cornerSize;
    } else if (index == 10) {
      // Bottom-right corner (Jail)
      x = half - _cornerSize;
      y = half - _cornerSize;
      w = h = _cornerSize;
    } else if (index <= 19) {
      // Right column, bottom→top
      x = half - _cornerSize;
      y = half - _cornerSize - (index - 10) * _tileSize;
      w = _cornerSize;
      h = _tileSize;
    } else if (index == 20) {
      // Top-right corner (Free Parking)
      x = half - _cornerSize;
      y = -half;
      w = h = _cornerSize;
    } else if (index <= 29) {
      // Top row, right→left
      x = half - _cornerSize - (index - 20) * _tileSize;
      y = -half;
      w = _tileSize;
      h = _cornerSize;
    } else if (index == 30) {
      // Top-left corner (Go To Jail)
      x = -half;
      y = -half;
      w = h = _cornerSize;
    } else {
      // Left column, top→bottom
      x = -half;
      y = -half + _cornerSize + (index - 31) * _tileSize;
      w = _cornerSize;
      h = _tileSize;
    }

    return _TileRect(x: x, y: y, w: w, h: h);
  }

  Vector2 _applyIsometricTransform(Vector2 flat) {
    // Simple isometric: rotate + scale. In Flame we use the component's
    // own transform so we just return flat coords here (transform applied
    // at game level via camera angle).
    return flat + position;
  }

  Color _tileColor(dynamic tile) {
    if (tile is Property) return const Color(0xFFFFFFF8);
    return switch ((tile as dynamic).type as TileType) {
      TileType.go => const Color(0xFFFFF9C4),
      TileType.jail => const Color(0xFFBBDEFB),
      TileType.freeParking => const Color(0xFFC8E6C9),
      TileType.goToJail => const Color(0xFFFFCDD2),
      TileType.chance => const Color(0xFFFFF3E0),
      TileType.communityChest => const Color(0xFFE1F5FE),
      TileType.tax => const Color(0xFFFFF9C4),
      TileType.utility => const Color(0xFFD7CCC8),
      TileType.property => const Color(0xFFFFFFF8),
    };
  }
}

// ── Internal data ─────────────────────────────────────────────────────────────

class _TileRect {
  final double x, y, w, h;
  const _TileRect({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

/// Tappable hitbox overlay for each tile (until Flame Tiled integration).
class _TileHitbox extends RectangleComponent with TapCallbacks {
  final int tileIndex;
  final _TileRect rect;
  final Function(int) onTap;
  final GameEngine engine;

  _TileHitbox({
    required this.tileIndex,
    required this.rect,
    required this.onTap,
    required Color tileColor,
    required this.engine,
  }) : super(
          position: Vector2(rect.x, rect.y),
          size: Vector2(rect.w, rect.h),
          anchor: Anchor.topLeft,
          paint: Paint()
            ..color = tileColor
            ..style = PaintingStyle.fill,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawRect(size.toRect(), borderPaint);

    // Property color bar
    final tile = engine.board.getTile(tileIndex);
    if (tile is Property) {
      final barPaint = Paint()
        ..color = _propertyColor(tile.color)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 8), barPaint);
    }

    // Tile label
    _drawTileLabel(canvas, tile);
  }

  void _drawTileLabel(Canvas canvas, dynamic tile) {
    final name = tile.name as String;
    final span = TextSpan(
      text: name,
      style: const TextStyle(
        fontSize: 5.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF212121),
        height: 1.1,
      ),
    );
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x - 4);

    tp.paint(
      canvas,
      Offset(
        (size.x - tp.width) / 2,
        size.y / 2 - tp.height / 2 + 4,
      ),
    );
  }

  Color _propertyColor(PropertyColor color) {
    return switch (color) {
      PropertyColor.brown => const Color(0xFF795548),
      PropertyColor.lightBlue => const Color(0xFF81D4FA),
      PropertyColor.pink => const Color(0xFFF48FB1),
      PropertyColor.orange => const Color(0xFFFFB74D),
      PropertyColor.red => const Color(0xFFE53935),
      PropertyColor.yellow => const Color(0xFFFFEE58),
      PropertyColor.green => const Color(0xFF4CAF50),
      PropertyColor.darkBlue => const Color(0xFF1565C0),
    };
  }

  @override
  bool onTapUp(TapUpEvent event) {
    onTap(tileIndex);
    return true;
  }
}
