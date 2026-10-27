import 'package:flutter/material.dart';
import '../models/game_engine.dart';
import '../models/board.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/tile.dart';
import '../services/game_sync_service.dart';

/// Bottom sheet listing all properties the current player can mortgage or
/// unmortgage.  Tapping a row executes the action and calls [onChanged].
class MortgageSheet extends StatefulWidget {
  final GameEngine engine;
  final VoidCallback onChanged;
  final GameSyncService? syncService;

  const MortgageSheet({
    super.key,
    required this.engine,
    required this.onChanged,
    this.syncService,
  });

  @override
  State<MortgageSheet> createState() => _MortgageSheetState();
}

class _MortgageSheetState extends State<MortgageSheet> {
  GameEngine get engine => widget.engine;

  List<_TileEntry> get _entries {
    final result = <_TileEntry>[];
    for (int i = 0; i < engine.board.tiles.length; i++) {
      final tile = engine.board.tiles[i];
      final ownedByMe = (tile is Property && tile.owner == engine.currentPlayer.id) ||
          (tile is Utility && tile.owner == engine.currentPlayer.id);
      if (!ownedByMe) continue;

      final isMortgaged =
          (tile is Property && tile.isMortgaged) ||
          (tile is Utility && tile.isMortgaged);
      final canDo = isMortgaged
          ? engine.canUnmortgage(i)
          : engine.canMortgage(i);
      result.add(_TileEntry(index: i, tile: tile, isMortgaged: isMortgaged, canAct: canDo));
    }
    return result;
  }

  Color _tileAccent(Tile tile) {
    if (tile is Property) return propertyColorMap[tile.color] ?? Colors.grey;
    return const Color(0xFFFFD600);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF795548).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Color(0xFF795548)),
              ),
              const SizedBox(width: 10),
              const Text('Gadai / Tebus Properti',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Gadai = terima ½ harga. Tebus = bayar ½ harga + 10% bunga.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Tidak ada properti yang bisa digadai.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...entries.map((e) => _buildRow(e)),
        ],
      ),
    );
  }

  Widget _buildRow(_TileEntry e) {
    final accent = _tileAccent(e.tile);
    final value = engine.mortgageValue(e.index);
    final cost  = engine.unmortgageCost(e.index);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: e.isMortgaged
            ? Colors.grey.shade100
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: e.isMortgaged ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 6,
          height: 36,
          decoration: BoxDecoration(
            color: e.isMortgaged ? Colors.grey : accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          e.tile.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: e.isMortgaged ? Colors.grey : Colors.black87,
            decoration:
                e.isMortgaged ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          e.isMortgaged
              ? 'DIGADAI — tebus Rp $cost'
              : 'Gadai → terima Rp $value',
          style: TextStyle(
            fontSize: 11,
            color: e.isMortgaged
                ? const Color(0xFFD32F2F)
                : const Color(0xFF2E7D32),
          ),
        ),
        trailing: e.canAct
            ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (e.isMortgaged) {
                      if (widget.syncService != null) {
                        widget.syncService!.unmortgageProperty(e.index);
                      } else {
                        engine.unmortgageProperty(e.index);
                      }
                    } else {
                      if (widget.syncService != null) {
                        widget.syncService!.mortgageProperty(e.index);
                      } else {
                        engine.mortgageProperty(e.index);
                      }
                    }
                  });
                  widget.onChanged();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      e.isMortgaged ? const Color(0xFF1565C0) : const Color(0xFF795548),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    e.isMortgaged ? 'TEBUS' : 'GADAI',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              )
            : Text(
                e.isMortgaged ? 'Kurang uang' : 'Ada rumah',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
      ),
    );
  }
}

class _TileEntry {
  final int index;
  final Tile tile;
  final bool isMortgaged;
  final bool canAct;
  const _TileEntry(
      {required this.index,
      required this.tile,
      required this.isMortgaged,
      required this.canAct});
}
