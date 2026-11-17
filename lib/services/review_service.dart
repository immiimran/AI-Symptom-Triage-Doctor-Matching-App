import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../app/assets.dart';
import '../models/review_model.dart';

/// Loads sample reviews. Firestore replaces this in the Firebase step.
class ReviewService {
  Future<List<ReviewModel>> loadSeedReviews() async {
    final reviews = await _read(AppAssets.reviewsJson);
    final known = reviews.map((r) => r.id).toSet();

    // More reviews live in a second file so they are easy to add.
    try {
      for (final review in await _read(AppAssets.reviewsMoreJson)) {
        if (known.add(review.id)) reviews.add(review);
      }
    } catch (_) {
      // The extra file is optional.
    }
    return reviews;
  }

  Future<List<ReviewModel>> _read(String path) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
