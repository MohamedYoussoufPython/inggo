class VehicleType { // ignore: unused_element
  final String value;
  const VehicleType._(this.value);
  static const moto = VehicleType._('moto');
}

class DriverModel {
  final String id;
  final String vehicleType;
  final String plateNumber;
  final String? vehicleColor;
  final bool isVerified;
  final bool isOnline;
  final int totalRides;
  final double totalEarnings;
  final double rating;
  final String? idCardUrl;
  final String? licenseUrl;
  final String? vehiclePhotoUrl;
  final double? currentLat;
  final double? currentLng;
  final DateTime? lastLocationUpdate;
  final DateTime? createdAt;

  const DriverModel({
    required this.id,
    this.vehicleType = 'moto',
    required this.plateNumber,
    this.vehicleColor,
    this.isVerified = false,
    this.isOnline = false,
    this.totalRides = 0,
    this.totalEarnings = 0.0,
    this.rating = 5.0,
    this.idCardUrl,
    this.licenseUrl,
    this.vehiclePhotoUrl,
    this.currentLat,
    this.currentLng,
    this.lastLocationUpdate,
    this.createdAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? 'moto',
      plateNumber: json['plate_number'] as String? ?? '',
      vehicleColor: json['vehicle_color'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? false,
      totalRides: json['total_rides'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      idCardUrl: json['id_card_url'] as String?,
      licenseUrl: json['license_url'] as String?,
      vehiclePhotoUrl: json['vehicle_photo_url'] as String?,
      currentLat: (json['current_lat'] as num?)?.toDouble(),
      currentLng: (json['current_lng'] as num?)?.toDouble(),
      lastLocationUpdate: json['last_location_update'] != null
          ? DateTime.parse(json['last_location_update'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'vehicle_color': vehicleColor,
      'is_verified': isVerified,
      'is_online': isOnline,
      'total_rides': totalRides,
      'total_earnings': totalEarnings,
      'rating': rating,
      'id_card_url': idCardUrl,
      'license_url': licenseUrl,
      'vehicle_photo_url': vehiclePhotoUrl,
      'current_lat': currentLat,
      'current_lng': currentLng,
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  DriverModel copyWith({
    String? id,
    String? vehicleType,
    String? plateNumber,
    String? vehicleColor,
    bool? isVerified,
    bool? isOnline,
    int? totalRides,
    double? totalEarnings,
    double? rating,
    String? idCardUrl,
    String? licenseUrl,
    String? vehiclePhotoUrl,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
    DateTime? createdAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      totalRides: totalRides ?? this.totalRides,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      rating: rating ?? this.rating,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
