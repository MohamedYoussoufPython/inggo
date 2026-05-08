import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();
  static final _log = Logger();

  bool isPaymentAvailable(String method) => method == AppConstants.paymentCash;

  Map<String, dynamic> calculateRidePayment() {
    return {
      'price': AppConstants.ridePrice,
      'commission': AppConstants.rideCommission,
      'driver_earning': AppConstants.ridePrice - AppConstants.rideCommission,
      'currency': AppConstants.currency,
    };
  }

  Future<bool> processPayment({
    required String rideId,
    required String method,
    required double amount,
  }) async {
    if (!isPaymentAvailable(method)) {
      _log.w('Payment method $method not available');
      return false;
    }
    if (method == AppConstants.paymentCash) {
      _log.i('Cash confirmed for ride $rideId');
      return true;
    }
    return false;
  }

  List<Map<String, dynamic>> getPaymentMethods() {
    return [
      {'id': 'cash', 'name': 'Espèces', 'available': true, 'icon': '💵'},
      {'id': 'waafi', 'name': 'Waafi', 'available': false, 'icon': '📱'},
      {'id': 'dmoney', 'name': 'D-Money', 'available': false, 'icon': '💳'},
      {'id': 'cacpay', 'name': 'CAC Pay', 'available': false, 'icon': '🏦'},
      {'id': 'sabapay', 'name': 'Saba Pay', 'available': false, 'icon': '📲'},
      {'id': 'dahabplus', 'name': 'Dahabplus', 'available': false, 'icon': '🥇'},
    ];
  }
}
