import 'package:flutter/material.dart';

import '../app/color.dart';

/// One option for [OptionChips].
class OptionChipItem<T> {
  const OptionChipItem(this.value, this.label);

  final T value;
  final String label;
}

/// Single-choice chips (age group, duration, ...).
class OptionChips<T> extends StatelessWidget {
  const OptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<OptionChipItem<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option.value == selected;
        return ChoiceChip(
          label: Text(option.label),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => onSelected(option.value),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.greyLight,
          ),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}
