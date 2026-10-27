import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_engine.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../models/dice.dart';
import '../../models/property.dart';
import '../../models/tile.dart';
import '../../models/utility.dart';
import '../../models/board.dart';
import '../../widgets/player_status_card.dart';
import '../../widgets/trade_dialog.dart';
import '../../widgets/auction_dialog.dart';
import '../../widgets/mortgage_sheet.dart';
import '../../widgets/overlays/lottie_card_overlay.dart';
import '../../widgets/overlays/lottie_jail_overlay.dart';
import '../../widgets/player_assets_dialog.dart';
import '../../services/game_sync_service.dart';
import '../../widgets/auction_dialog.dart';
import '../../services/audio_service.dart';
import '../monopoli_game.dart';
import '../../constants/app_constants.dart';

/// Flame-powered game screen.
///
/// Structure:
///   Stack(
///     GameWidget(game: MonopoliGame)  ← Flame renders board, tokens, dice
///     HUD overlay (Flutter widgets)   ← Player cards, action buttons, etc.
///   )
///
/// All game logic stays in [GameEngine] as before.
class FlameGameScreen extends StatefulWidget {
  final GameEngine initialEngine;
  final String localPlayerId;
  final GameSyncService? syncService;
  final Function(GameEngine)? onEngineUpdated;

  const FlameGameScreen({
    super.key,
    required this.initialEngine,
    required this.localPlayerId,
    this.syncService,
    this.onEngineUpdated,
  });

  @override
  State<FlameGameScreen> createState() => _FlameGameScreenState();
}

class _FlameGameScreenState extends State<FlameGameScreen> {
  late MonopoliGame _flameGame;
  late GameEngine _engine;
  bool _isDiceRolling = false;
  DiceRoll? _lastRoll;

