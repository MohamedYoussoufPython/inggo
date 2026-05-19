class FavoriteModel {
  final String id;
  final String userId;
  final String label;
  final String address;
  final double lat;
  final double lng;
  final DateTime? createdAt;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    required this.lat,
    required this.lng,
    this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'label': label,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }

  /// Full JSON including read-only fields (id, timestamps).
  Map<String, dynamic> toJsonFull() {
    final json = toJson();
    json['id'] = id;
    json['created_at'] = createdAt?.toIso8601String();
    return json;
  }

  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? address,
    double? lat,
    double? lng,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
