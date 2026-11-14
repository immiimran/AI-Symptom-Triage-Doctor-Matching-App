import 'package:flutter/foundation.dart';

import '../models/auth_exception.dart';
import '../services/auth_service.dart';

/// Exposes authentication state to the UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorKey;
  String? _userName;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  /// Text key of the last error, or null. Show it with t(errorKey).
  String? get errorKey => _errorKey;

  String get userName => _userName ?? '';
  String get userEmail => _userEmail ?? '';

  /// First word of the user's name, for greetings.
  String get firstName {
    final name = userName.trim();
    if (name.isEmpty) return '';
    return name.split(RegExp(r'\s+')).first;
  }

  /// Reads the saved auth state. Any error is treated as "not logged in".
  Future<void> checkAuthStatus() async {
    try {
      _isLoggedIn = await _service.isSignedIn();
      if (_isLoggedIn) {
        _userName = await _service.currentUserName();
        _userEmail = await _service.currentUserEmail();
      } else {
        _userName = null;
        _userEmail = null;
      }
    } catch (_) {
      _isLoggedIn = false;
      _userName = null;
      _userEmail = null;
    }
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _service.signIn(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => _service.register(name: name, email: email, password: password),
    );
  }

  /// Changes the display name (used by Edit profile).
  Future<void> updateName(String name) async {
    try {
      await _service.updateName(name);
      _userName = name.trim();
      notifyListeners();
    } catch (_) {
      // The profile still saves; only the account name stays the same.
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  /// Runs an auth action, tracks loading/error state, returns success.
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      await action();
      _isLoggedIn = true;
      _userName = await _service.currentUserName();
      _userEmail = await _service.currentUserEmail();
      return true;
    } on AuthException catch (e) {
      _errorKey = e.messageKey;
      return false;
    } catch (_) {
      _errorKey = 'err_auth_unknown';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
