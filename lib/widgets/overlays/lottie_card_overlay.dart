import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class LottieCardOverlay extends StatefulWidget {
  final String description;
  final bool isChance;
  final VoidCallback onComplete;

  const LottieCardOverlay({
    super.key,
    required this.description,
    required this.isChance,
    required this.onComplete,
  });

  @override
  State<LottieCardOverlay> createState() => _LottieCardOverlayState();
}

class _LottieCardOverlayState extends State<LottieCardOverlay> with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showText) {
          widget.onComplete();
        } else {
          // Skip animation
          _controller.value = 1.0;
          setState(() {
            _showText = true;
          });
        }
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isChance ? 'KESEMPATAN' : 'DANA UMUM',
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: widget.isChance ? const Color(0xFFF9A825) : const Color(0xFF1565C0),
                  shadows: [
                    const Shadow(
                      color: Colors.white,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 250,
                child: Lottie.asset(
                  'assets/lottie/card_flip.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward().whenComplete(() {
                        if (mounted) {
                          setState(() {
                            _showText = true;
                          });
                        }
                      });
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if dummy or real asset fails
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_showText) {
                        setState(() {
                          _showText = true;
                        });
                      }
                    });
                    return Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isChance ? const Color(0xFFF9A825) : const Color(0xFF1565C0),
                          width: 4,
                        ),
                      ),
                      child: const Center(child: Icon(Icons.style, size: 60, color: Colors.grey)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                opacity: _showText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isChance ? const Color(0xFFF9A825) : const Color(0xFF1565C0)).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: widget.onComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isChance ? const Color(0xFFF9A825) : const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'TUTUP',
                          style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }
}
