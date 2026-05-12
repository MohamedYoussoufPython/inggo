import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

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

  /// Returns the list of available payment methods.
  /// Pass [loc] to get localized display names; otherwise French defaults are used.
  List<Map<String, dynamic>> getPaymentMethods([AppLocalizations? loc]) {
    return [
      {'id': 'cash', 'name': loc?.paymentCash ?? 'Espèces', 'available': true, 'icon': '💵'},
      {'id': 'waafi', 'name': loc?.paymentWaafi ?? 'Waafi', 'available': false, 'icon': '📱'},
      {'id': 'dmoney', 'name': loc?.paymentDMoney ?? 'D-Money', 'available': false, 'icon': '💳'},
      {'id': 'cacpay', 'name': loc?.paymentCacPay ?? 'CAC Pay', 'available': false, 'icon': '🏦'},
      {'id': 'sabapay', 'name': loc?.paymentSabaPay ?? 'Saba Pay', 'available': false, 'icon': '📲'},
      {'id': 'dahabplus', 'name': loc?.paymentDahabplus ?? 'Dahabplus', 'available': false, 'icon': '🥇'},
    ];
  }
}
