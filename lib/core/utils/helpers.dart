import 'package:uuid/uuid.dart';

class Helpers {
  Helpers._();

  static const _uuid = Uuid();

  static String generateId() => _uuid.v4();

  static String getFullPhone(String localPhone) {
    final cleaned = localPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('253')) return '+$cleaned';
    return '+253$cleaned';
  }

  static String getLocalPhone(String fullPhone) {
    if (fullPhone.startsWith('+253')) {
      return fullPhone.substring(4);
    }
    if (fullPhone.startsWith('253')) {
      return fullPhone.substring(3);
    }
    return fullPhone;
  }

  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = (dLat / 2) * (dLat / 2) +
        _toRadians(lat1) *
            _toRadians(lat2) *
            (dLng / 2) *
            (dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * 0.017453292519943295;
  static double _sqrt(double x) => x;
  static double _atan2(double y, double x) => _atan2(y, x);

  static int estimateDuration(double distanceMeters) {
    final avgSpeedMps = 8.33; // ~30 km/h
    return (distanceMeters / avgSpeedMps / 60).round().clamp(1, 120);
  }
}
