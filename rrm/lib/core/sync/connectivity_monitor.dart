import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityMonitor {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isOnline = false;

  ConnectivityMonitor() {
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // The plugin returns a list in latest versions. We check if ANY is not none.
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (_isOnline != hasConnection) {
        _isOnline = hasConnection;
        _controller.add(_isOnline);
      }
    });

    // Initial check
    _connectivity.checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      _controller.add(_isOnline);
    });
  }

  bool get isOnline => _isOnline;
  Stream<bool> get connectivityStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
