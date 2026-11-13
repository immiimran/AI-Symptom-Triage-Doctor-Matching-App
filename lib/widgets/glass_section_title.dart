import 'package:flutter/material.dart';

import '../app/color.dart';

/// Section heading for glass screens.
class GlassSectionTitle extends StatelessWidget {
  const GlassSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.onGlass,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
