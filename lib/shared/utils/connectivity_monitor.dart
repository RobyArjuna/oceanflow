import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for real-time connectivity state.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return ConnectivityMonitor.instance.onConnectivityChanged;
});

/// Snapshot provider — current connectivity state (non-streaming).
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStreamProvider).valueOrNull ?? true;
});

/// Abstraction over connectivity_plus for testability.
class ConnectivityMonitor {
  ConnectivityMonitor._();
  static final instance = ConnectivityMonitor._();

  final _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }
}
