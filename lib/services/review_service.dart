import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../app/assets.dart';
import '../models/review_model.dart';

/// Loads sample reviews. Firestore replaces this in the Firebase step.
class ReviewService {
  Future<List<ReviewModel>> loadSeedReviews() async {
    final raw = await rootBundle.loadString(AppAssets.reviewsJson);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
