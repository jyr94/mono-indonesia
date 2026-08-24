import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String get userId => _auth.currentUser?.uid ?? '';
  String get displayName => _auth.currentUser?.displayName ?? 'Guest';
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      await _analytics.logLogin(loginMethod: 'anonymous');
      return cred.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      final cred = await _auth.signInWithProvider(googleProvider);
      await _analytics.logLogin(loginMethod: 'google');
      return cred.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }
}
