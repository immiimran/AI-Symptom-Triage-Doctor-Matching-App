import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../services/speech_service.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_chip.dart';
import '../../widgets/glass_sheet.dart';

enum _VoiceState {
  initializing,
  ready,
  listening,
  unavailable,
  languageUnsupported,
  error,
}

/// Frosted bottom sheet for voice input. Returns the recognized text on
/// "Use this text", or null if the user closes it.
class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return GlassSheet.show<String>(
      context,
      builder: (_) => const VoiceInputSheet(),
    );
  }

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final SpeechService _speech = SpeechService.instance;
  late final AnimationController _pulse;

  _VoiceState _state = _VoiceState.initializing;
  SpeechInitStatus _initStatus = SpeechInitStatus.ready;
  AppLanguage _voiceLanguage = AppTexts.current;
  String _transcript = '';

  /// The error code from the speech plugin, e.g. "error_no_match".
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _speech.onStatus = _onStatus;
    _speech.onError = _onError;
    _init();
  }

  Future<void> _init() async {
    setState(() => _state = _VoiceState.initializing);

    final status = await _speech.init();
    if (!mounted) return;

    if (status != SpeechInitStatus.ready) {
      setState(() {
        _initStatus = status;
        _errorCode = _speech.lastError;
        _state = _VoiceState.unavailable;
      });
      return;
    }
    await _start();
  }

  Future<void> _start() async {
    final localeId = _speech.resolveLocale(_voiceLanguage);
    if (localeId == null) {
      setState(() => _state = _VoiceState.languageUnsupported);
      return;
    }

    setState(() {
      _state = _VoiceState.listening;
      _transcript = '';
      _errorCode = null;
    });

    try {
      await _speech.start(
        localeId: localeId,
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _transcript = text;
            if (isFinal) _state = _VoiceState.ready;
          });
        },
      );
    } catch (e) {
      debugPrint('Speech start failed: $e');
      if (mounted) {
        setState(() {
          _errorCode = 'listen_failed';
          _state = _VoiceState.error;
        });
      }
    }
  }

  Future<void> _stop() async {
    await _speech.stop();
    if (mounted) setState(() => _state = _VoiceState.ready);
  }

  void _toggleListening() {
    if (_state == _VoiceState.listening) {
      _stop();
    } else if (_state != _VoiceState.initializing &&
        _state != _VoiceState.unavailable) {
      _start();
    }
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    await _speech.cancel();
    if (!mounted) return;
    setState(() => _voiceLanguage = language);
    await _start();
  }

  Future<void> _useText() async {
    await _speech.stop();
    if (!mounted) return;
    Navigator.of(context).pop(_transcript.trim());
  }

  void _onStatus(String status) {
    if (!mounted) return;
    final finished =
        status == 'notListening' ||
        status == 'done' ||
        status == 'doneNoResult';
    if (finished && _state == _VoiceState.listening) {
      setState(() => _state = _VoiceState.ready);
    }
  }

  void _onError(String message) {
    debugPrint('Speech error: $message');
    if (!mounted) return;
    setState(() {
      _errorCode = message;
      _state = _transcript.isEmpty ? _VoiceState.error : _VoiceState.ready;
    });
  }

  /// Picks the text that matches the error code.
  String _errorText() {
    final code = (_errorCode ?? '').toLowerCase();
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;

    if (code.contains('permission')) return t('voice_perm_blocked');
    if (code.contains('language')) {
      return _voiceLanguage == AppLanguage.bn
          ? t('voice_bn_unsupported')
          : t('voice_error');
    }
    if (code.contains('network')) return t('voice_network');
    if (code.contains('no_match') || code.contains('speech_timeout')) {
      return t('voice_no_speech');
    }
    if (code.contains('audio') ||
        code.contains('busy') ||
        code.contains('listen_failed')) {
      return t('voice_mic_problem');
    }
    // On iOS an unknown error right after starting is typical for the
    // Simulator.
    if (isIos && code.contains('error_unknown')) return t('voice_ios_stopped');
    return t('voice_error');
  }

  /// Message for when the speech service could not start at all.
  String _unavailableText() {
    final code = (_errorCode ?? '').toLowerCase();

    switch (_initStatus) {
      case SpeechInitStatus.permissionDenied:
        return t('voice_perm_denied');
      case SpeechInitStatus.permissionBlocked:
        return t('voice_perm_blocked');
      case SpeechInitStatus.notAvailable:
        if (code.contains('timeout')) return t('voice_init_timeout');
        return defaultTargetPlatform == TargetPlatform.android
            ? t('voice_no_service_android')
            : t('voice_no_service_ios');
      case SpeechInitStatus.ready:
        return t('voice_not_available');
    }
  }

  String _message() {
    switch (_state) {
      case _VoiceState.initializing:
        return t('voice_preparing');
      case _VoiceState.listening:
        return t('voice_listening');
      case _VoiceState.ready:
        return _transcript.isEmpty
            ? t('voice_tap_to_start')
            : t('voice_done_hint');
      case _VoiceState.unavailable:
        return _unavailableText();
      case _VoiceState.languageUnsupported:
        return _voiceLanguage == AppLanguage.bn
            ? t('voice_bn_unsupported')
            : t('voice_not_available');
      case _VoiceState.error:
        return _errorText();
    }
  }

  @override
  void dispose() {
    _speech.onStatus = null;
    _speech.onError = null;
    _speech.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _state == _VoiceState.listening;
    final isUnavailable = _state == _VoiceState.unavailable;
    final isProblem = isUnavailable || _state == _VoiceState.error;
    final canUse = _transcript.trim().isNotEmpty;

    return Column(
      children: [
        Text(
          t('voice_title'),
          style: const TextStyle(
            color: AppColors.onGlass,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _message(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isProblem ? AppColors.onGlassError : AppColors.onGlassMuted,
            height: 1.4,
          ),
        ),
        // The phone's own error text, to help find the problem.
        if (_errorCode != null && _errorCode!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '${t('voice_details')}: $_errorCode',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 11),
          ),
        ],
        if (isUnavailable) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassChip(
                icon: Icons.settings_outlined,
                label: t('voice_open_settings'),
                selected: false,
                onTap: _speech.openSettings,
              ),
              const SizedBox(width: 10),
              GlassChip(
                icon: Icons.refresh_rounded,
                label: t('voice_try_again'),
                selected: true,
                onTap: _init,
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _MicButton(
          isListening: isListening,
          pulse: _pulse,
          onTap: (isUnavailable || _state == _VoiceState.initializing)
              ? null
              : _toggleListening,
        ),
        const SizedBox(height: 20),
        _TranscriptBox(text: _transcript),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassChip(
              label: t('lang_name_bn'),
              selected: _voiceLanguage == AppLanguage.bn,
              onTap: () {
                if (!isUnavailable) _changeLanguage(AppLanguage.bn);
              },
            ),
            const SizedBox(width: 10),
            GlassChip(
              label: t('lang_name_en'),
              selected: _voiceLanguage == AppLanguage.en,
              onTap: () {
                if (!isUnavailable) _changeLanguage(AppLanguage.en);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: canUse ? 1 : 0.45,
          child: GlassButton(
            label: t('voice_use_text'),
            onPressed: canUse ? _useText : null,
          ),
        ),
      ],
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isListening,
    required this.pulse,
    required this.onTap,
  });

  final bool isListening;
  final Animation<double> pulse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = isListening
        ? const [AppColors.accent, AppColors.primaryDark]
        : const [AppColors.glassButtonStart, AppColors.glassButtonEnd];

    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: SizedBox(
        width: 124,
        height: 124,
        child: AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final scale = isListening ? 1 + pulse.value * 0.2 : 1.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.onGlass.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          // A plain Container draws the round glow; Ink drew a square one.
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.5),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Center(
                  child: Icon(
                    isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: AppColors.onGlass,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TranscriptBox extends StatelessWidget {
  const _TranscriptBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.isEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        isEmpty ? t('voice_hint_speak') : text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          color: isEmpty ? AppColors.onGlassMuted : AppColors.onGlass,
        ),
      ),
    );
  }
}
