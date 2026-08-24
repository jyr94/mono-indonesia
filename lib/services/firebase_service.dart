import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static FirebaseService? _instance;
  late final FirebaseDatabase _database;

  FirebaseService._() {
    _database = FirebaseDatabase.instance;
    _database.setLoggingEnabled(false);
  }

  factory FirebaseService() {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  FirebaseDatabase get database => _database;

  DatabaseReference get roomsRef => _database.ref('rooms');
  DatabaseReference roomRef(String code) => _database.ref('rooms/$code');
  DatabaseReference playersRef(String code) =>
      _database.ref('rooms/$code/players');
  DatabaseReference playerRef(String code, String playerId) =>
      _database.ref('rooms/$code/players/$playerId');
  DatabaseReference gameStateRef(String code) =>
      _database.ref('rooms/$code/gameState');
  DatabaseReference actionsRef(String code) =>
      _database.ref('rooms/$code/actions');
  DatabaseReference turnDeadlineRef(String code) =>
      _database.ref('rooms/$code/turnDeadline');

  Future<void> setWithRetry(DatabaseReference ref, dynamic value,
      {int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      try {
        await ref.set(value);
        return;
      } catch (e) {
        if (i == retries - 1) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
      }
    }
  }

  Future<void> updateWithRetry(DatabaseReference ref, Map<String, dynamic> value,
      {int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      try {
        await ref.update(value);
        return;
      } catch (e) {
        if (i == retries - 1) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
      }
    }
  }

  Future<String> pushAction(String roomCode, Map<String, dynamic> action) async {
    final ref = actionsRef(roomCode).push();
    await ref.set(action);
    return ref.key!;
  }
}
