import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/board.dart';
import '../models/tile.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/player.dart';
import 'player_token_widget.dart';

/// Standard Monopoly board layout: 40 tiles total.
///   Bottom row  : indices  0–10  (left → right, 11 tiles incl. corners)
///   Right column: indices 11–19  (bottom → top, 9 middle tiles)
///   Top row     : indices 20–30  (right → left, 11 tiles incl. corners)
///   Left column : indices 31–39  (top → bottom, 9 middle tiles)
class BoardWidget extends StatelessWidget {
  final Board board;
  final List<Player> players;
  final String? movingPlayerId;
  final Function(int)? onTileTap;

  const BoardWidget({
    super.key,
    required this.board,
    this.players = const [],
    this.movingPlayerId,
    this.onTileTap,
  });

  // ── Layout constants ────────────────────────────────────────────────────────
  // Corner tiles are square (cornerSize × cornerSize).
  // Side tiles are (sideW × cornerSize) for horizontal rows or
  // (cornerSize × sideH) for vertical columns.
  static const double cornerSize = 72.0;
  static const double sideW = 52.0; // side tile width  (horizontal rows)
  static const double sideH = 52.0; // side tile height (vertical columns)

  // Full board = cornerSize + 9×sideW + cornerSize
  static double get boardSize => cornerSize * 2 + sideW * 9;

