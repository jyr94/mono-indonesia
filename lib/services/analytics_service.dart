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
        'is_multiplayer': isMultiplayer,
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
        'won': won,
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
}
