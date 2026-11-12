import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/review_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/favorite_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_doctor_card.dart';
import '../../widgets/glass_scaffold.dart';

/// Favorites tab: doctors the user saved with the heart button.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final reviews = context.watch<ReviewProvider>();
    final favorites = doctors.favoriteDoctors;

    return GlassScaffold(
      title: t('favorites_title'),
      showBack: false,
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 44,
                        color: AppColors.sphereRose,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('no_favorites'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.onGlass,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t('no_favorites_hint'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.onGlassMuted),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doctor = favorites[index];
                return GlassDoctorCard(
                  doctor: doctor,
                  specialtyName: doctors.specialtyName(doctor.specialtyId),
                  rating: reviews.ratingOf(doctor),
                  reviewCount: reviews.countOf(doctor),
                  isFavorite: true,
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.doctorDetails, arguments: doctor.id),
                  onFavoriteTap: () =>
                      toggleFavoriteWithMessage(context, doctors, doctor.id),
                );
              },
            ),
    );
  }
}
