import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/review_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/favorite_helper.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/glass_background.dart';
import '../../widgets/glass_doctor_card.dart';
import '../../widgets/glass_section_header.dart';
import '../../widgets/glass_specialty_chip.dart';
import 'home_header.dart';
import 'home_search_bar.dart';
import 'symptom_check_card.dart';
import 'upcoming_appointment_card.dart';

/// Home tab (glass design): header, search, symptom card, specialties,
/// upcoming appointment and popular doctors.
/// [onSwitchTab] switches the bottom navigation (1 = Appointments,
/// 4 = Profile).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSwitchTab});

  final ValueChanged<int> onSwitchTab;

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

  /// Opens the notification list. It may ask to switch to another tab.
  Future<void> _openNotifications(BuildContext context) async {
    final tab = await Navigator.of(context)
        .pushNamed<int>(AppRoutes.notifications);
    if (tab != null) onSwitchTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final reviews = context.watch<ReviewProvider>();
    final appointments = context.watch<AppointmentProvider>();

    final upcoming = appointments.upcoming;
    final next = upcoming.isEmpty ? null : upcoming.first;
    final nextDoctor = next == null ? null : doctors.doctorById(next.doctorId);

    return GlassBackground(
      showSilverSphere: false,
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            FadeSlideIn(
              child: HomeHeader(
                onBellTap: () => _openNotifications(context),
                onAvatarTap: () => onSwitchTab(4),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delay: const Duration(milliseconds: 60),
              child: HomeSearchBar(
                onTap: () => _openDoctors(context),
                onFilterTap: () => _openDoctors(context),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: SymptomCheckCard(
                onTap: () => _openSymptoms(context),
                onMicTap: () => _openSymptoms(context, voice: true),
              ),
            ),
            const SizedBox(height: 26),
            FadeSlideIn(
              delay: const Duration(milliseconds: 180),
              child: GlassSectionHeader(
                title: t('specialties'),
                actionLabel: t('see_all'),
                onAction: () => _openDoctors(context),
              ),
            ),
            const SizedBox(height: 14),
            FadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: _buildSpecialties(context, doctors),
            ),
            const SizedBox(height: 26),
            FadeSlideIn(
              delay: const Duration(milliseconds: 260),
              child: GlassSectionHeader(
                title: t('upcoming_schedule'),
                count: upcoming.length,
              ),
            ),
            const SizedBox(height: 14),
            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: (next != null && nextDoctor != null)
                  ? UpcomingAppointmentCard(
                      appointment: next,
                      doctor: nextDoctor,
                      specialtyName: doctors.specialtyName(
                        nextDoctor.specialtyId,
                      ),
                      onTap: () => onSwitchTab(1),
                    )
                  : const EmptyAppointmentCard(),
            ),
            const SizedBox(height: 26),
            FadeSlideIn(
              delay: const Duration(milliseconds: 340),
              child: GlassSectionHeader(
                title: t('popular_doctors'),
                actionLabel: t('see_all'),
                onAction: () => _openDoctors(context),
              ),
            ),
            const SizedBox(height: 14),
            ..._buildPopularDoctors(context, doctors, reviews),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialties(BuildContext context, DoctorProvider doctors) {
    if (doctors.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.onGlass),
        ),
      );
    }
    if (doctors.hasError) {
      return Text(
        t('load_error'),
        style: const TextStyle(color: AppColors.onGlassError),
      );
    }
    final items = doctors.specialties;
    return SizedBox(
      height: 112,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final specialty = items[index];
          return GlassSpecialtyChip(
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
    ReviewProvider reviews,
  ) {
    if (doctors.isLoading) {
      return const [
        Center(child: CircularProgressIndicator(color: AppColors.onGlass)),
      ];
    }
    final popular = doctors.popularDoctors;
    if (popular.isEmpty) {
      return [
        Text(
          t('no_doctors'),
          style: const TextStyle(color: AppColors.onGlassMuted),
        ),
      ];
    }
    return [
      for (var i = 0; i < popular.length; i++)
        FadeSlideIn(
          delay: Duration(milliseconds: 380 + i * 50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassDoctorCard(
              doctor: popular[i],
              specialtyName: doctors.specialtyName(popular[i].specialtyId),
              rating: reviews.ratingOf(popular[i]),
              reviewCount: reviews.countOf(popular[i]),
              isFavorite: doctors.isFavorite(popular[i].id),
              onTap: () => _openDoctor(context, popular[i]),
              onFavoriteTap: () =>
                  toggleFavoriteWithMessage(context, doctors, popular[i].id),
            ),
          ),
        ),
    ];
  }
}
