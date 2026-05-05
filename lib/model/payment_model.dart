class PaymentModel {
  final String id;
  final String rideId;
  final String method;
  final double amount;
  final String status;
  final String? transactionId;
  final String? phoneNumber;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    required this.rideId,
    required this.method,
    required this.amount,
    this.status = 'pending',
    this.transactionId,
    this.phoneNumber,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String? ?? '',
      rideId: json['ride_id'] as String? ?? '',
      method: json['method'] as String? ?? 'cash',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      transactionId: json['transaction_id'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'method': method,
      'amount': amount,
      'status': status,
      'transaction_id': transactionId,
      'phone_number': phoneNumber,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class PaymentMethods {
  PaymentMethods._();

  static const String cash = 'cash';
  static const String waafi = 'waafi';
  static const String dmoney = 'dmoney';
  static const String cacpay = 'cacpay';
  static const String sabapay = 'sabapay';
  static const String dahabplus = 'dahabplus';

  static bool isAvailable(String method) => method == cash;

  static String getDisplayName(String method) {
    switch (method) {
      case cash:
        return 'Espèces';
      case waafi:
        return 'Waafi';
      case dmoney:
        return 'D-Money';
      case cacpay:
        return 'CAC Pay';
      case sabapay:
        return 'Saba Pay';
      case dahabplus:
        return 'Dahabplus';
      default:
        return method;
    }
  }

  static List<String> get all =>
      [cash, waafi, dmoney, cacpay, sabapay, dahabplus];
}
