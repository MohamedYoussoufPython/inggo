class DriverModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final String? address;
  final String? vehicle;
  final String? licensePlate;
  final String status;
  final bool isOnline;
  final double rating;
  final int totalRides;
  final String? avatarUrl;
  final String? bankName;
  final String? bankNumber;

  DriverModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.address,
    this.vehicle,
    this.licensePlate,
    this.status = 'pending',
    this.isOnline = false,
    this.rating = 5.0,
    this.totalRides = 0,
    this.avatarUrl,
    this.bankName,
    this.bankNumber,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      vehicle: json['vehicle'] as String?,
      licensePlate: json['license_plate'] as String?,
      status: json['status'] as String? ?? 'pending',
      isOnline: json['is_online'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: json['total_rides'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
      bankName: json['bank_name'] as String?,
      bankNumber: json['bank_number'] as String?,
    );
  }
}
