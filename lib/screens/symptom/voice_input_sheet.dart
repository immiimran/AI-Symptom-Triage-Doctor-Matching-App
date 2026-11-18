import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../services/speech_service.dart';
import '../../texts/app_texts.dart';
import '../../widgets/primary_button.dart';

enum _VoiceState {
  initializing,
  ready,
  listening,
  unavailable,
  languageUnsupported,
  error,
}

/// Bottom sheet for voice input. Returns the recognized text on "Use this
/// text", or null if the user closes it.
class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
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
    final ok = await _speech.init();
    if (!mounted) return;
    if (!ok) {
      setState(() => _state = _VoiceState.unavailable);
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
    } else if (_state != _VoiceState.initializing) {
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
    if (code.contains('permission')) return t('voice_not_available');
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
    return t('voice_error');
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
        return t('voice_not_available');
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
    final textTheme = Theme.of(context).textTheme;
    final isListening = _state == _VoiceState.listening;
    final hasProblem = _state == _VoiceState.unavailable;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t('voice_title'),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _message(),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: hasProblem ? AppColors.error : AppColors.textMuted,
              ),
            ),
            // Only in debug builds: the real error code, to find problems.
            if (kDebugMode && _errorCode != null) ...[
              const SizedBox(height: 4),
              Text(
                '[debug] $_errorCode',
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 24),
            _MicButton(
              isListening: isListening,
              pulse: _pulse,
              onTap: hasProblem ? null : _toggleListening,
            ),
            const SizedBox(height: 20),
            _TranscriptBox(text: _transcript),
            const SizedBox(height: 16),
            SegmentedButton<AppLanguage>(
              segments: [
                ButtonSegment(
                  value: AppLanguage.bn,
                  label: Text(t('lang_name_bn')),
                ),
                ButtonSegment(
                  value: AppLanguage.en,
                  label: Text(t('lang_name_en')),
                ),
              ],
              selected: {_voiceLanguage},
              onSelectionChanged: hasProblem
                  ? null
                  : (selection) => _changeLanguage(selection.first),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: t('voice_use_text'),
              onPressed: _transcript.trim().isEmpty ? null : _useText,
            ),
          ],
        ),
      ),
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
    return SizedBox(
      width: 120,
      height: 120,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final scale = isListening ? 1 + pulse.value * 0.18 : 1.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: Material(
          color: isListening ? AppColors.accent : AppColors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Icon(
                isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 36,
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Text(
        isEmpty ? t('voice_hint_speak') : text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          color: isEmpty ? AppColors.textMuted : AppColors.textDark,
        ),
      ),
    );
  }
}
