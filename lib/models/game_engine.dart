import 'dart:math';
import 'board.dart';
import 'player.dart';
import 'property.dart';
import 'utility.dart';
import 'tile.dart';
import 'dice.dart';
import 'game_state.dart';

enum GameAction {
  rollDice,
  buyProperty,
  payRent,
  buildHouse,
  auction,
  mortgage,
  trade,
  endTurn,
  none,
}

// ── Auction ──────────────────────────────────────────────────────────────────

class AuctionState {
  final String propertyIndex;
  final Map<String, int> bids;
  final String? highestBidder;
  final int highestBid;
  final List<String> activeBidders;

  const AuctionState({
    required this.propertyIndex,
    this.bids = const {},
    this.highestBidder,
    this.highestBid = 0,
    this.activeBidders = const [],
  });

  AuctionState copyWith({
    Map<String, int>? bids,
    String? highestBidder,
    int? highestBid,
    List<String>? activeBidders,
  }) {
    return AuctionState(
      propertyIndex: propertyIndex,
      bids: bids ?? this.bids,
      highestBidder: highestBidder ?? this.highestBidder,
      highestBid: highestBid ?? this.highestBid,
      activeBidders: activeBidders ?? this.activeBidders,
    );
  }

  Map<String, dynamic> toJson() => {
    'propertyIndex': propertyIndex,
    'bids': bids,
    'highestBidder': highestBidder,
    'highestBid': highestBid,
    'activeBidders': activeBidders,
  };

  factory AuctionState.fromJson(Map<String, dynamic> json) {
    return AuctionState(
      propertyIndex: json['propertyIndex'] as String,
      bids: Map<String, int>.from(json['bids'] as Map? ?? {}),
      highestBidder: json['highestBidder'] as String?,
      highestBid: json['highestBid'] as int? ?? 0,
      activeBidders: List<String>.from(json['activeBidders'] as List? ?? []),
    );
  }
}

// ── Trade ─────────────────────────────────────────────────────────────────────

class TradeOffer {
  /// Player making the offer.
  final String fromPlayerId;

  /// Player receiving the offer.
  final String toPlayerId;

  /// Tile indices the initiating player offers.
  final List<int> offeredTiles;

  /// Tile indices the initiating player wants in return.
  final List<int> requestedTiles;

  /// Cash the initiating player pays (can be negative = demands cash).
  final int cashOffer;

  const TradeOffer({
    required this.fromPlayerId,
    required this.toPlayerId,
    this.offeredTiles = const [],
    this.requestedTiles = const [],
    this.cashOffer = 0,
  });

  Map<String, dynamic> toJson() => {
    'fromPlayerId': fromPlayerId,
    'toPlayerId': toPlayerId,
    'offeredTiles': offeredTiles,
    'requestedTiles': requestedTiles,
    'cashOffer': cashOffer,
  };

  factory TradeOffer.fromJson(Map<String, dynamic> json) {
    return TradeOffer(
      fromPlayerId: json['fromPlayerId'] as String,
      toPlayerId: json['toPlayerId'] as String,
      offeredTiles: List<int>.from(json['offeredTiles'] as List? ?? []),
      requestedTiles: List<int>.from(json['requestedTiles'] as List? ?? []),
      cashOffer: json['cashOffer'] as int? ?? 0,
    );
  }
}

// ── GameEngine ────────────────────────────────────────────────────────────────

class GameEngine {
  Board board;
  GameState gameState;
  AuctionState? auctionState;
  TradeOffer? pendingTrade;
  String? messageLog;

  GameEngine({
    required this.board,
    required this.gameState,
  });

  Player get currentPlayer => gameState.currentPlayer;

  void _updatePlayers(Player updatedPlayer) {
    final updatedPlayers = List<Player>.from(gameState.players);
    updatedPlayers[gameState.currentPlayerIndex] = updatedPlayer;
    gameState = gameState.copyWith(players: updatedPlayers);
  }

  Player _getPlayer(int index) => gameState.players[index];

  void _setMessage(String msg) => messageLog = msg;

  // ── Dice & Turn Flow ──────────────────────────────────────────────────────

