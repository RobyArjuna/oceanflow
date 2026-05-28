import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../core/constants/sync_constants.dart';
import '../core/database/app_database.dart';
import '../core/network/network_info.dart';
import '../core/sync/sync_engine.dart';
import '../shared/utils/connectivity_monitor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('BackgroundService: Starting background task: $task');

    try {
      final dbHelper = AppDatabase();
      final networkInfo = NetworkInfoImpl(ConnectivityMonitor.instance);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(dbHelper),
          networkInfoProvider.overrideWithValue(networkInfo),
        ],
      );

      final syncEngine = container.read(syncEngineProvider);

      // Process queue
      await syncEngine.processQueue();

      container.dispose();
      return true;
    } catch (e) {
      debugPrint('BackgroundService failure: $e');
      return false;
    }
  });
}

class BackgroundService {
  BackgroundService._();

  static Future<void> initialize() async {
    if (kIsWeb) return;

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register a periodic task for offline database recovery
    await Workmanager().registerPeriodicTask(
      SyncConstants.backgroundSyncTaskName,
      SyncConstants.backgroundSyncTaskName,
      frequency:
          const Duration(minutes: 15), // 15 mins is Android OS system minimum
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
