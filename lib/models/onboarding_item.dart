import 'package:flutter/material.dart';

/// Content of one onboarding intro slide.
/// Text is stored as keys and resolved with t() so it follows the language.
class OnboardingItem {
  const OnboardingItem({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });

  final IconData icon;
  final String titleKey;
  final String descriptionKey;
}