  DiceRoll rollDice() {
    if (gameState.phase != TurnPhase.preRoll) {
      throw StateError('Not in preRoll phase');
    }

    final roll = DiceRoll.roll();
    Player player = currentPlayer;

    if (player.isInJail) {
      return _handleJailRoll(player, roll);
    }

    int newDoublesCount = player.doublesCount;
    if (roll.isDoubles) {
      newDoublesCount++;
      if (newDoublesCount >= 3) {
        // Three doubles in a row → straight to jail
        _sendToJail(player);
        _setMessage('${player.name} lempar 3× double! Langsung masuk penjara!');
        gameState = gameState.copyWith(lastRoll: roll, phase: TurnPhase.ended);
        return roll;
      }
    } else {
      newDoublesCount = 0;
    }

    final oldPosition = player.position;
    final newPosition = (oldPosition + roll.total) % board.totalTiles;
    final passedGo = _didPassGo(oldPosition, roll.total);

    player = player.copyWith(position: newPosition, doublesCount: newDoublesCount);
    _updatePlayers(player);

    if (passedGo) {
      player = player.copyWith(money: player.money + 200);
      _updatePlayers(player);
      _setMessage('${player.name} melewati GO! Terima Rp 200');
    }

    gameState = gameState.copyWith(lastRoll: roll, phase: TurnPhase.postRoll);
    _handleTileLanding(player);
    return roll;
  }

  DiceRoll _handleJailRoll(Player player, DiceRoll roll) {
    // Use jail-free card first if available
    if (player.jailFreeCards > 0) {
      player = player.copyWith(
        jailFreeCards: player.jailFreeCards - 1,
        status: PlayerStatus.playing,
        jailTurns: 0,
        doublesCount: 0,
        position: (player.position + roll.total) % board.totalTiles,
      );
      _updatePlayers(player);
      _setMessage('${player.name} pakai Kartu Bebas Penjara! Keluar!');
      gameState = gameState.copyWith(lastRoll: roll, phase: TurnPhase.postRoll);
      _handleTileLanding(player);
      return roll;
    }

    if (roll.isDoubles) {
      player = player.copyWith(
        status: PlayerStatus.playing,
        jailTurns: 0,
        doublesCount: 0,
        position: (player.position + roll.total) % board.totalTiles,
      );
      _updatePlayers(player);
      _setMessage('${player.name} lempar double! Bebas dari penjara!');
      gameState = gameState.copyWith(lastRoll: roll, phase: TurnPhase.postRoll);
      _handleTileLanding(player);
    } else {
      final newTurns = player.jailTurns + 1;
      if (newTurns >= 3) {
        // Three failed attempts → pay Rp 50 and move
        player = player.copyWith(
          status: PlayerStatus.playing,
          jailTurns: 0,
          money: player.money - 50,
          position: (player.position + roll.total) % board.totalTiles,
        );
        _updatePlayers(player);
        _setMessage('${player.name} keluar penjara paksa (bayar Rp 50)');
        _checkBankrupt(player);
        gameState = gameState.copyWith(lastRoll: roll, phase: TurnPhase.postRoll);
        _handleTileLanding(player);
      } else {
        player = player.copyWith(jailTurns: newTurns);
        _updatePlayers(player);
        _setMessage('${player.name} masih di penjara (giliran $newTurns/3)');
        gameState = gameState.copyWith(lastRoll: roll, phase: TurnPhase.ended);
      }
    }
    return roll;
  }

  void _sendToJail(Player player) {
    final updated = player.copyWith(
      position: 10,
      status: PlayerStatus.inJail,
      jailTurns: 0,
      doublesCount: 0,
    );
    _updatePlayers(updated);
  }

  bool _didPassGo(int oldPosition, int diceTotal) {
    return (oldPosition + diceTotal) >= board.totalTiles;
  }

  // ── Tile Landing ──────────────────────────────────────────────────────────

