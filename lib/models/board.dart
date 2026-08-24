import 'package:flutter/material.dart';

import 'tile.dart';
import 'property.dart';
import 'utility.dart';

class Board {
  final List<Tile> tiles;

  const Board({required this.tiles});

  // ---------------------------------------------------------------------------
  // Standard 40-tile Indonesian Monopoly board
  //
  // Layout (clockwise from GO at index 0):
  //   Bottom row  : 0–10   (GO → Jail/Visiting)
  //   Right col   : 11–19  (Pink / Orange properties)
  //   Top row     : 20–30  (GoToJail → Red / Yellow)
  //   Left col    : 31–39  (Green / DarkBlue properties)
  // ---------------------------------------------------------------------------
  static Board createIndonesianBoard() {
    return Board(tiles: [
      // ── Bottom row (left→right, indices 0–10) ─────────────────────────────
      // 0 — GO
      const Tile(index: 0, name: 'GO', type: TileType.go, description: 'Kumpulkan Rp 200'),

      // 1 — Brown
      const Property(
        index: 1, name: 'Jalan Malioboro', price: 60, baseRent: 2,
        rentWith1House: 10, rentWith2Houses: 30, rentWith3Houses: 90,
        rentWith4Houses: 160, rentWithHotel: 250, houseCost: 50,
        color: PropertyColor.brown, description: 'Yogyakarta',
      ),

      // 2 — Community Chest
      const Tile(index: 2, name: 'Dana Umum', type: TileType.communityChest),

      // 3 — Brown
      const Property(
        index: 3, name: 'Jalan Solo', price: 60, baseRent: 4,
        rentWith1House: 20, rentWith2Houses: 60, rentWith3Houses: 180,
        rentWith4Houses: 320, rentWithHotel: 450, houseCost: 50,
        color: PropertyColor.brown, description: 'Yogyakarta',
      ),

      // 4 — Tax
      const Tile(index: 4, name: 'Pajak Penghasilan', type: TileType.tax, description: 'Bayar Rp 200'),

      // 5 — Utility (Train)
      Utility(index: 5, name: 'Kereta Trans-Jawa', price: 200, description: 'Stasiun Kereta'),

      // 6 — Light Blue
      const Property(
        index: 6, name: 'Jalan Braga', price: 100, baseRent: 6,
        rentWith1House: 30, rentWith2Houses: 90, rentWith3Houses: 270,
        rentWith4Houses: 400, rentWithHotel: 550, houseCost: 50,
        color: PropertyColor.lightBlue, description: 'Bandung',
      ),

      // 7 — Chance
      const Tile(index: 7, name: 'Kesempatan', type: TileType.chance),

      // 8 — Light Blue
      const Property(
        index: 8, name: 'Jalan Asia Afrika', price: 100, baseRent: 6,
        rentWith1House: 30, rentWith2Houses: 90, rentWith3Houses: 270,
        rentWith4Houses: 400, rentWithHotel: 550, houseCost: 50,
        color: PropertyColor.lightBlue, description: 'Bandung',
      ),

      // 9 — Light Blue
      const Property(
        index: 9, name: 'Braga City Walk', price: 120, baseRent: 8,
        rentWith1House: 40, rentWith2Houses: 100, rentWith3Houses: 300,
        rentWith4Houses: 450, rentWithHotel: 600, houseCost: 50,
        color: PropertyColor.lightBlue, description: 'Bandung',
      ),

      // 10 — Jail / Just Visiting
      const Tile(index: 10, name: 'Penjara', type: TileType.jail, description: 'Hanya Kunjungan'),

      // ── Right column (top→bottom, indices 11–19) ──────────────────────────
      // 11 — Pink
      const Property(
        index: 11, name: 'Jalan Pahlawan', price: 140, baseRent: 10,
        rentWith1House: 50, rentWith2Houses: 150, rentWith3Houses: 450,
        rentWith4Houses: 625, rentWithHotel: 750, houseCost: 100,
        color: PropertyColor.pink, description: 'Surabaya',
      ),

      // 12 — Utility (Electric)
      Utility(index: 12, name: 'PLN Listrik', price: 150, description: 'Perusahaan Listrik'),

      // 13 — Pink
      const Property(
        index: 13, name: 'Jalan Tunjungan', price: 140, baseRent: 10,
        rentWith1House: 50, rentWith2Houses: 150, rentWith3Houses: 450,
        rentWith4Houses: 625, rentWithHotel: 750, houseCost: 100,
        color: PropertyColor.pink, description: 'Surabaya',
      ),

      // 14 — Pink
      const Property(
        index: 14, name: 'Jembatan Suramadu', price: 160, baseRent: 12,
        rentWith1House: 60, rentWith2Houses: 180, rentWith3Houses: 500,
        rentWith4Houses: 700, rentWithHotel: 900, houseCost: 100,
        color: PropertyColor.pink, description: 'Surabaya',
      ),

      // 15 — Free Parking
      const Tile(index: 15, name: 'Parkir Gratis', type: TileType.freeParking),

      // 16 — Orange
      const Property(
        index: 16, name: 'Jalan Diponegoro', price: 180, baseRent: 14,
        rentWith1House: 70, rentWith2Houses: 200, rentWith3Houses: 550,
        rentWith4Houses: 750, rentWithHotel: 950, houseCost: 100,
        color: PropertyColor.orange, description: 'Semarang',
      ),

      // 17 — Community Chest
      const Tile(index: 17, name: 'Dana Umum', type: TileType.communityChest),

      // 18 — Orange
      const Property(
        index: 18, name: 'Jalan Pandanaran', price: 180, baseRent: 14,
        rentWith1House: 70, rentWith2Houses: 200, rentWith3Houses: 550,
        rentWith4Houses: 750, rentWithHotel: 950, houseCost: 100,
        color: PropertyColor.orange, description: 'Semarang',
      ),

      // 19 — Orange
      const Property(
        index: 19, name: 'Lawang Sewu', price: 200, baseRent: 16,
        rentWith1House: 80, rentWith2Houses: 220, rentWith3Houses: 600,
        rentWith4Houses: 800, rentWithHotel: 1000, houseCost: 100,
        color: PropertyColor.orange, description: 'Semarang',
      ),

      // ── Top row (right→left, indices 20–30) ───────────────────────────────
      // 20 — Go To Jail
      const Tile(index: 20, name: 'Masuk Penjara', type: TileType.goToJail),

      // 21 — Red
      const Property(
        index: 21, name: 'Jalan Sudirman', price: 220, baseRent: 18,
        rentWith1House: 90, rentWith2Houses: 250, rentWith3Houses: 700,
        rentWith4Houses: 875, rentWithHotel: 1050, houseCost: 150,
        color: PropertyColor.red, description: 'Jakarta',
      ),

      // 22 — Chance
      const Tile(index: 22, name: 'Kesempatan', type: TileType.chance),

      // 23 — Red
      const Property(
        index: 23, name: 'Jalan Thamrin', price: 220, baseRent: 18,
        rentWith1House: 90, rentWith2Houses: 250, rentWith3Houses: 700,
        rentWith4Houses: 875, rentWithHotel: 1050, houseCost: 150,
        color: PropertyColor.red, description: 'Jakarta',
      ),

      // 24 — Red
      const Property(
        index: 24, name: 'Bundaran HI', price: 240, baseRent: 20,
        rentWith1House: 100, rentWith2Houses: 300, rentWith3Houses: 750,
        rentWith4Houses: 925, rentWithHotel: 1100, houseCost: 150,
        color: PropertyColor.red, description: 'Jakarta',
      ),

      // 25 — Utility (Airport)
      Utility(index: 25, name: 'Bandara Soekarno-Hatta', price: 200, description: 'Bandar Udara'),

      // 26 — Yellow
      const Property(
        index: 26, name: 'Kuta Beach', price: 260, baseRent: 22,
        rentWith1House: 110, rentWith2Houses: 330, rentWith3Houses: 800,
        rentWith4Houses: 975, rentWithHotel: 1150, houseCost: 150,
        color: PropertyColor.yellow, description: 'Bali',
      ),

      // 27 — Yellow
      const Property(
        index: 27, name: 'Seminyak', price: 260, baseRent: 22,
        rentWith1House: 110, rentWith2Houses: 330, rentWith3Houses: 800,
        rentWith4Houses: 975, rentWithHotel: 1150, houseCost: 150,
        color: PropertyColor.yellow, description: 'Bali',
      ),

      // 28 — Community Chest
      const Tile(index: 28, name: 'Dana Umum', type: TileType.communityChest),

      // 29 — Yellow
      const Property(
        index: 29, name: 'Nusa Dua', price: 280, baseRent: 24,
        rentWith1House: 120, rentWith2Houses: 360, rentWith3Houses: 850,
        rentWith4Houses: 1025, rentWithHotel: 1200, houseCost: 150,
        color: PropertyColor.yellow, description: 'Bali',
      ),

      // 30 — Tax
      const Tile(index: 30, name: 'Pajak Mewah', type: TileType.tax, description: 'Bayar Rp 100'),

      // ── Left column (bottom→top, indices 31–39) ───────────────────────────
      // 31 — Green
      const Property(
        index: 31, name: 'Jalan Penghibur', price: 300, baseRent: 26,
        rentWith1House: 130, rentWith2Houses: 390, rentWith3Houses: 900,
        rentWith4Houses: 1100, rentWithHotel: 1275, houseCost: 200,
        color: PropertyColor.green, description: 'Makassar',
      ),

      // 32 — Green
      const Property(
        index: 32, name: 'Trans Studio Makassar', price: 300, baseRent: 26,
        rentWith1House: 130, rentWith2Houses: 390, rentWith3Houses: 900,
        rentWith4Houses: 1100, rentWithHotel: 1275, houseCost: 200,
        color: PropertyColor.green, description: 'Makassar',
      ),

      // 33 — Chance
      const Tile(index: 33, name: 'Kesempatan', type: TileType.chance),

      // 34 — Green
      const Property(
        index: 34, name: 'Fort Rotterdam', price: 320, baseRent: 28,
        rentWith1House: 150, rentWith2Houses: 450, rentWith3Houses: 1000,
        rentWith4Houses: 1200, rentWithHotel: 1400, houseCost: 200,
        color: PropertyColor.green, description: 'Makassar',
      ),

      // 35 — Utility (Toll)
      Utility(index: 35, name: 'Jalan Tol Trans Sumatera', price: 200, description: 'Jalan Tol'),

      // 36 — Community Chest
      const Tile(index: 36, name: 'Dana Umum', type: TileType.communityChest),

      // 37 — Dark Blue
      const Property(
        index: 37, name: 'Monas', price: 350, baseRent: 35,
        rentWith1House: 175, rentWith2Houses: 500, rentWith3Houses: 1100,
        rentWith4Houses: 1300, rentWithHotel: 1500, houseCost: 200,
        color: PropertyColor.darkBlue, description: 'Jakarta',
      ),

      // 38 — Tax
      const Tile(index: 38, name: 'Pajak Properti', type: TileType.tax, description: 'Bayar Rp 75'),

      // 39 — Dark Blue
      const Property(
        index: 39, name: 'Istana Negara', price: 400, baseRent: 50,
        rentWith1House: 200, rentWith2Houses: 600, rentWith3Houses: 1400,
        rentWith4Houses: 1700, rentWithHotel: 2000, houseCost: 200,
        color: PropertyColor.darkBlue, description: 'Jakarta',
      ),
    ]);
  }

