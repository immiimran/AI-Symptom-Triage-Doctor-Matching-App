import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../texts/app_texts.dart';

/// Why speech recognition could (not) start.
enum SpeechInitStatus {
  ready,

  /// Microphone permission was not granted (can ask again).
  permissionDenied,

  /// Microphone permission is blocked: only the phone Settings can fix it.
  permissionBlocked,

  /// The phone has no speech recognition service, or it is turned off.
  notAvailable,
}

/// Wrapper around the speech_to_text plugin (voice input).
/// It is a singleton because the plugin can only be initialised once.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  List<LocaleName> _locales = const [];

  /// The last error text from the phone's speech service (for diagnosis).
  String? lastError;

  /// Set by the screen that is currently listening.
  void Function(String status)? onStatus;
  void Function(String errorMessage)? onError;

  /// Prepares speech recognition and says why it failed, if it did.
  Future<SpeechInitStatus> init() async {
    if (_initialized) return SpeechInitStatus.ready;
    lastError = null;

    try {
      _initialized = await _speech.initialize(
        onStatus: (status) => onStatus?.call(status),
        onError: (error) {
          lastError = error.errorMsg;
          onError?.call(error.errorMsg);
        },
        debugLogging: kDebugMode,
      );
    } catch (e) {
      lastError = e.toString();
      _initialized = false;
    }

    if (_initialized) {
      _locales = await _speech.locales();
      return SpeechInitStatus.ready;
    }

    // Failed. On Android we can check the microphone permission directly.
    if (defaultTargetPlatform == TargetPlatform.android) {
      final mic = await Permission.microphone.status;
      if (mic.isPermanentlyDenied) return SpeechInitStatus.permissionBlocked;
      if (!mic.isGranted) return SpeechInitStatus.permissionDenied;
    }
    return SpeechInitStatus.notAvailable;
  }

  /// Opens the phone's Settings page for this app.
  Future<void> openSettings() => openAppSettings();

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
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