  void _handleTileLanding(Player player) {
    final tile = board.getTile(player.position);
    switch (tile.type) {
      case TileType.go:
        break; // GO bonus already applied when passing
      case TileType.tax:
        _handleTax(player, tile);
      case TileType.chance:
        _handleChance(player);
      case TileType.communityChest:
        _handleCommunityChest(player);
      case TileType.goToJail:
        _handleGoToJail(player);
      case TileType.jail:
        _setMessage('${player.name} hanya mengunjungi penjara 👀');
      case TileType.freeParking:
        _setMessage('${player.name} parkir gratis! Tenang sejenak ⛱️');
      case TileType.property:
        _handlePropertyLanding(player, tile as Property);
      case TileType.utility:
        _handleUtilityLanding(player, tile as Utility);
    }
  }

  void _handleTax(Player player, Tile tile) {
    // Index-specific tax amounts
    final taxAmount = switch (tile.index) {
      4  => 200,
      30 => 100,
      38 => 75,
      _  => 200,
    };
    final updated = player.copyWith(money: player.money - taxAmount);
    _updatePlayers(updated);
    _setMessage('${player.name} bayar pajak Rp $taxAmount 💸');
    _checkBankrupt(updated);
  }

  // ── Chance Cards (15 cards, Indonesian-themed) ────────────────────────────

  static const List<Map<String, dynamic>> _chanceCards = [
    {'type': 'money', 'amount': 150,  'msg': '🎉 Menang undian berhadiah! Terima Rp 150'},
    {'type': 'money', 'amount': -150, 'msg': '🔨 Biaya renovasi rumah! Bayar Rp 150'},
    {'type': 'go',    'amount': 200,  'msg': '🚀 Maju ke GO! Terima Rp 200'},
    {'type': 'jail',  'amount': 0,    'msg': '🚔 Ketangkap polisi! Masuk Penjara!'},
    {'type': 'money', 'amount': -100, 'msg': '🚦 Kena tilang polisi! Bayar Rp 100'},
    {'type': 'money', 'amount': 100,  'msg': '📈 Hasil investasi saham! Terima Rp 100'},
    {'type': 'money', 'amount': 200,  'msg': '🏆 Juara kompetisi startup! Terima Rp 200'},
    {'type': 'money', 'amount': -75,  'msg': '🔧 Servis motor! Bayar Rp 75'},
    {'type': 'money', 'amount': 50,   'msg': '💰 Dapat transfer dari teman! Terima Rp 50'},
    {'type': 'money', 'amount': -200, 'msg': '💊 Rawat inap di rumah sakit! Bayar Rp 200'},
    {'type': 'money', 'amount': 150,  'msg': '🎁 Dapat bonus proyek freelance! Terima Rp 150'},
    {'type': 'money', 'amount': -50,  'msg': '⚠️ Denda parkir liar! Bayar Rp 50'},
    {'type': 'free',  'amount': 0,    'msg': '🎟️ Kartu Bebas Penjara! Simpan untuk nanti'},
    {'type': 'money', 'amount': 75,   'msg': '📱 Jual HP lama! Terima Rp 75'},
    {'type': 'money', 'amount': -125, 'msg': '🌊 Banjir merusak properti! Bayar Rp 125'},
  ];

  // ── Community Chest Cards (15 cards, Indonesian-themed) ───────────────────