  @override
  void initState() {
    super.initState();
    _engine = widget.initialEngine;

    _flameGame = MonopoliGame(
      engine: _engine,
      localPlayerId: widget.localPlayerId,
      onStateUpdated: () {
        if (mounted) setState(() {});
      },
    );

    _flameGame.onTileTap = _onTileTap;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBotTurn();
    });
  }

  GameState get gs => _engine.gameState;
  Player get current => gs.currentPlayer;
  
  bool get isMyTurn {
    if (widget.syncService == null) {
      return !current.isBot; // Human turn in single-player
    }
    return current.id == widget.localPlayerId;   // multiplayer
  }

  bool _isBotRunning = false;

  void _checkBotTurn() {
    if (!mounted || widget.syncService != null) return;
    if (current.isBot && gs.phase == TurnPhase.preRoll && !_isDiceRolling && !_isBotRunning) {
      _runBotTurn();
    }
  }

  Future<void> _runBotTurn() async {
    if (_isBotRunning || !mounted || !current.isBot) return;
    _isBotRunning = true;

    try {
      // Pause so the player sees it's bot's turn
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted || !current.isBot) return;

      setState(() => _isDiceRolling = true);
      final oldPos = current.position;
      final roll = _engine.rollDice();
      _lastRoll = roll;
      AudioService().playDiceRoll();

      await _flameGame.animateDiceRoll(roll.die1, roll.die2, onDone: () {
        AudioService().playDiceLand();
        if (mounted) setState(() => _isDiceRolling = false);
      });

      if (!mounted) return;

      await _flameGame.animatePlayerMove(
        current.id,
        oldPos,
        current.position,
      );

      if (!mounted) return;

      final tile = _engine.board.getTile(current.position);
      if (tile.type == TileType.chance || tile.type == TileType.communityChest) {
        AudioService().playCard();
        await Future<void>.delayed(const Duration(milliseconds: 1000));
      } else if (current.isInJail || tile.type == TileType.goToJail) {
        AudioService().playJail();
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }

      if (!mounted) return;

      if (gs.phase == TurnPhase.buying) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        int price = 0;
        if (tile is Property) price = tile.price;
        if (tile is Utility) price = tile.price;

        if (current.money >= price + 150) {
          _buyProperty();
        } else {
          _declineBuy();
        }
      }

      if (_engine.buildableProperties.isNotEmpty && current.money >= 500) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        _buildHouse();
      }

      if (gs.phase == TurnPhase.inDebt) {
        _declareBankruptcy();
      }

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      _endTurn();
    } finally {
      _isBotRunning = false;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _rollDice() async {
    if (_isDiceRolling || !isMyTurn) return;
    if (gs.phase != TurnPhase.preRoll) return;

    setState(() => _isDiceRolling = true);

    // Save old position BEFORE engine updates it
    final oldPos = current.position;

    final roll = _engine.rollDice();
    _lastRoll = roll;

    AudioService().playDiceRoll();

    // Sync Flame dice animation
    await _flameGame.animateDiceRoll(roll.die1, roll.die2, onDone: () {
      AudioService().playDiceLand();
      setState(() => _isDiceRolling = false);
    });

    // Animate token movement using saved oldPos
    await _flameGame.animatePlayerMove(
      current.id,
      oldPos,
      current.position,
    );

    final tile = _engine.board.getTile(current.position);
    if (tile.type == TileType.chance || tile.type == TileType.communityChest) {
      AudioService().playCard();
      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, anim1, anim2) => FadeTransition(
          opacity: anim1,
          child: LottieCardOverlay(
            description: _engine.messageLog ?? '',
            isChance: tile.type == TileType.chance,
            onComplete: () => Navigator.pop(ctx),
          ),
        ),
      );
    } else if (current.isInJail || tile.type == TileType.goToJail) {
      AudioService().playJail();
      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, anim1, anim2) => FadeTransition(
          opacity: anim1,
          child: LottieJailOverlay(
            onComplete: () => Navigator.pop(ctx),
          ),
        ),
      );
    }

    if (gs.phase == TurnPhase.buying) {
      _showBuyDialog();
    }
  }

  void _buyProperty() {
    if (_engine.buyProperty()) {
      AudioService().playCashRegister();
      _flameGame.spawnCoinRain();
      _flameGame.spawnBuildEffect(current.position);
      setState(() {});
    }
  }

  void _declineBuy() {
    if (widget.syncService != null) {
      widget.syncService!.declineBuy();
    } else {
      _engine.declineBuy();
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_engine.isInAuction) _showAuction();
      });
    }
  }

  void _buildHouse() {
    final buildables = _engine.buildableProperties;
    if (buildables.isEmpty) return;
    // Build on first available (TODO: show picker dialog)
    final prop = buildables.first;
    if (_engine.buildHouse(prop.index)) {
      AudioService().playBuildHouse();
      _flameGame.spawnBuildEffect(prop.index);
      setState(() {});
    }
  }

  void _endTurn() {
    AudioService().playTurn();
    _engine.endTurn();
    _flameGame.syncFromEngine(_engine);
    setState(() {
      _lastRoll = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBotTurn();
    });
  }

  void _declareBankruptcy() {
    _engine.declareBankruptcy();
    _flameGame.syncFromEngine(_engine);
    setState(() {});
  }

  void _sellHouse(int propertyIndex) {
    if (_engine.sellHouse(propertyIndex)) {
      _flameGame.spawnBuildEffect(propertyIndex);
      setState(() {});
    }
  }

  void _mortgage(int tileIndex) {
    if (_engine.mortgageProperty(tileIndex)) {
      setState(() {});
    }
  }

  void _unmortgage(int tileIndex) {
    if (_engine.unmortgageProperty(tileIndex)) {
      setState(() {});
    }
  }

  void _onTileTap(int tileIndex) {
    final tile = _engine.board.getTile(tileIndex);
    _showTileInfo(tile, tileIndex);
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showBuyDialog() {
    final tile = _engine.board.getTile(current.position);
    String name = tile.name;
    int price = 0;
    if (tile is Property) price = tile.price;
    if (tile is Utility) price = tile.price;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BuyBottomSheet(
        name: name,
        price: price,
        playerMoney: current.money,
        onBuy: () {
          Navigator.pop(context);
          _buyProperty();
        },
        onDecline: () {
          Navigator.pop(context);
          _declineBuy();
        },
      ),
    );
  }

  void _showAuction() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AuctionDialog(
        engine: _engine,
        syncService: widget.syncService,
        onAuctionComplete: () {
          setState(() {});
          _flameGame.syncFromEngine(_engine);
        },
      ),
    );
  }

  void _showTileInfo(dynamic tile, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TileInfoSheet(
        tile: tile, 
        index: index, 
        engine: _engine,
        onSellHouse: () {
          Navigator.pop(context);
          _sellHouse(index);
        },
        onMortgage: () {
          Navigator.pop(context);
          _mortgage(index);
        },
        onUnmortgage: () {
          Navigator.pop(context);
          _unmortgage(index);
        },
      ),
    );
  }

  void _showPlayerAssets(String playerId) {
    final player = gs.players.firstWhere((p) => p.id == playerId);
    final properties = _engine.board.getAllPropertiesOwnedBy(playerId);
    final utilities = _engine.board.getAllUtilitiesOwnedBy(playerId);
    final assets = [...properties, ...utilities];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Player Assets',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      pageBuilder: (ctx, anim1, anim2) => FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
          )),
          child: PlayerAssetsDialog(
            player: player,
            assets: assets,
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Flame game world ──────────────────────────────────────────────
          GameWidget(
            game: _flameGame,
            loadingBuilder: (_) => const _LoadingPlaceholder(),
          ),

          // ── HUD overlay ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Player status row
                _PlayerStatusRow(
                  players: gs.players,
                  currentPlayerId: current.id,
                  localPlayerId: widget.localPlayerId,
                  onPlayerTap: _showPlayerAssets,
                ),

                // Turn banner
                if (isMyTurn)
                  _TurnBanner(timeRemaining: 60)
                else
                  _WaitingBanner(
                    playerName: current.name,
                    isBot: current.isBot,
                  ),

                const Spacer(),

                // Dice result display
                if (_lastRoll != null)
                  _DiceResultBadge(roll: _lastRoll!),

                const SizedBox(height: 8),

                // Action bar
                _ActionBar(
                  engine: _engine,
                  isMyTurn: isMyTurn,
                  isDiceRolling: _isDiceRolling,
                  onRoll: _rollDice,
                  onBuy: _buyProperty,
                  onBuild: _buildHouse,
                  onEndTurn: _endTurn,
                  onDeclareBankruptcy: _declareBankruptcy,
                ),
              ],
            ),
          ),

          // ── Floating message overlay ──────────────────────────────────────
          if (_engine.messageLog != null)
            Positioned(
              bottom: 120,
              left: 24,
              right: 24,
              child: _FloatingMessage(message: _engine.messageLog!),
            ),
        ],
      ),
    );
  }
}

