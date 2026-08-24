class RoomPlayer {
  final String id;
  final String name;
  final bool isHost;
  final bool connected;

  const RoomPlayer({
    required this.id,
    required this.name,
    this.isHost = false,
    this.connected = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isHost': isHost,
        'connected': connected,
      };

  factory RoomPlayer.fromJson(Map<String, dynamic> json) => RoomPlayer(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Player',
        isHost: json['isHost'] as bool? ?? false,
        connected: json['connected'] as bool? ?? true,
      );
}

class RoomModel {
  final String code;
  final String hostId;
  final String state;
  final Map<String, RoomPlayer> players;

  const RoomModel({
    required this.code,
    required this.hostId,
    this.state = 'waiting',
    this.players = const {},
  });

  bool get isWaiting => state == 'waiting';
  bool get isInProgress => state == 'inProgress';
  bool get isFinished => state == 'finished';
  int get playerCount => players.length;
  bool get isFull => playerCount >= 4;

  RoomPlayer? getPlayer(String id) => players[id];

  Map<String, dynamic> toJson() => {
        'hostId': hostId,
        'state': state,
        'players': players.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory RoomModel.fromJson(String code, Map<String, dynamic> json) {
    final playersMap = <String, RoomPlayer>{};
    if (json['players'] != null) {
      final raw = json['players'] as Map<String, dynamic>;
      for (final entry in raw.entries) {
        playersMap[entry.key] =
            RoomPlayer.fromJson(entry.value as Map<String, dynamic>);
      }
    }
    return RoomModel(
      code: code,
      hostId: json['hostId'] as String? ?? '',
      state: json['state'] as String? ?? 'waiting',
      players: playersMap,
    );
  }
}