  static const List<Map<String, dynamic>> _communityChestCards = [
    {'type': 'money', 'amount': 200,  'msg': '🏠 Warisan dari Mbah! Terima Rp 200'},
    {'type': 'money', 'amount': -50,  'msg': '💡 Tagihan listrik PLN! Bayar Rp 50'},
    {'type': 'money', 'amount': 100,  'msg': '💼 Bonus gaji ke-13! Terima Rp 100'},
    {'type': 'money', 'amount': -100, 'msg': '🏥 Biaya perawatan kesehatan! Bayar Rp 100'},
    {'type': 'go',    'amount': 200,  'msg': '🚀 Maju ke GO! Terima Rp 200'},
    {'type': 'money', 'amount': 50,   'msg': '🎂 Hadiah ulang tahun dari keluarga! Terima Rp 50'},
    {'type': 'money', 'amount': 250,  'msg': '💰 Dapat THR lebaran! Terima Rp 250'},
    {'type': 'money', 'amount': -75,  'msg': '🚿 Tagihan air PDAM! Bayar Rp 75'},
    {'type': 'money', 'amount': 125,  'msg': '🎓 Beasiswa kuliah! Terima Rp 125'},
    {'type': 'money', 'amount': -150, 'msg': '🛫 Biaya mudik lebaran! Bayar Rp 150'},
    {'type': 'money', 'amount': 175,  'msg': '📦 Usaha online shop sukses! Terima Rp 175'},
    {'type': 'money', 'amount': -60,  'msg': '📡 Tagihan internet indihome! Bayar Rp 60'},
    {'type': 'free',  'amount': 0,    'msg': '🎟️ Kartu Bebas Penjara! Simpan untuk nanti'},
    {'type': 'money', 'amount': 80,   'msg': '🥘 Dapat katering arisan! Terima Rp 80'},
    {'type': 'money', 'amount': -40,  'msg': '🌿 Iuran warga RT/RW! Bayar Rp 40'},
  ];

  void _handleChance(Player player) {
    final card = _chanceCards[Random().nextInt(_chanceCards.length)];
    _applyCard(player, card, prefix: 'Kartu Kesempatan');
  }

  void _handleCommunityChest(Player player) {
    final card = _communityChestCards[Random().nextInt(_communityChestCards.length)];
    _applyCard(player, card, prefix: 'Kartu Dana Umum');
  }

  void _applyCard(Player player, Map<String, dynamic> card, {required String prefix}) {
    final type   = card['type'] as String;
    final amount = card['amount'] as int;
    final msg    = card['msg'] as String;

    switch (type) {
      case 'go':
        final updated = player.copyWith(position: 0, money: player.money + amount);
        _updatePlayers(updated);
        _setMessage('$prefix: $msg');
      case 'jail':
        _sendToJail(player);
        _setMessage('$prefix: $msg');
        gameState = gameState.copyWith(phase: TurnPhase.ended);
      case 'free':
        final updated = player.copyWith(jailFreeCards: player.jailFreeCards + 1);
        _updatePlayers(updated);
        _setMessage('$prefix: $msg');
      default: // 'money'
        final updated = player.copyWith(money: player.money + amount);
        _updatePlayers(updated);
        _setMessage('$prefix: $msg');
        if (amount < 0) _checkBankrupt(updated);
    }
  }

  void _handleGoToJail(Player player) {
    _sendToJail(player);
    _setMessage('${player.name} masuk penjara! 🚔');
    gameState = gameState.copyWith(phase: TurnPhase.ended);
  }

  // ── Property / Utility Landing ────────────────────────────────────────────

  void _handlePropertyLanding(Player player, Property property) {
    if (property.isMortgaged) {
      _setMessage('${property.name} sedang digadai — tidak ada sewa.');
      return;
    }
    if (!property.isOwned) {
      gameState = gameState.copyWith(phase: TurnPhase.buying);
      _setMessage('${property.name} belum dimiliki! Harga: Rp ${property.price}');
      return;
    }
    if (property.owner == player.id) {
      _setMessage('${player.name} mendarat di properti sendiri 🏠');
      return;
    }

    final ownerIndex = gameState.players.indexWhere((p) => p.id == property.owner);
    if (ownerIndex == -1) return;
    final owner = _getPlayer(ownerIndex);

    bool hasFullSet = board.playerOwnsFullColorSet(owner.id, property.color);
    int rent = property.currentRent;
    if (hasFullSet && property.houses == 0) rent = property.baseRent * 2;

    _payRent(player, owner, rent, property.name);
  }

