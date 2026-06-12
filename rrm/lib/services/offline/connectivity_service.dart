import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'sync_coordinator.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = false;

  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    bool previouslyOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none) && results.isNotEmpty;

    // Trigger sync when transitioning from offline to online
    if (!previouslyOnline && _isOnline) {
      final coordinator = GetIt.instance<SyncCoordinator>();
      coordinator.onNetworkAvailable();
    }
  }

  bool get isOnline => _isOnline;

  void dispose() {
    _subscription.cancel();
  }
}
