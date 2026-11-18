import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/language_option_tile.dart';

/// Last onboarding page (glass design): language choice and the medical
/// disclaimer.
class OnboardingSetupPage extends StatelessWidget {
  const OnboardingSetupPage({
    super.key,
    required this.accepted,
    required this.onAcceptedChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onAcceptedChanged;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('onb_setup_title'),
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('onb_setup_subtitle'),
            style: const TextStyle(color: AppColors.onGlassMuted),
          ),
          const SizedBox(height: 20),
          LanguageOptionTile(
            label: t('lang_name_bn'),
            selected: language.language == AppLanguage.bn,
            onTap: () => language.setLanguage(AppLanguage.bn),
          ),
          const SizedBox(height: 12),
          LanguageOptionTile(
            label: t('lang_name_en'),
            selected: language.language == AppLanguage.en,
            onTap: () => language.setLanguage(AppLanguage.en),
          ),
          const SizedBox(height: 24),
          const DisclaimerBanner(),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: accepted,
            onChanged: (value) => onAcceptedChanged(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.sphereRose,
            checkColor: AppColors.onGlass,
            side: const BorderSide(color: AppColors.onGlass, width: 1.5),
            title: Text(
              t('disclaimer_accept'),
              style: const TextStyle(color: AppColors.onGlass),
            ),
          ),
        ],
      ),
    );
  }
}
