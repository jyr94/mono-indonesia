import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PlayerIdentity {
  static PlayerIdentity? _instance;
  late String playerId;
  late String playerName;

  PlayerIdentity._({required this.playerId, required this.playerName});

  static Future<PlayerIdentity> getInstance() async {
    if (_instance != null) return _instance!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('player_id');
    var name = prefs.getString('player_name');

    if (id == null) {
      id = const Uuid().v4().substring(0, 8);
      await prefs.setString('player_id', id);
    }

    name ??= 'Pemain ${id.substring(0, 4).toUpperCase()}';
    await prefs.setString('player_name', name);

    _instance = PlayerIdentity._(playerId: id, playerName: name);
    return _instance!;
  }

  Future<void> updateName(String newName) async {
    playerName = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', newName);
  }
}
