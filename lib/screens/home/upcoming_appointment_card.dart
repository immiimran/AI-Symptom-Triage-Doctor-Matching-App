import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/glass_card.dart';

/// Glass card for the next appointment: doctor, hospital, date, time, serial.
class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({
    super.key,
    required this.appointment,
    required this.doctor,
    required this.specialtyName,
    this.onTap,
  });

  final AppointmentModel appointment;
  final DoctorModel doctor;
  final String specialtyName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              DoctorAvatar(doctor: doctor, size: 52, radius: 26, onDark: true),
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
                  ],
                ),
              ),
              _SerialBadge(serial: appointment.serialNumber),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.local_hospital_outlined,
                size: 16,
                color: AppColors.onGlassMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  doctor.hospital,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            t('serial'),
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 11),
          ),
          Text(
            '#$serial',
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 18,
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

/// Shown instead of the card when there is no upcoming appointment.
class EmptyAppointmentCard extends StatelessWidget {
  const EmptyAppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        blur: false,
        radius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: 36,
              color: AppColors.sphereRose,
            ),
            const SizedBox(height: 10),
            Text(
              t('no_upcoming'),
              style: const TextStyle(
                color: AppColors.onGlass,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t('no_upcoming_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onGlassMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
