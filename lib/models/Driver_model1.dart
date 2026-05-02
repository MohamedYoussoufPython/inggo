class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String vehicle;
  final String plate;
  final String status;
  final DateTime? createdAt;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.vehicle,
    required this.plate,
    required this.status,
    this.createdAt,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      id: map['id']?.toString() ?? '',
      name: map['full_name'] ?? map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
      vehicle: map['vehicle'] ?? map['vehicle_model'] ?? '',
      plate: map['plate'] ?? map['license_plate'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'vehicle': vehicle,
      'plate': plate,
      'status': status,
    };
  }
}
