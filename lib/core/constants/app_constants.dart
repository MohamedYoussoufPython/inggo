class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Inggo';
  static const String appVersion = '1.0.0';

  // Currency
  static const String currency = 'FDJ';
  static const String currencySymbol = 'Fdj';

  // Ride Pricing
  static const double ridePrice = 250;
  static const double rideCommission = 125;
  static const double driverEarning = 125;

  // Phone
  static const String countryCode = '+253';
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 120;

  // Ride
  static const int searchDriverTimeoutSeconds = 180;
  static const double defaultLat = 11.5880;
  static const double defaultLng = 43.1456;
  static const String defaultCity = 'Djibouti';

  // Location
  static const int locationUpdateIntervalSeconds = 5;

  // Pagination
  static const int pageSize = 20;

  // Rating
  static const double defaultRating = 5.0;
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentWaafi = 'waafi';
  static const String paymentDMoney = 'dmoney';
  static const String paymentCacPay = 'cacpay';
  static const String paymentSabaPay = 'sabapay';
  static const String paymentDahabplus = 'dahabplus';

  // Roles
  static const String roleClient = 'client';
  static const String roleDriver = 'driver';

  // Note: Ride status strings are handled by the RideStatus enum in ride_model.dart.
  // Use RideStatus.toSupabase() and RideModel.parseRideStatus() instead of string constants.
}
