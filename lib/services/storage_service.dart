import 'package:shared_preferences/shared_preferences.dart';

/// Simple local key-value storage (language, login, favorites, bookings).
class StorageService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyLanguage = 'language_code';
  static const String _keyDemoName = 'demo_user_name';
  static const String _keyDemoEmail = 'demo_user_email';
  static const String _keyFavorites = 'favorite_doctor_ids';
  static const String _keyAppointments = 'appointments_json';

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

  /// Demo mode only: remembers the registered name and email.
  /// The password is intentionally NOT stored.
  Future<void> saveDemoUser({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDemoName, name);
    await prefs.setString(_keyDemoEmail, email);
  }

  Future<String?> getDemoUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDemoName);
  }

  Future<String?> getDemoUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDemoEmail);
  }

  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? <String>[];
  }

  Future<void> setFavoriteIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, ids);
  }

  /// Returns null if appointments were never saved (first launch).
  Future<String?> getAppointmentsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppointments);
  }

  Future<void> saveAppointmentsJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppointments, json);
  }
}
