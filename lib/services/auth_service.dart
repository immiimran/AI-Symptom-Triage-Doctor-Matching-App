import 'package:firebase_auth/firebase_auth.dart';

import '../app/constants.dart';
import '../models/auth_exception.dart';
import 'storage_service.dart';

/// Handles sign in, registration and sign out.
/// Demo mode uses local storage (no password check, for testing only).
/// Otherwise it uses Firebase Auth (email/password).
class AuthService {
  AuthService({StorageService? storage})
    : _storage = storage ?? StorageService();

  final StorageService _storage;

  /// Returns true if a user is currently signed in.
  Future<bool> isSignedIn() async {
    if (AppConstants.demoMode) {
      return _storage.getLoggedIn();
    }
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Display name of the signed-in user, or null.
  Future<String?> currentUserName() async {
    if (AppConstants.demoMode) {
      return _storage.getDemoUserName();
    }
    return FirebaseAuth.instance.currentUser?.displayName;
  }

  /// Email of the signed-in user, or null.
  Future<String?> currentUserEmail() async {
    if (AppConstants.demoMode) {
      return _storage.getDemoUserEmail();
    }
    return FirebaseAuth.instance.currentUser?.email;
  }

  /// Changes the display name of the signed-in user.
  Future<void> updateName(String name) async {
    if (AppConstants.demoMode) {
      final email = await _storage.getDemoUserEmail() ?? '';
      await _storage.saveDemoUser(name: name.trim(), email: email);
      return;
    }
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name.trim());
  }

  Future<void> signIn({required String email, required String password}) async {
    if (AppConstants.demoMode) {
      final saved = await _storage.getDemoUserEmail();
      if (saved == null || saved.toLowerCase() != email.trim().toLowerCase()) {
        throw const AuthException('err_user_not_found');
      }
      await _storage.setLoggedIn(true);
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageKey(e.code));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (AppConstants.demoMode) {
      await _storage.saveDemoUser(name: name.trim(), email: email.trim());
      await _storage.setLoggedIn(true);
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      await credential.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageKey(e.code));
    }
  }

  Future<void> signOut() async {
    if (AppConstants.demoMode) {
      await _storage.setLoggedIn(false);
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  /// Maps a Firebase error code to a text key from the texts folder.
  String _messageKey(String code) {
    switch (code) {
      case 'user-not-found':
        return 'err_user_not_found';
      case 'wrong-password':
      case 'invalid-credential':
        return 'err_wrong_password';
      case 'email-already-in-use':
        return 'err_email_in_use';
      case 'weak-password':
        return 'err_weak_password';
      case 'invalid-email':
        return 'err_email_invalid';
      case 'network-request-failed':
        return 'err_network';
      case 'too-many-requests':
        return 'err_too_many_requests';
      default:
        return 'err_auth_unknown';
    }
  }
}
