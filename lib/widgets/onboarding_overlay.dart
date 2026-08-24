import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingOverlay({super.key, required this.onComplete});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _currentStep = 0;

  static const _steps = [
    OnboardingStep(
      title: 'Lempar Dadu',
      description:
          'Tekan tombol "Lempar Dadu" untuk memulai giliran. Angka dadu menentukan langkahmu di papan!',
      icon: Icons.casino,
    ),
    OnboardingStep(
      title: 'Beli Properti',
      description:
          'Saat mendarat di properti yang belum dimiliki, kamu bisa membelinya. Kumpulkan properti untuk mendapatkan sewa!',
      icon: Icons.shopping_cart,
    ),
    OnboardingStep(
      title: 'Bangun Rumah',
      description:
          'Jika kamu memiliki semua properti dalam satu warna, kamu bisa membangun rumah untuk meningkatkan sewa!',
      icon: Icons.home,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Material(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    return Container(
                      width: i == _currentStep ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _currentStep
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.icon, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  step.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onComplete,
                      child: const Text('Lewati'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentStep < _steps.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          widget.onComplete();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        _currentStep < _steps.length - 1
                            ? 'Lanjut'
                            : 'Mulai!',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showOnboardingIfNeeded(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('onboarding_shown') ?? false;
    if (shown || !context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OnboardingOverlay(
        onComplete: () async {
          await prefs.setBool('onboarding_shown', true);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  } catch (_) {}
}
