import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/room_model.dart';
import 'firebase_service.dart';

class RoomService {
  final _fb = FirebaseService();

  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<RoomModel> createRoom(String playerId, String playerName) async {
    String code;
    bool exists;
    int attempts = 0;
    do {
      code = generateRoomCode();
      final snapshot = await _fb.roomRef(code).get();
      exists = snapshot.exists;
      attempts++;
    } while (exists && attempts < 10);

    final roomData = {
      'hostId': playerId,
      'state': 'waiting',
      'createdAt': ServerValue.timestamp,
      'players': {
        playerId: {
          'id': playerId,
          'name': playerName,
          'isHost': true,
          'connected': true,
        },
      },
    };

    await _fb.setWithRetry(_fb.roomRef(code), roomData);

    return RoomModel(
      code: code,
      hostId: playerId,
      state: 'waiting',
      players: {
        playerId: RoomPlayer(
          id: playerId,
          name: playerName,
          isHost: true,
        ),
      },
    );
  }

  Future<RoomModel?> joinRoom(
      String code, String playerId, String playerName) async {
    final snapshot = await _fb.roomRef(code).get();
    if (!snapshot.exists) return null;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final roomJson = _convertMap(data);
    final room = RoomModel.fromJson(code, roomJson);

    if (room.isFull) return null;
    if (room.state != 'waiting') return null;

    await _fb.playerRef(code, playerId).set({
      'id': playerId,
      'name': playerName,
      'isHost': false,
      'connected': true,
    });

    final updatedPlayers = Map<String, RoomPlayer>.from(room.players);
    updatedPlayers[playerId] = RoomPlayer(id: playerId, name: playerName);

    return RoomModel(
      code: code,
      hostId: room.hostId,
      state: room.state,
      players: updatedPlayers,
    );
  }

  Future<void> leaveRoom(String code, String playerId) async {
    await _fb.playerRef(code, playerId).remove();

    final snapshot = await _fb.playersRef(code).get();
    if (!snapshot.exists || (snapshot.value as Map?)?.isEmpty != false) {
      await _fb.roomRef(code).remove();
    }
  }

  Future<void> setPlayerConnected(
      String code, String playerId, bool connected) async {
    await _fb.playerRef(code, playerId).update({'connected': connected});
  }

  Future<void> startGame(String code, String hostId) async {
    final snapshot = await _fb.roomRef(code).get();
    if (!snapshot.exists) return;

    final data = _convertMap(snapshot.value as Map<dynamic, dynamic>);
    if (data['hostId'] != hostId) return;

    await _fb.roomRef(code).update({'state': 'inProgress'});
  }

  Future<void> deleteRoom(String code) async {
    await _fb.roomRef(code).remove();
  }

  Stream<RoomModel?> roomStream(String code) {
    return _fb.roomRef(code).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      final data = _convertMap(event.snapshot.value as Map<dynamic, dynamic>);
      return RoomModel.fromJson(code, data);
    });
  }

  Stream<Map<String, dynamic>?> gameStateStream(String code) {
    return _fb.gameStateRef(code).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return _convertMap(event.snapshot.value as Map<dynamic, dynamic>);
    });
  }

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> raw) {
    final result = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      if (entry.value is Map) {
        result[key] = _convertMap(entry.value as Map<dynamic, dynamic>);
      } else {
        result[key] = entry.value;
      }
    }
    return result;
  }
}
