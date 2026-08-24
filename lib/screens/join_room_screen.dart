import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/room_service.dart';

class JoinRoomScreen extends StatefulWidget {
  final String playerId;
  final String playerName;

  const JoinRoomScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _roomService = RoomService();
  bool _loading = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      _showMessage('Kode room harus 6 karakter');
      _shakeCtrl.forward(from: 0);
      return;
    }

    setState(() => _loading = true);
    try {
      final room = await _roomService.joinRoom(
        code,
        widget.playerId,
        widget.playerName,
      );
      if (room == null) {
        _showMessage('Room tidak ditemukan atau penuh');
        _shakeCtrl.forward(from: 0);
        return;
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/lobby', arguments: {
          'roomCode': room.code,
          'playerId': widget.playerId,
          'playerName': widget.playerName,
          'isHost': false,
        });
      }
    } catch (e) {
      _showMessage('Gagal bergabung: $e');
      _shakeCtrl.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFF1B1B1B),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _shakeCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1A0A),
              Color(0xFF0D0D0D),
              Color(0xFF1A0A0A),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1565C0).withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC62828).withOpacity(0.05),
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
                          onTap: () => Navigator.pop(context),
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
                        Text(
                          'GABUNG ROOM',
                          style: GoogleFonts.baloo2(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1565C0).withOpacity(0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.group_add_rounded,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 28),

                            Text(
                              'Masukkan Kode Room',
                              style: GoogleFonts.baloo2(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Minta kode dari teman yang membuat room',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.45),
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Code input
                            AnimatedBuilder(
                              animation: _shakeAnim,
                              builder: (context, child) {
                                final sineValue = _shakeCtrl.isAnimating
                                    ? (8 * (0.5 - (_shakeAnim.value - 0.5).abs()) * 2)
                                    : 0.0;
                                return Transform.translate(
                                  offset: Offset(sineValue, 0),
                                  child: child,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  color: Colors.white.withOpacity(0.06),
                                ),
                                child: TextField(
                                  controller: _codeController,
                                  textAlign: TextAlign.center,
                                  textCapitalization: TextCapitalization.characters,
                                  maxLength: 6,
                                  style: GoogleFonts.baloo2(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 10,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '------',
                                    hintStyle: GoogleFonts.baloo2(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white12,
                                      letterSpacing: 10,
                                    ),
                                    counterText: '',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 20,
                                    ),
                                  ),
                                  onSubmitted: (_) => _joinRoom(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Player info
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_rounded, size: 16, color: Colors.white54),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bergabung sebagai: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                  Text(
                                    widget.playerName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFFD700),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Join button
                            GestureDetector(
                              onTap: _loading ? null : _joinRoom,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: _loading
                                      ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
                                      : const LinearGradient(
                                          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: !_loading
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1565C0).withOpacity(0.45),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login_rounded, color: Colors.white, size: 22),
                                            SizedBox(width: 10),
                                            Text(
                                              'GABUNG SEKARANG',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
