import 'dart:math';

class DiceRoll {
  final int die1;
  final int die2;

  const DiceRoll({required this.die1, this.die2 = 0});

  /// Sum of both dice.
  int get total => die1 + die2;

  /// True when both dice show the same value.
  bool get isDoubles => die1 == die2;

  /// Roll two standard six-sided dice.
  static DiceRoll roll() {
    final rng = Random();
    return DiceRoll(
      die1: rng.nextInt(6) + 1,
      die2: rng.nextInt(6) + 1,
    );
  }

  Map<String, dynamic> toJson() => {'die1': die1, 'die2': die2};

  factory DiceRoll.fromJson(Map<String, dynamic> json) {
    return DiceRoll(
      die1: json['die1'] as int,
      die2: json['die2'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'DiceRoll($die1+$die2) total=$total isDoubles=$isDoubles';
}
