import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/date_utils.dart';
import '../../utils/launcher.dart';
import '../../widgets/glass_action_tile.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_info_row.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_section_title.dart';
import 'reminder_card.dart';

/// Shown after booking: serial number, hospital, time, reminder and tips.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final appointments = context.watch<AppointmentProvider>();
    final doctors = context.watch<DoctorProvider>();

    final id = ModalRoute.of(context)?.settings.arguments;
    final appointment = id is String ? appointments.byId(id) : null;
    final doctor = appointment == null
        ? null
        : doctors.doctorById(appointment.doctorId);

    // Back button goes to Home, not back to the booking form.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goHome(context);
      },
      child: GlassScaffold(
        title: t('booking_confirmed'),
        showBack: false,
        body: (appointment == null || doctor == null)
            ? Center(
                child: Text(
                  t('doctor_not_found'),
                  style: const TextStyle(color: AppColors.onGlass),
                ),
              )
            : _Content(
                appointment: appointment,
                doctor: doctor,
                specialtyName: doctors.specialtyName(doctor.specialtyId),
              ),
        bottom: GlassButton(
          label: t('back_to_home'),
          onPressed: () => _goHome(context),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.appointment,
    required this.doctor,
    required this.specialtyName,
  });

  final AppointmentModel appointment;
  final DoctorModel doctor;
  final String specialtyName;

  @override
  Widget build(BuildContext context) {
    final arriveBy = appointment.dateTime.subtract(
      const Duration(minutes: AppConstants.arriveEarlyMinutes),
    );
    final tips = <String>[
      'tip_spec_${doctor.specialtyId}',
      'tip_arrive_early',
      'tip_bring_documents',
      'tip_keep_fee',
      'tip_call_late',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t('booking_confirmed_hint'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.onGlassMuted),
        ),
        const SizedBox(height: 18),
        GlassCard(
          radius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                t('your_serial'),
                style: const TextStyle(
                  color: AppColors.onGlassMuted,
                  fontSize: 13,
                ),
              ),
              Text(
                '#${appointment.serialNumber}',
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                specialtyName,
                style: const TextStyle(color: AppColors.onGlassMuted),
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
                icon: Icons.payments_outlined,
                label: t('consultation_fee'),
                value: '${AppConstants.currencySymbol}${doctor.fee}',
                isLast: true,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
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
        const SizedBox(height: 14),
        ReminderCard(appointment: appointment, doctor: doctor),
        const SizedBox(height: 14),
        GlassCard(
          blur: false,
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassSectionTitle(t('tips_title')),
              const SizedBox(height: 12),
              for (final key in tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: AppColors.sphereRose,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t(key),
                          style: const TextStyle(
                            color: AppColors.onGlass,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
