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
      id: json['id'] as int,
      driverId: json['driver_id'] as String,
      rideId: json['ride_id'] as int?,
      amount: json['amount'] as int,
      commission: json['commission'] as int? ?? 0,
      netAmount: json['net_amount'] as int,
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }
}
