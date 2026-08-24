import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_service.dart';

class ChatMessage {
  final String senderId;
  final String senderName;
  final String message;
  final int timestamp;
  final bool isPreset;

  const ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isPreset = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        senderId: json['senderId'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '',
        message: json['message'] as String? ?? '',
        timestamp: json['timestamp'] as int? ?? 0,
        isPreset: json['isPreset'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': ServerValue.timestamp,
        'isPreset': isPreset,
      };
}

class ChatService {
  final FirebaseService _fb = FirebaseService();
  final String roomCode;
  final String playerId;
  final String playerName;

  final _messageController = StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get onMessages => _messageController.stream;

  final List<ChatMessage> _messages = [];
  StreamSubscription? _chatSub;

  static const List<String> presetMessages = [
    'Halo! 👋',
    'Bagus! 👍',
    'Wah, beruntung! 🍀',
    'Ayo cepat! ⏰',
    'Haha 😂',
    'GG! 🎉',
    'Sial... 😤',
    'Oke, giliranku!',
  ];

  ChatService({
    required this.roomCode,
    required this.playerId,
    required this.playerName,
  });

  void startListening() {
    _chatSub = _fb.database
        .ref('rooms/$roomCode/chat')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onChildAdded
        .listen((event) {
      if (!event.snapshot.exists) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final msg = ChatMessage.fromJson(_convertMap(data));
      _messages.add(msg);
      _messageController.add(List.from(_messages));
    });
  }

  Future<void> sendMessage(String message, {bool isPreset = false}) async {
    await _fb.database.ref('rooms/$roomCode/chat').push().set({
      'senderId': playerId,
      'senderName': playerName,
      'message': message,
      'timestamp': ServerValue.timestamp,
      'isPreset': isPreset,
    });
  }

  Future<void> sendPreset(int index) async {
    if (index < 0 || index >= presetMessages.length) return;
    await sendMessage(presetMessages[index], isPreset: true);
  }

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> raw) {
    final result = <String, dynamic>{};
    for (final entry in raw.entries) {
      result[entry.key.toString()] = entry.value;
    }
    return result;
  }

  Future<void> dispose() async {
    await _chatSub?.cancel();
    await _messageController.close();
  }
}
