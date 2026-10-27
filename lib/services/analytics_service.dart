import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalytics get observer => _analytics;

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logMatchStart({required int playerCount, required bool isMultiplayer}) async {
    await _analytics.logEvent(
      name: 'match_start',
      parameters: {
        'player_count': playerCount,
        'is_multiplayer': isMultiplayer ? 1 : 0,
      },
    );
  }

  Future<void> logMatchEnd({
    required bool won,
    required int durationSeconds,
    required int playerCount,
  }) async {
    await _analytics.logEvent(
      name: 'match_end',
      parameters: {
        'won': won ? 1 : 0,
        'duration_seconds': durationSeconds,
        'player_count': playerCount,
      },
    );
  }

  Future<void> logAdWatched({required String adType, required String placement}) async {
    await _analytics.logEvent(
      name: 'ad_watched',
      parameters: {
        'ad_type': adType,
        'placement': placement,
      },
    );
  }

  Future<void> logRoomCreated(String roomCode) async {
    await _analytics.logEvent(
      name: 'room_created',
      parameters: {'room_code': roomCode},
    );
  }

  Future<void> logRoomJoined(String roomCode) async {
    await _analytics.logEvent(
      name: 'room_joined',
      parameters: {'room_code': roomCode},
    );
  }

  Future<void> logPropertyBought(String propertyName, int price) async {
    await _analytics.logEvent(
      name: 'property_bought',
      parameters: {
        'property_name': propertyName,
        'price': price,
      },
    );
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logReviewPromptShown({String source = 'game_over'}) async {
    await _analytics.logEvent(
      name: 'review_prompt_shown',
      parameters: {'source': source},
    );
  }

  Future<void> logReviewResponse({required bool liked, required String source}) async {
    await _analytics.logEvent(
      name: 'review_response',
      parameters: {
        'liked': liked ? 1 : 0,
        'source': source,
      },
    );
  }

  Future<void> logInAppReviewRequested() async {
    await _analytics.logEvent(name: 'in_app_review_requested');
  }

  Future<void> logInternalFeedbackSubmitted({
    required String category,
    required int rating,
  }) async {
    await _analytics.logEvent(
      name: 'internal_feedback_submitted',
      parameters: {
        'category': category,
        'rating': rating,
      },
    );
  }
}
