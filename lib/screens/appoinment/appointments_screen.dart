import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/appointment_model.dart';
import '../../models/appointment_tab.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_confirm_sheet.dart';
import '../../widgets/glass_scaffold.dart';
import '../doctors/review_flow.dart';
import 'appointment_card.dart';
import 'appointment_details_sheet.dart';

/// Appointments tab: Upcoming, Past and Cancelled lists.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  Future<void> _cancel(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final provider = context.read<AppointmentProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmSheet(
      context,
      title: t('cancel_confirm_title'),
      message: t('cancel_confirm_message'),
      confirmLabel: t('cancel_appointment'),
      cancelLabel: t('keep_it'),
      destructive: true,
      icon: Icons.event_busy_rounded,
    );
    if (!confirmed) return;

    await provider.cancel(appointment.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t('appointment_cancelled'))));
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final appointments = context.watch<AppointmentProvider>();
    final doctors = context.watch<DoctorProvider>();

    final upcoming = appointments.upcoming;
    final past = appointments.past;
    final cancelled = appointments.cancelled;

    Widget list(AppointmentTab tab, List<AppointmentModel> items) {
      return _AppointmentList(
        tab: tab,
        items: items,
        doctors: doctors,
        onOpen: (a) => AppointmentDetailsSheet.show(context, a.id),
        onCancel: (a) => _cancel(context, a),
        onReschedule: (a) =>
            Navigator.of(context)
                .pushNamed(AppRoutes.reschedule, arguments: a.id),
        onBookAgain: (a) =>
            Navigator.of(context)
                .pushNamed(AppRoutes.booking, arguments: a.doctorId),
        onRate: (a) {
          final doctor = doctors.doctorById(a.doctorId);
          if (doctor != null) writeReviewFlow(context, doctor);
        },
      );
    }

    return DefaultTabController(
      length: 3,
      child: GlassScaffold(
        title: t('nav_appointments'),
        showBack: false,
        body: Column(
          children: [
            TabBar(
              labelColor: AppColors.onGlass,
              unselectedLabelColor: AppColors.onGlassMuted,
              indicatorColor: AppColors.onGlass,
              dividerColor: AppColors.glassBorder,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: '${t('tab_upcoming')} (${upcoming.length})'),
                Tab(text: '${t('tab_past')} (${past.length})'),
                Tab(text: '${t('tab_cancelled')} (${cancelled.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  list(AppointmentTab.upcoming, upcoming),
                  list(AppointmentTab.past, past),
                  list(AppointmentTab.cancelled, cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.tab,
    required this.items,
    required this.doctors,
    required this.onOpen,
    required this.onCancel,
    required this.onReschedule,
    required this.onBookAgain,
    required this.onRate,
  });

  final AppointmentTab tab;
  final List<AppointmentModel> items;
  final DoctorProvider doctors;
  final ValueChanged<AppointmentModel> onOpen;
  final ValueChanged<AppointmentModel> onCancel;
  final ValueChanged<AppointmentModel> onReschedule;
  final ValueChanged<AppointmentModel> onBookAgain;
  final ValueChanged<AppointmentModel> onRate;

  @override
  Widget build(BuildContext context) {
    final entries = <(AppointmentModel, DoctorModel)>[];
    for (final appointment in items) {
      final doctor = doctors.doctorById(appointment.doctorId);
      if (doctor != null) entries.add((appointment, doctor));
    }

    if (entries.isEmpty) return _EmptyState(tab: tab);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final (appointment, doctor) = entries[index];
        return AppointmentCard(
          appointment: appointment,
          doctor: doctor,
          specialtyName: doctors.specialtyName(doctor.specialtyId),
          tab: tab,
          onTap: () => onOpen(appointment),
          onCancel: () => onCancel(appointment),
          onReschedule: () => onReschedule(appointment),
          onBookAgain: () => onBookAgain(appointment),
          onRate: () => onRate(appointment),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});

  final AppointmentTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_note_outlined,
                size: 44,
                color: AppColors.sphereRose,
              ),
              const SizedBox(height: 12),
              Text(
                t('empty_${tab.name}'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('empty_${tab.name}_hint'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onGlassMuted),
              ),
              if (tab == AppointmentTab.upcoming) ...[
                const SizedBox(height: 18),
                GlassButton(
                  label: t('find_doctors'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.doctors),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
