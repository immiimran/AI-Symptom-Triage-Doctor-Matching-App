import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// App settings that the user can change.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({StorageService? storage})
    : _storage = storage ?? StorageService();

  final StorageService _storage;

  int? _defaultReminderMinutes;

  /// Minutes before every new appointment, or null for none.
  int? get defaultReminderMinutes => _defaultReminderMinutes;

  Future<void> load() async {
    _defaultReminderMinutes = await _storage.getDefaultReminderMinutes();
    notifyListeners();
  }

  Future<void> setDefaultReminder(int? minutes) async {
    _defaultReminderMinutes = minutes;
    notifyListeners();
    await _storage.setDefaultReminderMinutes(minutes);
  }
}
