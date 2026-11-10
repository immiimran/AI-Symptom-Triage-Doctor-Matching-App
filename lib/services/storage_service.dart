import 'package:shared_preferences/shared_preferences.dart';

/// Simple local key-value storage (language, login flag, history).
class StorageService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyLanguage = 'language_code';

  Future<bool> getLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  /// Returns 'en', 'bn' or null if the user never chose a language.
  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }
}
