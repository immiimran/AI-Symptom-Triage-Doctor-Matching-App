import 'package:flutter/material.dart';

import '../../models/common_symptom.dart';
import '../../widgets/glass_chip.dart';

/// Quick-pick symptom chips (glass). Tapping toggles the symptom.
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
      children: [
        for (final symptom in symptoms)
          GlassChip(
            label: symptom.label,
            icon: selectedIds.contains(symptom.id) ? Icons.check_rounded : null,
            selected: selectedIds.contains(symptom.id),
            onTap: () => onToggle(symptom),
          ),
      ],
    );
  }
}
