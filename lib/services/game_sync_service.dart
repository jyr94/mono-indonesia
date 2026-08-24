import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/game_engine.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/board.dart';
import '../models/dice.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/tile.dart';
import 'firebase_service.dart';

const int _turnTimerSeconds = 60;
const int _rateLimitWindowMs = 500;
const int _maxActionsPerWindow = 5;

class GameSyncService {
  final FirebaseService _fb = FirebaseService();
  final String roomCode;
  final String playerId;
  final bool isHost;

  GameEngine? _engine;
  StreamSubscription? _gameStateSub;
  StreamSubscription? _actionsSub;
  StreamSubscription? _turnDeadlineSub;
  Timer? _turnTimer;
  Timer? _hostSyncTimer;

  final Map<String, int> _actionTimestamps = {};

  final _stateController = StreamController<GameEngine>.broadcast();
  final _messageController = StreamController<String>.broadcast();
  final _turnTimerController = StreamController<int>.broadcast();

  Stream<GameEngine> get onStateChange => _stateController.stream;
  Stream<String> get onMessage => _messageController.stream;
  Stream<int> get onTurnTimer => _turnTimerController.stream;
  GameEngine? get engine => _engine;

  GameSyncService({
    required this.roomCode,
    required this.playerId,
    required this.isHost,
  });

  // W3.3: Initialize game with host as authoritative
  Future<void> initGame(List<Player> players) async {
    _engine = GameEngine(
      board: Board.createIndonesianBoard(),
      gameState: GameState(
        roomId: roomCode,
        players: players,
        status: GameStatus.inProgress,
        phase: TurnPhase.preRoll,
      ),
    );

    if (isHost) {
      await _syncStateToRTDB();
      _startTurnTimer();
    }

    _listenForStateChanges();
    if (!isHost) {
      _listenForActions();
    }
  }

