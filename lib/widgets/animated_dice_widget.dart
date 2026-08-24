import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AnimatedDiceWidget extends StatefulWidget {
  final int? finalDie1;
  final int? finalDie2;
  final bool isRolling;
  final VoidCallback? onRollComplete;

  const AnimatedDiceWidget({
    super.key,
    this.finalDie1,
    this.finalDie2,
    this.isRolling = false,
    this.onRollComplete,
  });

  @override
  State<AnimatedDiceWidget> createState() => _AnimatedDiceWidgetState();
}

class _AnimatedDiceWidgetState extends State<AnimatedDiceWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  Timer? _flickerTimer;
  int _displayDie1 = 1;
  int _displayDie2 = 1;
  bool _showResult = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 50));
    _shakeAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _bounceAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedDiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) _startRolling();
  }

  void _startRolling() {
    setState(() => _showResult = false);
    _shakeController.repeat(reverse: true);
    int ticks = 0;
    _flickerTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      ticks++;
      setState(() {
        _displayDie1 = _rng.nextInt(6) + 1;
        _displayDie2 = _rng.nextInt(6) + 1;
      });
      if (ticks >= 18) {
        timer.cancel();
        _shakeController.stop();
        _bounceController.forward(from: 0);
        setState(() {
          _displayDie1 = widget.finalDie1 ?? 1;
          _displayDie2 = widget.finalDie2 ?? 1;
          _showResult = true;
        });
        widget.onRollComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    _flickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnim, _bounceAnim]),
      builder: (context, child) {
        final shake = _showResult ? 0.0 : _shakeAnim.value;
        final scale = _showResult ? _bounceAnim.value : 1.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDieFace(_displayDie1),
          const SizedBox(width: 20),
          _buildDieFace(_displayDie2),
          if (_showResult && widget.finalDie1 != null && widget.finalDie2 != null) ...[
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '= ${widget.finalDie1! + widget.finalDie2!}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
                ),
                if (widget.finalDie1 == widget.finalDie2)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DOUBLE!',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDieFace(int value) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: _showResult
              ? [Colors.white, const Color(0xFFF5F5F5)]
              : [Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showResult ? const Color(0xFF424242) : Colors.grey.shade400,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _showResult ? 0.3 : 0.15),
            blurRadius: _showResult ? 8 : 3,
            offset: const Offset(2, 3),
          ),
          if (_showResult)
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: -2,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: _buildDots(value),
      ),
    );
  }

  Widget _buildDots(int value) {
    const dotSize = 8.0;
    const dotColor = Color(0xFF212121);

    Widget dot() => Container(
      width: dotSize, height: dotSize,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 1, offset: const Offset(0, 1))],
      ),
    );

    Widget empty() => const SizedBox(width: dotSize, height: dotSize);

    // Standard dice dot layouts
    switch (value) {
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [dot()])],
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [dot()]),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [dot()]),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dot(), dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dot(), dot()]),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dot(), dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dot(), dot()]),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dot(), dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dot(), dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dot(), dot()]),
          ],
        );
      default:
        return empty();
    }
  }
}
