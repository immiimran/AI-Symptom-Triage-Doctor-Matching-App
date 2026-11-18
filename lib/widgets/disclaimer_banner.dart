import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/color.dart';
import '../providers/language_provider.dart';
import '../texts/app_texts.dart';
import 'glass_card.dart';

/// Medical disclaimer box (glass design).
/// Reused on onboarding and on the triage result.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();

    return GlassCard(
      blur: false,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_outlined,
            color: AppColors.sphereRose,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('disclaimer_title'),
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t('disclaimer_text'),
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 13,
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
