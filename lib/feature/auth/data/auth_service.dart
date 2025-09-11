import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  // Stream of auth state (logged in/out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user;
  }
  // Sign out

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
