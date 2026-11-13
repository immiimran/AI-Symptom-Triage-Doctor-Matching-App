import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/time_slot.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../widgets/glass_chip.dart';

/// Period filter (All / Morning / Afternoon / Evening) and the time slots.
/// Each slot shows its time and its serial number.
class TimeSlotPicker extends StatelessWidget {
  const TimeSlotPicker({
    super.key,
    required this.slots,
    required this.selected,
    required this.period,
    required this.onPeriodChanged,
    required this.onSelected,
  });

  static const List<String> _periodOrder = ['morning', 'afternoon', 'evening'];

  /// Slots that have not started yet.
  final List<TimeSlot> slots;
  final TimeSlot? selected;

  /// 'morning', 'afternoon', 'evening' or null for all.
  final String? period;
  final ValueChanged<String?> onPeriodChanged;
  final ValueChanged<TimeSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          t('no_slots'),
          style: const TextStyle(color: AppColors.onGlassMuted),
        ),
      );
    }

    final present = slots.map((s) => s.period).toSet();
    final periods = _periodOrder.where(present.contains).toList();
    final visible = period == null
        ? slots
        : slots.where((s) => s.period == period).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (periods.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GlassChip(
                label: t('period_all'),
                selected: period == null,
                onTap: () => onPeriodChanged(null),
              ),
              for (final p in periods)
                GlassChip(
                  label: t('period_$p'),
                  selected: period == p,
                  onTap: () => onPeriodChanged(p),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final width = (constraints.maxWidth - spacing * 2) / 3;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final slot in visible)
                  SizedBox(
                    width: width,
                    child: _SlotChip(
                      slot: slot,
                      selected: selected?.start == slot.start,
                      onTap: () => onSelected(slot),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          t('slot_booked_legend'),
          style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final TimeSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final taken = slot.isTaken;

    return Opacity(
      opacity: taken ? 0.4 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: taken ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected
                  ? AppColors.onGlass.withValues(alpha: 0.22)
                  : AppColors.glassFill,
              border: Border.all(
                color: selected ? AppColors.onGlass : AppColors.glassBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  AppDateUtils.time(slot.start),
                  style: TextStyle(
                    color: AppColors.onGlass,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    decoration: taken
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: AppColors.onGlass,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${slot.serial}',
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
