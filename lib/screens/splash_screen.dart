import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/player_identity.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _titleCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _bgOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.4)),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic));
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    final identityFuture = PlayerIdentity.getInstance();
    await _bgCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _logoCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _titleCtrl.forward();
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 2500)),
      identityFuture,
    ]);
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;
    if (onboardingDone) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _bgOpacity,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8B0000),
                Color(0xFFC62828),
                Color(0xFFD32F2F),
                Color(0xFF1B1B1B),
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -60,
                child: _buildGlowCircle(220, const Color(0xFFFFD700), 0.06),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _buildGlowCircle(280, const Color(0xFFFFD700), 0.04),
              ),
              ..._buildDiceParticles(),
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: _buildLogo(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: _buildTitle(),
                        ),
                      ),
                      const SizedBox(height: 60),
                      FadeTransition(
                        opacity: _titleOpacity,
                        child: _buildLoader(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFC62828)],
        ),
        border: Border.all(color: const Color(0xFFFFD700), width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFFC62828).withOpacity(0.6),
            blurRadius: 50,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (context, child) {
              return Transform.rotate(
                angle: _shimmerCtrl.value * 2 * pi,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.35, 0.5, 0.65],
                    ),
                  ),
                ),
              );
            },
          ),
          const Icon(Icons.casino_rounded, size: 70, color: Color(0xFFFFD700)),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'MONOPOLI',
          style: GoogleFonts.baloo2(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFFD700),
            letterSpacing: 6,
            shadows: const [
              Shadow(
                color: Color(0xFF8B0000),
                offset: Offset(2, 4),
                blurRadius: 8,
              ),
              Shadow(
                color: Color(0x88FFD700),
                offset: Offset(0, 0),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        Text(
          'INDONESIA',
          style: GoogleFonts.baloo2(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.85),
            letterSpacing: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 100,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Colors.white, Color(0xFFFFD700)],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Kuasai Nusantara, Raih Kemenangan!',
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: Colors.white.withOpacity(0.65),
            letterSpacing: 0.3,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: const Color(0xFFFFD700).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Memuat permainan...',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.white.withOpacity(0.45),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }

  List<Widget> _buildDiceParticles() {
    final positions = [
      <String, dynamic>{'left': 30.0, 'top': 100.0, 'value': 3, 'opacity': 0.15},
      <String, dynamic>{'right': 40.0, 'top': 180.0, 'value': 5, 'opacity': 0.12},
      <String, dynamic>{'left': 60.0, 'bottom': 200.0, 'value': 1, 'opacity': 0.10},
      <String, dynamic>{'right': 30.0, 'bottom': 250.0, 'value': 6, 'opacity': 0.13},
    ];

    return positions.map((pos) {
      return Positioned(
        left: pos['left'] as double?,
        right: pos['right'] as double?,
        top: pos['top'] as double?,
        bottom: pos['bottom'] as double?,
        child: Opacity(
          opacity: pos['opacity'] as double,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '${pos['value'] as int}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC62828),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
