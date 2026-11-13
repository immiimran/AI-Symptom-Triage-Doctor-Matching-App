import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointment_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/reminder_labels.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_chip.dart';

/// Lets the user choose when to be reminded about an appointment.
/// Options that are already in the past are dimmed.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.appointment,
    required this.doctor,
  });

  final AppointmentModel appointment;
  final DoctorModel doctor;

  List<int?> get _options => <int?>[
    null,
    ...AppConstants.reminderOptions,
    if (AppConstants.demoMode) AppConstants.testReminderMinutes,
  ];

  bool _isAvailable(int? minutes) {
    if (minutes == null || minutes == AppConstants.testReminderMinutes) {
      return true;
    }
    final when = appointment.dateTime.subtract(Duration(minutes: minutes));
    return when.isAfter(DateTime.now());
  }

  String _messageKey(ReminderResult result) {
    switch (result) {
      case ReminderResult.set:
        return 'reminder_set';
      case ReminderResult.off:
        return 'reminder_cancelled';
      case ReminderResult.denied:
        return 'reminder_denied';
      case ReminderResult.tooLate:
        return 'reminder_too_late';
      case ReminderResult.unsupported:
        return 'reminder_unavailable';
    }
  }

  Future<void> _choose(BuildContext context, int? minutes) async {
    final provider = context.read<AppointmentProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await provider.setReminder(
      appointment: appointment,
      doctor: doctor,
      minutesBefore: minutes,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t(_messageKey(result)))));
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.sphereRose,
              ),
              const SizedBox(width: 10),
              Text(
                t('reminder_section'),
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in _options)
                Opacity(
                  opacity: _isAvailable(minutes) ? 1 : 0.35,
                  child: IgnorePointer(
                    ignoring: !_isAvailable(minutes),
                    child: GlassChip(
                      label: reminderLabel(minutes),
                      selected: appointment.reminderMinutes == minutes,
                      onTap: () => _choose(context, minutes),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
