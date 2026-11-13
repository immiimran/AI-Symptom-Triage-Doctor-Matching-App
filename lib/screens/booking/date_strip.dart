import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../models/doctor_model.dart';
import '../../texts/app_texts.dart';
import '../../utils/doctor_schedule.dart';

/// Horizontal list of the next days. Days when the doctor does not sit
/// are dimmed and cannot be selected.
class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.doctor,
    required this.selected,
    required this.onSelected,
  });

  final DoctorModel doctor;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.bookingDaysAhead,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = DateTime(now.year, now.month, now.day + index);
          final isSelected =
              selected != null &&
              selected!.year == date.year &&
              selected!.month == date.month &&
              selected!.day == date.day;
          return _DateChip(
            date: date,
            isToday: index == 0,
            enabled: DoctorSchedule.sitsOn(doctor, date),
            selected: isSelected,
            onTap: () => onSelected(date),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isToday,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 62,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected
                  ? AppColors.onGlass.withValues(alpha: 0.22)
                  : AppColors.glassFill,
              border: Border.all(
                color: selected ? AppColors.onGlass : AppColors.glassBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t('day_${DoctorSchedule.dayCode(date)}'),
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isToday ? t('today') : '',
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 10,
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
