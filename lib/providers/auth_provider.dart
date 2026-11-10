import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Exposes authentication state to the UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Reads the saved auth state. Any error is treated as "not logged in".
  Future<void> checkAuthStatus() async {
    try {
      _isLoggedIn = await _service.isSignedIn();
    } catch (_) {
      _isLoggedIn = false;
    }
    notifyListeners();
  }
}