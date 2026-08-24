import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/room_model.dart';
import '../models/player.dart';
import '../services/room_service.dart';
import '../services/game_sync_service.dart';

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  final String playerId;
  final String playerName;
  final bool isHost;

  const LobbyScreen({
    super.key,
    required this.roomCode,
    required this.playerId,
    required this.playerName,
    required this.isHost,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with TickerProviderStateMixin {
  final _roomService = RoomService();
  StreamSubscription? _roomSub;
  RoomModel? _room;
  bool _starting = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _codeCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _codeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _listenToRoom();
  }

  void _listenToRoom() {
    _roomSub = _roomService.roomStream(widget.roomCode).listen((room) {
      if (mounted) {
        setState(() => _room = room);
        if (room != null && room.isInProgress) {
          _navigateToGame();
        }
        if (room == null) {
          _showMessage('Room telah dihapus');
          Navigator.pop(context);
        }
      }
    });
  }

  void _navigateToGame() {
    if (_room == null) return;
    final players = _room!.players.values
        .map((rp) => Player(
              id: rp.id,
              name: rp.name,
              isHost: rp.isHost,
              status: PlayerStatus.playing,
              avatarColor: _playerColor(rp.id),
            ))
        .toList();

    final syncService = GameSyncService(
      roomCode: widget.roomCode,
      playerId: widget.playerId,
      isHost: widget.isHost,
    );
    syncService.initGame(players);
    syncService.startHostSync();

    Navigator.pushReplacementNamed(
      context,
      '/game',
      arguments: {'syncService': syncService},
    );
  }

  String _playerColor(String id) {
    const colors = ['red', 'blue', 'green', 'yellow'];
    return colors[id.hashCode.abs() % colors.length];
  }

  Future<void> _startGame() async {
    if (!widget.isHost) return;
    if (_room == null || _room!.playerCount < 2) {
      _showMessage('Minimal 2 pemain untuk memulai');
      return;
    }
    setState(() => _starting = true);
    try {
      await _roomService.startGame(widget.roomCode, widget.playerId);
    } catch (e) {
      _showMessage('Gagal memulai game: $e');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _leaveRoom() async {
    await _roomService.leaveRoom(widget.roomCode, widget.playerId);
    if (mounted) Navigator.pop(context);
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    _showMessage('Kode room disalin! 📋');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1B1B1B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _pulseCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Color _avatarColor(String colorName) {
    switch (colorName) {
      case 'red': return const Color(0xFFD32F2F);
      case 'blue': return const Color(0xFF1565C0);
      case 'green': return const Color(0xFF2E7D32);
      case 'yellow': return const Color(0xFFF9A825);
      default: return Colors.grey;
    }
  }

  IconData _avatarIcon(String colorName) {
    switch (colorName) {
      case 'red': return Icons.pedal_bike_rounded;
      case 'blue': return Icons.pets_rounded;
      case 'green': return Icons.flutter_dash_rounded;
      case 'yellow': return Icons.sailing_rounded;
      default: return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = _room?.players.values.toList() ?? [];
    final playerCount = players.length;
    final canStart = widget.isHost && playerCount >= 2 && !_starting;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveRoom();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A0A0A),
                Color(0xFF0D0D0D),
                Color(0xFF0A1A0A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative glow circles
              Positioned(
                top: -60,
                left: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFC62828).withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD700).withOpacity(0.05),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _leaveRoom,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'RUANG TUNGGU',
                              style: GoogleFonts.baloo2(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: playerCount >= 2
                                  ? const Color(0xFF2E7D32).withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: playerCount >= 2
                                    ? const Color(0xFF4CAF50).withOpacity(0.4)
                                    : Colors.orange.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$playerCount/4',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: playerCount >= 2 ? const Color(0xFF4CAF50) : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Room code card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: child,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8B0000), Color(0xFFC62828)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC62828).withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.vpn_key_rounded, color: Color(0xFFFFD700), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'KODE ROOM',
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white60,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    widget.isHost ? '👑 Host' : '🎮 Pemain',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.roomCode,
                                style: GoogleFonts.baloo2(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 10,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFFFFD700),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _copyCode,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.copy_rounded, size: 15, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Salin & Bagikan',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Players section header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'PEMAIN',
                            style: GoogleFonts.baloo2(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white60,
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          if (playerCount < 2)
                            Text(
                              'Butuh minimal 2 pemain',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Player list
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            if (index < players.length) {
                              final player = players[index];
                              final isMe = player.id == widget.playerId;
                              final color = _playerColor(player.id);
                              final avatarColor = _avatarColor(color);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isMe
                                        ? const Color(0xFFFFD700).withOpacity(0.4)
                                        : Colors.white.withOpacity(0.08),
                                    width: isMe ? 1.5 : 1,
                                  ),
                                  boxShadow: isMe
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withOpacity(0.08),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            avatarColor,
                                            avatarColor.withOpacity(0.7),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: avatarColor.withOpacity(0.4),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _avatarIcon(color),
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                player.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              if (isMe) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFD700).withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: const Color(0xFFFFD700).withOpacity(0.4),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Kamu',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w900,
                                                      color: Color(0xFFFFD700),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            player.isHost ? '👑 Host Room' : '🎮 Siap Bermain',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white.withOpacity(0.45),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: player.connected
                                            ? const Color(0xFF4CAF50)
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                        boxShadow: player.connected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                                                  blurRadius: 6,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Empty slot
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person_add_rounded,
                                      color: Colors.white.withOpacity(0.2),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Menunggu pemain...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.2),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Bottom action area
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        MediaQuery.of(context).padding.bottom + 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      child: widget.isHost
                          ? GestureDetector(
                              onTap: canStart ? _startGame : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: canStart
                                      ? const LinearGradient(
                                          colors: [Color(0xFFC62828), Color(0xFF8B0000)],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade800,
                                            Colors.grey.shade900,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: canStart
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFC62828).withOpacity(0.45),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: _starting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.play_arrow_rounded,
                                              color: canStart ? Colors.white : Colors.white30,
                                              size: 26,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              playerCount >= 2 ? 'MULAI PERMAINAN' : 'Menunggu Pemain...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: canStart ? Colors.white : Colors.white30,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            )
                          : Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFFD700).withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: const Color(0xFFFFD700).withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Menunggu host memulai...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