// ─── HUD Components ───────────────────────────────────────────────────────────

class _PlayerStatusRow extends StatelessWidget {
  final List<Player> players;
  final String currentPlayerId;
  final String localPlayerId;
  final Function(String) onPlayerTap;

  const _PlayerStatusRow({
    required this.players,
    required this.currentPlayerId,
    required this.localPlayerId,
    required this.onPlayerTap,
  });

  static const _colors = {
    'red': Color(0xFFD32F2F),
    'blue': Color(0xFF1565C0),
    'green': Color(0xFF2E7D32),
    'yellow': Color(0xFFF9A825),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: players.where((p) => !p.isBankrupt).map((player) {
          final isActive = player.id == currentPlayerId;
          final color = _colors[player.avatarColor] ?? Colors.grey;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPlayerTap(player.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isActive
                      ? color.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.55),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.2),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: GoogleFonts.baloo2(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rp ${_fmt(player.money)}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? const Color(0xFFFFD700)
                          : const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toString();
  }
}

class _TurnBanner extends StatelessWidget {
  final int timeRemaining;
  const _TurnBanner({required this.timeRemaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_rounded, color: Color(0xFFC62828), size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'GILIRAN KAMU!',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFC62828),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '0:${timeRemaining.toString().padLeft(2, '0')}',
              style: GoogleFonts.baloo2(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingBanner extends StatelessWidget {
  final String playerName;
  final bool isBot;
  const _WaitingBanner({required this.playerName, this.isBot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isBot
            ? const Color(0xFFC62828).withValues(alpha: 0.85)
            : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: isBot ? Border.all(color: const Color(0xFFFFD700), width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBot) ...[
            const Icon(Icons.smart_toy_rounded, color: Color(0xFFFFD700), size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            isBot ? 'Giliran $playerName (Komputer)...' : 'Giliran $playerName...',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: isBot ? FontWeight.w700 : FontWeight.w500,
              color: isBot ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiceResultBadge extends StatelessWidget {
  final DiceRoll roll;
  const _DiceResultBadge({required this.roll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DiceFaceSmall(value: roll.die1),
          const SizedBox(width: 8),
          _DiceFaceSmall(value: roll.die2),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Total ${roll.total}',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (roll.isDoubles) ...[
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DOUBLE!',
                    style: GoogleFonts.baloo2(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8B0000),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiceFaceSmall extends StatelessWidget {
  final int value;
  const _DiceFaceSmall({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFFC62828),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final GameEngine engine;
  final bool isMyTurn;
  final bool isDiceRolling;
  final VoidCallback onRoll;
  final VoidCallback onBuy;
  final VoidCallback onBuild;
  final VoidCallback onEndTurn;
  final VoidCallback onDeclareBankruptcy;

  const _ActionBar({
    required this.engine,
    required this.isMyTurn,
    required this.isDiceRolling,
    required this.onRoll,
    required this.onBuy,
    required this.onBuild,
    required this.onEndTurn,
    required this.onDeclareBankruptcy,
  });

  GameState get gs => engine.gameState;

  @override
  Widget build(BuildContext context) {
    final canRoll = isMyTurn && gs.phase == TurnPhase.preRoll && !isDiceRolling;
    final canBuy = isMyTurn && gs.phase == TurnPhase.buying;
    final canBuild = isMyTurn && engine.buildableProperties.isNotEmpty && gs.phase != TurnPhase.inDebt;
    final isInDebt = isMyTurn && gs.phase == TurnPhase.inDebt;
    final canEnd = isMyTurn &&
        gs.phase != TurnPhase.preRoll &&
        gs.phase != TurnPhase.buying &&
        gs.phase != TurnPhase.auctioning &&
        gs.phase != TurnPhase.inDebt;

    return AnimatedSlide(
      offset: isMyTurn ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isMyTurn ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: 0.75),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (isInDebt)
                _ActionBtn(
                  icon: Icons.flag_rounded,
                  label: 'MENYERAH',
                  color: Colors.red.shade800,
                  enabled: true,
                  onTap: onDeclareBankruptcy,
                )
              else ...[
                _ActionBtn(
                  icon: Icons.casino_rounded,
                  label: 'LEMPAR',
                  color: const Color(0xFF1565C0),
                  enabled: canRoll,
                  isLoading: isDiceRolling,
                  onTap: onRoll,
                ),
                _ActionBtn(
                  icon: Icons.home_rounded,
                  label: 'BELI',
                  color: const Color(0xFF2E7D32),
                  enabled: canBuy,
                  onTap: onBuy,
                ),
                Tooltip(
                  message: 'Kumpulkan semua set warna untuk membangun!',
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 3),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  child: _ActionBtn(
                    icon: Icons.apartment_rounded,
                    label: 'BANGUN',
                    color: const Color(0xFF6A1B9A),
                    enabled: canBuild,
                    onTap: onBuild,
                  ),
                ),
              ],
              _ActionBtn(
                icon: Icons.check_circle_rounded,
                label: 'SELESAI',
                color: const Color(0xFFE65100),
                enabled: canEnd,
                onTap: onEndTurn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : Colors.grey.shade700;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: effectiveColor,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: effectiveColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMessage extends StatelessWidget {
  final String message;
  const _FloatingMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          message,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF87CEEB),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );
  }
}

// ── Modal Sheets ──────────────────────────────────────────────────────────────

class _BuyBottomSheet extends StatelessWidget {
  final String name;
  final int price;
  final int playerMoney;
  final VoidCallback onBuy;
  final VoidCallback onDecline;

  const _BuyBottomSheet({
    required this.name,
    required this.price,
    required this.playerMoney,
    required this.onBuy,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = playerMoney >= price;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2033), Color(0xFF0D1117)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          if (_TileImageHelper.buildTileImage(name, height: 100) != null) ...[
            _TileImageHelper.buildTileImage(name, height: 100)!,
            const SizedBox(height: 12),
          ] else ...[
            const Icon(Icons.home_rounded, color: Color(0xFFFFD700), size: 48),
            const SizedBox(height: 12),
          ],
          Text(
            name,
            style: GoogleFonts.baloo2(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Harga: Rp $price',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFD700),
            ),
          ),
          Text(
            'Saldo kamu: Rp $playerMoney',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Lewati', style: GoogleFonts.baloo2(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canAfford ? onBuy : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      canAfford ? '🏠  BELI!' : 'Tidak cukup',
                      style: GoogleFonts.baloo2(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
     ),
    );
  }
}

class _TileInfoSheet extends StatelessWidget {
  final dynamic tile;
  final int index;
  final GameEngine engine;
  final VoidCallback onSellHouse;
  final VoidCallback onMortgage;
  final VoidCallback onUnmortgage;

  const _TileInfoSheet({
    required this.tile,
    required this.index,
    required this.engine,
    required this.onSellHouse,
    required this.onMortgage,
    required this.onUnmortgage,
  });

  @override
  Widget build(BuildContext context) {
    final isProperty = tile is Property;
    final isUtility = tile is Utility;
    final name = tile.name as String;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF1B2033),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_TileImageHelper.buildTileImage(name, height: 120) != null) ...[
            Center(child: _TileImageHelper.buildTileImage(name, height: 120)),
            const SizedBox(height: 12),
          ],
          Text(
            name,
            style: GoogleFonts.baloo2(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (isProperty) ...[
            const SizedBox(height: 8),
            _InfoRow('Harga', 'Rp ${(tile as Property).price}'),
            _InfoRow('Sewa Dasar', 'Rp ${(tile as Property).baseRent}'),
            _InfoRow(
              'Pemilik',
              (tile as Property).owner != null
                  ? engine.gameState.players
                      .firstWhere((p) => p.id == (tile as Property).owner,
                          orElse: () => const Player(id: '', name: 'Unknown'))
                      .name
                  : 'Belum ada',
            ),
          ],
          if (isUtility) ...[
            const SizedBox(height: 8),
            _InfoRow('Harga', 'Rp ${(tile as Utility).price}'),
            _InfoRow(
              'Pemilik',
              (tile as Utility).owner != null
                  ? engine.gameState.players
                      .firstWhere((p) => p.id == (tile as Utility).owner,
                          orElse: () => const Player(id: '', name: 'Unknown'))
                      .name
                  : 'Belum ada',
            ),
            if ((tile as Utility).isMortgaged)
              _InfoRow('Status', 'Digadaikan 🔴'),
          ],
          
          // Action Buttons
          if (tile.owner == engine.currentPlayer.id && engine.currentPlayer.id == engine.gameState.players[engine.gameState.currentPlayerIndex].id) ...[
            const SizedBox(height: 20),
            if (isProperty && engine.canSellHouse(tile as Property))
              _ActionButton(
                label: '🏠 Jual Rumah (Rp ${(tile as Property).houseCost ~/ 2})',
                color: Colors.orange,
                onPressed: onSellHouse,
              ),
            if (!tile.isMortgaged && engine.canMortgage(index))
              _ActionButton(
                label: '🏦 Gadaikan (Terima Rp ${engine.mortgageValue(index)})',
                color: Colors.redAccent,
                onPressed: onMortgage,
              ),
            if (tile.isMortgaged && engine.canUnmortgage(index))
              _ActionButton(
                label: '💰 Tebus (Bayar Rp ${engine.unmortgageCost(index)})',
                color: Colors.green,
                onPressed: onUnmortgage,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  
  const _ActionButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _TileImageHelper {
  static Widget? buildTileImage(String name, {double height = 80}) {
    final n = name.toLowerCase();
    String? assetPath;
    bool isSvg = false;

    if (n.contains('asia afrika')) { assetPath = 'assets/images/landmarks_real/asia_afrika.jpg'; }
    else if (n.contains('braga')) { assetPath = 'assets/images/landmarks_real/braga.jpg'; }
    else if (n.contains('diponegoro') || n.contains('pandanaran')) { assetPath = 'assets/images/landmarks_real/diponegoro.jpg'; }
    else if (n.contains('lawang sewu')) { assetPath = 'assets/images/landmarks_real/lawang_sewu.jpg'; }
    else if (n.contains('malioboro')) { assetPath = 'assets/images/landmarks_real/malioboro.jpg'; }
    else if (n.contains('solo')) { assetPath = 'assets/images/landmarks_real/solo.jpg'; }
    else if (n.contains('pahlawan') || n.contains('tunjungan')) { assetPath = 'assets/images/landmarks_real/pahlawan.jpg'; }
    else if (n.contains('suramadu')) { assetPath = 'assets/images/landmarks_real/suramadu.jpg'; }
    else if (n.contains('sudirman')) { assetPath = 'assets/images/landmarks_real/sudirman.jpg'; }
    else if (n.contains('thamrin') || n.contains('bundaran hi')) { assetPath = 'assets/images/landmarks_real/thamrin.jpg'; }
    else if (n.contains('penghibur') || n.contains('trans studio') || n.contains('rotterdam')) { assetPath = 'assets/images/landmarks_real/suramadu.jpg'; } // Fallback makassar to suramadu
    else if (n.contains('kuta') || n.contains('seminyak') || n.contains('nusa dua')) { assetPath = 'assets/images/landmarks_real/braga.jpg'; } // Fallback bali
    else if (n.contains('monas')) { assetPath = 'assets/images/landmarks_real/sudirman.jpg'; } // Fallback
    else if (n.contains('kesempatan')) { assetPath = 'assets/images/tile_chance.svg'; isSvg = true; }
    else if (n.contains('dana umum')) { assetPath = 'assets/images/tile_community.svg'; isSvg = true; }
    else if (n.contains('go') && n.length <= 4) { assetPath = 'assets/images/tile_go.svg'; isSvg = true; }
    else if (n.contains('penjara')) { assetPath = 'assets/images/tile_jail.svg'; isSvg = true; }
    else if (n.contains('parkir')) { assetPath = 'assets/images/tile_parking.svg'; isSvg = true; }
    else if (n.contains('pajak')) { assetPath = 'assets/images/tile_tax.svg'; isSvg = true; }
    else if (n.contains('listrik') || n.contains('kereta') || n.contains('bandara') || n.contains('tol') || n.contains('air')) {
       // Just fallback to chance or text if none
    }
    
    if (assetPath == null) return null;

    if (isSvg) {
      return SvgPicture.asset(assetPath, height: height);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(assetPath, height: height, fit: BoxFit.cover),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              )),
          Text(value,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}
