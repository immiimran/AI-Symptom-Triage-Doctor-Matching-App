import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/common_symptom.dart';
import '../../models/symptom_input.dart';
import '../../providers/language_provider.dart';
import '../../providers/triage_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/option_chips.dart';
import '../../widgets/primary_button.dart';
import 'common_symptom_chips.dart';
import 'severity_selector.dart';
import 'symptom_text_box.dart';
import 'voice_input_sheet.dart';

/// Main feature screen: the user describes symptoms by typing, tapping
/// chips or speaking, then taps "Analyze".
class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _selectedIds = {};

  AgeGroup _age = AgeGroup.adult;
  SymptomDuration _duration = SymptomDuration.oneToThreeDays;
  SymptomSeverity _severity = SymptomSeverity.moderate;
  bool _argsHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsHandled) return;
    _argsHandled = true;

    // Home's mic button sends `true` to open the voice sheet immediately.
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openVoice();
      });
    }
  }

  Future<void> _openVoice() async {
    FocusScope.of(context).unfocus();
    final text = await VoiceInputSheet.show(context);
    if (!mounted || text == null || text.trim().isEmpty) return;
    _appendText(text.trim(), separator: ' ');
  }

  void _appendText(String value, {String separator = ', '}) {
    final current = _controller.text.trim();
    _controller.text = current.isEmpty ? value : '$current$separator$value';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _toggleChip(CommonSymptom symptom) {
    setState(() {
      if (_selectedIds.remove(symptom.id)) {
        _removeLabel(symptom.label);
      } else {
        _selectedIds.add(symptom.id);
        _appendText(symptom.label);
      }
    });
  }

  void _removeLabel(String label) {
    var text = _controller.text.replaceFirst(label, '');
    text = text
        .replaceAll(RegExp(r'\s*,\s*,\s*'), ', ')
        .replaceAll(RegExp(r'^\s*,\s*|\s*,\s*$'), '')
        .trim();
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _selectedIds.clear();
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.length < 3) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('symptom_too_short'))));
      return;
    }
    FocusScope.of(context).unfocus();

    final input = SymptomInput(
      text: text,
      ageGroup: _age,
      duration: _duration,
      severity: _severity,
      symptomIds: _selectedIds.toList(),
    );
    debugPrint(input.toString());
    Navigator.of(context).pushNamed(AppRoutes.analyzing, arguments: input);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final symptoms = context.watch<TriageProvider>().commonSymptoms;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(t('symptom_screen_title')),
      actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: t('history_title'),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.history),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Text(
                    t('symptom_screen_intro'),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SymptomTextBox(
                    controller: _controller,
                    hint: t('symptom_input_hint'),
                    onMicTap: _openVoice,
                    onClear: _clear,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(t('common_symptoms')),
                  const SizedBox(height: 12),
                  CommonSymptomChips(
                    symptoms: symptoms,
                    selectedIds: _selectedIds,
                    onToggle: _toggleChip,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(t('age_group_title')),
                  const SizedBox(height: 12),
                  OptionChips<AgeGroup>(
                    options: [
                      OptionChipItem(AgeGroup.child, t('age_child')),
                      OptionChipItem(AgeGroup.adult, t('age_adult')),
                      OptionChipItem(AgeGroup.senior, t('age_senior')),
                    ],
                    selected: _age,
                    onSelected: (value) => setState(() => _age = value),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(t('duration_title')),
                  const SizedBox(height: 12),
                  OptionChips<SymptomDuration>(
                    options: [
                      OptionChipItem(
                        SymptomDuration.underOneDay,
                        t('duration_lt_day'),
                      ),
                      OptionChipItem(
                        SymptomDuration.oneToThreeDays,
                        t('duration_1_3'),
                      ),
                      OptionChipItem(
                        SymptomDuration.fourToSevenDays,
                        t('duration_4_7'),
                      ),
                      OptionChipItem(
                        SymptomDuration.overWeek,
                        t('duration_gt_week'),
                      ),
                    ],
                    selected: _duration,
                    onSelected: (value) => setState(() => _duration = value),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(t('severity_title')),
                  const SizedBox(height: 12),
                  SeveritySelector(
                    selected: _severity,
                    onSelected: (value) => setState(() => _severity = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(label: t('analyze_button'), onPressed: _submit),
                  const SizedBox(height: 8),
                  Text(
                    t('symptom_disclaimer_short'),
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
