import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../models/doctor_model.dart';
import '../../texts/app_texts.dart';
import '../../utils/doctor_schedule.dart';
import '../../utils/launcher.dart';
import '../../widgets/glass_action_tile.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_info_row.dart';

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
                const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.sphereRose,
                  size: 28,
                ),
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
              GlassInfoRow(
                icon: Icons.local_hospital_outlined,
                label: t('hospital'),
                value: doctor.hospital,
              ),
              GlassInfoRow(
                icon: Icons.place_outlined,
                label: t('address'),
                value: doctor.address,
              ),
              GlassInfoRow(
                icon: Icons.calendar_month_outlined,
                label: t('sits_on'),
                value: doctor.chamberDaysLabel,
              ),
              GlassInfoRow(
                icon: Icons.access_time_rounded,
                label: t('time'),
                value: doctor.chamberTime,
              ),
              GlassInfoRow(
                icon: Icons.payments_outlined,
                label: t('consultation_fee'),
                value: '${AppConstants.currencySymbol}${doctor.fee}',
              ),
              GlassInfoRow(
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
              child: GlassActionTile(
                icon: Icons.call_rounded,
                label: t('call_chamber'),
                onTap: () => openUri(context, phoneUri(doctor.phone)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassActionTile(
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
