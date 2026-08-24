import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Shows two animated dice that spin and land on the final values.
/// Triggers [onRollComplete] once the animation finishes.
class DiceResultPanel extends StatefulWidget {
  final int? finalDie1;
  final int? finalDie2;
  final bool isRolling;
  final VoidCallback? onRollComplete;
  final bool enabled;

  const DiceResultPanel({
    super.key,
    this.finalDie1,
    this.finalDie2,
    this.isRolling = false,
    this.onRollComplete,
    this.enabled = true,
  });

  @override
  State<DiceResultPanel> createState() => _DiceResultPanelState();
}

class _DiceResultPanelState extends State<DiceResultPanel>
    with TickerProviderStateMixin {
  late AnimationController _throwCtrl;
  // Slight phase offset so the two dice don't spin identically
  late AnimationController _throwCtrl2;
  Timer? _flicker;
  int _die1 = 1;
  int _die2 = 1;
  bool _showResult = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _throwCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..addStatusListener((status) {
        if (status != AnimationStatus.completed || !mounted) return;
        setState(() {
          _die1 = widget.finalDie1 ?? 1;
          _die2 = widget.finalDie2 ?? 1;
          _showResult = true;
        });
        widget.onRollComplete?.call();
      });

    _throwCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    );
  }

  @override
  void didUpdateWidget(DiceResultPanel old) {
    super.didUpdateWidget(old);
    if (widget.isRolling && !old.isRolling) _startRoll();
  }

  void _startRoll() {
    _flicker?.cancel();
    setState(() => _showResult = false);
    _throwCtrl.forward(from: 0);
    _throwCtrl2.forward(from: 0);
    _flicker = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted || !_throwCtrl.isAnimating) {
        timer.cancel();
        return;
      }
      setState(() {
        _die1 = _rng.nextInt(6) + 1;
        _die2 = _rng.nextInt(6) + 1;
      });
    });
  }

  @override
  void dispose() {
    _throwCtrl.dispose();
    _throwCtrl2.dispose();
    _flicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDoubles = _showResult && _die1 == _die2;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.62),
            Colors.black.withValues(alpha: 0.74),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDoubles
              ? const Color(0xFFFFD54F).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.22),
          width: isDoubles ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _animatedDie(_throwCtrl, _die1, phaseOffset: 0.0),
          const SizedBox(width: 10),
          // "+" separator
          Text(
            '+',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 10),
          _animatedDie(_throwCtrl2, _die2, phaseOffset: 0.15),
          const SizedBox(width: 12),
          // Result panel
          SizedBox(
            width: 52,
            child: AnimatedOpacity(
              opacity: _showResult ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_die1 + _die2}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  if (isDoubles)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'DOUBLE!',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedDie(AnimationController ctrl, int value,
      {double phaseOffset = 0.0}) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = (ctrl.value + phaseOffset).clamp(0.0, 1.0);
        final flight = sin(pi * min(t / 0.72, 1));
        final landing = t < 0.72
            ? 0.0
            : sin((t - 0.72) / 0.28 * pi * 3) * (1 - t) * 20;
        final lift = -(flight * 55) - landing.abs();
        final drift = sin(t * pi * 3.5 + phaseOffset * 10) * (1 - t) * 14;
        final squash = t > 0.72
            ? 1 - (sin((t - 0.72) / 0.28 * pi).abs() * 0.12)
            : 1.0;

        return Transform.translate(
          offset: Offset(drift, lift),
          child: Transform.rotate(
            angle: t * pi * (5.5 + phaseOffset * 2),
            child: Transform.scale(
              scaleX: 2 - squash,
              scaleY: squash,
              child: _build2DDie(value),
            ),
          ),
        );
      },
    );
  }

  Widget _build2DDie(int value) {
    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE1E1E1)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _showResult ? const Color(0xFFFFD54F) : const Color(0xFF616161),
          width: _showResult ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(3, 4),
          ),
        ],
      ),
      child: _dots(value),
    );
  }

  Widget _dots(int value) {
    Widget dot() => Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
              color: Color(0xFF212121), shape: BoxShape.circle),
        );

    Widget row(bool l, bool c, bool r) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            l ? dot() : const SizedBox(width: 10),
            c ? dot() : const SizedBox(width: 10),
            r ? dot() : const SizedBox(width: 10),
          ],
        );

    return switch (value) {
      1 => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [row(false, true, false)]),
      2 => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [row(false, false, true), row(true, false, false)]),
      3 => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            row(false, false, true),
            row(false, true, false),
            row(true, false, false)
          ]),
      4 => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [row(true, false, true), row(true, false, true)]),
      5 => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            row(true, false, true),
            row(false, true, false),
            row(true, false, true)
          ]),
      6 => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            row(true, false, true),
            row(true, false, true),
            row(true, false, true)
          ]),
      _ => const SizedBox(),
    };
  }
}
