import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final int gamesPlayed;
  final int gamesWon;
  final int totalEarnings;
  final DateTime? lastLogin;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalEarnings = 0,
    this.lastLogin,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? 'Player',
      gamesPlayed: data['gamesPlayed'] ?? 0,
      gamesWon: data['gamesWon'] ?? 0,
      totalEarnings: data['totalEarnings'] ?? 0,
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'totalEarnings': totalEarnings,
        'lastLogin': FieldValue.serverTimestamp(),
      };
}

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;

  ProfileService(this._authService);

  CollectionReference get _users => _firestore.collection('users');

  Future<UserProfile?> getProfile() async {
    if (!_authService.isLoggedIn) return null;
    final doc = await _users.doc(_authService.userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> createOrUpdateProfile(String displayName) async {
    if (!_authService.isLoggedIn) return;
    await _users.doc(_authService.userId).set(
      {
        'displayName': displayName,
        'lastLogin': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> recordMatch({required bool won, required int earnings}) async {
    if (!_authService.isLoggedIn) return;
    await _users.doc(_authService.userId).set(
      {
        'gamesPlayed': FieldValue.increment(1),
        if (won) 'gamesWon': FieldValue.increment(1),
        'totalEarnings': FieldValue.increment(earnings),
        'lastLogin': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
