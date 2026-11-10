import 'package:firebase_auth/firebase_auth.dart';

import '../app/constants.dart';
import 'storage_service.dart';

/// Handles authentication state.
/// In demo mode it uses local storage; otherwise Firebase Auth.
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
}