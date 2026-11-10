import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/common_symptom.dart';

/// Quick-pick symptom chips. Tapping toggles the symptom.
class CommonSymptomChips extends StatelessWidget {
  const CommonSymptomChips({
    super.key,
    required this.symptoms,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<CommonSymptom> symptoms;
  final Set<String> selectedIds;
  final ValueChanged<CommonSymptom> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: symptoms.map((symptom) {
        final isSelected = selectedIds.contains(symptom.id);
        return FilterChip(
          label: Text(symptom.label),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => onToggle(symptom),
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary.withValues(alpha: 0.12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.greyLight,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}
