import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/symptom_input.dart';
import '../../texts/app_texts.dart';

/// Three glass cards: mild, moderate, severe.
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
    final radius = BorderRadius.circular(18);

    return Expanded(
      child: InkWell(
        borderRadius: radius,
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: isSelected
                ? color.withValues(alpha: 0.26)
                : AppColors.glassFill,
            border: Border.all(
              color: isSelected ? color : AppColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 6),
              Text(
                t(labelKey),
                style: TextStyle(
                  color: AppColors.onGlass,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
