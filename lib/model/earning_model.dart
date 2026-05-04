class EarningModel {
  final int id;
  final String driverId;
  final int? rideId;
  final int amount;
  final int commission;
  final int netAmount;
  final DateTime earnedAt;

  EarningModel({
    required this.id,
    required this.driverId,
    this.rideId,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.earnedAt,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      id: (json['id'] as num).toInt(),
      driverId: json['driver_id'] as String,
      rideId: json['ride_id'] != null ? (json['ride_id'] as num).toInt() : null,
      amount: (json['amount'] as num).toInt(),
      commission: json['commission'] != null ? (json['commission'] as num).toInt() : 0,
      netAmount: (json['net_amount'] as num).toInt(),
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }
}
