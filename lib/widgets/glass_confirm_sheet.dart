import 'package:flutter/material.dart';

import '../app/color.dart';
import '../texts/app_texts.dart';
import 'glass_button.dart';
import 'glass_sheet.dart';

/// Frosted confirmation sheet. Returns true if the user confirms.
/// Set [destructive] for dangerous actions (cancel, delete): red button.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final result = await GlassSheet.show<bool>(
    context,
    builder: (sheetContext) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            icon,
            size: 42,
            color: destructive ? AppColors.onGlassError : AppColors.sphereRose,
          ),
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
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onGlassMuted, height: 1.4),
          ),
          const SizedBox(height: 22),
          if (destructive)
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            GlassButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(sheetContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.onGlass),
            child: Text(cancelLabel ?? t('btn_cancel')),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
