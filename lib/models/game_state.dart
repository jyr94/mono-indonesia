import 'player.dart';
import 'dice.dart';

enum GameStatus {
  waiting,
  inProgress,
  finished,
}

enum TurnPhase {
  preRoll,
  rolling,
  postRoll,
  buying,
  auctioning,
  building,
  ended,
}

class GameState {
  final String roomId;
  final List<Player> players;
  final int currentPlayerIndex;
  final GameStatus status;
  final TurnPhase phase;
  final DiceRoll? lastRoll;
  final int turnTimer;
  final String? winnerId;
  final List<String> chatMessages;

  const GameState({
    required this.roomId,
    this.players = const [],
    this.currentPlayerIndex = 0,
    this.status = GameStatus.waiting,
    this.phase = TurnPhase.preRoll,
    this.lastRoll,
    this.turnTimer = 60,
    this.winnerId,
    this.chatMessages = const [],
  });

  Player get currentPlayer => players[currentPlayerIndex];
  bool get isGameFull => players.length >= 4;
  bool get canStart => players.length >= 2 && status == GameStatus.waiting;
  bool get isFinished => status == GameStatus.finished;

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    GameStatus? status,
    TurnPhase? phase,
    DiceRoll? lastRoll,
    int? turnTimer,
    String? winnerId,
    List<String>? chatMessages,
  }) {
    return GameState(
      roomId: roomId,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      lastRoll: lastRoll ?? this.lastRoll,
      turnTimer: turnTimer ?? this.turnTimer,
      winnerId: winnerId ?? this.winnerId,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'players': players.map((p) => p.toJson()).toList(),
      'currentPlayerIndex': currentPlayerIndex,
      'status': status.name,
      'phase': phase.name,
      'lastRoll': lastRoll?.toJson(),
      'turnTimer': turnTimer,
      'winnerId': winnerId,
      'chatMessages': chatMessages,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      roomId: json['roomId'] as String,
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentPlayerIndex: json['currentPlayerIndex'] as int? ?? 0,
      status: GameStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GameStatus.waiting,
      ),
      phase: TurnPhase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => TurnPhase.preRoll,
      ),
      lastRoll: json['lastRoll'] != null
          ? DiceRoll.fromJson(json['lastRoll'] as Map<String, dynamic>)
          : null,
      turnTimer: json['turnTimer'] as int? ?? 60,
      winnerId: json['winnerId'] as String?,
      chatMessages: (json['chatMessages'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
