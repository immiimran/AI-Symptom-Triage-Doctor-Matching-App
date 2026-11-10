import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/specialty_chip.dart';
import 'home_header.dart';
import 'home_search_bar.dart';
import 'symptom_check_card.dart';
import 'upcoming_appointment_card.dart';

/// Home tab: greeting, search, symptom card, specialties,
/// upcoming appointment and popular doctors.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSymptoms(BuildContext context, {bool voice = false}) {
    Navigator.of(context).pushNamed(AppRoutes.symptom, arguments: voice);
  }

  void _openDoctors(BuildContext context, {String? specialtyId}) {
    Navigator.of(context).pushNamed(AppRoutes.doctors, arguments: specialtyId);
  }

  void _openDoctor(BuildContext context, DoctorModel doctor) {
    Navigator.of(context)
        .pushNamed(AppRoutes.doctorDetails, arguments: doctor.id);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final appointments = context.watch<AppointmentProvider>();

    final upcoming = appointments.upcoming;
    final next = upcoming.isEmpty ? null : upcoming.first;
    final nextDoctor = next == null ? null : doctors.doctorById(next.doctorId);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const HomeHeader(),
          const SizedBox(height: 20),
          HomeSearchBar(
            onTap: () => _openDoctors(context),
            onFilterTap: () => _openDoctors(context),
          ),
          const SizedBox(height: 20),
          SymptomCheckCard(
            onTap: () => _openSymptoms(context),
            onMicTap: () => _openSymptoms(context, voice: true),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: t('specialties'),
            actionLabel: t('see_all'),
            onAction: () => _openDoctors(context),
          ),
          const SizedBox(height: 14),
          _buildSpecialties(context, doctors),
          const SizedBox(height: 24),
          SectionHeader(title: t('upcoming_schedule'), count: upcoming.length),
          const SizedBox(height: 14),
          if (next != null && nextDoctor != null)
            UpcomingAppointmentCard(
              appointment: next,
              doctor: nextDoctor,
              specialtyName: doctors.specialtyName(nextDoctor.specialtyId),
              onTap: () => _openDoctor(context, nextDoctor),
            )
          else
            const EmptyAppointmentCard(),
          const SizedBox(height: 24),
          SectionHeader(
            title: t('popular_doctors'),
            actionLabel: t('see_all'),
            onAction: () => _openDoctors(context),
          ),
          const SizedBox(height: 14),
          ..._buildPopularDoctors(context, doctors),
        ],
      ),
    );
  }

  Widget _buildSpecialties(BuildContext context, DoctorProvider doctors) {
    if (doctors.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (doctors.hasError) {
      return Text(t('load_error'));
    }
    final items = doctors.specialties;
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final specialty = items[index];
          return SpecialtyChip(
            specialty: specialty,
            onTap: () => _openDoctors(context, specialtyId: specialty.id),
          );
        },
      ),
    );
  }

  List<Widget> _buildPopularDoctors(
    BuildContext context,
    DoctorProvider doctors,
  ) {
    if (doctors.isLoading) {
      return const [Center(child: CircularProgressIndicator())];
    }
    final popular = doctors.popularDoctors;
    if (popular.isEmpty) {
      return [
        Text(
          t('no_doctors'),
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ];
    }
    return [
      for (final doctor in popular)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DoctorCard(
            doctor: doctor,
            specialtyName: doctors.specialtyName(doctor.specialtyId),
            isFavorite: doctors.isFavorite(doctor.id),
            onTap: () => _openDoctor(context, doctor),
            onFavoriteTap: () => doctors.toggleFavorite(doctor.id),
          ),
        ),
    ];
  }
}
