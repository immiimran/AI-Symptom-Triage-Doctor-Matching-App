import 'package:flutter/material.dart';

import '../app/color.dart';
import 'glass_sheet.dart';

/// Frosted sheet with a title and paragraphs (privacy policy, about, ...).
Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required List<String> paragraphs,
  IconData icon = Icons.info_outline_rounded,
  String? footer,
}) {
  return GlassSheet.show<void>(
    context,
    builder: (_) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 42, color: AppColors.sphereRose),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final paragraph in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                paragraph,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  height: 1.45,
                ),
              ),
            ),
          if (footer != null) ...[
            const SizedBox(height: 4),
            Text(
              footer,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onGlassMuted),
            ),
          ],
        ],
      );
    },
  );
}