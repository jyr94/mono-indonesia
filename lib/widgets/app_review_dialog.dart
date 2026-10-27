import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/analytics_service.dart';
import '../services/app_review_service.dart';

/// The two-step satisfaction prompt dialog:
/// Asks "Suka dengan game ini?".
/// - If YES: Prompts Google Play In-App Review.
/// - If NO: Directs to Internal Feedback Dialog so ratings are protected.
class AppReviewDialog extends StatelessWidget {
  final String source;

  const AppReviewDialog({
    super.key,
    this.source = 'game_over',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF1E222A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.goldAccent.withValues(alpha: 0.12),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Icon with Glow
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.45),
                      blurRadius: 22,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Suka dengan Game Ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Baloo2',
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Apakah kamu menikmati bermain Monopoli Indonesia? Pendapatmu sangat berarti untuk kemajuan game ini!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Positive Option: "Ya, Suka Banget!" -> Google Play In-App Review
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await AnalyticsService().logReviewResponse(
                        liked: true,
                        source: source,
                      );
                      // Trigger Google Play In-App Review
                      await AppReviewService.instance.triggerGooglePlayReview();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.star_rounded, color: AppColors.goldAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Terima kasih banyak atas dukunganmu! 🇮🇩✨'),
                                ),
                              ],
                            ),
                            backgroundColor: Color(0xFF1B5E20),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Ya, Suka Banget! ⭐',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Negative / Constructive Option: "Ada Masukan / Kurang Suka" -> Form Feedback Internal
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C323D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await AnalyticsService().logReviewResponse(
                        liked: false,
                        source: source,
                      );
                      if (context.mounted) {
                        await AppReviewService.instance.showInternalFeedbackDialog(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ada Masukan / Kurang Suka',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dismiss Option: "Nanti Saja"
              TextButton(
                onPressed: () {
                  AppReviewService.instance.markPromptDismissed();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white54,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                child: const Text(
                  'Nanti Saja',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

/// Internal Feedback Form Dialog:
/// Catches bugs, complaints, and constructive feedback directly to Firebase Firestore
/// preventing negative ratings on Google Play Store.
class InternalFeedbackDialog extends StatefulWidget {
  const InternalFeedbackDialog({super.key});

  @override
  State<InternalFeedbackDialog> createState() => _InternalFeedbackDialogState();
}

class _InternalFeedbackDialogState extends State<InternalFeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  final List<String> _categories = [
    '🐛 Bug / Error',
    '⚡ Koneksi / Lag',
    '🎲 Aturan Gameplay',
    '💡 Ide / Fitur Baru',
    '✨ Lainnya',
  ];

  late String _selectedCategory;
  int _rating = 3;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tuliskan masukan atau kendala yang kamu alami.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await AppReviewService.instance.submitInternalFeedback(
      category: _selectedCategory,
      feedback: text,
      rating: _rating,
      contactInfo: _contactController.text.trim().isNotEmpty
          ? _contactController.text.trim()
          : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFFFFD54F)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success
                    ? 'Masukanmu berhasil dikirim! Tim developer akan segera memeriksanya. Terima kasih! 🙏'
                    : 'Terima kasih atas masukanmu! Kritik & saranmu telah kami catat. 🙏',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: const Color(0xFF1E222A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC62828).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFFFF8A80),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Form Masukan Developer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Baloo2',
                          ),
                        ),
                        Text(
                          'Bantu kami memperbaiki kendala game',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Rating stars
              Text(
                'Bagaimana kepuasanmu secara umum?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = starNum),
                    icon: Icon(
                      starNum <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: starNum <= _rating ? AppColors.goldAccent : Colors.white30,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Category selector
              Text(
                'Kategori Masukan:',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.goldAccent,
                    backgroundColor: const Color(0xFF2C323D),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.goldAccent
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Text Field: Feedback Content
              Text(
                'Kendala / Saran Perbaikan:',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Jelaskan apa yang kurang atau kendala apa yang kamu temukan...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF252A34),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.goldAccent),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),

              // Optional contact info (Email / No HP)
              Text(
                'Email / WhatsApp (Opsional, untuk follow-up):',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _contactController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'contoh: nama@email.com',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12.5),
                  filled: true,
                  fillColor: const Color(0xFF252A34),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.goldAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 22),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'KIRIM MASUKAN',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
