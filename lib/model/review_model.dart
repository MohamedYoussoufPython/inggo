class ReviewModel {
  final String id;
  final String rideId;
  final String fromUserId;
  final String toUserId;
  final double rating;
  final String? comment;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.rideId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      rideId: json['ride_id'] as String? ?? '',
      fromUserId: json['from_user_id'] as String? ?? '',
      toUserId: json['to_user_id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
