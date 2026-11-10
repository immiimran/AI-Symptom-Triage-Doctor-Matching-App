import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/symptom_input.dart';
import '../../texts/app_texts.dart';

/// Three colored cards: mild, moderate, severe.
class SeveritySelector extends StatelessWidget {
  const SeveritySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SymptomSeverity selected;
  final ValueChanged<SymptomSeverity> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _card(
          SymptomSeverity.mild,
          'severity_mild',
          Icons.sentiment_satisfied_rounded,
          AppColors.success,
        ),
        const SizedBox(width: 10),
        _card(
          SymptomSeverity.moderate,
          'severity_moderate',
          Icons.sentiment_neutral_rounded,
          AppColors.warning,
        ),
        const SizedBox(width: 10),
        _card(
          SymptomSeverity.severe,
          'severity_severe',
          Icons.sentiment_very_dissatisfied_rounded,
          AppColors.error,
        ),
      ],
    );
  }

  Widget _card(
    SymptomSeverity value,
    String labelKey,
    IconData icon,
    Color color,
  ) {
    final isSelected = value == selected;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : AppColors.greyLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 6),
              Text(
                t(labelKey),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
