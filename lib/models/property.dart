import 'tile.dart';

enum PropertyColor {
  brown,
  lightBlue,
  pink,
  orange,
  red,
  yellow,
  green,
  darkBlue,
}

class Property extends Tile {
  final int price;
  final int baseRent;
  final int rentWith1House;
  final int rentWith2Houses;
  final int rentWith3Houses;
  final int rentWith4Houses;
  final int rentWithHotel;
  final int houseCost;
  final PropertyColor color;
  final String? owner;
  final int houses;
  final bool isMortgaged;

  const Property({
    required super.index,
    required super.name,
    required this.price,
    required this.baseRent,
    required this.rentWith1House,
    required this.rentWith2Houses,
    required this.rentWith3Houses,
    required this.rentWith4Houses,
    required this.rentWithHotel,
    required this.houseCost,
    required this.color,
    this.owner,
    this.houses = 0,
    this.isMortgaged = false,
    super.description,
  }) : super(type: TileType.property);

  bool get isOwned => owner != null;

  int get currentRent {
    if (isMortgaged) return 0;
    return switch (houses) {
      0 => baseRent,
      1 => rentWith1House,
      2 => rentWith2Houses,
      3 => rentWith3Houses,
      4 => rentWith4Houses,
      5 => rentWithHotel,
      _ => baseRent,
    };
  }

  Property copyWith({
    String? owner,
    int? houses,
    bool? isMortgaged,
  }) {
    return Property(
      index: index,
      name: name,
      price: price,
      baseRent: baseRent,
      rentWith1House: rentWith1House,
      rentWith2Houses: rentWith2Houses,
      rentWith3Houses: rentWith3Houses,
      rentWith4Houses: rentWith4Houses,
      rentWithHotel: rentWithHotel,
      houseCost: houseCost,
      color: color,
      owner: owner ?? this.owner,
      houses: houses ?? this.houses,
      isMortgaged: isMortgaged ?? this.isMortgaged,
      description: description,
    );
  }
}
