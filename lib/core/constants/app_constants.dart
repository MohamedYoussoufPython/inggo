class AppConstants {
  AppConstants._();

  // App Info
  static const String appVersion = '1.0.0';

  // Currency
  static const String currency = 'FDJ';

  // Ride Pricing
  static const int ridePrice = 250;
  static const int rideCommission = 125;
  static const int driverEarning = ridePrice - rideCommission;

  // Phone
  static const String countryCode = '+253';

  // Ride
  static const int searchDriverTimeoutSeconds = 180;
  static const int rideRequestTimeoutSeconds = 30;
  static const double defaultLat = 11.5880;
  static const double defaultLng = 43.1456;

  // Pagination
  static const int pageSize = 20;

  // Payment Methods
  static const String paymentCash = 'cash';
}
