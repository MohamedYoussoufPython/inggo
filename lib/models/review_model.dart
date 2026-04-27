class ReviewModel {
  final int id;
  final int? rideId;
  final String reviewerId;
  final String reviewedId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String? reviewerName;

  ReviewModel({
    required this.id,
    this.rideId,
    required this.reviewerId,
    required this.reviewedId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      rideId: json['ride_id'] as int?,
      reviewerId: json['reviewer_id'] as String,
      reviewedId: json['reviewed_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewerName: json['reviewer_name'] as String?,
    );
  }
}
