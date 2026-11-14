import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/doctor_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../texts/app_texts.dart';
import 'write_review_sheet.dart';

/// Opens the review sheet for [doctor] and saves what the user writes.
Future<void> writeReviewFlow(BuildContext context, DoctorModel doctor) async {
  final reviews = context.read<ReviewProvider>();
  final auth = context.read<AuthProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final mine = reviews.myReviewFor(doctor.id);

  final draft = await WriteReviewSheet.show(
    context,
    doctorName: doctor.name,
    initialRating: mine?.rating ?? 0,
    initialComment: mine?.comment ?? '',
  );
  if (draft == null) return;

  await reviews.submit(
    doctorId: doctor.id,
    authorName: auth.firstName.isEmpty ? t('anonymous') : auth.firstName,
    rating: draft.rating,
    comment: draft.comment,
  );
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(t('review_thanks'))));
}
