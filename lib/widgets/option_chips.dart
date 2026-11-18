import 'package:flutter/material.dart';

import 'glass_chip.dart';

/// One option for [OptionChips].
class OptionChipItem<T> {
  const OptionChipItem(this.value, this.label);

  final T value;
  final String label;
}

/// Single-choice glass chips (age group, duration, ...).
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
      children: [
        for (final option in options)
          GlassChip(
            label: option.label,
            selected: option.value == selected,
            onTap: () => onSelected(option.value),
          ),
      ],
    );
  }
}
