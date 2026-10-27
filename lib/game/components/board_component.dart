import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/game_engine.dart';
import '../../models/tile.dart';
import '../../models/property.dart';
import '../../models/utility.dart';

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
  final Map<TileType, Svg> _svgs = {};
  final Map<String, ui.Image> _propertyImages = {};

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
    
    // Load SVGs
    final svgFiles = {
      TileType.go: 'images/tile_go.svg',
      TileType.chance: 'images/tile_chance.svg',
      TileType.communityChest: 'images/tile_community.svg',
      TileType.jail: 'images/tile_jail.svg',
      TileType.freeParking: 'images/tile_parking.svg',
      TileType.goToJail: 'images/tile_gotojail.svg',
      TileType.tax: 'images/tile_tax.svg',
    };

    for (final entry in svgFiles.entries) {
      try {
        _svgs[entry.key] = await Svg.load(entry.value);
      } catch (e) {
        debugPrint('Failed to load SVG ${entry.value}');
      }
    }

    // Load property images
    final propertyImagesToLoad = [
      'landmarks_real/asia_afrika.jpg',
      'landmarks_real/braga.jpg',
      'landmarks_real/diponegoro.jpg',
      'landmarks_real/lawang_sewu.jpg',
      'landmarks_real/malioboro.jpg',
      'landmarks_real/pahlawan.jpg',
      'landmarks_real/solo.jpg',
      'landmarks_real/sudirman.jpg',
      'landmarks_real/suramadu.jpg',
      'landmarks_real/thamrin.jpg',
    ];

    for (final path in propertyImagesToLoad) {
      try {
        _propertyImages[path] = await Flame.images.load(path);
      } catch (e) {
        debugPrint('Failed to load image $path');
      }
    }

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
      return position;
    }
    final rect = _tileRects[tileIndex];
    // Convert from center-relative tile coords → world coords.
    // Tile rect x,y is center-relative; add board position to get world pos.
    return position + Vector2(
      rect.x + rect.w / 2,
      rect.y + rect.h / 2,
    );
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

  /// Center of this component in local space.
  /// In Flame, children are positioned from parent's top-left (0,0).
  /// Since BoardComponent size = (_boardSide+200) × (_boardSide+200) and
  /// anchor = Anchor.center, the visual center in local space is (size/2).
  double get _cx => size.x / 2; // = (_boardSide + 200) / 2 = 460
  double get _cy => size.y / 2; // = (_boardSide + 200) / 2 = 460

  void _buildBoardBase() {
    // Outer green border — centered in local space
    final base = RectangleComponent(
      position: Vector2(_cx, _cy),
      size: Vector2(_boardSide, _boardSide),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF4E7C3F),
    );
    add(base);

    // Board inner cream surface
    final inner = RectangleComponent(
      position: Vector2(_cx, _cy),
      size: Vector2(_boardSide - 14, _boardSide - 14),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE8F5E9),
    );
    add(inner);

    // Green center area (placeholder until center art asset is ready)
    final centerArea = _BoardCenterLogo(
      position: Vector2(_cx, _cy),
      size: Vector2(
        _boardSide - _cornerSize * 2 - 4,
        _boardSide - _cornerSize * 2 - 4,
      ),
    );
    add(centerArea);
  }

  void _buildTileRects() {
    _tileRects.clear();

    final half = _boardSide / 2;

    for (int i = 0; i < 40; i++) {
      _tileRects.add(_computeTileRect(i, half));
    }

    // Add tap targets — shift positions from center-relative to local top-left-relative
    for (int i = 0; i < _tileRects.length; i++) {
      final rect = _tileRects[i];
      final tile = engine.board.getTile(i);
      
      ui.Image? tileImage;
      if (tile is Property) {
        final n = (tile.name as String).toLowerCase();
        if (n.contains('asia afrika')) { tileImage = _propertyImages['landmarks_real/asia_afrika.jpg']; }
        else if (n.contains('braga')) { tileImage = _propertyImages['landmarks_real/braga.jpg']; }
        else if (n.contains('diponegoro') || n.contains('pandanaran')) { tileImage = _propertyImages['landmarks_real/diponegoro.jpg']; }
        else if (n.contains('lawang sewu')) { tileImage = _propertyImages['landmarks_real/lawang_sewu.jpg']; }
        else if (n.contains('malioboro')) { tileImage = _propertyImages['landmarks_real/malioboro.jpg']; }
        else if (n.contains('solo')) { tileImage = _propertyImages['landmarks_real/solo.jpg']; }
        else if (n.contains('pahlawan') || n.contains('tunjungan')) { tileImage = _propertyImages['landmarks_real/pahlawan.jpg']; }
        else if (n.contains('suramadu')) { tileImage = _propertyImages['landmarks_real/suramadu.jpg']; }
        else if (n.contains('sudirman')) { tileImage = _propertyImages['landmarks_real/sudirman.jpg']; }
        else if (n.contains('thamrin') || n.contains('bundaran hi')) { tileImage = _propertyImages['landmarks_real/thamrin.jpg']; }
        else if (n.contains('penghibur') || n.contains('trans studio') || n.contains('rotterdam')) { tileImage = _propertyImages['landmarks_real/suramadu.jpg']; }
        else if (n.contains('kuta') || n.contains('seminyak') || n.contains('nusa dua')) { tileImage = _propertyImages['landmarks_real/braga.jpg']; }
        else if (n.contains('monas')) { tileImage = _propertyImages['landmarks_real/sudirman.jpg']; }
      }

      final tapTarget = _TileHitbox(
        tileIndex: i,
        localOffset: Vector2(_cx, _cy),
        rect: rect,
        onTap: onTileTap,
        tileColor: _tileColor(tile),
        engine: engine,
        svg: _svgs[(tile as dynamic).type as TileType],
        propertyImage: tileImage,
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
  final Svg? svg;
  final ui.Image? propertyImage;

  _TileHitbox({
    required this.tileIndex,
    required this.rect,
    required this.onTap,
    required Color tileColor,
    required this.engine,
    this.svg,
    this.propertyImage,
    Vector2? localOffset, // offset to convert center-origin → top-left-origin
  }) : super(
          // rect.x/y are center-relative; add localOffset to shift to top-left coords
          position: Vector2(
            rect.x + (localOffset?.x ?? 0),
            rect.y + (localOffset?.y ?? 0),
          ),
          size: Vector2(rect.w, rect.h),
          anchor: Anchor.topLeft,
          paint: Paint()
            ..color = tileColor
            ..style = PaintingStyle.fill,
        );


  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    canvas.save();

    double lw = size.x;
    double lh = size.y;
    double angle = 0;

    if (tileIndex >= 11 && tileIndex <= 19) {
      angle = -3.14159 / 2;
      lw = size.y; lh = size.x;
    } else if (tileIndex >= 21 && tileIndex <= 29) {
      angle = 3.14159;
    } else if (tileIndex >= 31 && tileIndex <= 39) {
      angle = 3.14159 / 2;
      lw = size.y; lh = size.x;
    } else if (tileIndex == 10) {
      angle = -3.14159 / 2; 
    } else if (tileIndex == 20) {
      angle = 3.14159; 
    } else if (tileIndex == 30) {
      angle = 3.14159 / 2; 
    }

    if (angle != 0) {
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(angle);
      canvas.translate(-lw / 2, -lh / 2);
    }

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawRect(Rect.fromLTWH(0, 0, lw, lh), borderPaint);

    final tile = engine.board.getTile(tileIndex);
    final isCorner = tileIndex % 10 == 0;

    // Render SVG if available (for corners, chance, tax, etc)
    if (svg != null) {
      final minDimension = lw < lh ? lw : lh;
      final renderSize = minDimension * (isCorner ? 0.6 : 0.6); 
      
      canvas.save();
      // For SVG, we center it. If it's chance/chest, we move it slightly down to make room for text.
      double dy = (lh - renderSize) / 2;
      if (!isCorner) dy += 8; 
      canvas.translate((lw - renderSize) / 2, dy);
      svg!.render(canvas, Vector2.all(renderSize));
      canvas.restore();

      if (!isCorner) {
         _drawTileText(canvas, tile, lw, lh, hasImage: false);
      }
    } else {
      bool hasImage = propertyImage != null;
      if (hasImage) {
        // Draw image covering most of the tile
        final imageRect = Rect.fromLTWH(0, 14, lw, lh - 14);
        paintImage(
          canvas: canvas,
          rect: imageRect,
          image: propertyImage!,
          fit: BoxFit.cover,
        );
        // Dark overlay so white text is readable
        final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
        canvas.drawRect(imageRect, overlayPaint);
      } else if (tile is Utility) {
        // Draw Emoji for utility
        String emoji = '🏢';
        final n = (tile.name as String).toLowerCase();
        if (n.contains('listrik')) emoji = '⚡';
        else if (n.contains('kereta')) emoji = '🚂';
        else if (n.contains('bandara')) emoji = '✈️';
        else if (n.contains('tol')) emoji = '🛣️';

        final emojiSpan = TextSpan(
          text: emoji,
          style: const TextStyle(fontSize: 24),
        );
        final emojiPainter = TextPainter(
          text: emojiSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();
        
        emojiPainter.paint(
          canvas,
          Offset((lw - emojiPainter.width) / 2, (lh - emojiPainter.height) / 2 + 4),
        );
      }

      // Property color bar
      if (tile is Property) {
        final barPaint = Paint()
          ..color = _propertyColor(tile.color)
          ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromLTWH(0, 0, lw, 14), barPaint);
      }

      // Tile label and price
      _drawTileText(canvas, tile, lw, lh, hasImage: hasImage);
    }
    
    canvas.restore();
  }

  void _drawTileText(Canvas canvas, dynamic tile, double lw, double lh, {required bool hasImage}) {
    final name = tile.name as String;
    final textColor = hasImage ? Colors.white : const Color(0xFF212121);
    
    // Draw Name
    final nameSpan = TextSpan(
      text: name,
      style: TextStyle(
        fontSize: hasImage ? 7.5 : 7.0,
        fontWeight: FontWeight.w800,
        color: textColor,
        height: 1.1,
      ),
    );
    final namePainter = TextPainter(
      text: nameSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: lw - 4);

    namePainter.paint(
      canvas,
      Offset((lw - namePainter.width) / 2, 16),
    );

    // Draw Price for properties
    if (tile is Property) {
      final priceStr = 'Rp${tile.price}';
      final priceSpan = TextSpan(
        text: priceStr,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: hasImage ? const Color(0xFFFFD54F) : const Color(0xFFB71C1C),
        ),
      );
      final pricePainter = TextPainter(
        text: priceSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: lw - 4);

      pricePainter.paint(
        canvas,
        Offset((lw - pricePainter.width) / 2, lh - 14),
      );
    }
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

// ── Board Center Logo ────────────────────────────────────────────────────────

class _BoardCenterLogo extends PositionComponent {
  _BoardCenterLogo({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    // 1. Draw green background
    final bgPaint = Paint()..color = const Color(0xFFA8D5A2);
    canvas.drawRect(size.toRect(), bgPaint);

    // 2. Rotate canvas diagonally for the logo
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(-3.14159 / 4); // -45 degrees

    // 3. Draw Red Background Banner for "MONOPOLI"
    final bannerRect = Rect.fromCenter(center: Offset.zero, width: 440, height: 100);
    final bannerPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;
    
    // Add black border to banner
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRect(bannerRect, bannerPaint);
    canvas.drawRect(bannerRect, borderPaint);

    // 4. Draw "MONOPOLI" Text
    final monoSpan = const TextSpan(
      text: 'MONOPOLI',
      style: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 10.0,
      ),
    );
    
    final monoPainter = TextPainter(
      text: monoSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    
    // Add text shadow
    final shadowSpan = TextSpan(
      text: 'MONOPOLI',
      style: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        letterSpacing: 10.0,
      ),
    );
    final shadowPainter = TextPainter(
      text: shadowSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    shadowPainter.paint(
      canvas,
      Offset(-monoPainter.width / 2 + 4, -monoPainter.height / 2 + 4),
    );
    monoPainter.paint(
      canvas,
      Offset(-monoPainter.width / 2, -monoPainter.height / 2),
    );

    // 5. Draw "INDONESIA" Text below the banner
    final indoSpan = const TextSpan(
      text: 'INDONESIA',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32), // Dark Green
        letterSpacing: 16.0,
      ),
    );
    final indoPainter = TextPainter(
      text: indoSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    
    indoPainter.paint(
      canvas,
      Offset(-indoPainter.width / 2, bannerRect.bottom + 12),
    );

    canvas.restore();
  }
}
