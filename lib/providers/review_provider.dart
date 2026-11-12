import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/doctor_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../services/storage_service.dart';

/// Holds sample reviews and the reviews written by the user.
/// A doctor's shown rating = base rating + the user's own review.
class ReviewProvider extends ChangeNotifier {
  ReviewProvider({ReviewService? service, StorageService? storage})
    : _service = service ?? ReviewService(),
      _storage = storage ?? StorageService();

  final ReviewService _service;
  final StorageService _storage;

  List<ReviewModel> _seed = [];
  List<ReviewModel> _mine = [];

  Future<void> load() async {
    try {
      _seed = await _service.loadSeedReviews();
    } catch (_) {
      _seed = [];
    }

    final raw = await _storage.getMyReviewsJson();
    if (raw != null) {
      try {
        _mine = (jsonDecode(raw) as List<dynamic>)
            .map(
              (e) =>
                  ReviewModel.fromJson(e as Map<String, dynamic>, isMine: true),
            )
            .toList();
      } catch (_) {
        _mine = [];
      }
    }
    notifyListeners();
  }

  /// The user's review first, then the others, newest first.
  List<ReviewModel> reviewsFor(String doctorId) {
    final mine = _mine.where((r) => r.doctorId == doctorId).toList();
    final others = _seed.where((r) => r.doctorId == doctorId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return [...mine, ...others];
  }

  ReviewModel? myReviewFor(String doctorId) {
    for (final review in _mine) {
      if (review.doctorId == doctorId) return review;
    }
    return null;
  }

  double ratingOf(DoctorModel doctor) {
    final mine = myReviewFor(doctor.id);
    if (mine == null) return doctor.rating;
    final total = doctor.rating * doctor.reviewCount + mine.rating;
    return total / (doctor.reviewCount + 1);
  }

  int countOf(DoctorModel doctor) =>
      doctor.reviewCount + (myReviewFor(doctor.id) == null ? 0 : 1);

  /// Saves (or replaces) the user's review for a doctor.
  Future<void> submit({
    required String doctorId,
    required String authorName,
    required int rating,
    required String comment,
  }) async {
    final review = ReviewModel(
      id: 'mine_$doctorId',
      doctorId: doctorId,
      authorName: authorName,
      rating: rating,
      comment: comment.trim(),
      date: DateTime.now(),
      isMine: true,
    );
    _mine = [
      for (final r in _mine)
        if (r.doctorId != doctorId) r,
      review,
    ];
    notifyListeners();
    await _storage.saveMyReviewsJson(
      jsonEncode(_mine.map((r) => r.toJson()).toList()),
    );
  }
}
