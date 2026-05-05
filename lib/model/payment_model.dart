import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String rideId,
    required String method,
    required double amount,
    @Default('pending') String status,
    String? transactionId,
    String? phoneNumber,
    DateTime? createdAt,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
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
