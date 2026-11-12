/// What the user entered in the "write a review" sheet.
class ReviewDraft {
  const ReviewDraft({required this.rating, required this.comment});

  final int rating;
  final String comment;
}
