import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/appointment_model.dart';
import '../../models/appointment_tab.dart';
import '../../models/doctor_model.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../utils/reminder_labels.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/glass_card.dart';

/// One appointment in the list. The buttons at the bottom depend on the tab.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.doctor,
    required this.specialtyName,
    required this.tab,
    required this.onTap,
    this.onCancel,
    this.onReschedule,
    this.onBookAgain,
    this.onRate,
  });

  final AppointmentModel appointment;
  final DoctorModel doctor;
  final String specialtyName;
  final AppointmentTab tab;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onBookAgain;
  final VoidCallback? onRate;

  List<Widget> _actions() {
    switch (tab) {
      case AppointmentTab.upcoming:
        return [
          _PillButton(
            icon: Icons.event_repeat_rounded,
            label: t('reschedule'),
            onTap: onReschedule,
          ),
          _PillButton(
            icon: Icons.close_rounded,
            label: t('btn_cancel'),
            color: AppColors.onGlassError,
            onTap: onCancel,
          ),
        ];
      case AppointmentTab.past:
        return [
          _PillButton(
            icon: Icons.star_rounded,
            label: t('rate_doctor'),
            onTap: onRate,
          ),
          _PillButton(
            icon: Icons.replay_rounded,
            label: t('book_again'),
            onTap: onBookAgain,
          ),
        ];
      case AppointmentTab.cancelled:
        return [
          _PillButton(
            icon: Icons.replay_rounded,
            label: t('book_again'),
            onTap: onBookAgain,
          ),
        ];
    }
  }

  (String, Color) _status() {
    switch (tab) {
      case AppointmentTab.upcoming:
        return (t('status_upcoming'), AppColors.sphereRose);
      case AppointmentTab.past:
        return (t('status_completed'), AppColors.success);
      case AppointmentTab.cancelled:
        return (t('status_cancelled'), AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = _actions();
    final (statusLabel, statusColor) = _status();
    final reminder = appointment.reminderMinutes;

    return GlassCard(
      blur: false,
      radius: 22,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorAvatar(doctor: doctor, size: 58, radius: 16, onDark: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.onGlass,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      specialtyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.onGlassMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          size: 14,
                          color: AppColors.onGlassMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.hospital,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.onGlassMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SerialBadge(serial: appointment.serialNumber),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  text: AppDateUtils.fullDate(appointment.dateTime),
                ),
                _InfoItem(
                  icon: Icons.access_time_rounded,
                  text: AppDateUtils.time(appointment.dateTime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(text: statusLabel, color: statusColor),
                if (reminder != null && tab == AppointmentTab.upcoming)
                  _Pill(
                    icon: Icons.notifications_active_outlined,
                    text: reminderLabel(reminder),
                    color: AppColors.sphereRose,
                  ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: actions[i]),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SerialBadge extends StatelessWidget {
  const _SerialBadge({required this.serial});

  final int serial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            t('serial'),
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 10),
          ),
          Text(
            '#$serial',
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onGlassMuted),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: AppColors.onGlass, fontSize: 13),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.onGlass),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.onGlass,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
