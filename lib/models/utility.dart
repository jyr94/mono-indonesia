import 'tile.dart';

class Utility extends Tile {
  final int price;
  final String? owner;
  final bool isMortgaged;

  const Utility({
    required super.index,
    required super.name,
    required this.price,
    this.owner,
    this.isMortgaged = false,
    super.description,
  }) : super(type: TileType.utility);

  bool get isOwned => owner != null;

  int calculateRent(int diceRoll, {int utilitiesOwned = 1}) {
    if (isMortgaged) return 0;
    return utilitiesOwned >= 2 ? diceRoll * 10 : diceRoll * 4;
  }

  Utility copyWith({String? owner, bool? isMortgaged}) {
    return Utility(
      index: index,
      name: name,
      price: price,
      owner: owner ?? this.owner,
      isMortgaged: isMortgaged ?? this.isMortgaged,
      description: description,
    );
  }
}
