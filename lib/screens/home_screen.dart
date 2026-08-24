import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/player.dart';
import '../services/player_identity.dart';
import '../services/room_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  PlayerIdentity? _identity;
  final _nameController = TextEditingController();
  bool _loading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final identity = await PlayerIdentity.getInstance();
    setState(() {
      _identity = identity;
      _nameController.text = identity.playerName;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _playLocal() async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'local_setup',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, _, __) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: LocalSetupDialog(
            onStart: (players) {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/game', arguments: {
                'localPlayers': players,
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _createRoom() async {
    if (_identity == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) { _showMessage('Masukkan nama terlebih dahulu'); return; }
    await _identity!.updateName(name);
    _showLoading('Membuat room...');
    try {
      final room = await RoomService().createRoom(_identity!.playerId, name);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/lobby', arguments: {
          'roomCode': room.code, 'playerId': _identity!.playerId, 'playerName': name, 'isHost': true,
        });
      }
    } catch (e) {
      if (mounted) { Navigator.pop(context); _showMessage('Gagal membuat room: $e'); }
    }
  }

  Future<void> _joinRoom() async {
    if (_identity == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) { _showMessage('Masukkan nama terlebih dahulu'); return; }
    await _identity!.updateName(name);
    if (!mounted) return;
    Navigator.pushNamed(context, '/join', arguments: {'playerId': _identity!.playerId, 'playerName': name});
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), duration: const Duration(seconds: 3),
      backgroundColor: AppColors.primaryDark, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showLoading(String msg) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(
      child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: AppColors.primary), const SizedBox(height: 16), Text(msg),
        ])),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B5E20),
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Premium tropical green background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1B5E20)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Procedural Kawung Batik Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BatikBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) => Transform.scale(scale: _pulseAnim.value, child: child),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                          ),
                          border: Border.all(color: AppColors.goldAccent, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldAccent.withOpacity(0.35),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: const Color(0xFFD32F2F).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Sweep Gradient shine animation
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _pulseController.value * 2 * pi,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.15),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.4, 0.5, 0.6],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Icon(Icons.casino, size: 56, color: Color(0xFFFFD54F)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'MONOPOLI',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD54F),
                        letterSpacing: 8,
                        fontFamily: 'Baloo2',
                        shadows: [
                          Shadow(color: Colors.black38, offset: Offset(2, 3), blurRadius: 5),
                          Shadow(color: AppColors.goldAccent, offset: Offset(0, 0), blurRadius: 10),
                        ],
                      ),
                    ),
                    Text(
                      'INDONESIA',
                      style: GoogleFonts.baloo2(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(color: AppColors.goldAccent.withOpacity(0.5), blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Game Monopoli Bertema Indonesia',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 14),
                    // Social proof bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.goldAccent.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎮', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '10K+ Pemain',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 1,
                            height: 12,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Text('⭐', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '4.8 Rating',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 1,
                            height: 12,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Text('🏆', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            'Free to Play',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Name input
                    SizedBox(
                      width: 300,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nama Pemain',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.goldAccent, width: 2),
                            ),
                            prefixIcon: const Icon(Icons.person, color: Color(0xFFC62828)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          maxLength: 20,
                          buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    _GameButton(
                      label: 'MAIN LOKAL',
                      subtitle: '2–4 pemain di satu HP',
                      icon: Icons.play_arrow_rounded,
                      gradient: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      onTap: _playLocal,
                    ),
                    const SizedBox(height: 12),
                    _GameButton(
                      label: 'BUAT ROOM',
                      subtitle: 'Main online multiplayer',
                      icon: Icons.add_circle_outline,
                      gradient: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      onTap: _createRoom,
                    ),
                    const SizedBox(height: 12),
                    _GameButton(
                      label: 'GABUNG ROOM',
                      subtitle: 'Masukkan kode room',
                      icon: Icons.group_add,
                      gradient: const [Color(0xFFE65100), Color(0xFFBF360C)],
                      onTap: _joinRoom,
                    ),
                    const SizedBox(height: 32),

                    // Dice decoration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _miniDie(5),
                        const SizedBox(width: 8),
                        _miniDie(3),
                        const SizedBox(width: 8),
                        _miniDie(6),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🇮🇩  Kuasai Nusantara, Raih Kejayaan!',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniDie(int value) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _GameButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GameButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<_GameButton> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animCtrl.forward(),
      onTapUp: (_) {
        _animCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: 300,
          height: 64,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.gradient),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.last.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocalSetupDialog extends StatefulWidget {
  final Function(List<Player>) onStart;

  const LocalSetupDialog({super.key, required this.onStart});

  @override
  State<LocalSetupDialog> createState() => _LocalSetupDialogState();
}

class _LocalSetupDialogState extends State<LocalSetupDialog> {
  int _playerCount = 2;
  final List<TextEditingController> _controllers = [
    TextEditingController(text: 'ANDA'),
    TextEditingController(text: 'MAYA'),
    TextEditingController(text: 'BUDI'),
    TextEditingController(text: 'SARI'),
  ];
  final List<String> _colors = ['blue', 'red', 'green', 'yellow', 'purple', 'teal'];

  final List<Map<String, dynamic>> _characters = [
    {'color': 'blue',   'name': 'KOMODO', 'icon': Icons.pets_rounded,            'colorVal': Color(0xFF1565C0)},
    {'color': 'red',    'name': 'BECAK',  'icon': Icons.pedal_bike_rounded,       'colorVal': Color(0xFFD32F2F)},
    {'color': 'green',  'name': 'GARUDA', 'icon': Icons.flutter_dash_rounded,     'colorVal': Color(0xFF2E7D32)},
    {'color': 'yellow', 'name': 'KAPAL',  'icon': Icons.sailing_rounded,          'colorVal': Color(0xFFF9A825)},
    {'color': 'purple', 'name': 'WAYANG', 'icon': Icons.theater_comedy_rounded,   'colorVal': Color(0xFF6A1B9A)},
    {'color': 'teal',   'name': 'KERIS',  'icon': Icons.architecture_rounded,     'colorVal': Color(0xFF00695C)},
  ];

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  Color _colorVal(String color) {
    return _characters.firstWhere((c) => c['color'] == color)['colorVal'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.goldAccent, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC62828), Color(0xFF8B0000)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  const Text(
                    'MAIN LOKAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atur pemain & pilih karakter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Player count selector
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JUMLAH PEMAIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.woodDark,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [2, 3, 4].map((count) {
                              final selected = _playerCount == count;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _playerCount = count),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selected ? AppColors.primary : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: selected
                                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 8)]
                                          : null,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$count',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: selected ? Colors.white : Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'Pemain',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: selected ? Colors.white70 : Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Player setups
                    ...List.generate(_playerCount, (i) {
                      return Column(
                        children: [
                          _buildPlayerSetup(
                            title: i == 0 ? 'PEMAIN 1 (HOST)' : 'PEMAIN ${i + 1}',
                            controller: _controllers[i],
                            selectedColor: _colors[i],
                            onColorSelected: (color) {
                              setState(() {
                                // Swap if conflict
                                for (int j = 0; j < _playerCount; j++) {
                                  if (j != i && _colors[j] == color) {
                                    _colors[j] = _colors[i];
                                  }
                                }
                                _colors[i] = color;
                              });
                            },
                            disabledColors: List.generate(_playerCount, (j) => _colors[j])
                                .where((_, ) => true)
                                .toList()
                                .asMap()
                                .entries
                                .where((e) => e.key != i)
                                .map((e) => _colors[e.key])
                                .toList(),
                          ),
                          if (i < _playerCount - 1) ...[
                            const SizedBox(height: 10),
                            const Divider(color: Colors.black12, height: 1),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    }),

                    const SizedBox(height: 20),

                    // Start button
                    GestureDetector(
                      onTap: () {
                        final players = List.generate(_playerCount, (i) => Player(
                          id: '${i + 1}',
                          name: _controllers[i].text.trim().isEmpty
                              ? ['ANDA', 'MAYA', 'BUDI', 'SARI'][i]
                              : _controllers[i].text.trim().toUpperCase(),
                          avatarColor: _colors[i],
                          isHost: i == 0,
                          status: PlayerStatus.playing,
                        ));
                        widget.onStart(players);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC62828), Color(0xFF8B0000)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC62828).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'MULAI PERMAINAN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSetup({
    required String title,
    required TextEditingController controller,
    required String selectedColor,
    required ValueChanged<String> onColorSelected,
    required List<String> disabledColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _colorVal(selectedColor),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.woodDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          textCapitalization: TextCapitalization.characters,
          maxLength: 12,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _colorVal(selectedColor), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _characters.map((char) {
            final color = char['color'] as String;
            final icon = char['icon'] as IconData;
            final name = char['name'] as String;
            final colorVal = char['colorVal'] as Color;
            final isSelected = selectedColor == color;
            final isDisabled = disabledColors.contains(color);

            return Expanded(
              child: GestureDetector(
                onTap: isDisabled ? null : () => onColorSelected(color),
                child: Opacity(
                  opacity: isDisabled ? 0.2 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? colorVal.withOpacity(0.12) : Colors.white,
                      border: Border.all(
                        color: isSelected ? colorVal : Colors.grey.shade300,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [BoxShadow(color: colorVal.withOpacity(0.3), blurRadius: 6)]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(icon, color: colorVal, size: 26),
                        const SizedBox(height: 3),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? colorVal : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}



class BatikBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw overlapping diamond grid (classic kawung or parang-like structures)
    final gridWidth = 60.0;
    final gridHeight = 60.0;

    for (double x = 0; x < size.width + gridWidth; x += gridWidth) {
      for (double y = 0; y < size.height + gridHeight; y += gridHeight) {
        canvas.drawCircle(Offset(x, y), 25, paint);
        canvas.drawCircle(Offset(x + gridWidth / 2, y + gridHeight / 2), 25, paint);

        final path = Path();
        path.moveTo(x - 20, y);
        path.quadraticBezierTo(x, y - 20, x + 20, y);
        path.quadraticBezierTo(x, y + 20, x - 20, y);
        canvas.drawPath(path, paint);

        final pathVertical = Path();
        pathVertical.moveTo(x, y - 20);
        pathVertical.quadraticBezierTo(x - 20, y, x, y + 20);
        pathVertical.quadraticBezierTo(x + 20, y, x, y - 20);
        canvas.drawPath(pathVertical, paint);

        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
