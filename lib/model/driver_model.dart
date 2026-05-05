import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

enum VehicleType { moto }

@freezed
class DriverModel with _$DriverModel {
  const factory DriverModel({
    required String id,
    @Default(VehicleType.moto) VehicleType vehicleType,
    required String plateNumber,
    String? vehicleColor,
    @Default(false) bool isVerified,
    @Default(false) bool isOnline,
    @Default(0) int totalRides,
    @Default(0.0) double totalEarnings,
    @Default(5.0) double rating,
    String? idCardUrl,
    String? licenseUrl,
    String? vehiclePhotoUrl,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
    DateTime? createdAt,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}