  void _handleUtilityLanding(Player player, Utility utility) {
    if (utility.isMortgaged) {
      _setMessage('${utility.name} sedang digadai — tidak ada sewa.');
      return;
    }
    if (!utility.isOwned) {
      gameState = gameState.copyWith(phase: TurnPhase.buying);
      _setMessage('${utility.name} belum dimiliki! Harga: Rp ${utility.price}');
      return;
    }
    if (utility.owner == player.id) {
      _setMessage('${player.name} mendarat di utilitas sendiri ⚡');
      return;
    }

    final ownerIndex = gameState.players.indexWhere((p) => p.id == utility.owner);
    if (ownerIndex == -1) return;
    final owner = _getPlayer(ownerIndex);

    final diceTotal = gameState.lastRoll?.total ?? 7;
    final utilitiesOwned = board.countUtilitiesOwned(owner.id);
    final rent = utility.calculateRent(diceTotal, utilitiesOwned: utilitiesOwned);

    _payRent(player, owner, rent, utility.name);
  }

  void _payRent(Player tenant, Player owner, int amount, String propertyName) {
    final updatedTenant = tenant.copyWith(money: tenant.money - amount);
    final updatedOwner  = owner.copyWith(money: owner.money + amount);

    final updatedPlayers = List<Player>.from(gameState.players);
    updatedPlayers[gameState.currentPlayerIndex] = updatedTenant;
    final ownerIdx = gameState.players.indexWhere((p) => p.id == owner.id);
    updatedPlayers[ownerIdx] = updatedOwner;

    gameState = gameState.copyWith(players: updatedPlayers);
    _setMessage('${tenant.name} bayar sewa Rp $amount ke ${owner.name} ($propertyName) 💸');
    _checkBankrupt(updatedTenant);
  }

  // ── Buy Property ──────────────────────────────────────────────────────────

  bool buyProperty() {
    if (gameState.phase != TurnPhase.buying) return false;
    final player = currentPlayer;
    final tile = board.getTile(player.position);

    if (tile is Property) {
      if (tile.isOwned || player.money < tile.price) return false;
      _updateTile(tile.index, tile.copyWith(owner: player.id));
      _updatePlayers(player.copyWith(money: player.money - tile.price));
      _setMessage('${player.name} membeli ${tile.name} seharga Rp ${tile.price} 🏠');
      gameState = gameState.copyWith(phase: TurnPhase.postRoll);
      return true;
    }
    if (tile is Utility) {
      if (tile.isOwned || player.money < tile.price) return false;
      _updateTile(tile.index, tile.copyWith(owner: player.id));
      _updatePlayers(player.copyWith(money: player.money - tile.price));
      _setMessage('${player.name} membeli ${tile.name} seharga Rp ${tile.price} ⚡');
      gameState = gameState.copyWith(phase: TurnPhase.postRoll);
      return true;
    }
    return false;
  }

  void declineBuy() {
    if (gameState.phase != TurnPhase.buying) return;
    final tile = board.getTile(currentPlayer.position);
    _setMessage('${currentPlayer.name} menolak membeli ${tile.name}. Lelang dimulai! 🔨');
    _startAuction();
  }

  // ── Auction ───────────────────────────────────────────────────────────────

  void _startAuction() {
    final tileIndex   = currentPlayer.position;
    final activeBidders = gameState.players
        .where((p) => !p.isBankrupt)
        .map((p) => p.id)
        .toList();

    auctionState = AuctionState(
      propertyIndex: tileIndex.toString(),
      activeBidders: activeBidders,
    );
    gameState = gameState.copyWith(phase: TurnPhase.auctioning);
  }

  bool placeBid(String playerId, int amount) {
    if (auctionState == null) return false;
    if (amount <= auctionState!.highestBid) return false;
    final player = gameState.players.firstWhere((p) => p.id == playerId);
    if (player.money < amount) return false;

    final newBids = Map<String, int>.from(auctionState!.bids)..[playerId] = amount;
    auctionState = auctionState!.copyWith(
      bids: newBids, highestBidder: playerId, highestBid: amount,
    );
    return true;
  }

  void passAuction(String playerId) {
    if (auctionState == null) return;
    final newActive = List<String>.from(auctionState!.activeBidders)..remove(playerId);
    if (newActive.length <= 1) {
      _resolveAuction();
    } else {
      auctionState = auctionState!.copyWith(activeBidders: newActive);
    }
  }

