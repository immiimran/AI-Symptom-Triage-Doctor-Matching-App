import 'dart:async';

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

  /// The phone has no speech recognition service, or it did not answer.
  notAvailable,
}

/// Wrapper around the speech_to_text plugin (voice input).
/// It is a singleton because the plugin can only be initialised once.
/// Every step has a time limit, so the screen never waits forever.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  static const Duration _initTimeout = Duration(seconds: 8);
  static const Duration _localesTimeout = Duration(seconds: 3);

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

    // Android: ask for the microphone ourselves, so the dialog always shows.
    if (defaultTargetPlatform == TargetPlatform.android) {
      var mic = await Permission.microphone.status;
      if (!mic.isGranted) mic = await Permission.microphone.request();
      if (mic.isPermanentlyDenied) return SpeechInitStatus.permissionBlocked;
      if (!mic.isGranted) return SpeechInitStatus.permissionDenied;
    }

    try {
      _initialized = await _speech
          .initialize(
            onStatus: (status) => onStatus?.call(status),
            onError: (error) {
              lastError = error.errorMsg;
              onError?.call(error.errorMsg);
            },
            debugLogging: kDebugMode,
          )
          .timeout(
            _initTimeout,
            onTimeout: () {
              lastError = 'initialize timeout';
              return false;
            },
          );
    } catch (e) {
      lastError = e.toString();
      _initialized = false;
    }

    if (!_initialized) return SpeechInitStatus.notAvailable;

    // Some phones never answer the language list. Then we use defaults.
    try {
      _locales = await _speech.locales().timeout(
        _localesTimeout,
        onTimeout: () {
          debugPrint('locales() timed out, using default languages');
          return <LocaleName>[];
        },
      );
    } catch (_) {
      _locales = const [];
    }
    return SpeechInitStatus.ready;
  }

  /// Opens the phone's Settings page for this app.
  Future<void> openSettings() => openAppSettings();

  /// Finds the best locale id for [language].
  /// If the phone did not give a language list, a standard id is returned.
  String? resolveLocale(AppLanguage language) {
    final isBangla = language == AppLanguage.bn;
    if (_locales.isEmpty) return isBangla ? 'bn_BD' : 'en_US';

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
