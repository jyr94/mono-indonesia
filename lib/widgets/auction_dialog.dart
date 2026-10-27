import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/game_engine.dart';
import '../models/board.dart';
import '../constants/app_constants.dart';
import '../services/game_sync_service.dart';

class AuctionDialog extends StatefulWidget {
  final GameEngine engine;
  final VoidCallback onAuctionComplete;
  final GameSyncService? syncService;

  const AuctionDialog({
    super.key,
    required this.engine,
    required this.onAuctionComplete,
    this.syncService,
  });

  @override
  State<AuctionDialog> createState() => _AuctionDialogState();
}

class _AuctionDialogState extends State<AuctionDialog> {
  GameEngine get engine => widget.engine;
  AuctionState? get auction => engine.auctionState;

  Tile? get auctionTile {
    if (auction == null) return null;
    return engine.board.getTile(int.parse(auction!.propertyIndex));
  }

  @override
  void initState() {
    super.initState();
  }

  void _placeBid(String playerId, int amount) {
    setState(() {
      if (widget.syncService != null && widget.syncService!.playerId == playerId) {
        widget.syncService!.auctionBid(amount);
      } else {
        engine.placeBid(playerId, amount);
      }
    });
  }

  void _passBid(String playerId) {
    setState(() {
      if (widget.syncService != null && widget.syncService!.playerId == playerId) {
        widget.syncService!.auctionPass();
      } else {
        engine.passAuction(playerId);
      }
      if (!engine.isInAuction) {
        widget.onAuctionComplete();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tile = auctionTile;
    if (tile == null || auction == null) {
      return const SizedBox.shrink();
    }

    final currentBid = auction!.highestBid;
    final activeBidders = auction!.activeBidders;
    final allPlayers = engine.gameState.players;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.gavel, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lelang',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  tile.name,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Property info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (tile is Property)
                    Container(
                      width: 12,
                      height: 30,
                      decoration: BoxDecoration(
                        color: propertyColorMap[tile.color],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga dasar: Rp ${tile is Property ? tile.price : tile is Utility ? tile.price : 0}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (tile is Property)
                          Text(
                            'Sewa: Rp ${tile.baseRent}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Current highest bid
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: currentBid > 0
                    ? AppColors.moneyGreen.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: currentBid > 0 ? AppColors.moneyGreen : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    currentBid > 0 ? 'Tawaran Tertinggi' : 'Belum Ada Tawaran',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp $currentBid',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: currentBid > 0 ? AppColors.moneyGreen : Colors.grey,
                    ),
                  ),
                  if (auction!.highestBidder != null)
                    Text(
                      'oleh ${allPlayers.firstWhere((p) => p.id == auction!.highestBidder).name}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Player bid controls
            ...allPlayers.where((p) => !p.isBankrupt).map((player) {
              final isActive = activeBidders.contains(player.id);
              final playerBid = auction!.bids[player.id] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? Colors.grey.shade300 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    // Player avatar
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _playerColor(player),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          player.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isActive ? AppColors.textDark : Colors.grey,
                            ),
                          ),
                          Text(
                            'Rp ${player.money}${playerBid > 0 ? ' | Bid: Rp $playerBid' : ''}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive) 
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true, // so buttons align to the right initially if possible
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBidButton(
                                player.id,
                                currentBid + 10,
                                '+10',
                                player.money > currentBid + 10,
                              ),
                              const SizedBox(width: 4),
                              _buildBidButton(
                                player.id,
                                currentBid + 50,
                                '+50',
                                player.money > currentBid + 50,
                              ),
                              const SizedBox(width: 4),
                              // Pass button
                              SizedBox(
                                height: 30,
                                child: OutlinedButton(
                                  onPressed: () => _passBid(player.id),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    side: BorderSide(color: Colors.grey.shade400),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lewat',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(
                        'Lewat',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
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

  Widget _buildBidButton(String playerId, int amount, String label, bool enabled) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: enabled ? () => _placeBid(playerId, amount) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.moneyGreen,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Color _playerColor(Player player) {
    switch (player.avatarColor) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
