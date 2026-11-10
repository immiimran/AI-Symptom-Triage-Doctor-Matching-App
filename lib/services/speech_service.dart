// ignore_for_file: deprecated_member_use

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../texts/app_texts.dart';

/// Wrapper around the speech_to_text plugin (voice input).
/// It is a singleton because the plugin can only be initialised once.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  List<LocaleName> _locales = const [];

  /// Set by the screen that is currently listening.
  void Function(String status)? onStatus;
  void Function(String errorMessage)? onError;

  /// Prepares speech recognition. Returns false if it is not available
  /// (no permission, or not supported on this device).
  Future<bool> init() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onStatus: (status) => onStatus?.call(status),
      onError: (error) => onError?.call(error.errorMsg),
    );
    if (_initialized) {
      _locales = await _speech.locales();
    }
    return _initialized;
  }

  /// Finds the best locale id for [language], or null if the device does
  /// not support it (for example Bangla on some phones).
  String? resolveLocale(AppLanguage language) {
    final isBangla = language == AppLanguage.bn;
    final preferred = isBangla ? 'bn_bd' : 'en_us';
    final prefix = isBangla ? 'bn' : 'en';

    String normalize(String id) => id.toLowerCase().replaceAll('-', '_');

    for (final locale in _locales) {
      if (normalize(locale.localeId) == preferred) return locale.localeId;
    }
    for (final locale in _locales) {
      if (normalize(locale.localeId).startsWith(prefix)) {
        return locale.localeId;
      }
    }
    return null;
  }

  Future<void> start({
    required String localeId,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) =>
          onResult(result.recognizedWords, result.finalResult),
      // ignore: duplicate_ignore
      // ignore: deprecated_member_use
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
