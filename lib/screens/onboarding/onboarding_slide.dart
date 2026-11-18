import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../models/onboarding_item.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';

/// One intro slide (glass design): big glass icon, title and description.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({super.key, required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.sphereRose.withValues(alpha: 0.4),
                  AppColors.glassButtonEnd.withValues(alpha: 0.25),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glassButtonStart.withValues(alpha: 0.35),
                  blurRadius: 50,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(item.icon, size: 92, color: AppColors.onGlass),
          ),
          const SizedBox(height: 48),
          Text(
            t(item.titleKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t(item.descriptionKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onGlassMuted,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