  void _resolveAuction() {
    if (auctionState == null) return;
    final winner    = auctionState!.highestBidder;
    final price     = auctionState!.highestBid;
    final tileIndex = int.parse(auctionState!.propertyIndex);

    if (winner != null && price > 0) {
      final winnerPlayer = gameState.players.firstWhere((p) => p.id == winner);
      final updatedPlayer = winnerPlayer.copyWith(money: winnerPlayer.money - price);

      final tile = board.getTile(tileIndex);
      if (tile is Property) { _updateTile(tileIndex, tile.copyWith(owner: winner)); }
      else if (tile is Utility) { _updateTile(tileIndex, tile.copyWith(owner: winner)); }

      final updatedPlayers = List<Player>.from(gameState.players);
      updatedPlayers[updatedPlayers.indexWhere((p) => p.id == winner)] = updatedPlayer;
      gameState = gameState.copyWith(players: updatedPlayers);
      _setMessage('${winnerPlayer.name} memenangkan lelang Rp $price! 🏆');
    } else {
      _setMessage('Lelang selesai — tidak ada penawar.');
    }

    auctionState = null;
    gameState = gameState.copyWith(phase: TurnPhase.postRoll);
  }

  // ── Build House ───────────────────────────────────────────────────────────

  bool canBuildHouse(Property property) {
    if (!property.isOwned) return false;
    if (property.isMortgaged) return false;
    if (property.houses >= 5) return false;
    if (property.owner != currentPlayer.id) return false;

    final hasFullSet = board.playerOwnsFullColorSet(currentPlayer.id, property.color);
    if (!hasFullSet) return false;

    // Even-building rule
    final properties = board.getPropertiesByColor(property.color);
    final minHouses  = properties.map((p) => p.houses).reduce(min);
    if (property.houses > minHouses) return false;

    return currentPlayer.money >= property.houseCost;
  }

  bool buildHouse(int propertyIndex) {
    final tile = board.getTile(propertyIndex);
    if (tile is! Property || !canBuildHouse(tile)) return false;

    _updateTile(propertyIndex, tile.copyWith(houses: tile.houses + 1));
    _updatePlayers(currentPlayer.copyWith(money: currentPlayer.money - tile.houseCost));
    _setMessage('${currentPlayer.name} membangun di ${tile.name} 🏗️ (${tile.houses + 1})');
    return true;
  }

  List<Property> get buildableProperties =>
      board.getAllPropertiesOwnedBy(currentPlayer.id).where(canBuildHouse).toList();

  // ── Mortgage ──────────────────────────────────────────────────────────────

  /// Mortgage value = half the purchase price.
  int mortgageValue(int tileIndex) {
    final tile = board.getTile(tileIndex);
    if (tile is Property) return tile.price ~/ 2;
    if (tile is Utility) return tile.price ~/ 2;
    return 0;
  }

  /// Unmortgage cost = mortgage value × 1.1 (10% interest).
  int unmortgageCost(int tileIndex) => (mortgageValue(tileIndex) * 1.1).round();

  bool canMortgage(int tileIndex) {
    final tile = board.getTile(tileIndex);
    if (tile is Property) {
      if (tile.owner != currentPlayer.id) return false;
      if (tile.isMortgaged) return false;
      // Cannot mortgage if any house exists in the color group
      final group = board.getPropertiesByColor(tile.color);
      return group.every((p) => p.houses == 0);
    }
    if (tile is Utility) return tile.owner == currentPlayer.id && !tile.isMortgaged;
    return false;
  }

  bool canUnmortgage(int tileIndex) {
    final tile = board.getTile(tileIndex);
    if (tile is Property) {
      return tile.owner == currentPlayer.id &&
          tile.isMortgaged &&
          currentPlayer.money >= unmortgageCost(tileIndex);
    }
    if (tile is Utility) {
      return tile.owner == currentPlayer.id &&
          tile.isMortgaged &&
          currentPlayer.money >= unmortgageCost(tileIndex);
    }
    return false;
  }

