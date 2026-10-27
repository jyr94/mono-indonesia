import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/player.dart';
import '../models/dice.dart';
import '../models/game_state.dart';
import '../models/game_engine.dart';
import '../models/tile.dart';
import '../services/game_sync_service.dart';
import '../services/audio_service.dart';
import '../widgets/property_detail_sheet.dart';
import '../widgets/auction_dialog.dart';
import '../widgets/trade_dialog.dart';
import '../widgets/mortgage_sheet.dart';
import '../game/overlays/flame_game_screen.dart';
import '../services/app_review_service.dart';

class GameScreen extends StatefulWidget {
  final GameSyncService? syncService;
  final List<Player>? localPlayers;
  const GameScreen({super.key, this.syncService, this.localPlayers});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameEngine engine;
  DiceRoll? currentRoll;
  bool _isDiceRolling = false;
  bool get _isMultiplayer => widget.syncService != null;
  StreamSubscription? _stateSub;
  StreamSubscription? _messageSub;
  StreamSubscription? _timerSub;
  int _turnTimeRemaining = 60;
  String? _floatingMsg;
  String? _movingPlayerId;
  int? _animatedPosition;
  int? _moveStartPosition;
  bool _isFollowingToken = false;
  bool _isTradeDialogShowing = false;
  late AnimationController _floatCtrl;
  late Animation<Offset> _floatAnim;
  late AnimationController _pulseCtrl;
  late AnimationController _sceneryFloatCtrl;
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    unawaited(_audio.initialize());
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _floatAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.2),
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeOut));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _sceneryFloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    if (_isMultiplayer) {
      // Multiplayer: use engine from sync service or create a placeholder for waiting state
      engine = widget.syncService!.engine ??
          GameEngine(
            board: Board.createIndonesianBoard(),
            gameState: GameState(
              roomId: 'mp',
              players: [],
              status: GameStatus.waiting,
            ),
          );
      _listenSync();
    } else {
      // Single-player: initialize local engine with provided players or defaults
      engine = GameEngine(
        board: Board.createIndonesianBoard(),
        gameState: GameState(
          roomId: 'local',
          players: widget.localPlayers ?? [
            const Player(
              id: '1',
              name: 'ANDA',
              avatarColor: 'blue',
              isHost: true,
              status: PlayerStatus.playing,
            ),
            const Player(
              id: '2',
              name: 'MAYA',
              avatarColor: 'red',
              status: PlayerStatus.playing,
            ),
          ],
          status: GameStatus.inProgress,
          phase: TurnPhase.preRoll,
        ),
      );
    }
  }

  void _listenSync() {
    final s = widget.syncService!;
    _stateSub = s.onStateChange.listen((e) {
      if (!mounted) return;
      setState(() {
        engine = e;
        if (e.gameState.lastRoll != null) currentRoll = e.gameState.lastRoll;
      });
      if (e.gameState.isFinished) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showWinner());
      }
      
      if (e.pendingTrade != null && e.pendingTrade!.toPlayerId == s.playerId) {
         if (!_isTradeDialogShowing) {
             _isTradeDialogShowing = true;
             WidgetsBinding.instance.addPostFrameCallback((_) => _showReceivedTrade(e.pendingTrade!));
         }
      } else {
         _isTradeDialogShowing = false;
      }
    });
    _messageSub = s.onMessage.listen((m) {
      if (mounted) _float(m);
    });
    _timerSub = s.onTurnTimer.listen((t) {
      if (mounted) setState(() => _turnTimeRemaining = t);
    });
  }

  GameState get gs => engine.gameState;
  Player get current => gs.currentPlayer;

  /// Local player ID — used by FlameGameScreen to know whose turn it is.
  String get _localPlayerId {
    if (_isMultiplayer) return widget.syncService!.playerId;
    // Single-player: always the first player
    return engine.gameState.players.isNotEmpty
        ? engine.gameState.players.first.id
        : '1';
  }

  void _float(String msg) {
    setState(() => _floatingMsg = msg);
    _floatCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _floatingMsg = null);
    });
  }

  Color _pColor(Player p) {
    return switch (p.avatarColor) {
      'red'    => const Color(0xFFD32F2F),
      'blue'   => const Color(0xFF1565C0),
      'green'  => const Color(0xFF2E7D32),
      'yellow' => const Color(0xFFF9A825),
      'purple' => const Color(0xFF6A1B9A),
      'teal'   => const Color(0xFF00695C),
      _        => Colors.grey,
    };
  }

  List<Color> _getPropertyColors(String playerId) {
    return engine.board.getAllPropertiesOwnedBy(playerId)
        .map((p) => propertyColorMap[p.color] ?? Colors.grey)
        .toList();
  }

  // ── Actions ──

  void _rollDice() {
    if (_isDiceRolling) return;
    _audio.playDiceRoll();
    _movingPlayerId = current.id;
    _moveStartPosition = current.position;
    _animatedPosition = current.position;
    if (_isMultiplayer) {
      widget.syncService!.rollDice();
      setState(() => _isDiceRolling = true);
      return;
    }
    setState(() {
      try {
        currentRoll = engine.rollDice();
        _isDiceRolling = true;
      } catch (_) {
        _isDiceRolling = false;
      }
    });
  }

  Future<void> _onDiceDone() async {
    _audio.playDiceLand();
    if (_isMultiplayer) {
      setState(() => _isDiceRolling = false);
    } else {
      setState(() => _isDiceRolling = false);
      if (engine.messageLog != null) _float(engine.messageLog!);
    }

    await _animatePlayerMovement();
    if (!mounted) return;
    _checkLanding();
  }

  Future<void> _animatePlayerMovement() async {
    final playerId = _movingPlayerId;
    final roll = currentRoll;
    final start = _moveStartPosition;
    if (playerId == null || roll == null || start == null) return;

    setState(() => _isFollowingToken = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));

    for (var step = 1; step <= roll.total; step++) {
      if (!mounted) return;
      setState(() {
        _animatedPosition = (start + step) % engine.board.totalTiles;
      });
      _audio.playStep();
      await Future<void>.delayed(const Duration(milliseconds: 950));
    }

    Player? actualPlayer;
    for (final player in engine.gameState.players) {
      if (player.id == playerId) {
        actualPlayer = player;
        break;
      }
    }
    if (actualPlayer != null && actualPlayer.position != _animatedPosition) {
      final landingPosition = actualPlayer.position;
      setState(() => _animatedPosition = landingPosition);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
    }

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isFollowingToken = false);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _movingPlayerId = null;
      _animatedPosition = null;
      _moveStartPosition = null;
    });
  }

  List<Player> get _displayPlayers {
    final movingId = _movingPlayerId;
    final position = _animatedPosition;
    if (movingId == null || position == null) return gs.players;
    return gs.players
        .map(
          (player) => player.id == movingId
              ? player.copyWith(position: position)
              : player,
        )
        .toList();
  }

  Alignment _boardFocusForTile(int? index) {
    if (index == null) return Alignment.center;
    final n = index % engine.board.totalTiles; // 0-39

    double x = 0;
    double y = 0;

    if (n <= 10) {
      final t = n / 10.0;
      x = -0.8 + t * 1.6;
      y = 0.75;
    } else if (n <= 19) {
      final t = (n - 10) / 9.0;
      x = 0.8;
      y = 0.75 - t * 1.5;
    } else if (n <= 30) {
      final t = (n - 20) / 10.0;
      x = 0.8 - t * 1.6;
      y = -0.75;
    } else {
      final t = (n - 31) / 8.0;
      x = -0.8;
      y = -0.75 + t * 1.5;
    }

    // Apply the same isometric projection that BoardWidget uses.
    // rotateZ(45 deg) + rotateX(tilt)
    final double screenX = (x - y) * 0.707;
    final double screenY = (x + y) * 0.55;
    
    return Alignment(screenX, screenY);
  }

  void _checkLanding() {
    final tile = engine.board.getTile(current.position);
    if (tile.type == TileType.chance || tile.type == TileType.communityChest) {
      _audio.playCard();
    } else if (current.isInJail || tile.type == TileType.goToJail) {
      _audio.playJail();
    }
    if (gs.phase == TurnPhase.buying) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showPropertyCard());
    }
  }

  void _buyProperty() {
    _audio.playCashRegister();
    if (_isMultiplayer) {
      widget.syncService!.buyProperty();
    } else {
      setState(() {
        if (engine.buyProperty()) {
          _float(engine.messageLog ?? 'Properti dibeli!');
        }
      });
    }
  }

  void _declineBuy() {
    if (_isMultiplayer) {
      widget.syncService!.declineBuy();
    } else {
      setState(() {
        engine.declineBuy();
        _float(engine.messageLog ?? 'Lelang dimulai!');
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (engine.isInAuction) _showAuction();
      });
    }
  }

  void _buildHouse() {
    if (engine.buildableProperties.isEmpty) return;
    _showBuildSheet();
  }

  void _endTurn() {
    _audio.playTurn();
    if (_isMultiplayer) {
      widget.syncService!.endTurn();
    } else {
      setState(() {
        engine.endTurn();
        currentRoll = null;
        if (engine.messageLog != null) _float(engine.messageLog!);
      });
      if (gs.isFinished) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showWinner());
      }
    }
  }

  // ── Dialogs ──

  void _showPropertyCard() {
    final tile = engine.board.getTile(current.position);
    if (tile is! Property && tile is! Utility) return;
    final price = tile is Property
        ? tile.price
        : tile is Utility
        ? tile.price
        : 0;
    final cBar = tile is Property
        ? propertyColorMap[tile.color]
        : const Color(0xFFD7CCC8);

    showGeneralDialog(
      context: context,
      barrierLabel: 'prop',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (_, a, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 310,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cBar,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tile.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (tile is Property) ...[
                            _row('Sewa Dasar', 'Rp ${tile.baseRent}'),
                            _row('1 Rumah', 'Rp ${tile.rentWith1House}'),
                            _row('Hotel', 'Rp ${tile.rentWithHotel}'),
                            const Divider(),
                            _row('Harga', 'Rp ${tile.price}', bold: true),
                          ],
                          if (tile is Utility)
                            _row('Harga', 'Rp ${tile.price}', bold: true),
                          const SizedBox(height: 12),
                          Text(
                            'Rp $price',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: current.money >= price
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _declineBuy();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.gavel,
                                    size: 18,
                                    color: Color(0xFFE65100),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'LELANG',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade200,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: engine.canBuyProperty
                                ? () {
                                    Navigator.pop(context);
                                    _buyProperty();
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: engine.canBuyProperty
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey.shade200,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(22),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    size: 18,
                                    color: engine.canBuyProperty
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'BELI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: engine.canBuyProperty
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _row(String l, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  void _showBuildSheet() {
    final props = engine.buildableProperties;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.home, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Bangun Gedung',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...props.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    width: 8,
                    height: 36,
                    decoration: BoxDecoration(
                      color: propertyColorMap[p.color],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${p.houseCost}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _audio.playBuildHouse();
                    if (_isMultiplayer) {
                      widget.syncService!.buildHouse(p.index);
                    } else {
                      setState(() {
                        if (engine.buildHouse(p.index)) {
                          _float(engine.messageLog ?? 'Rumah dibangun!');
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuction() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AuctionDialog(
        engine: engine,
        syncService: widget.syncService,
        onAuctionComplete: () {
          setState(() {
            if (engine.messageLog != null) _float(engine.messageLog!);
          });
        },
      ),
    );
  }

  void _showWinner() {
    _audio.playWin();
    AppReviewService.instance.recordGameCompleted();
    final w = gs.players.firstWhere(
      (p) => p.id == gs.winnerId,
      orElse: () => gs.players.first,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: ConfettiOverlay())),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PEMENANG!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 4,
                ),
              ),
              Text(
                w.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'IDR ${w.money}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isMultiplayer) widget.syncService!.dispose();
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
],
),
);
}

  void _showTileInfo(int i) {
    final tile = engine.board.getTile(i);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          child: PropertyDetailSheet(
            tile: tile,
            board: engine.board,
            players: gs.players,
          ),
        ),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Info Permainan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...gs.players.map((p) {
              final props = engine.board.getAllPropertiesOwnedBy(p.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _pColor(p),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'IDR ${p.money}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: p.money < 0
                                  ? Colors.red
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                          if (props.isNotEmpty)
                            Text(
                              props.map((pp) => pp.name).join(', '),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showTrade() {
    showDialog(
      context: context,
      builder: (ctx) => TradeDialog(
        engine: engine,
        syncService: widget.syncService,
        onTradeComplete: () {
          setState(() {
            if (engine.messageLog != null) _float(engine.messageLog!);
          });
        },
      ),
    );
  }

  void _showReceivedTrade(TradeOffer offer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Tawaran Pertukaran', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pemain ${offer.fromPlayerId} mengajak bertukar!'),
            const SizedBox(height: 10),
            Text('Dia menawarkan uang: Rp ${offer.cashOffer}'),
            if (offer.offeredTiles.isNotEmpty) Text('Dia menawarkan properti: ${offer.offeredTiles.map((i) => engine.board.getTile(i).name).join(', ')}'),
            if (offer.requestedTiles.isNotEmpty) Text('Dia meminta propertimu: ${offer.requestedTiles.map((i) => engine.board.getTile(i).name).join(', ')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.syncService?.declineTrade();
              Navigator.pop(ctx);
            },
            child: const Text('TOLAK', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.syncService?.acceptTrade();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: const Text('TERIMA'),
          ),
        ],
      ),
    ).then((_) => _isTradeDialogShowing = false);
  }

  void _showMortgage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: MortgageSheet(
          engine: engine,
          syncService: widget.syncService,
          onChanged: () {
            setState(() {
              if (engine.messageLog != null) _float(engine.messageLog!);
            });
          },
        ),
      ),
    );
  }

  // _showChatTrade removed — info button now calls _showMenu directly

  @override
  void dispose() {
    _stateSub?.cancel();
    _messageSub?.cancel();
    _timerSub?.cancel();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _sceneryFloatCtrl.dispose();
    super.dispose();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    // ── Flame-powered game screen ──────────────────────────────────────────
    // Engine init + sync subscriptions remain in this State.
    // All rendering (board, tokens, dice, HUD) is handled by FlameGameScreen.
    return FlameGameScreen(
      initialEngine: engine,
      localPlayerId: _localPlayerId,
      syncService: widget.syncService,
      onEngineUpdated: (updatedEngine) {
        if (mounted) setState(() => engine = updatedEngine);
      },
    );
  }
}

// ─── Confetti overlay for winner celebration ──────────────────────────────────

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_ConfettiParticle> _particles = [];
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 80; i++) _particles.add(_ConfettiParticle(_rnd));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _ctrl.addListener(() {
      for (final p in _particles) p.update(_ctrl.value);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ConfettiPainter(_particles), size: Size.infinite);
}

class _ConfettiParticle {
  double x, y, angle, speed, size;
  Color color;
  static final _colors = [
    const Color(0xFFFFD700), const Color(0xFFC62828),
    const Color(0xFF1565C0), const Color(0xFF2E7D32),
    const Color(0xFFFFB300), Colors.white,
  ];
  _ConfettiParticle(Random rnd)
      : x = rnd.nextDouble(), y = rnd.nextDouble() * -0.5,
        angle = rnd.nextDouble() * 3.14,
        speed = 0.002 + rnd.nextDouble() * 0.003,
        size = 6 + rnd.nextDouble() * 8,
        color = _colors[rnd.nextInt(_colors.length)];
  void update(double t) { y += speed; angle += 0.04; if (y > 1.3) y = -0.1; }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      if (p.y > 1.2 || p.y < -0.1) continue;
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.angle);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
