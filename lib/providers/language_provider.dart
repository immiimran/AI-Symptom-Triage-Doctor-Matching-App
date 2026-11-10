import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';
import '../texts/app_texts.dart';

/// Holds the selected language and keeps [AppTexts] in sync.
class LanguageProvider extends ChangeNotifier {
  LanguageProvider({StorageService? storage})
    : _storage = storage ?? StorageService();

  final StorageService _storage;

  AppLanguage _language = AppLanguage.en;
  AppLanguage get language => _language;
  bool get isBangla => _language == AppLanguage.bn;

  /// Loads the saved language. Call once before runApp().
  Future<void> load() async {
    final code = await _storage.getLanguageCode();
    _language = code == 'bn' ? AppLanguage.bn : AppLanguage.en;
    AppTexts.current = _language;
    notifyListeners();
  }

  /// Switches the language and remembers the choice.
  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    AppTexts.current = language;
    notifyListeners();
    await _storage.setLanguageCode(language.name);
  }
}
