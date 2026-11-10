import 'bn_texts.dart';
import 'en_texts.dart';

/// Languages supported by the app.
enum AppLanguage { en, bn }

/// Holds the current language and looks up translated text.
class AppTexts {
  AppTexts._();

  /// Currently selected language. Changed by LanguageProvider.
  static AppLanguage current = AppLanguage.en;

  /// Returns the text for [key] in the current language.
  /// Falls back to English, then to the key itself if missing.
  static String get(String key) {
    final Map<String, String> map =
        current == AppLanguage.bn ? bnTexts : enTexts;
    return map[key] ?? enTexts[key] ?? key;
  }
}

/// Short helper used everywhere: t('book_now')
String t(String key) => AppTexts.get(key);