  @override
  Widget build(BuildContext context) {
    final bs = boardSize; // ~648 px
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: bs + 160,  // extra room for perspective canvas
        height: bs + 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Drop shadow behind board ──
            Positioned(
              top: 90,
              child: Transform.rotate(
                angle: 0.785,
                child: Container(
                  width: bs - 40,
                  height: bs - 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D4C41),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 28,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Board surface (perspective transform) ──
            Positioned(
              top: 4,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateX(-0.68)
                  ..rotateZ(0.785),
                child: Container(
                  width: bs,
                  height: bs,
                  decoration: BoxDecoration(
                    color: const Color(0xFF795548),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                        blurRadius: 28,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF5D4037), width: 2.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildBoardGrid(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardGrid() {
    return Stack(
      children: [
        // ── Bottom row: tiles 0–10, left→right ────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          height: cornerSize,
          child: Row(
            children: [
              _tile(0,  w: cornerSize, h: cornerSize, isCorner: true),
              for (int i = 1; i <= 9; i++) Expanded(child: _tile(i)),
              _tile(10, w: cornerSize, h: cornerSize, isCorner: true),
            ],
          ),
        ),
        // ── Right column: tiles 11–19, bottom→top ─────────────────────────
        Positioned(
          right: 0, top: cornerSize, bottom: cornerSize,
          width: cornerSize,
          child: Column(
            children: [for (int i = 19; i >= 11; i--) Expanded(child: _tile(i))],
          ),
        ),
        // ── Top row: tiles 20–30, right→left ──────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          height: cornerSize,
          child: Row(
            children: [
              _tile(30, w: cornerSize, h: cornerSize, isCorner: true),
              for (int i = 29; i >= 21; i--) Expanded(child: _tile(i)),
              _tile(20, w: cornerSize, h: cornerSize, isCorner: true),
            ],
          ),
        ),
        // ── Left column: tiles 31–39, top→bottom ──────────────────────────
        Positioned(
          left: 0, top: cornerSize, bottom: cornerSize,
          width: cornerSize,
          child: Column(
            children: [for (int i = 31; i <= 39; i++) Expanded(child: _tile(i))],
          ),
        ),
        // ── Center ────────────────────────────────────────────────────────
        Positioned(
          top: cornerSize + 2,
          left: cornerSize + 2,
          right: cornerSize + 2,
          bottom: cornerSize + 2,
          child: _buildCenter(),
        ),
      ],
    );
  }

  // Convenience wrapper so corners can fix their size
  Widget _tile(int index, {double? w, double? h, bool isCorner = false}) {
    final inner = _buildTile(index, isCorner: isCorner);
    if (w != null && h != null) {
      return SizedBox(width: w, height: h, child: inner);
    }
    return inner;
  }

  Widget _buildCenter() {
    return Container(
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.1,
          colors: [Color(0xFF81D4FA), Color(0xFFA5D6A7), Color(0xFFFFF8E1)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18, top: 26,
            child: Icon(Icons.sailing, size: 34,
                color: Colors.white.withValues(alpha: 0.9)),
          ),
          const Positioned(
            right: 28, top: 24,
            child: Icon(Icons.temple_buddhist, size: 44, color: Color(0xFF6D4C41)),
          ),
          const Positioned(
            left: 54, bottom: 54,
            child: Icon(Icons.location_city, size: 42, color: Color(0xFFC62828)),
          ),
          const Positioned(
            right: 62, bottom: 44,
            child: Icon(Icons.forest, size: 44, color: Color(0xFF2E7D32)),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 10, offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('MONOPOLI',
                      style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 2,
                        shadows: [Shadow(color: Color(0xFF6D1B1B), offset: Offset(0, 2), blurRadius: 1)],
                      )),
                  Text('INDONESIA',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 2,
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            left: 80, right: 80, bottom: 30,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.question_mark, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int index, {bool isCorner = false}) {
    final tile = board.getTile(index);
    final playersOnTile = players
        .where((p) => p.position == index && !p.isBankrupt)
        .toList();

    return GestureDetector(
      onTap: onTileTap != null ? () => onTileTap!(index) : null,
      child: Container(
        decoration: BoxDecoration(
          color: _getTileColor(tile),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.45),
            width: 0.6,
          ),
        ),
        child: Stack(
          children: [
            // Tile content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Color bar for properties
                if (tile is Property) ...[
                  Container(
                    height: isCorner ? 12 : 10,
                    width: double.infinity,
                    color: propertyColorMap[tile.color],
                  ),
                  const SizedBox(height: 1),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  child: _buildTileArtwork(tile, isCorner: isCorner),
                ),
                // Tile name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    tile.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isCorner ? 7.5 : 6,
                      fontWeight: FontWeight.w700,
                      color: _getTileTextColor(tile),
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (tile is Property)
                  Text('Rp${tile.price}',
                      style: TextStyle(
                          fontSize: isCorner ? 6.5 : 5.5,
                          color: const Color(0xFF424242))),
                if (tile is Utility)
                  Text('Rp${tile.price}',
                      style: TextStyle(
                          fontSize: isCorner ? 6.5 : 5.5,
                          color: const Color(0xFF424242))),
                if (tile is Property && tile.houses > 0)
                  _buildHouseIndicator(tile),
              ],
            ),
            // Player tokens
            if (playersOnTile.isNotEmpty)
              Positioned(
                bottom: 2, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: playersOnTile.take(4).map((player) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: PlayerTokenWidget(
                        playerName: player.name,
                        avatarColor: player.avatarColor,
                        color: _getPlayerColor(player),
                        isCurrentPlayer: player.id ==
                            players.where((p) => !p.isBankrupt).first.id,
                        isMoving: player.id == movingPlayerId,
                        size: playersOnTile.length > 2 ? 16 : 20,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileArtwork(Tile tile, {required bool isCorner}) {
    final height = isCorner ? 30.0 : 22.0;

    final specialAsset = switch (tile.type) {
      TileType.go           => 'assets/images/tile_go.svg',
      TileType.chance       => 'assets/images/tile_chance.svg',
      TileType.communityChest => 'assets/images/tile_community.svg',
      TileType.jail         => 'assets/images/tile_jail.svg',
      TileType.freeParking  => 'assets/images/tile_parking.svg',
      TileType.goToJail     => 'assets/images/tile_gotojail.svg',
      TileType.tax          => 'assets/images/tile_tax.svg',
      _ => null,
    };

    if (specialAsset != null) {
      return SizedBox(
        height: height, width: double.infinity,
        child: SvgPicture.asset(specialAsset, fit: BoxFit.contain),
      );
    }

    if (tile is Property) {
      return SizedBox(
        height: height, width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.asset(
            _landmarkPhotoAsset(tile.index),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => SvgPicture.asset(
              _landmarkFallbackAsset(tile.description),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    if (tile is Utility) {
      final isTrain    = tile.name.toLowerCase().contains('kereta');
      final isAirport  = tile.name.toLowerCase().contains('bandara');
      final isToll     = tile.name.toLowerCase().contains('tol');
      final iconData   = isTrain   ? Icons.train_rounded
                       : isAirport ? Icons.flight_rounded
                       : isToll    ? Icons.directions_car_rounded
                       : Icons.electric_bolt_rounded;
      final startColor = isTrain || isAirport || isToll
          ? const Color(0xFFE3F2FD) : const Color(0xFFFFF8E1);
      final endColor   = isTrain || isAirport || isToll
          ? const Color(0xFF90CAF9) : const Color(0xFFFFD54F);
      final iconColor  = isTrain || isAirport || isToll
          ? const Color(0xFF1565C0) : const Color(0xFFE65100);

      return Container(
        height: height, width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [startColor, endColor]),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(iconData, size: height * 0.72, color: iconColor),
      );
    }

    return SizedBox(height: height);
  }

  String _landmarkPhotoAsset(int tileIndex) {
    const root = 'assets/images/landmarks_real';
    return switch (tileIndex) {
      1  => '$root/malioboro.jpg',
      3  => '$root/solo.jpg',
      6  => '$root/braga.jpg',
      8  => '$root/asia_afrika.jpg',
      9  => '$root/braga.jpg',
      11 => '$root/pahlawan.jpg',
      13 => '$root/pahlawan.jpg',
      14 => '$root/suramadu.jpg',
      16 => '$root/diponegoro.jpg',
      18 => '$root/lawang_sewu.jpg',
      19 => '$root/lawang_sewu.jpg',
      21 => '$root/sudirman.jpg',
      23 => '$root/thamrin.jpg',
      24 => '$root/thamrin.jpg',
      26 => '$root/malioboro.jpg', // Bali fallback
      27 => '$root/malioboro.jpg',
      29 => '$root/malioboro.jpg',
      31 => '$root/pahlawan.jpg', // Makassar fallback
      32 => '$root/pahlawan.jpg',
      34 => '$root/pahlawan.jpg',
      37 => '$root/sudirman.jpg', // Monas/Jakarta
      39 => '$root/sudirman.jpg', // Istana Negara
      _  => '$root/malioboro.jpg',
    };
  }

  String _landmarkFallbackAsset(String? city) {
    return switch (city?.toLowerCase()) {
      'bandung'  => 'assets/images/landmark_bandung.svg',
      'surabaya' => 'assets/images/landmark_surabaya.svg',
      'semarang' => 'assets/images/landmark_semarang.svg',
      'jakarta'  => 'assets/images/landmark_jakarta.svg',
      'bali'     => 'assets/images/landmark_jakarta.svg',
      'makassar' => 'assets/images/landmark_surabaya.svg',
      _          => 'assets/images/landmark_yogya.svg',
    };
  }

  Widget _buildHouseIndicator(Property property) {
    if (property.houses == 5) {
      return Container(
        margin: const EdgeInsets.only(top: 1),
        width: 12, height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFFC62828),
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Center(
          child: Text('H',
              style: TextStyle(fontSize: 4, color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(property.houses, (_) => Container(
        margin: const EdgeInsets.only(top: 1, left: 1),
        width: 5, height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: const Color(0xFF1B5E20), width: 0.4),
        ),
      )),
    );
  }

  Color _getPlayerColor(Player player) {
    switch (player.avatarColor) {
      case 'red':    return const Color(0xFFD32F2F);
      case 'blue':   return const Color(0xFF1565C0);
      case 'green':  return const Color(0xFF2E7D32);
      case 'yellow': return const Color(0xFFF9A825);
      case 'purple': return const Color(0xFF6A1B9A);
      case 'teal':   return const Color(0xFF00695C);
      default:       return Colors.grey;
    }
  }

  Color _getTileColor(Tile tile) {
    switch (tile.type) {
      case TileType.go:            return const Color(0xFFFFF9C4);
      case TileType.jail:          return const Color(0xFFBBDEFB);
      case TileType.freeParking:   return const Color(0xFFC8E6C9);
      case TileType.goToJail:      return const Color(0xFFFFCDD2);
      case TileType.chance:        return const Color(0xFFFFF3E0);
      case TileType.communityChest:return const Color(0xFFE1F5FE);
      case TileType.tax:           return const Color(0xFFFFF9C4);
      case TileType.utility:       return const Color(0xFFD7CCC8);
      case TileType.property:      return const Color(0xFFFFFFF8);
    }
  }

  Color _getTileTextColor(Tile tile) {
    switch (tile.type) {
      case TileType.go:            return const Color(0xFFC62828);
      case TileType.goToJail:      return const Color(0xFFC62828);
      case TileType.jail:          return const Color(0xFF1565C0);
      case TileType.chance:        return const Color(0xFFE65100);
      case TileType.communityChest:return const Color(0xFF0277BD);
      case TileType.tax:           return const Color(0xFFE65100);
      default:                     return const Color(0xFF212121);
    }
  }
}