  bool mortgageProperty(int tileIndex) {
    if (!canMortgage(tileIndex)) return false;
    final value = mortgageValue(tileIndex);
    final tile  = board.getTile(tileIndex);

    if (tile is Property) {
      _updateTile(tileIndex, tile.copyWith(isMortgaged: true));
    } else if (tile is Utility) {
      _updateTile(tileIndex, tile.copyWith(isMortgaged: true));
    }
    _updatePlayers(currentPlayer.copyWith(money: currentPlayer.money + value));
    _setMessage('${currentPlayer.name} menggadai ${tile.name} → Terima Rp $value 💰');
    return true;
  }

  bool unmortgageProperty(int tileIndex) {
    if (!canUnmortgage(tileIndex)) return false;
    final cost = unmortgageCost(tileIndex);
    final tile = board.getTile(tileIndex);

    if (tile is Property) {
      _updateTile(tileIndex, tile.copyWith(isMortgaged: false));
    } else if (tile is Utility) {
      _updateTile(tileIndex, tile.copyWith(isMortgaged: false));
    }
    _updatePlayers(currentPlayer.copyWith(money: currentPlayer.money - cost));
    _setMessage('${currentPlayer.name} menebus ${tile.name} → Bayar Rp $cost');
    return true;
  }

  List<int> get mortgageableTiles => [
    for (int i = 0; i < board.tiles.length; i++)
      if (canMortgage(i)) i,
  ];

  List<int> get unmortgageableTiles => [
    for (int i = 0; i < board.tiles.length; i++)
      if (canUnmortgage(i)) i,
  ];

  // ── Trade ─────────────────────────────────────────────────────────────────

  /// Propose a trade. Returns false if the offer is invalid.
  bool proposeTrade(TradeOffer offer) {
    // Basic validation: offered tiles must belong to initiator
    for (final idx in offer.offeredTiles) {
      final tile = board.getTile(idx);
      if (tile is Property && tile.owner != offer.fromPlayerId) return false;
      if (tile is Utility  && tile.owner != offer.fromPlayerId) return false;
    }
    // Requested tiles must belong to target
    for (final idx in offer.requestedTiles) {
      final tile = board.getTile(idx);
      if (tile is Property && tile.owner != offer.toPlayerId) return false;
      if (tile is Utility  && tile.owner != offer.toPlayerId) return false;
    }
    // Initiator must have enough cash for cashOffer (if positive = paying)
    if (offer.cashOffer > 0) {
      final from = gameState.players.firstWhere((p) => p.id == offer.fromPlayerId);
      if (from.money < offer.cashOffer) return false;
    }
    pendingTrade = offer;
    _setMessage('${_playerName(offer.fromPlayerId)} menawarkan perdagangan kepada ${_playerName(offer.toPlayerId)} 🤝');
    return true;
  }

  /// Accept the pending trade.
  bool acceptTrade() {
    final offer = pendingTrade;
    if (offer == null) return false;

    var players = List<Player>.from(gameState.players);
    final fromIdx = players.indexWhere((p) => p.id == offer.fromPlayerId);
    final toIdx   = players.indexWhere((p) => p.id == offer.toPlayerId);
    if (fromIdx == -1 || toIdx == -1) return false;

    // Transfer offered tiles from → to
    for (final idx in offer.offeredTiles) {
      final tile = board.getTile(idx);
      if (tile is Property) _updateTile(idx, tile.copyWith(owner: offer.toPlayerId));
      if (tile is Utility)  _updateTile(idx, tile.copyWith(owner: offer.toPlayerId));
    }
    // Transfer requested tiles to → from
    for (final idx in offer.requestedTiles) {
      final tile = board.getTile(idx);
      if (tile is Property) _updateTile(idx, tile.copyWith(owner: offer.fromPlayerId));
      if (tile is Utility)  _updateTile(idx, tile.copyWith(owner: offer.fromPlayerId));
    }
    // Transfer cash
    if (offer.cashOffer != 0) {
      players[fromIdx] = players[fromIdx].copyWith(money: players[fromIdx].money - offer.cashOffer);
      players[toIdx]   = players[toIdx].copyWith(money: players[toIdx].money + offer.cashOffer);
      gameState = gameState.copyWith(players: players);
    }

    pendingTrade = null;
    _setMessage('Perdagangan antara ${_playerName(offer.fromPlayerId)} dan ${_playerName(offer.toPlayerId)} selesai! ✅');
    return true;
  }