  Tile getTile(int index) => tiles[index % tiles.length];

  Property? getProperty(int index) {
    final tile = tiles[index];
    if (tile is Property) return tile;
    return null;
  }

  Utility? getUtility(int index) {
    final tile = tiles[index];
    if (tile is Utility) return tile;
    return null;
  }

  int get totalTiles => tiles.length;

  List<Property> getPropertiesByColor(PropertyColor color) {
    return tiles.whereType<Property>().where((p) => p.color == color).toList();
  }

  bool playerOwnsFullColorSet(String playerId, PropertyColor color) {
    final properties = getPropertiesByColor(color);
    return properties.isNotEmpty && properties.every((p) => p.owner == playerId);
  }

  int countUtilitiesOwned(String playerId) {
    return tiles.whereType<Utility>().where((u) => u.owner == playerId).length;
  }

  List<Property> getAllPropertiesOwnedBy(String playerId) {
    return tiles.whereType<Property>().where((p) => p.owner == playerId).toList();
  }

  List<Utility> getAllUtilitiesOwnedBy(String playerId) {
    return tiles.whereType<Utility>().where((u) => u.owner == playerId).toList();
  }

  static const Map<PropertyColor, int> colorGroupSize = {
    PropertyColor.brown: 2,
    PropertyColor.lightBlue: 3,
    PropertyColor.pink: 3,
    PropertyColor.orange: 3,
    PropertyColor.red: 3,
    PropertyColor.yellow: 3,
    PropertyColor.green: 3,
    PropertyColor.darkBlue: 2,
  };
}

final Map<PropertyColor, Color> propertyColorMap = {
  PropertyColor.brown: const Color(0xFF8B4513),
  PropertyColor.lightBlue: const Color(0xFF87CEEB),
  PropertyColor.pink: const Color(0xFFFF69B4),
  PropertyColor.orange: const Color(0xFFFFA500),
  PropertyColor.red: const Color(0xFFE53935),
  PropertyColor.yellow: const Color(0xFFFFD600),
  PropertyColor.green: const Color(0xFF43A047),
  PropertyColor.darkBlue: const Color(0xFF1565C0),
};
