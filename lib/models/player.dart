enum PlayerStatus {
  waiting,
  playing,
  inJail,
  bankrupt,
  disconnected,
}

class Player {
  final String id;
  final String name;
  final int money;
  final int position;
  final PlayerStatus status;
  final int jailTurns;
  final int doublesCount;
  final String? avatarColor;
  final bool isHost;
  /// How many "Get Out of Jail Free" cards this player holds.
  final int jailFreeCards;
  final bool isBot;

  const Player({
    required this.id,
    required this.name,
    this.money = 1500,
    this.position = 0,
    this.status = PlayerStatus.waiting,
    this.jailTurns = 0,
    this.doublesCount = 0,
    this.avatarColor,
    this.isHost = false,
    this.jailFreeCards = 0,
    this.isBot = false,
  });

  bool get isBankrupt => status == PlayerStatus.bankrupt;
  bool get isInJail => status == PlayerStatus.inJail;

  Player copyWith({
    String? name,
    int? money,
    int? position,
    PlayerStatus? status,
    int? jailTurns,
    int? doublesCount,
    String? avatarColor,
    bool? isHost,
    int? jailFreeCards,
    bool? isBot,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      money: money ?? this.money,
      position: position ?? this.position,
      status: status ?? this.status,
      jailTurns: jailTurns ?? this.jailTurns,
      doublesCount: doublesCount ?? this.doublesCount,
      avatarColor: avatarColor ?? this.avatarColor,
      isHost: isHost ?? this.isHost,
      jailFreeCards: jailFreeCards ?? this.jailFreeCards,
      isBot: isBot ?? this.isBot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'money': money,
      'position': position,
      'status': status.name,
      'jailTurns': jailTurns,
      'doublesCount': doublesCount,
      'avatarColor': avatarColor,
      'isHost': isHost,
      'jailFreeCards': jailFreeCards,
      'isBot': isBot,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      money: json['money'] as int? ?? 1500,
      position: json['position'] as int? ?? 0,
      status: PlayerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PlayerStatus.waiting,
      ),
      jailTurns: json['jailTurns'] as int? ?? 0,
      doublesCount: json['doublesCount'] as int? ?? 0,
      avatarColor: json['avatarColor'] as String?,
      isHost: json['isHost'] as bool? ?? false,
      jailFreeCards: json['jailFreeCards'] as int? ?? 0,
      isBot: json['isBot'] as bool? ?? false,
    );
  }
}