  void declineTrade() {
    final offer = pendingTrade;
    if (offer == null) return;
    pendingTrade = null;
    _setMessage('${_playerName(offer.toPlayerId)} menolak tawaran perdagangan ❌');
  }

  String _playerName(String id) =>
      gameState.players.firstWhere((p) => p.id == id, orElse: () => Player(id: id, name: id)).name;

  // ── Bankrupt ──────────────────────────────────────────────────────────────

  void _checkBankrupt(Player player) {
    if (player.money >= 0) return;

    final updatedPlayer = player.copyWith(status: PlayerStatus.bankrupt);
    _updatePlayers(updatedPlayer);
    _releaseAllProperties(player.id);
    _setMessage('${player.name} bangkrut! 💀');
    _checkGameEnd();
  }

  void _releaseAllProperties(String playerId) {
    for (int i = 0; i < board.tiles.length; i++) {
      final tile = board.tiles[i];
      if (tile is Property && tile.owner == playerId) {
        _updateTile(i, tile.copyWith(owner: null, houses: 0, isMortgaged: false));
      } else if (tile is Utility && tile.owner == playerId) {
        _updateTile(i, tile.copyWith(owner: null, isMortgaged: false));
      }
    }
  }

  void _checkGameEnd() {
    final active = gameState.players.where((p) => !p.isBankrupt).toList();
    if (active.length == 1) {
      gameState = gameState.copyWith(
        status: GameStatus.finished, winnerId: active.first.id,
      );
      _setMessage('${active.first.name} MENANG! 🥇');
    }
  }

  // ── Turn Management ───────────────────────────────────────────────────────

  void endTurn() {
    if (gameState.phase == TurnPhase.buying || gameState.phase == TurnPhase.auctioning) {
      return;
    }

    Player player = currentPlayer;
    // Doubles = extra turn (but not after jail release)
    final getExtraTurn =
        player.doublesCount > 0 && !player.isInJail && !player.isBankrupt;

    if (getExtraTurn) {
      _setMessage('${player.name} dapat giliran lagi karena double! 🎲🎲');
      gameState = gameState.copyWith(phase: TurnPhase.preRoll);
      return;
    }

    player = player.copyWith(doublesCount: 0);
    _updatePlayers(player);

    int nextIndex = gameState.currentPlayerIndex;
    int attempts  = 0;
    do {
      nextIndex = (nextIndex + 1) % gameState.players.length;
      attempts++;
    } while (gameState.players[nextIndex].isBankrupt &&
             attempts < gameState.players.length);

    if (attempts >= gameState.players.length) {
      _checkGameEnd();
      return;
    }

    gameState = gameState.copyWith(
      currentPlayerIndex: nextIndex,
      phase: TurnPhase.preRoll,
      lastRoll: null,
    );
    _setMessage('Giliran ${_getPlayer(nextIndex).name}');
  }

  // ── Utility helpers ───────────────────────────────────────────────────────

  void _updateTile(int index, Tile newTile) {
    final newTiles = List<Tile>.from(board.tiles)..[index] = newTile;
    board = Board(tiles: newTiles);
  }

  bool get canRollDice =>
      gameState.phase == TurnPhase.preRoll && !currentPlayer.isBankrupt;

  bool get canBuyProperty {
    if (gameState.phase != TurnPhase.buying) return false;
    final tile = board.getTile(currentPlayer.position);
    if (tile is Property) return !tile.isOwned && currentPlayer.money >= tile.price;
    if (tile is Utility)  return !tile.isOwned && currentPlayer.money >= tile.price;
    return false;
  }

  bool get canEndTurn =>
      gameState.phase == TurnPhase.postRoll ||
      gameState.phase == TurnPhase.ended    ||
      gameState.phase == TurnPhase.buying;

  bool get isInAuction => gameState.phase == TurnPhase.auctioning;

  bool get hasPendingTrade => pendingTrade != null;
}
