import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../models/review_draft.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_sheet.dart';
import '../../widgets/rating_stars.dart';

/// Bottom sheet to rate a doctor (1-5 stars) and write a short review.
class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({
    super.key,
    required this.doctorName,
    this.initialRating = 0,
    this.initialComment = '',
  });

  final String doctorName;
  final int initialRating;
  final String initialComment;

  static Future<ReviewDraft?> show(
    BuildContext context, {
    required String doctorName,
    int initialRating = 0,
    String initialComment = '',
  }) {
    return GlassSheet.show<ReviewDraft>(
      context,
      builder: (_) => WriteReviewSheet(
        doctorName: doctorName,
        initialRating: initialRating,
        initialComment: initialComment,
      ),
    );
  }

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  late int _rating = widget.initialRating;
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialComment,
  );
  bool _showError = false;

  void _submit() {
    if (_rating == 0) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context)
        .pop(ReviewDraft(rating: _rating, comment: _controller.text.trim()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.glassBorder),
    );

    return Column(
      children: [
        Text(
          t('write_review'),
          style: const TextStyle(
            color: AppColors.onGlass,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.doctorName,
          style: const TextStyle(color: AppColors.onGlassMuted),
        ),
        const SizedBox(height: 20),
        Text(
          t('your_rating'),
          style: const TextStyle(color: AppColors.onGlass),
        ),
        const SizedBox(height: 8),
        StarRatingInput(
          value: _rating,
          onChanged: (value) => setState(() {
            _rating = value;
            _showError = false;
          }),
        ),
        if (_showError) ...[
          const SizedBox(height: 8),
          Text(
            t('review_rating_required'),
            style: const TextStyle(color: AppColors.onGlassError),
          ),
        ],
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 5,
          style: const TextStyle(color: AppColors.onGlass),
          cursorColor: AppColors.onGlass,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassFill,
            hintText: t('your_review_hint'),
            hintStyle: const TextStyle(color: AppColors.onGlassMuted),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(
                color: AppColors.onGlass,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GlassButton(label: t('submit_review'), onPressed: _submit),
      ],
    );
  }
}
