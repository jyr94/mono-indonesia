import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/tile.dart';
import '../models/player.dart';
import '../models/board.dart';
import '../constants/app_constants.dart';

class PropertyDetailSheet extends StatelessWidget {
  final Tile tile;
  final Board board;
  final List<Player> players;

  const PropertyDetailSheet({
    super.key,
    required this.tile,
    required this.board,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          if (tile is Property) _buildPropertyDetails(tile as Property),
          if (tile is Utility) _buildUtilityDetails(tile as Utility),
          if (tile.type == TileType.go) _buildSpecialInfo('Kumpulkan Rp 200 setiap melewati atau mendarat di sini.'),
          if (tile.type == TileType.tax) _buildSpecialInfo('Bayar pajak penghasilan Rp 200.'),
          if (tile.type == TileType.chance) _buildSpecialInfo('Ambil kartu Kesempatan! Bisa dapat uang, bayar denda, atau masuk penjara.'),
          if (tile.type == TileType.communityChest) _buildSpecialInfo('Ambil kartu Dana Umum! Berisi hadiah atau kewajiban.'),
          if (tile.type == TileType.jail) _buildSpecialInfo('Hanya mengunjungi. Tidak ada efek.'),
          if (tile.type == TileType.freeParking) _buildSpecialInfo('Istirahat gratis! Tidak ada efek.'),
          if (tile.type == TileType.goToJail) _buildSpecialInfo('Langsung masuk penjara! Tidak boleh lewat GO.'),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    Color headerColor = AppColors.primary;
    if (tile is Property) {
      headerColor = propertyColorMap[(tile as Property).color] ?? AppColors.primary;
    }

    return Row(
      children: [
        Container(
          width: 6,
          height: 40,
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tile.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (tile.description != null)
                Text(
                  tile.description!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
            ],
          ),
        ),
        _buildTypeBadge(),
      ],
    );
  }

  Widget _buildTypeBadge() {
    String label;
    Color color;
    switch (tile.type) {
      case TileType.property:
        label = 'Properti';
        color = AppColors.primary;
      case TileType.utility:
        label = 'Utilitas';
        color = AppColors.utilityTile;
      case TileType.chance:
        label = 'Kesempatan';
        color = AppColors.chanceTile;
      case TileType.communityChest:
        label = 'Dana Umum';
        color = AppColors.communityChestTile;
      case TileType.tax:
        label = 'Pajak';
        color = AppColors.taxTile;
      case TileType.go:
        label = 'GO';
        color = AppColors.goTile;
      case TileType.jail:
        label = 'Penjara';
        color = AppColors.jailTile;
      case TileType.freeParking:
        label = 'Parkir';
        color = AppColors.freeParkingTile;
      case TileType.goToJail:
        label = 'Masuk Penjara';
        color = AppColors.goToJailTile;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.computeLuminance() < 0.5 ? color : AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(Property property) {
    final owner = property.owner != null
        ? players.where((p) => p.id == property.owner).firstOrNull
        : null;
    final hasFullSet = property.owner != null
        ? board.playerOwnsFullColorSet(property.owner!, property.color)
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Harga Beli', 'Rp ${property.price}'),
        const Divider(height: 16),
        const Text(
          'Tabel Sewa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        _buildRentRow('Tanpa rumah', property.baseRent, property.houses == 0),
        _buildRentRow('1 Rumah', property.rentWith1House, property.houses == 1),
        _buildRentRow('2 Rumah', property.rentWith2Houses, property.houses == 2),
        _buildRentRow('3 Rumah', property.rentWith3Houses, property.houses == 3),
        _buildRentRow('4 Rumah', property.rentWith4Houses, property.houses == 4),
        _buildRentRow('Hotel', property.rentWithHotel, property.houses == 5),
        const Divider(height: 16),
        _buildInfoRow('Biaya Bangun', 'Rp ${property.houseCost}'),
        if (hasFullSet && property.houses == 0)
          _buildInfoRow('Sewa Full Set', 'Rp ${property.baseRent * 2}'),
        if (owner != null) ...[
          const Divider(height: 16),
          Row(
            children: [
              const Text('Pemilik: ', style: TextStyle(fontSize: 12)),
              Text(
                owner.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              if (property.houses > 0) ...[
                const Spacer(),
                Icon(
                  property.houses == 5 ? Icons.home_work : Icons.home,
                  size: 16,
                  color: property.houses == 5 ? Colors.red : AppColors.moneyGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  property.houses == 5 ? 'Hotel' : '${property.houses} Rumah',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildUtilityDetails(Utility utility) {
    final owner = utility.owner != null
        ? players.where((p) => p.id == utility.owner).firstOrNull
        : null;
    final utilityCount = utility.owner != null
        ? board.countUtilitiesOwned(utility.owner!)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Harga Beli', 'Rp ${utility.price}'),
        const Divider(height: 16),
        const Text(
          'Sewa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        _buildInfoRow('1 Utilitas', '4x lemparan dadu'),
        _buildInfoRow('2 Utilitas', '10x lemparan dadu'),
        if (owner != null) ...[
          const Divider(height: 16),
          Row(
            children: [
              const Text('Pemilik: ', style: TextStyle(fontSize: 12)),
              Text(
                owner.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$utilityCount dimiliki',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRentRow(String label, int rent, bool isCurrent) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: isCurrent ? 6 : 0),
      decoration: isCurrent
          ? BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Rp $rent',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialInfo(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
