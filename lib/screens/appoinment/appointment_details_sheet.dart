import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../utils/launcher.dart';
import '../../widgets/glass_action_tile.dart';
import '../../widgets/glass_info_row.dart';
import '../../widgets/glass_sheet.dart';
import '../booking/reminder_card.dart';

/// Bottom sheet with everything about one appointment: serial, hospital,
/// time, patient, call/directions and (for upcoming ones) the reminder.
class AppointmentDetailsSheet extends StatelessWidget {
  const AppointmentDetailsSheet({super.key, required this.appointmentId});

  final String appointmentId;

  static Future<void> show(BuildContext context, String appointmentId) {
    return GlassSheet.show<void>(
      context,
      builder: (_) => AppointmentDetailsSheet(appointmentId: appointmentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentProvider>();
    final doctors = context.watch<DoctorProvider>();

    final appointment = appointments.byId(appointmentId);
    final doctor = appointment == null
        ? null
        : doctors.doctorById(appointment.doctorId);

    if (appointment == null || doctor == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          t('doctor_not_found'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.onGlass),
        ),
      );
    }

    final isUpcoming =
        appointment.status == AppointmentStatus.upcoming &&
        appointment.dateTime.isAfter(
          DateTime.now().subtract(const Duration(hours: 1)),
        );
    final arriveBy = appointment.dateTime.subtract(
      const Duration(minutes: AppConstants.arriveEarlyMinutes),
    );
    final patient = appointment.patientAge == null
        ? appointment.patientName
        : '${appointment.patientName}, ${appointment.patientAge}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('appointment_details'),
          style: const TextStyle(
            color: AppColors.onGlass,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    t('serial'),
                    style: const TextStyle(
                      color: AppColors.onGlassMuted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '#${appointment.serialNumber}',
                    style: const TextStyle(
                      color: AppColors.onGlass,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      color: AppColors.onGlass,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    doctors.specialtyName(doctor.specialtyId),
                    style: const TextStyle(color: AppColors.onGlassMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: AppColors.glassBorder, height: 1),
        ),
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
          icon: Icons.calendar_today_outlined,
          label: t('summary_date'),
          value: AppDateUtils.fullDate(appointment.dateTime),
        ),
        GlassInfoRow(
          icon: Icons.access_time_rounded,
          label: t('summary_time'),
          value: AppDateUtils.time(appointment.dateTime),
        ),
        GlassInfoRow(
          icon: Icons.person_outline_rounded,
          label: t('details_patient'),
          value: patient,
        ),
        if (appointment.note.isNotEmpty)
          GlassInfoRow(
            icon: Icons.notes_rounded,
            label: t('details_reason'),
            value: appointment.note,
          ),
        GlassInfoRow(
          icon: Icons.payments_outlined,
          label: t('consultation_fee'),
          value:
              '${AppConstants.currencySymbol}${appointment.fee > 0 ? appointment.fee : doctor.fee}',
          isLast: true,
        ),
        if (isUpcoming) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sphereRose.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.sphereRose.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_walk_rounded,
                  color: AppColors.onGlass,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${t('arrive_by')} ${AppDateUtils.time(arriveBy)}',
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        if (isUpcoming) ...[
          const SizedBox(height: 14),
          ReminderCard(appointment: appointment, doctor: doctor),
        ],
      ],
    );
  }
}