  void _listenForStateChanges() {
    _gameStateSub =
        _fb.gameStateRef(roomCode).onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data = _convertMap(event.snapshot.value as Map<dynamic, dynamic>);
      final newState = _deserializeGameState(data);

      if (_engine != null) {
        _engine!.gameState = newState;
        _restoreEngineStates(data);
        if (data['boardTiles'] != null) {
          _engine!.board = _deserializeBoard(
              data['boardTiles'] as Map<dynamic, dynamic>);
        }
        _stateController.add(_engine!);
      }
    });

    _turnDeadlineSub =
        _fb.turnDeadlineRef(roomCode).onValue.listen((event) {
      if (!event.snapshot.exists) return;
      final deadline = event.snapshot.value as int;
      final remaining =
          (deadline - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
      if (remaining > 0) {
        _turnTimerController.add(remaining);
      }
    });
  }

  void _listenForActions() {
    _actionsSub =
        _fb.actionsRef(roomCode).orderByChild('processed').equalTo(null).onChildAdded.listen((event) {
      if (!isHost) return;
      final action =
          _convertMap(event.snapshot.value as Map<dynamic, dynamic>);
      final actionKey = event.snapshot.key;
      _processAction(action, actionKey);
    });
  }

  // W3.4: Host processes dice roll
  Future<void> rollDice() async {
    if (!_validateAction('roll_dice')) return;

    if (isHost) {
      _executeRoll();
    } else {
      await _sendAction('roll_dice', {});
    }
  }

  void _executeRoll() {
    if (_engine == null) return;
    if (_engine!.gameState.phase != TurnPhase.preRoll) return;

    _engine!.rollDice();
    final msg = _engine!.messageLog;

    _syncStateToRTDB();
    _broadcastMessage(msg ?? 'Dadu dilempar');

    if (_engine!.gameState.phase == TurnPhase.buying) {
      _broadcastMessage('Properti bisa dibeli!');
    }
  }

  // W3.6: Buy property
  Future<void> buyProperty() async {
    if (!_validateAction('buy_property')) return;

    if (isHost) {
      _executeBuy();
    } else {
      await _sendAction('buy_property', {});
    }
  }

  void _executeBuy() {
    if (_engine == null) return;
    final result = _engine!.buyProperty();
    if (result) {
      _syncStateToRTDB();
      _broadcastMessage(_engine!.messageLog ?? 'Properti dibeli');
    }
  }

  // W3.6: Decline buy -> auction
  Future<void> declineBuy() async {
    if (!_validateAction('decline_buy')) return;

    if (isHost) {
      _executeDeclineBuy();
    } else {
      await _sendAction('decline_buy', {});
    }
  }

  void _executeDeclineBuy() {
    if (_engine == null) return;
    _engine!.declineBuy();
    _syncStateToRTDB();
    _broadcastMessage(_engine!.messageLog ?? 'Lelang dimulai');
  }

  // W3.6: Build house
  Future<void> buildHouse(int propertyIndex) async {
    if (!_validateAction('build_house')) return;

    if (isHost) {
      _executeBuildHouse(propertyIndex);
    } else {
      await _sendAction('build_house', {'propertyIndex': propertyIndex});
    }
  }

  void _executeBuildHouse(int propertyIndex) {
    if (_engine == null) return;
    final result = _engine!.buildHouse(propertyIndex);
    if (result) {
      _syncStateToRTDB();
      _broadcastMessage(_engine!.messageLog ?? 'Rumah dibangun');
    }
  }

  // W3.6: Auction bid
  Future<void> auctionBid(int amount) async {
    if (!_validateAction('auction_bid')) return;

    if (isHost) {
      _executeAuctionBid(playerId, amount);
    } else {
      await _sendAction('auction_bid', {'amount': amount});
    }
  }

  void _executeAuctionBid(String pid, int amount) {
    if (_engine == null) return;
    _engine!.placeBid(pid, amount);
    _syncStateToRTDB();
  }

  // W3.6: Auction pass
  Future<void> auctionPass() async {
    if (!_validateAction('auction_pass')) return;

    if (isHost) {
      _executeAuctionPass(playerId);
    } else {
      await _sendAction('auction_pass', {});
    }
  }

  void _executeAuctionPass(String pid) {
    if (_engine == null) return;
    _engine!.passAuction(pid);
    if (!_engine!.isInAuction) {
      _broadcastMessage(_engine!.messageLog ?? 'Lelang selesai');
    }
    _syncStateToRTDB();
  }

  // ── Mortgage ──
  Future<void> mortgageProperty(int propertyIndex) async {
    if (!_validateAction('mortgage_property')) return;
    if (isHost) {
      _executeMortgage(propertyIndex);
    } else {
      await _sendAction('mortgage_property', {'propertyIndex': propertyIndex});
    }
  }

  void _executeMortgage(int propertyIndex) {
    if (_engine == null) return;
    final result = _engine!.mortgageProperty(propertyIndex);
    if (result) {
      _syncStateToRTDB();
      _broadcastMessage(_engine!.messageLog ?? 'Properti digadai');
    }
  }

  Future<void> unmortgageProperty(int propertyIndex) async {
    if (!_validateAction('unmortgage_property')) return;
    if (isHost) {
      _executeUnmortgage(propertyIndex);
    } else {
      await _sendAction('unmortgage_property', {'propertyIndex': propertyIndex});
    }
  }

  void _executeUnmortgage(int propertyIndex) {
    if (_engine == null) return;
    final result = _engine!.unmortgageProperty(propertyIndex);
    if (result) {
      _syncStateToRTDB();
      _broadcastMessage(_engine!.messageLog ?? 'Gadai ditebus');
    }
  }

  // ── Trade ──
  Future<void> proposeTrade(TradeOffer offer) async {
    if (!_validateAction('propose_trade')) return;
    if (isHost) {
      _executeProposeTrade(offer.fromPlayerId, offer.toPlayerId, offer.offeredTiles, offer.requestedTiles, offer.cashOffer);
    } else {
      await _sendAction('propose_trade', {
        'toPlayerId': offer.toPlayerId,
        'offeredTiles': offer.offeredTiles,
        'requestedTiles': offer.requestedTiles,
        'cashOffer': offer.cashOffer,
      });
    }
  }

  void _executeProposeTrade(String fromId, String toId, List<int> offered, List<int> requested, int cash) {
    if (_engine == null) return;
    final offer = TradeOffer(
      fromPlayerId: fromId,
      toPlayerId: toId,
      offeredTiles: offered,
      requestedTiles: requested,
      cashOffer: cash,
    );
    if (_engine!.proposeTrade(offer)) {
      _syncStateToRTDB();
      _broadcastMessage(_engine!.messageLog ?? 'Tawaran pertukaran dikirim');
    }
  }

  Future<void> acceptTrade() async {
    if (!_validateAction('accept_trade')) return;
    if (isHost) {
      _executeAcceptTrade();
    } else {
      await _sendAction('accept_trade', {});
    }
  }

  void _executeAcceptTrade() {
    if (_engine == null) return;
    if (_engine!.acceptTrade()) {
      _syncStateToRTDB();
      _broadcastMessage(_engine!.messageLog ?? 'Pertukaran berhasil');
    }
  }

  Future<void> declineTrade() async {
    if (!_validateAction('decline_trade')) return;
    if (isHost) {
      _executeDeclineTrade();
    } else {
      await _sendAction('decline_trade', {});
    }
  }

  void _executeDeclineTrade() {
    if (_engine == null) return;
    _engine!.declineTrade();
    _syncStateToRTDB();
    _broadcastMessage(_engine!.messageLog ?? 'Tawaran pertukaran ditolak');
  }

  // W3.5: End turn
  Future<void> endTurn() async {
    if (!_validateAction('end_turn')) return;

    if (isHost) {
      _executeEndTurn();
    } else {
      await _sendAction('end_turn', {});
    }
  }

  void _executeEndTurn() {
    if (_engine == null) return;
    _engine!.endTurn();
    _syncStateToRTDB();
    _broadcastMessage(_engine!.messageLog ?? 'Giliran berakhir');
    _startTurnTimer();

    if (_engine!.gameState.isFinished) {
      _broadcastMessage(_engine!.messageLog ?? 'Permainan selesai');
    }
  }

  // W3.3: Sync authoritative state to RTDB
  Future<void> _syncStateToRTDB() async {
    if (_engine == null) return;

    final stateData = _serializeGameState(_engine!.gameState);
    stateData['boardTiles'] = _serializeBoard(_engine!.board);

    await _fb.updateWithRetry(_fb.gameStateRef(roomCode), stateData);
  }

  // W3.5: Turn timer (60s auto-skip)
  void _startTurnTimer() {
    _turnTimer?.cancel();
    if (_engine == null || _engine!.gameState.isFinished) return;

    final deadline =
        DateTime.now().millisecondsSinceEpoch + (_turnTimerSeconds * 1000);
    _fb.turnDeadlineRef(roomCode).set(deadline);

    _turnTimer = Timer(const Duration(seconds: _turnTimerSeconds), () {
      if (isHost && _engine != null && !_engine!.gameState.isFinished) {
        _broadcastMessage('Waktu habis! Giliran dilewati.');
        _executeEndTurn();
      }
    });
  }

  // W3.7: Rate limiting
  bool _validateAction(String actionType) {
    if (_engine == null) return false;
    if (_engine!.gameState.isFinished) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final key = '${playerId}_$actionType';

    _actionTimestamps.removeWhere((_, ts) => now - ts > _rateLimitWindowMs);

    final recentCount =
        _actionTimestamps.entries.where((e) => e.key.startsWith('${playerId}_')).length;

    if (recentCount >= _maxActionsPerWindow) {
      _broadcastMessage('Terlalu cepat! Tunggu sebentar.');
      return false;
    }

    _actionTimestamps[key] = now;
    return true;
  }

  // W3.3 + W3.4: Host processes actions from clients
  void _processAction(Map<String, dynamic> action, String? actionKey) {
    final type = action['type'] as String?;
    final pid = action['playerId'] as String?;

    if (pid == null || type == null) return;

    // W3.7: Validate it's the player's turn for game actions
    if (['roll_dice', 'buy_property', 'decline_buy', 'build_house', 'end_turn', 'mortgage_property', 'unmortgage_property', 'propose_trade', 'accept_trade', 'decline_trade'].contains(type)) {
      // Allow trade acceptance/decline from target player
      if (type == 'accept_trade' || type == 'decline_trade') {
         if (_engine?.pendingTrade?.toPlayerId != pid) return;
      } else {
         if (_engine?.gameState.currentPlayer.id != pid) return;
      }
    }

    switch (type) {
      case 'roll_dice':
        _executeRoll();
        break;
      case 'buy_property':
        _executeBuy();
        break;
      case 'decline_buy':
        _executeDeclineBuy();
        break;
      case 'build_house':
        final propIndex = action['propertyIndex'] as int?;
        if (propIndex != null) _executeBuildHouse(propIndex);
        break;
      case 'mortgage_property':
        final propIndex = action['propertyIndex'] as int?;
        if (propIndex != null) _executeMortgage(propIndex);
        break;
      case 'unmortgage_property':
        final propIndex = action['propertyIndex'] as int?;
        if (propIndex != null) _executeUnmortgage(propIndex);
        break;
      case 'propose_trade':
        final toPlayerId = action['toPlayerId'] as String?;
        if (toPlayerId != null) {
          _executeProposeTrade(
            pid,
            toPlayerId,
            List<int>.from(action['offeredTiles'] as List? ?? []),
            List<int>.from(action['requestedTiles'] as List? ?? []),
            action['cashOffer'] as int? ?? 0,
          );
        }
        break;
      case 'accept_trade':
        _executeAcceptTrade();
        break;
      case 'decline_trade':
        _executeDeclineTrade();
        break;
      case 'auction_bid':
        final amount = action['amount'] as int?;
        if (amount != null) _executeAuctionBid(pid, amount);
        break;
      case 'auction_pass':
        _executeAuctionPass(pid);
        break;
      case 'end_turn':
        _executeEndTurn();
        break;
    }

    // Mark action as processed
    if (actionKey != null) {
      _fb.actionsRef(roomCode).child(actionKey).update({'processed': true});
    }
  }

  Future<void> _sendAction(String type, Map<String, dynamic> data) async {
    await _fb.pushAction(roomCode, {
      'type': type,
      'playerId': playerId,
      'timestamp': ServerValue.timestamp,
      ...data,
    });
  }

  void _broadcastMessage(String msg) {
    _messageController.add(msg);
  }

  Map<String, dynamic> _serializeGameState(GameState state) {
    return {
      'players': state.players
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'money': p.money,
                'position': p.position,
                'status': p.status.name,
                'jailTurns': p.jailTurns,
                'doublesCount': p.doublesCount,
                'avatarColor': p.avatarColor,
                'isHost': p.isHost,
              })
          .toList(),
      'currentPlayerIndex': state.currentPlayerIndex,
      'status': state.status.name,
      'phase': state.phase.name,
      'lastRoll': state.lastRoll != null
          ? {'die1': state.lastRoll!.die1, 'die2': state.lastRoll!.die2}
          : null,
      'winnerId': state.winnerId,
      'turnTimer': state.turnTimer,
      'auctionState': _engine!.auctionState?.toJson(),
      'pendingTrade': _engine!.pendingTrade?.toJson(),
    };
  }

  GameState _deserializeGameState(Map<String, dynamic> data) {
    final playersList = (data['players'] as List?)
            ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return GameState(
      roomId: roomCode,
      players: playersList,
      currentPlayerIndex: data['currentPlayerIndex'] as int? ?? 0,
      status: GameStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => GameStatus.inProgress,
      ),
      phase: TurnPhase.values.firstWhere(
        (e) => e.name == data['phase'],
        orElse: () => TurnPhase.preRoll,
      ),
      lastRoll: data['lastRoll'] != null
          ? DiceRoll.fromJson(data['lastRoll'] as Map<String, dynamic>)
          : null,
      winnerId: data['winnerId'] as String?,
      turnTimer: data['turnTimer'] as int? ?? 60,
    );
  }

  void _restoreEngineStates(Map<String, dynamic> data) {
    if (_engine != null) {
      if (data['auctionState'] != null) {
        _engine!.auctionState = AuctionState.fromJson(
            data['auctionState'] as Map<String, dynamic>);
      } else {
        _engine!.auctionState = null;
      }

      if (data['pendingTrade'] != null) {
        _engine!.pendingTrade = TradeOffer.fromJson(
            data['pendingTrade'] as Map<String, dynamic>);
      } else {
        _engine!.pendingTrade = null;
      }
    }
  }

  Map<String, dynamic> _serializeBoard(Board board) {
    final result = <String, dynamic>{};
    for (int i = 0; i < board.tiles.length; i++) {
      final tile = board.tiles[i];
      if (tile is Property) {
        result['$i'] = {
          'type': 'property',
          'owner': tile.owner,
          'houses': tile.houses,
          'isMortgaged': tile.isMortgaged,
        };
      } else if (tile is Utility) {
        result['$i'] = {
          'type': 'utility',
          'owner': tile.owner,
          'isMortgaged': tile.isMortgaged,
        };
      }
    }
    return result;
  }

  Board _deserializeBoard(Map<dynamic, dynamic> data) {
    final baseBoard = Board.createIndonesianBoard();
    final tiles = List<Tile>.from(baseBoard.tiles);

    for (final entry in data.entries) {
      final index = int.tryParse(entry.key.toString());
      if (index == null || index >= tiles.length) continue;

      final tileData = entry.value as Map<dynamic, dynamic>;
      final owner = tileData['owner'] as String?;

      if (tiles[index] is Property) {
        final prop = tiles[index] as Property;
        tiles[index] = prop.copyWith(
          owner: owner,
          houses: tileData['houses'] as int? ?? 0,
          isMortgaged: tileData['isMortgaged'] as bool? ?? false,
        );
      } else if (tiles[index] is Utility) {
        final util = tiles[index] as Utility;
        tiles[index] = util.copyWith(
          owner: owner,
          isMortgaged: tileData['isMortgaged'] as bool? ?? false,
        );
      }
    }

    return Board(tiles: tiles);
  }

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> raw) {
    final result = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      if (entry.value is Map) {
        result[key] = _convertMap(entry.value as Map<dynamic, dynamic>);
      } else {
        result[key] = entry.value;
      }
    }
    return result;
  }

  // W3.5: Host keep-alive - periodically sync state
  void startHostSync() {
    if (!isHost) return;
    _hostSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_engine != null && !_engine!.gameState.isFinished) {
        _syncStateToRTDB();
      }
    });
  }

  Future<void> dispose() async {
    _turnTimer?.cancel();
    _hostSyncTimer?.cancel();
    await _gameStateSub?.cancel();
    await _actionsSub?.cancel();
    await _turnDeadlineSub?.cancel();
    await _stateController.close();
    await _messageController.close();
    await _turnTimerController.close();
  }
}
