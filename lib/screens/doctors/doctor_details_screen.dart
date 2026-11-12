import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/review_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/favorite_helper.dart';
import '../../utils/launcher.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/rating_stars.dart';
import 'doctor_about_tab.dart';
import 'doctor_reviews_tab.dart';
import 'doctor_schedule_tab.dart';

/// Doctor profile: photo, name, degrees, stats and three tabs
/// (Schedule, About, Reviews), with Call and Book Now at the bottom.
class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final reviews = context.watch<ReviewProvider>();

    final args = ModalRoute.of(context)?.settings.arguments;
    final doctor = args is String ? doctors.doctorById(args) : null;

    if (doctor == null) {
      return GlassScaffold(
        title: t('doctor_profile'),
        body: Center(
          child: Text(
            t('doctor_not_found'),
            style: const TextStyle(color: AppColors.onGlass),
          ),
        ),
      );
    }

    final rating = reviews.ratingOf(doctor);
    final count = reviews.countOf(doctor);
    final isFavorite = doctors.isFavorite(doctor.id);

    return DefaultTabController(
      length: 3,
      child: GlassScaffold(
        title: t('doctor_profile'),
        actions: [
          GlassIconButton(
            icon: isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: isFavorite ? AppColors.sphereRose : AppColors.onGlass,
            onTap: () => toggleFavoriteWithMessage(context, doctors, doctor.id),
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Header(
                doctor: doctor,
                specialtyName: doctors.specialtyName(doctor.specialtyId),
                rating: rating,
                count: count,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Stats(doctor: doctor, rating: rating),
            ),
            const SizedBox(height: 8),
            TabBar(
              labelColor: AppColors.onGlass,
              unselectedLabelColor: AppColors.onGlassMuted,
              indicatorColor: AppColors.onGlass,
              dividerColor: AppColors.glassBorder,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: t('tab_schedule')),
                Tab(text: t('tab_about')),
                Tab(text: t('tab_reviews')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  DoctorScheduleTab(doctor: doctor),
                  DoctorAboutTab(doctor: doctor, doctors: doctors),
                  DoctorReviewsTab(doctor: doctor),
                ],
              ),
            ),
          ],
        ),
        bottom: Row(
          children: [
            GlassIconButton(
              icon: Icons.call_rounded,
              onTap: () => openUri(context, phoneUri(doctor.phone)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                label: t('book_now'),
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamed(AppRoutes.booking, arguments: doctor.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.doctor,
    required this.specialtyName,
    required this.rating,
    required this.count,
  });

  final DoctorModel doctor;
  final String specialtyName;
  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          DoctorAvatar(
            doctor: doctor,
            size: 96,
            radius: 22,
            showStatusDot: doctor.isAvailableToday,
            onDark: true,
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
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.degrees,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sphereRose.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    specialtyName,
                    style: const TextStyle(
                      color: AppColors.onGlass,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingStars(rating: rating, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${rating.toStringAsFixed(1)} ($count)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onGlass,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.doctor, required this.rating});

  final DoctorModel doctor;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _Stat(
            value: '${doctor.experienceYears}',
            label: t('years_experience'),
          ),
          const _Divider(),
          _Stat(value: '${doctor.patientCount}', label: t('patients')),
          const _Divider(),
          _Stat(value: rating.toStringAsFixed(1), label: t('rating')),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onGlass,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onGlassMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.glassBorder);
  }
}
