/// A patient review for a doctor.
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.doctorId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
    this.isMine = false,
  });

  final String id;
  final String doctorId;
  final String authorName;

  /// 1 to 5 stars.
  final int rating;
  final String comment;
  final DateTime date;

  /// True for reviews written by the current user.
  final bool isMine;

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctor_id': doctorId,
    'author': authorName,
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
  };

  factory ReviewModel.fromJson(
    Map<String, dynamic> json, {
    bool isMine = false,
  }) {
    return ReviewModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      authorName: (json['author'] as String?) ?? '',
      rating: (json['rating'] as num).toInt(),
      comment: (json['comment'] as String?) ?? '',
      date: DateTime.parse(json['date'] as String),
      isMine: isMine,
    );
  }
}
