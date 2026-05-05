import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();
  static final _log = Logger();

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void startMonitoring() {
    _log.i('Starting connectivity monitoring');
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      _connectionController.add(_isOnline);
      if (wasOnline != _isOnline) {
        _log.i('Connection: ${_isOnline ? "online" : "offline"}');
      }
    });
  }

  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      return _isOnline;
    } catch (e) {
      _log.e('Connectivity check failed: $e');
      return false;
    }
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }

  void dispose() {
    stopMonitoring();
    _connectionController.close();
  }
}
