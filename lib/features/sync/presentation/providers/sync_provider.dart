import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/sync/models/sync_action.dart';
import '../../../../core/sync/sync_engine.dart';

final syncListProvider =
    StateNotifierProvider<SyncListNotifier, AsyncValue<List<SyncAction>>>((ref) {
  return SyncListNotifier(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

class SyncListNotifier extends StateNotifier<AsyncValue<List<SyncAction>>> {
  final AppDatabase _dbHelper;
  final SyncEngine _syncEngine;

  SyncListNotifier(this._dbHelper, this._syncEngine) : super(const AsyncValue.loading()) {
    loadSyncQueue();
  }

  Future<void> loadSyncQueue() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbConstants.tableSyncQueue,
        orderBy: '${DbConstants.colCreatedAt} DESC',
      );

      final list = maps.map((map) {
        return SyncAction(
          id: map[DbConstants.colId] as String,
          actionType: SyncActionType.values.firstWhere(
            (a) => a.name == map[DbConstants.colActionType],
            orElse: () => SyncActionType.updateStatus,
          ),
          entityType: map[DbConstants.colEntityType] as String,
          entityId: map[DbConstants.colEntityId] as String,
          payload: jsonDecode(map[DbConstants.colPayload] as String) as Map<String, dynamic>,
          status: SyncStatus.values.firstWhere(
            (s) => s.name == map[DbConstants.colSyncStatus],
            orElse: () => SyncStatus.pending,
          ),
          retryCount: map[DbConstants.colRetryCount] as int? ?? 0,
          maxRetries: map[DbConstants.colMaxRetries] as int? ?? 5,
          lastError: map[DbConstants.colLastError] as String?,
          createdAt: map[DbConstants.colCreatedAt] as String,
          nextRetryAt: map[DbConstants.colNextRetryAt] as String?,
          priority: map[DbConstants.colPriority] as int? ?? 5,
        );
      }).toList();

      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> triggerSync() async {
    state = const AsyncValue.loading();
    await _syncEngine.processQueue();
    await loadSyncQueue();
  }

  Future<void> clearCompletedActions() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        DbConstants.tableSyncQueue,
        where: '${DbConstants.colSyncStatus} = ?',
        whereArgs: ['done'],
      );
      await loadSyncQueue();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
