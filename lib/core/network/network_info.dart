import '../../shared/utils/connectivity_monitor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ConnectivityMonitor.instance);
});

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final ConnectivityMonitor _monitor;

  NetworkInfoImpl(this._monitor);

  @override
  Future<bool> get isConnected => _monitor.isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _monitor.onConnectivityChanged;
}
