import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../models/doctor_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';
import 'write_review_sheet.dart';

/// "Reviews" tab: rating summary, write/edit review, and the review list.
class DoctorReviewsTab extends StatelessWidget {
  const DoctorReviewsTab({super.key, required this.doctor});

  final DoctorModel doctor;

  Future<void> _writeReview(BuildContext context) async {
    final provider = context.read<ReviewProvider>();
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final mine = provider.myReviewFor(doctor.id);

    final draft = await WriteReviewSheet.show(
      context,
      doctorName: doctor.name,
      initialRating: mine?.rating ?? 0,
      initialComment: mine?.comment ?? '',
    );
    if (draft == null) return;

    await provider.submit(
      doctorId: doctor.id,
      authorName: auth.firstName.isEmpty ? t('anonymous') : auth.firstName,
      rating: draft.rating,
      comment: draft.comment,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t('review_thanks'))));
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewProvider>();
    final rating = reviews.ratingOf(doctor);
    final count = reviews.countOf(doctor);
    final list = reviews.reviewsFor(doctor.id);
    final hasMine = reviews.myReviewFor(doctor.id) != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.onGlass,
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingStars(rating: rating, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      '$count ${t('reviews')}',
                      style: const TextStyle(color: AppColors.onGlassMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassButton(
          label: hasMine ? t('edit_review') : t('write_review'),
          onPressed: () => _writeReview(context),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t('no_reviews'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onGlassMuted),
            ),
          )
        else
          for (final review in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewCard(review: review),
            ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final initial = review.authorName.isEmpty
        ? '?'
        : String.fromCharCode(review.authorName.runes.first).toUpperCase();

    return GlassCard(
      blur: false,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.onGlass,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (review.isMine) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sphereRose.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t('you'),
                              style: const TextStyle(
                                color: AppColors.onGlass,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      DateFormat('MMM d, y').format(review.date),
                      style: const TextStyle(
                        color: AppColors.onGlassMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: review.rating.toDouble(), size: 15),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(color: AppColors.onGlass, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
