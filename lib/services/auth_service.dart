import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emits the current user, or null if signed out.
  Stream<User?> get authState => _auth.authStateChanges();

  /// Creates a new user, then sets their display name.
  Future<void> signup(String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
  }

  /// Signs in an existing user.
  Future<void> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user.
  Future<void> logout() {
    return _auth.signOut();
  }
}
