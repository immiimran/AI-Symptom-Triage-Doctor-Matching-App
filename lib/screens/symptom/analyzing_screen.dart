import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/symptom_input.dart';
import '../../models/triage_result.dart';
import '../../providers/language_provider.dart';
import '../../providers/triage_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_background.dart';

/// Short loading screen (glass design) shown while the triage engine runs.
/// Then it opens the result screen.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  static const List<String> _stepKeys = [
    'analyzing_step_1',
    'analyzing_step_2',
    'analyzing_step_3',
  ];
  static const Duration _stepDuration = Duration(milliseconds: 800);

  int _step = 0;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  Future<void> _run() async {
    final input = ModalRoute.of(context)?.settings.arguments;
    final navigator = Navigator.of(context);
    if (input is! SymptomInput) {
      navigator.pop();
      return;
    }

    final provider = context.read<TriageProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // Start the engine now, and show the steps while it works.
    TriageResult? result;
    final analysis = provider
        .analyze(input)
        .then((r) {
          result = r;
        })
        .catchError((_) {});

    for (var i = 1; i < _stepKeys.length; i++) {
      await Future<void>.delayed(_stepDuration);
      if (!mounted) return;
      setState(() => _step = i);
    }
    await Future<void>.delayed(_stepDuration);
    await analysis;
    if (!mounted) return;

    final finished = result;
    if (finished == null) {
      messenger.showSnackBar(SnackBar(content: Text(t('analyzing_error'))));
      navigator.pop();
      return;
    }
    navigator.pushReplacementNamed(AppRoutes.triageResult, arguments: finished);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();

    return Scaffold(
      body: GlassBackground(
        showSilverSphere: false,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glassFill,
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glassButtonStart.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 50,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 128,
                          height: 128,
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            color: AppColors.onGlass,
                            backgroundColor: AppColors.onGlass.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 54,
                          color: AppColors.onGlass,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    t('analyzing_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.onGlass,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      t(_stepKeys[_step]),
                      key: ValueKey(_step),
                      style: const TextStyle(color: AppColors.onGlassMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
