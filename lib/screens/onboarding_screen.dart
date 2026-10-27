import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/player_identity.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  // Controllers
  late AnimationController _bgAnim;
  late AnimationController _floatAnim;
  late AnimationController _particleAnim;
  late AnimationController _pageEnterAnim;
  late AnimationController _pulseAnim;

  // Animations
  late Animation<double> _floatY;
  late Animation<double> _pageEnterScale;
  late Animation<double> _pageEnterOpacity;
  late Animation<double> _pulseScale;

  // Name input
  final TextEditingController _nameCtrl = TextEditingController();
  bool _nameError = false;
  bool _isLoading = false;

  static const _gold = Color(0xFFFFD700);
  static const _red = Color(0xFFC62828);
  static const _darkRed = Color(0xFF8B0000);

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Selamat Datang di',
      titleHighlight: 'Monopoli Indonesia!',
      subtitle: 'Kuasai Nusantara, raih kemenangan!\nPerjalanan bisnis terbesar dimulai dari sini.',
      icon: Icons.casino_rounded,
      gradient: [Color(0xFF8B0000), Color(0xFFC62828), Color(0xFFE53935), Color(0xFF1B1B1B)],
      accentColor: Color(0xFFFFD700),
      features: [],
      illustration: _IllustrationWelcome(),
    ),
    _OnboardingPage(
      title: 'Kuasai',
      titleHighlight: 'Landmark Indonesia',
      subtitle: 'Beli properti ikonik dari Sabang sampai Merauke. Bangun rumah & hotel untuk menguasai Nusantara!',
      icon: Icons.location_city_rounded,
      gradient: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB), Color(0xFF0D0D1A)],
      accentColor: Color(0xFFFFD54F),
      features: [
        _Feature(Icons.home_rounded, 'Beli Properti', 'Monas, Borobudur, Raja Ampat'),
        _Feature(Icons.apartment_rounded, 'Bangun Rumah & Hotel', 'Tingkatkan pendapatanmu'),
        _Feature(Icons.gavel_rounded, 'Sistem Lelang', 'Rebut properti via lelang sengit'),
      ],
      illustration: _IllustrationProperties(),
    ),
    _OnboardingPage(
      title: 'Multiplayer',
      titleHighlight: 'Real-Time Online',
      subtitle: 'Tantang teman-temanmu 2–4 pemain lewat Room Code. Main kapan saja, di mana saja!',
      icon: Icons.people_rounded,
      gradient: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF00897B), Color(0xFF0A1A18)],
      accentColor: Color(0xFF80CBC4),
      features: [
        _Feature(Icons.vpn_key_rounded, 'Room Code', 'Buat atau gabung room dengan kode'),
        _Feature(Icons.bolt_rounded, 'Turn Timer', '60 detik per giliran — cepat!'),
        _Feature(Icons.sync_rounded, 'Sinkron Real-Time', 'Semua aksi tersinkron instan'),
      ],
      illustration: _IllustrationMultiplayer(),
    ),
    _OnboardingPage(
      title: 'Chat, Trade',
      titleHighlight: '& Strategi Licik!',
      subtitle: 'Negosiasi properti, kirim pesan, dan buat kesepakatan diam-diam. Diplomasi adalah senjatamu!',
      icon: Icons.chat_bubble_rounded,
      gradient: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2), Color(0xFF120D1A)],
      accentColor: Color(0xFFCE93D8),
      features: [
        _Feature(Icons.swap_horiz_rounded, 'Trade Properti', 'Negosiasi langsung dengan pemain'),
        _Feature(Icons.chat_rounded, 'Chat & Emote', 'Preset chat + emoji ekspresif'),
        _Feature(Icons.credit_card_rounded, 'Hipotek', 'Gadai aset saat terdesak'),
      ],
      illustration: _IllustrationSocial(),
    ),
    _OnboardingPage(
      title: 'Siap untuk',
      titleHighlight: 'Bertarung?',
      subtitle: '',
      icon: Icons.sports_esports_rounded,
      gradient: [Color(0xFF8B0000), Color(0xFFC62828), Color(0xFFE53935), Color(0xFF1B1B1B)],
      accentColor: Color(0xFFFFD700),
      features: [],
      illustration: _IllustrationStart(),
      isLastPage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _floatAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pageEnterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatAnim, curve: Curves.easeInOut),
    );

    _pageEnterScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pageEnterAnim, curve: Curves.easeOutBack),
    );

    _pageEnterOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageEnterAnim, curve: Curves.easeIn),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut),
    );

    _pageEnterAnim.forward();
    _initDefaultName();
  }

  Future<void> _initDefaultName() async {
    try {
      final identity = await PlayerIdentity.getInstance();
      if (mounted && _nameCtrl.text.isEmpty) {
        setState(() {
          _nameCtrl.text = identity.playerName;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _floatAnim.dispose();
    _particleAnim.dispose();
    _pageEnterAnim.dispose();
    _pulseAnim.dispose();
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _pageEnterAnim.reset();
    _pageEnterAnim.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _skipAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() {
      _isLoading = true;
      _nameError = false;
    });

    try {
      final identity = await PlayerIdentity.getInstance();
      String name = _nameCtrl.text.trim();
      if (name.isEmpty || name.length < 2) {
        name = identity.playerName;
      }
      await identity.updateName(name);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: page.gradient,
            stops: const [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            _ParticleBackground(
              controller: _particleAnim,
              accentColor: page.accentColor,
            ),

            // Glow orbs
            _GlowOrb(color: page.accentColor, top: -80, right: -60, size: 220),
            _GlowOrb(color: page.accentColor, bottom: -100, left: -80, size: 280),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button (hide on last page)
                  if (!page.isLastPage)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                        child: TextButton(
                          onPressed: _skipAll,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.7),
                          ),
                          child: Text(
                            'Lewati',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 8),

                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildPageContent(_pages[index]);
                      },
                    ),
                  ),

                  // Bottom nav
                  _buildBottomNav(page),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(_OnboardingPage page) {
    return FadeTransition(
      opacity: _pageEnterOpacity,
      child: ScaleTransition(
        scale: _pageEnterScale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Illustration area
              Expanded(
                flex: 5,
                child: AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatY.value),
                      child: child,
                    );
                  },
                  child: page.illustration,
                ),
              ),

              // Text content
              Expanded(
                flex: page.isLastPage ? 4 : 5,
                child: page.isLastPage
                    ? _buildLastPageContent()
                    : _buildRegularPageContent(page),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularPageContent(_OnboardingPage page) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        // Title
        Text(
          page.title,
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [page.accentColor, Colors.white, page.accentColor],
          ).createShader(bounds),
          child: Text(
            page.titleHighlight,
            style: GoogleFonts.baloo2(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        if (page.subtitle.isNotEmpty)
          Text(
            page.subtitle,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withOpacity(0.75),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        if (page.features.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...page.features.map((f) => _FeatureRow(feature: f, accentColor: page.accentColor)),
        ],
      ],
      ),
    );
  }

  Widget _buildLastPageContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [_gold, Colors.white, _gold],
            ).createShader(bounds),
            child: Text(
              'Siap untuk\nBertarung?',
              style: GoogleFonts.baloo2(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan nama jagoanmu!',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          // Name input field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TextField(
              controller: _nameCtrl,
              maxLength: 16,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Nama Pemain',
                hintStyle: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 16,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white.withOpacity(0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _nameError ? Colors.red.shade300 : _gold.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _nameError ? Colors.red.shade300 : _gold.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _gold, width: 2.5),
                ),
                prefixIcon: const Icon(Icons.person_rounded, color: _gold),
                errorText: _nameError ? 'Nama harus minimal 2 karakter' : null,
                errorStyle: GoogleFonts.nunito(color: Colors.orange.shade300, fontSize: 11),
              ),
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
              onSubmitted: (_) => _finishOnboarding(),
            ),
          ),
          const SizedBox(height: 16),
          // Start button
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseScale.value,
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _finishOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: _darkRed,
                  elevation: 12,
                  shadowColor: _gold.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(_darkRed),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sports_esports_rounded, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'MULAI BERMAIN!',
                            style: GoogleFonts.baloo2(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
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

  Widget _buildBottomNav(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dot indicators
          Row(
            children: List.generate(_pages.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? page.accentColor
                      : Colors.white.withOpacity(0.3),
                  boxShadow: isActive
                      ? [BoxShadow(color: page.accentColor.withOpacity(0.5), blurRadius: 6)]
                      : null,
                ),
              );
            }),
          ),

          // Next / Done button
          if (!page.isLastPage)
            _NextButton(
              onTap: _nextPage,
              accentColor: page.accentColor,
            ),
        ],
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class _OnboardingPage {
  final String title;
  final String titleHighlight;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accentColor;
  final List<_Feature> features;
  final Widget illustration;
  final bool isLastPage;

  const _OnboardingPage({
    required this.title,
    required this.titleHighlight,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.features,
    required this.illustration,
    this.isLastPage = false,
  });
}

