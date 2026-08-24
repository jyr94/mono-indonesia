import 'package:flutter/material.dart';
import '../models/game_engine.dart';
import '../models/player.dart';
import '../models/board.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/tile.dart';
import '../services/game_sync_service.dart';

/// Full trade proposal dialog.
/// Lets the current player select:
///   - which of their properties to offer
///   - which opponent to trade with
///   - which of that opponent's properties to request
///   - a cash sweetener (positive = initiator pays, negative = initiator demands)
class TradeDialog extends StatefulWidget {
  final GameEngine engine;
  final VoidCallback onTradeComplete;
  final GameSyncService? syncService;

  const TradeDialog({
    super.key,
    required this.engine,
    required this.onTradeComplete,
    this.syncService,
  });

  @override
  State<TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends State<TradeDialog> {
  GameEngine get engine => widget.engine;

  late String _targetPlayerId;
  final Set<int> _offeredTiles = {};
  final Set<int> _requestedTiles = {};
  final _cashCtrl = TextEditingController(text: '0');

  List<Player> get _opponents => engine.gameState.players
      .where((p) => p.id != engine.currentPlayer.id && !p.isBankrupt)
      .toList();

  @override
  void initState() {
    super.initState();
    _targetPlayerId = _opponents.isNotEmpty ? _opponents.first.id : '';
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  List<Tile> _tilesOwnedBy(String playerId) {
    return engine.board.tiles
        .where((t) =>
            (t is Property && t.owner == playerId) ||
            (t is Utility && t.owner == playerId))
        .toList();
  }

  Color _tileAccent(Tile tile) {
    if (tile is Property) return propertyColorMap[tile.color] ?? Colors.grey;
    return const Color(0xFFFFD600);
  }

  void _propose() {
    final cashText = int.tryParse(_cashCtrl.text) ?? 0;
    final offer = TradeOffer(
      fromPlayerId: engine.currentPlayer.id,
      toPlayerId: _targetPlayerId,
      offeredTiles: _offeredTiles.toList(),
      requestedTiles: _requestedTiles.toList(),
      cashOffer: cashText,
    );
    if (widget.syncService != null) {
      widget.syncService!.proposeTrade(offer);
      widget.onTradeComplete();
      Navigator.pop(context);
    } else {
      final ok = engine.proposeTrade(offer);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tawaran tidak valid. Periksa uang dan kepemilikan.')),
        );
        return;
      }
      // Auto-accept for local hot-seat (both players on same device)
      engine.acceptTrade();
      widget.onTradeComplete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_opponents.isEmpty) {
      return AlertDialog(
        title: const Text('Tukar Properti'),
        content: const Text('Tidak ada lawan untuk diajak berdagang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      );
    }

    final myTiles = _tilesOwnedBy(engine.currentPlayer.id);
    final targetPlayer =
        engine.gameState.players.firstWhere((p) => p.id == _targetPlayerId);
    final theirTiles = _tilesOwnedBy(_targetPlayerId);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF004D40)]),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Colors.white),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Tukar Properti',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Target player selector ──
              const Text('Tawaran ke:',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _opponents.map((p) {
                  final sel = p.id == _targetPlayerId;
                  return ChoiceChip(
                    label: Text(p.name),
                    selected: sel,
                    selectedColor: const Color(0xFF00695C),
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700),
                    onSelected: (_) => setState(() {
                      _targetPlayerId = p.id;
                      _requestedTiles.clear();
                    }),
                  );
                }).toList(),
              ),
              const Divider(height: 20),

              // ── My properties to offer ──
              Text('Properti ${engine.currentPlayer.name} (pilih untuk ditawarkan):',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              if (myTiles.isEmpty)
                const Text('Tidak punya properti',
                    style: TextStyle(color: Colors.grey, fontSize: 12))
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: myTiles.map((tile) {
                    final sel = _offeredTiles.contains(tile.index);
                    return _TileChip(
                      tile: tile,
                      selected: sel,
                      onTap: () => setState(() => sel
                          ? _offeredTiles.remove(tile.index)
                          : _offeredTiles.add(tile.index)),
                    );
                  }).toList(),
                ),
              const Divider(height: 20),

              // ── Their properties to request ──
              Text('Properti ${targetPlayer.name} (pilih yang diinginkan):',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              if (theirTiles.isEmpty)
                const Text('Tidak punya properti',
                    style: TextStyle(color: Colors.grey, fontSize: 12))
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: theirTiles.map((tile) {
                    final sel = _requestedTiles.contains(tile.index);
                    return _TileChip(
                      tile: tile,
                      selected: sel,
                      onTap: () => setState(() => sel
                          ? _requestedTiles.remove(tile.index)
                          : _requestedTiles.add(tile.index)),
                    );
                  }).toList(),
                ),
              const Divider(height: 20),

              // ── Cash sweetener ──
              const Text('Tambahan uang (positif = kamu bayar):',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Rp ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextField(
                      controller: _cashCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '0',
                      ),
                      onChanged: (_) {},  // value read in _propose via _cashCtrl.text
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Propose button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _propose,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(widget.syncService != null ? 'AJUKAN' : 'AJUKAN & SETUJUI',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileChip extends StatelessWidget {
  final Tile tile;
  final bool selected;
  final VoidCallback onTap;

  const _TileChip({
    required this.tile,
    required this.selected,
    required this.onTap,
  });

  Color get _accent {
    if (tile is Property) return propertyColorMap[(tile as Property).color] ?? Colors.grey;
    return const Color(0xFFFFD600);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? _accent.withOpacity(0.18) : Colors.white,
          border: Border.all(
              color: selected ? _accent : Colors.grey.shade300,
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 20,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              tile.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? _accent : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
