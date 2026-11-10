/// Error thrown by AuthService. Holds a text key, not a raw message,
/// so the UI can show it in the selected language with t().
class AuthException implements Exception {
  const AuthException(this.messageKey);

  final String messageKey;

  @override
  String toString() => 'AuthException($messageKey)';
}
