import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../models/doctor_model.dart';
import '../../texts/app_texts.dart';
import '../../utils/doctor_schedule.dart';
import '../../utils/launcher.dart';
import '../../widgets/glass_card.dart';

/// "Schedule" tab: where and when the doctor sits, fee, call and directions.
class DoctorScheduleTab extends StatelessWidget {
  const DoctorScheduleTab({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final next = DoctorSchedule.nextAvailable(doctor);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (next != null)
          GlassCard(
            radius: 20,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded,
                    color: AppColors.sphereRose, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('next_available'),
                        style: const TextStyle(
                          color: AppColors.onGlassMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${DoctorSchedule.label(next)} · ${doctor.chamberTime}',
                        style: const TextStyle(
                          color: AppColors.onGlass,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        GlassCard(
          blur: false,
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.local_hospital_outlined,
                label: t('hospital'),
                value: doctor.hospital,
              ),
              _InfoRow(
                icon: Icons.place_outlined,
                label: t('address'),
                value: doctor.address,
              ),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: t('sits_on'),
                value: doctor.chamberDaysLabel,
              ),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: t('time'),
                value: doctor.chamberTime,
              ),
              _InfoRow(
                icon: Icons.payments_outlined,
                label: t('consultation_fee'),
                value: '${AppConstants.currencySymbol}${doctor.fee}',
              ),
              _InfoRow(
                icon: Icons.call_outlined,
                label: t('phone'),
                value: doctor.phone,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.call_rounded,
                label: t('call_chamber'),
                onTap: () => openUri(context, phoneUri(doctor.phone)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.directions_rounded,
                label: t('get_directions'),
                onTap: () => openUri(
                  context,
                  mapsUri('${doctor.hospitalEn} ${doctor.addressEn}'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.onGlassMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.onGlass),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onGlass,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}