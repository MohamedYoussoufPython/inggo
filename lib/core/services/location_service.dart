import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();
  static final _log = Logger();

  Position? _lastPosition;
  Timer? _throttleTimer;
  Position? _throttledPosition;
  StreamSubscription<Position>? _positionStream;

  static const int _throttleSeconds = 5;
  static const int _distanceFilterMeters = 10;

  final _locationController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;

  Position? get currentPosition => _throttledPosition ?? _lastPosition;

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _lastPosition = position;
      _throttledPosition = position;
      _log.i('Position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _log.e('Failed to get position: $e');
      return null;
    }
  }

  void startTracking({void Function(Position)? onPositionUpdate}) {
    _log.i('Starting GPS tracking (throttle ${_throttleSeconds}s)');
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _distanceFilterMeters,
      ),
    ).listen((Position position) {
      _lastPosition = position;
      _throttlePosition(position, onPositionUpdate);
    });
  }

  void _throttlePosition(Position position, void Function(Position)? onUpdate) {
    if (_throttleTimer?.isActive ?? false) {
      _throttledPosition = position;
      return;
    }
    _throttledPosition = position;
    _locationController.add(position);
    onUpdate?.call(position);

    _throttleTimer = Timer(Duration(seconds: _throttleSeconds), () {
      if (_throttledPosition != null && _throttledPosition != _lastPosition) {
        _locationController.add(_throttledPosition!);
        onUpdate?.call(_throttledPosition!);
      }
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
    _throttleTimer?.cancel();
    _log.i('GPS tracking stopped');
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