class _Feature {
  final IconData icon;
  final String label;
  final String desc;
  const _Feature(this.icon, this.label, this.desc);
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double? top, bottom, left, right;
  final double size;

  const _GlowOrb({
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.07),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color accentColor;

  const _NextButton({required this.onTap, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor,
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.45),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.arrow_forward_rounded, color: Colors.black87, size: 26),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  final Color accentColor;

  const _FeatureRow({required this.feature, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.15),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(feature.icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.label,
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                Text(
                  feature.desc,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Particle Background ──────────────────────────────────────────────────────

class _ParticleBackground extends StatelessWidget {
  final AnimationController controller;
  final Color accentColor;

  const _ParticleBackground({required this.controller, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(controller.value, accentColor),
          child: Container(),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  static final _rnd = Random(42);
  static final _particles = List.generate(18, (i) => [
    _rnd.nextDouble(), // x ratio
    _rnd.nextDouble(), // y ratio
    _rnd.nextDouble() * 0.5 + 0.3, // speed multiplier
    _rnd.nextDouble() * 6 + 3, // size
    _rnd.nextDouble() * 0.12 + 0.04, // opacity
  ]);

  _ParticlePainter(this.progress, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in _particles) {
      final xRatio = p[0];
      final baseY = p[1];
      final speed = p[2];
      final r = p[3];
      final opacity = p[4];

      final dy = ((baseY - progress * speed) % 1.0 + 1.0) % 1.0;

      final paint = Paint()
        ..color = accentColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(xRatio * size.width, dy * size.height),
        r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

// ─── Illustrations ────────────────────────────────────────────────────────────

class _IllustrationWelcome extends StatefulWidget {
  const _IllustrationWelcome();
  @override
  State<_IllustrationWelcome> createState() => _IllustrationWelcomeState();
}

class _IllustrationWelcomeState extends State<_IllustrationWelcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _rotate = Tween<double>(begin: 0, end: 2 * pi).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            AnimatedBuilder(
              animation: _rotate,
              builder: (_, __) => Transform.rotate(
                angle: _rotate.value * 0.3,
                child: _buildRing(240, const Color(0xFFFFD700).withOpacity(0.12)),
              ),
            ),
            AnimatedBuilder(
              animation: _rotate,
              builder: (_, __) => Transform.rotate(
                angle: -_rotate.value * 0.2,
                child: _buildRing(200, const Color(0xFFFFD700).withOpacity(0.08)),
              ),
            ),
            // Main circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFC62828)],
                ),
                border: Border.all(color: const Color(0xFFFFD700), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _rotate,
                    builder: (_, __) => Transform.rotate(
                      angle: _rotate.value,
                      child: Container(
                        width: 148,
                        height: 148,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.25),
                              Colors.transparent,
                            ],
                            stops: const [0.35, 0.5, 0.65],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.casino_rounded, size: 80, color: Color(0xFFFFD700)),
                ],
              ),
            ),
            // Corner dice decorations
            ..._buildCornerDice(),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }

  List<Widget> _buildCornerDice() {
    final positions = [
      const Offset(-110, -80),
      const Offset(90, -90),
      const Offset(-100, 80),
      const Offset(100, 70),
    ];
    final values = [3, 5, 1, 6];
    return List.generate(4, (i) {
      return Positioned(
        left: 130 + positions[i].dx,
        top: 130 + positions[i].dy,
        child: _DiceMini(value: values[i]),
      );
    });
  }
}

class _IllustrationProperties extends StatefulWidget {
  const _IllustrationProperties();
  @override
  State<_IllustrationProperties> createState() => _IllustrationPropertiesState();
}

class _IllustrationPropertiesState extends State<_IllustrationProperties>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _shine = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Landmark cards row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LandmarkCard(
                name: 'Monas',
                emoji: '🏛️',
                color: const Color(0xFFFFD54F),
                price: '1.200.000',
                level: 3,
              ),
              const SizedBox(width: 12),
              _LandmarkCard(
                name: 'Borobudur',
                emoji: '⛩️',
                color: const Color(0xFF80CBC4),
                price: '2.000.000',
                level: 2,
              ),
              const SizedBox(width: 12),
              _LandmarkCard(
                name: 'Raja Ampat',
                emoji: '🌊',
                color: const Color(0xFF90CAF9),
                price: '3.500.000',
                level: 1,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Money visual
          AnimatedBuilder(
            animation: _shine,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD54F).withOpacity(0.15),
                      const Color(0xFFFFD54F).withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFD54F).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_money_rounded, color: Color(0xFFFFD54F), size: 28),
                    Text(
                      'IDR 1.500.000',
                      style: GoogleFonts.baloo2(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IllustrationMultiplayer extends StatefulWidget {
  const _IllustrationMultiplayer();
  @override
  State<_IllustrationMultiplayer> createState() => _IllustrationMultiplayerState();
}

class _IllustrationMultiplayerState extends State<_IllustrationMultiplayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = [
      {'name': 'Andi', 'color': const Color(0xFFEF5350), 'icon': Icons.person_rounded},
      {'name': 'Budi', 'color': const Color(0xFF42A5F5), 'icon': Icons.person_2_rounded},
      {'name': 'Cici', 'color': const Color(0xFF66BB6A), 'icon': Icons.person_3_rounded},
      {'name': 'Dodi', 'color': const Color(0xFFFFCA28), 'icon': Icons.person_4_rounded},
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Room code display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0x2580CBC4), Color(0x1580CBC4)],
              ),
              border: Border.all(color: const Color(0xFF80CBC4).withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF80CBC4).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'ROOM CODE',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFF80CBC4),
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ABC-123',
                  style: GoogleFonts.baloo2(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Players row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: players.map((p) {
              final idx = players.indexOf(p);
              return AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  final delay = idx * 0.25;
                  final t = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
                  return Transform.translate(
                    offset: Offset(0, -Curves.easeInOut.transform(t) * 8),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (p['color'] as Color).withOpacity(0.2),
                          border: Border.all(color: p['color'] as Color, width: 2.5),
                        ),
                        child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p['name'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _IllustrationSocial extends StatefulWidget {
  const _IllustrationSocial();
  @override
  State<_IllustrationSocial> createState() => _IllustrationSocialState();
}

class _IllustrationSocialState extends State<_IllustrationSocial>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _chatIdx = 0;

  final _chats = [
    {'msg': '🎲 Saya mau beli Monas!', 'align': CrossAxisAlignment.start, 'color': Color(0xFFCE93D8)},
    {'msg': '💰 Trade? Saya kasih Raja Ampat', 'align': CrossAxisAlignment.end, 'color': Color(0xFF80CBC4)},
    {'msg': '😤 Tidak! Lelang sekarang!', 'align': CrossAxisAlignment.start, 'color': Color(0xFFCE93D8)},
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _chatIdx = (_chatIdx + 1) % _chats.length);
          _ctrl.reset();
          _ctrl.forward();
        }
      });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Trade icon visual
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0x407B1FA2), Color(0x204A148C)],
              ),
              border: Border.all(color: const Color(0xFFCE93D8).withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCE93D8).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.swap_horiz_rounded, size: 60, color: Color(0xFFCE93D8)),
          ),
          const SizedBox(height: 20),
          // Animated chat bubbles
          SizedBox(
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_chats.length, (i) {
                final chat = _chats[i];
                final isVisible = i <= _chatIdx;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isVisible ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 400),
                    offset: isVisible ? Offset.zero : const Offset(0, 0.3),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: (chat['align'] as CrossAxisAlignment) == CrossAxisAlignment.end
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: (chat['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (chat['color'] as Color).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              chat['msg'] as String,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ));
  }
}

class _IllustrationStart extends StatefulWidget {
  const _IllustrationStart();
  @override
  State<_IllustrationStart> createState() => _IllustrationStartState();
}

class _IllustrationStartState extends State<_IllustrationStart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _rotate = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Transform.scale(
            scale: _scale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _rotate.value * 0.2,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -_rotate.value * 0.15,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFF8A65), Color(0xFFC62828)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_esports_rounded,
                    size: 60,
                    color: Color(0xFFFFD700),
                  ),
                ),
                // Star particles
                ..._buildStars(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStars() {
    final positions = [
      const Offset(-95, -20),
      const Offset(90, -30),
      const Offset(-80, 70),
      const Offset(85, 60),
      const Offset(0, -100),
    ];
    return positions.map((pos) {
      return Positioned(
        left: 100 + pos.dx,
        top: 100 + pos.dy,
        child: AnimatedBuilder(
          animation: _rotate,
          builder: (_, __) {
            final t = (_rotate.value / (2 * pi) + pos.dx / 400) % 1.0;
            return Opacity(
              opacity: 0.4 + 0.6 * sin(t * 2 * pi).abs(),
              child: const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
            );
          },
        ),
      );
    }).toList();
  }
}

// ─── Supporting mini widgets ──────────────────────────────────────────────────

class _DiceMini extends StatelessWidget {
  final int value;
  const _DiceMini({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFC62828),
          ),
        ),
      ),
    );
  }
}

class _LandmarkCard extends StatelessWidget {
  final String name;
  final String emoji;
  final Color color;
  final String price;
  final int level;

  const _LandmarkCard({
    required this.name,
    required this.emoji,
    required this.color,
    required this.price,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Color bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.baloo2(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // House indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < level ? color : color.withOpacity(0.2),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: GoogleFonts.nunito(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
