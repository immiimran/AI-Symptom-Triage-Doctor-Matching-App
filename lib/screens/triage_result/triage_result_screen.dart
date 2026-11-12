import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../models/triage_result.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/symptom_labels.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/specialty_match_bar.dart';
import 'urgency_banner.dart';
import '../../models/doctor_list_args.dart';

/// Shows the analysis: urgency, top specialties, summary and advice.
class TriageResultScreen extends StatelessWidget {
  const TriageResultScreen({super.key});

  Future<void> _callEmergency(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: AppConstants.emergencyNumber);
    var launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('call_failed'))));
    }
  }

  void _findDoctors(BuildContext context, TriageResult result) {
    Navigator.of(context).pushNamed(
      AppRoutes.doctors,
      arguments: DoctorListArgs(matches: result.matches),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! TriageResult) {
      return Scaffold(
        appBar: AppBar(title: Text(t('result_title'))),
        body: Center(child: Text(t('analyzing_error'))),
      );
    }
    final result = args;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(t('result_title'))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  UrgencyBanner(
                    urgency: result.urgency,
                    onCall: () => _callEmergency(context),
                  ),
                  const SizedBox(height: 20),
                  if (result.noMatch) ...[
                    const _NoMatchCard(),
                    const SizedBox(height: 20),
                  ],
                  _SectionTitle(t('suggested_specialties')),
                  const SizedBox(height: 12),
                  for (var i = 0; i < result.matches.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SpecialtyMatchBar(
                        specialtyId: result.matches[i].specialtyId,
                        name: doctors.specialtyName(
                          result.matches[i].specialtyId,
                        ),
                        percent: result.matches[i].percent,
                        isTop: i == 0 && !result.noMatch,
                      ),
                    ),
                  Text(
                    t('match_note'),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(t('your_symptoms')),
                  const SizedBox(height: 12),
                  _SummaryCard(result: result),
                  const SizedBox(height: 24),
                  const _AdviceCard(),
                  const SizedBox(height: 20),
                  const DisclaimerBanner(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: t('find_doctors'),
                    onPressed: () => _findDoctors(context, result),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t('check_again')),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final TriageResult result;

  @override
  Widget build(BuildContext context) {
    final input = result.input;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${input.text}"',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final symptom in result.matchedSymptoms)
                _InfoChip(text: symptom.name, highlighted: true),
              _InfoChip(text: ageLabel(input.ageGroup)),
              _InfoChip(text: durationLabel(input.duration)),
              _InfoChip(text: severityLabel(input.severity)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text, this.highlighted = false});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.greyLight,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: highlighted ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard();

  static const List<String> _tipKeys = ['tip_1', 'tip_2', 'tip_3'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(t('advice_title')),
          const SizedBox(height: 12),
          for (final key in _tipKeys)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t(key))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NoMatchCard extends StatelessWidget {
  const _NoMatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.urgent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('no_match_title'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(t('no_match_text')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
