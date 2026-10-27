import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';
import 'auth_service.dart';
import 'player_identity.dart';
import '../widgets/app_review_dialog.dart';

class AppReviewService {
  static AppReviewService? _instance;
  final InAppReview _inAppReview = InAppReview.instance;
  final AnalyticsService _analytics = AnalyticsService();

  static const String _keyHasRated = 'app_review_has_rated';
  static const String _keyLastPromptMillis = 'app_review_last_prompt_millis';
  static const String _keyGamesCompleted = 'app_review_games_completed';
  static const int _cooldownDays = 5;

  AppReviewService._();

  static AppReviewService get instance {
    _instance ??= AppReviewService._();
    return _instance!;
  }

  /// Increments completed games counter.
  Future<void> recordGameCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyGamesCompleted) ?? 0) + 1;
    await prefs.setInt(_keyGamesCompleted, count);
  }

  /// Checks if the app should proactively ask the user for a review.
  Future<bool> shouldPromptReview() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRated = prefs.getBool(_keyHasRated) ?? false;
    if (hasRated) return false;

    final gamesCount = prefs.getInt(_keyGamesCompleted) ?? 0;
    // Prompt only after at least 1 completed game
    if (gamesCount < 1) return false;

    final lastPrompt = prefs.getInt(_keyLastPromptMillis) ?? 0;
    if (lastPrompt > 0) {
      final daysSinceLastPrompt =
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastPrompt)).inDays;
      if (daysSinceLastPrompt < _cooldownDays) {
        return false;
      }
    }

    return true;
  }

  /// Marks that prompt was shown to respect cooldown period.
  Future<void> markPromptDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastPromptMillis, DateTime.now().millisecondsSinceEpoch);
  }

  /// Marks that user has either reviewed or submitted feedback.
  Future<void> markRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasRated, true);
    await prefs.setInt(_keyLastPromptMillis, DateTime.now().millisecondsSinceEpoch);
  }

  /// Initiates the Google Play In-App Review flow (Positive feedback path).
  Future<void> triggerGooglePlayReview() async {
    await markRated();
    await _analytics.logInAppReviewRequested();

    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        // Triggers Google Play In-App Review dialog directly inside the app
        await _inAppReview.requestReview();
      } else {
        // Fallback to opening Play Store listing if in-app review API is unavailable
        await _inAppReview.openStoreListing();
      }
    } catch (e) {
      debugPrint('[AppReviewService] Error requesting in-app review: $e');
      try {
        await _inAppReview.openStoreListing();
      } catch (_) {}
    }
  }

  /// Submits negative / constructive user complaints internally to Firebase Firestore
  /// so complaints don't turn into 1-star reviews on Google Play Store.
  Future<bool> submitInternalFeedback({
    required String category,
    required String feedback,
    required int rating,
    String? contactInfo,
  }) async {
    try {
      final auth = AuthService();
      final playerIdentity = await PlayerIdentity.getInstance();

      final userId = auth.isLoggedIn ? auth.userId : playerIdentity.playerId;
      final userName = auth.isLoggedIn && auth.displayName.isNotEmpty
          ? auth.displayName
          : playerIdentity.playerName;

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'category': category,
        'feedback': feedback,
        'rating': rating,
        'contactInfo': contactInfo ?? '',
        'userId': userId,
        'userName': userName,
        'platform': defaultTargetPlatform.name,
        'appVersion': '1.0.6+9',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await markRated();
      await _analytics.logInternalFeedbackSubmitted(
        category: category,
        rating: rating,
      );

      return true;
    } catch (e) {
      debugPrint('[AppReviewService] Error submitting internal feedback: $e');
      // Even if Firestore fails, keep local rated state so user is not repeatedly prompted
      await markRated();
      return false;
    }
  }

  /// Launches the two-step satisfaction prompt dialog:
  /// 1. "Suka dengan app ini?"
  /// 2. If YES -> Google Play In-App Review
  /// 3. If NO -> Internal Feedback Dialog
  Future<void> showSatisfactionPrompt(
    BuildContext context, {
    String source = 'game_over',
    bool force = false,
  }) async {
    if (!force) {
      final canShow = await shouldPromptReview();
      if (!canShow) return;
    }

    if (!context.mounted) return;

    await _analytics.logReviewPromptShown(source: source);
    await markPromptDismissed();

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AppReviewDialog(source: source),
    );
  }

  /// Directly opens internal feedback dialog (e.g. from Settings or Help menu)
  Future<void> showInternalFeedbackDialog(BuildContext context) async {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => const InternalFeedbackDialog(),
    );
  }
}
