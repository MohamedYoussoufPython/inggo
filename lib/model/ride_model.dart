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

class RideModel {
  final String id;
  final String clientId;
  final String? driverId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final double price;
  final double commission;
  final double tipAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final RideStatus status;
  final String? cancelReason;
  final double? rating;
  final String? review;
  final double? distance;
  final int? estimatedDuration;
  final int? actualDuration;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const RideModel({
    required this.id,
    required this.clientId,
    this.driverId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    this.price = 250,
    this.commission = 125,
    this.tipAmount = 0.0,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    this.status = RideStatus.pending,
    this.cancelReason,
    this.rating,
    this.review,
    this.distance,
    this.estimatedDuration,
    this.actualDuration,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
      driverId: json['driver_id'] as String?,
      pickupAddress: json['pickup_address'] as String? ?? '',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0.0,
      pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0.0,
      dropoffAddress: json['dropoff_address'] as String? ?? '',
      dropoffLat: (json['dropoff_lat'] as num?)?.toDouble() ?? 0.0,
      dropoffLng: (json['dropoff_lng'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 250,
      commission: (json['commission'] as num?)?.toDouble() ?? 125,
      tipAmount: (json['tip_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: _parsePaymentMethod(json['payment_method'] as String?),
      paymentStatus: _parsePaymentStatus(json['payment_status'] as String?),
      status: _parseRideStatus(json['status'] as String?),
      cancelReason: json['cancel_reason'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      estimatedDuration: json['estimated_duration'] as int?,
      actualDuration: json['actual_duration'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  static RideStatus _parseRideStatus(String? status) {
    switch (status) {
      case 'searching':
        return RideStatus.searching;
      case 'accepted':
        return RideStatus.accepted;
      case 'in_progress':
        return RideStatus.inProgress;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.pending;
    }
  }

  static PaymentMethod _parsePaymentMethod(String? method) {
    switch (method) {
      case 'waafi':
        return PaymentMethod.waafi;
      case 'dmoney':
        return PaymentMethod.dmoney;
      case 'cacpay':
        return PaymentMethod.cacpay;
      case 'sabapay':
        return PaymentMethod.sabapay;
      case 'dahabplus':
        return PaymentMethod.dahabplus;
      default:
        return PaymentMethod.cash;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'driver_id': driverId,
      'pickup_address': pickupAddress,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dropoff_address': dropoffAddress,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'price': price,
      'commission': commission,
      'tip_amount': tipAmount,
      'payment_method': paymentMethod.name,
      'payment_status': paymentStatus.name,
      'status': status.name,
      'cancel_reason': cancelReason,
      'rating': rating,
      'review': review,
      'distance': distance,
      'estimated_duration': estimatedDuration,
      'actual_duration': actualDuration,
      'created_at': createdAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  RideModel copyWith({
    String? id,
    String? clientId,
    String? driverId,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? dropoffAddress,
    double? dropoffLat,
    double? dropoffLng,
    double? price,
    double? commission,
    double? tipAmount,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    RideStatus? status,
    String? cancelReason,
    double? rating,
    String? review,
    double? distance,
    int? estimatedDuration,
    int? actualDuration,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      driverId: driverId ?? this.driverId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      price: price ?? this.price,
      commission: commission ?? this.commission,
      tipAmount: tipAmount ?? this.tipAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
