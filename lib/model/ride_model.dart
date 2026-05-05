import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

enum RideStatus {
  pending,
  searching,
  accepted,
  inProgress,
  completed,
  cancelled,
}

enum PaymentMethod {
  cash,
  waafi,
  dmoney,
  cacpay,
  sabapay,
  dahabplus,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
}

@freezed
class RideModel with _$RideModel {
  const factory RideModel({
    required String id,
    required String clientId,
    String? driverId,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
    @Default(250) double price,
    @Default(125) double commission,
    @Default(0.0) double tipAmount,
    @Default(PaymentMethod.cash) PaymentMethod paymentMethod,
    @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    @Default(RideStatus.pending) RideStatus status,
    String? cancelReason,
    double? rating,
    String? review,
    double? distance,
    int? estimatedDuration,
    int? actualDuration,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) = _RideModel;

  factory RideModel.fromJson(Map<String, dynamic> json) =>
      _$RideModelFromJson(json);
}
