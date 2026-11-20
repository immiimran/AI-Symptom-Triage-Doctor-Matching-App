import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../models/doctor_list_args.dart';
import '../../models/triage_result.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/symptom_labels.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_section_title.dart';
import '../../widgets/specialty_match_bar.dart';
import 'urgency_banner.dart';

/// Shows the analysis (glass design): urgency, top specialties, summary
/// and advice.
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
      return GlassScaffold(
        title: t('result_title'),
        body: Center(
          child: Text(
            t('analyzing_error'),
            style: const TextStyle(color: AppColors.onGlass),
          ),
        ),
      );
    }
    final result = args;

    return GlassScaffold(
      title: t('result_title'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        children: [
          FadeSlideIn(
            child: UrgencyBanner(
              urgency: result.urgency,
              onCall: () => _callEmergency(context),
            ),
          ),
          const SizedBox(height: 20),
          if (result.noMatch) ...[
            const _NoMatchCard(),
            const SizedBox(height: 20),
          ],
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: GlassSectionTitle(t('suggested_specialties')),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < result.matches.length; i++)
            FadeSlideIn(
              delay: Duration(milliseconds: 120 + i * 70),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SpecialtyMatchBar(
                  specialtyId: result.matches[i].specialtyId,
                  name: doctors.specialtyName(result.matches[i].specialtyId),
                  percent: result.matches[i].percent,
                  isTop: i == 0 && !result.noMatch,
                ),
              ),
            ),
          Text(
            t('match_note'),
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 340),
            child: GlassSectionTitle(t('your_symptoms')),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 380),
            child: _SummaryCard(result: result),
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 420),
            child: const _AdviceCard(),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: const Duration(milliseconds: 460),
            child: const DisclaimerBanner(),
          ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassButton(
            label: t('find_doctors'),
            onPressed: () => _findDoctors(context, result),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.onGlass),
            child: Text(t('check_again')),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final TriageResult result;

  @override
  Widget build(BuildContext context) {
    final input = result.input;

    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        blur: false,
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${input.text}"',
              style: const TextStyle(
                color: AppColors.onGlass,
                fontStyle: FontStyle.italic,
                height: 1.4,
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
            ? AppColors.sphereRose.withValues(alpha: 0.25)
            : AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? AppColors.sphereRose : AppColors.glassBorder,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: highlighted ? AppColors.onGlass : AppColors.onGlassMuted,
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
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        blur: false,
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassSectionTitle(t('advice_title')),
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
                      color: AppColors.sphereRose,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t(key),
                        style: const TextStyle(
                          color: AppColors.onGlass,
                          height: 1.35,
                        ),
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

class _NoMatchCard extends StatelessWidget {
  const _NoMatchCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.star),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('no_match_title'),
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t('no_match_text'),
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
