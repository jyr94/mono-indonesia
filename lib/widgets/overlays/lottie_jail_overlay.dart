import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class LottieJailOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const LottieJailOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<LottieJailOverlay> createState() => _LottieJailOverlayState();
}

class _LottieJailOverlayState extends State<LottieJailOverlay> with TickerProviderStateMixin {
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
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MASUK PENJARA!',
                style: GoogleFonts.baloo2(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD32F2F),
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
                width: 300,
                height: 300,
                child: Lottie.asset(
                  'assets/lottie/jail_slam.json',
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
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD32F2F),
                          width: 4,
                        ),
                      ),
                      child: const Center(child: Icon(Icons.lock, size: 80, color: Colors.grey)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                opacity: _showText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Text(
                      'Kamu dikirim langsung ke penjara!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'LANJUT',
                        style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold),
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
