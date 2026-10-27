import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player.dart';
import '../models/property.dart';
import '../models/utility.dart';
import '../models/tile.dart';
import '../models/board.dart';

class PlayerAssetsDialog extends StatelessWidget {
  final Player player;
  final List<Tile> assets;

  const PlayerAssetsDialog({
    super.key,
    required this.player,
    required this.assets,
  });

  Color _getPlayerColor() {
    switch (player.avatarColor) {
      case 'red': return const Color(0xFFD32F2F);
      case 'blue': return const Color(0xFF1565C0);
      case 'green': return const Color(0xFF2E7D32);
      case 'yellow': return const Color(0xFFF9A825);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerColor = _getPlayerColor();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 380,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: playerColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: playerColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                        style: GoogleFonts.baloo2(
                          color: playerColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aset ${player.name}',
                          style: GoogleFonts.baloo2(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Uang: Rp ${player.money}',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: assets.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Belum memiliki aset properti',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        final isProperty = asset is Property;
                        final isUtility = asset is Utility;
                        
                        final name = asset.name;
                        final isMortgaged = isProperty ? (asset as Property).isMortgaged : (isUtility ? (asset as Utility).isMortgaged : false);
                        final price = isProperty ? (asset as Property).price : (isUtility ? (asset as Utility).price : 0);
                        final propColor = isProperty ? (propertyColorMap[(asset as Property).color] ?? Colors.grey) : Colors.grey.shade700;
                        final houses = isProperty ? (asset as Property).houses : 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isMortgaged ? Colors.grey.shade200 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMortgaged ? Colors.grey.shade400 : Colors.grey.shade200,
                            ),
                            boxShadow: [
                              if (!isMortgaged)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isMortgaged ? Colors.grey.shade400 : propColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(11),
                                    bottomLeft: Radius.circular(11),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isMortgaged ? Colors.grey.shade500 : Colors.black87,
                                        decoration: isMortgaged ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    if (isMortgaged)
                                      Text(
                                        'Digadaikan',
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFD32F2F),
                                        ),
                                      )
                                    else if (isProperty)
                                      Row(
                                        children: [
                                          Icon(
                                            houses == 5 ? Icons.apartment : Icons.house_rounded,
                                            size: 14,
                                            color: propColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            houses == 5 ? 'Hotel' : '$houses Rumah',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (isUtility)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.business_rounded,
                                            size: 14,
                                            color: propColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Fasilitas Umum',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Text(
                                  'Rp $price',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isMortgaged ? Colors.grey.shade500 : Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
