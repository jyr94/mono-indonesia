enum TileType {
  property,
  utility,
  chance,
  communityChest,
  tax,
  go,
  jail,
  freeParking,
  goToJail,
}

class Tile {
  final int index;
  final String name;
  final TileType type;
  final String? description;

  const Tile({
    required this.index,
    required this.name,
    required this.type,
    this.description,
  });
}
