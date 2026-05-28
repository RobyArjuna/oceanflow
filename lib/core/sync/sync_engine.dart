import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../constants/db_constants.dart';
import '../constants/sync_constants.dart';
import '../network/network_info.dart';
import 'models/sync_action.dart';
import '../../features/shipment/domain/repositories/shipment_repository.dart';
import '../../features/shipment/presentation/providers/shipment_provider.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    ref.watch(appDatabaseProvider),
    ref.watch(networkInfoProvider),
    ref,
  );
});

class SyncEngine {
  final AppDatabase _dbHelper;
  final NetworkInfo _networkInfo;
  final Ref _ref;
  final _uuid = const Uuid();
  bool _isProcessing = false;

  SyncEngine(this._dbHelper, this._networkInfo, this._ref) {
    // Listen to network changes to automatically retry syncing
    _networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        processQueue();
      }
    });
  }

  Future<Database> get _db => _dbHelper.database;

  /// Enqueue an operation to be run when connected
  Future<void> enqueue({
    required SyncActionType actionType,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    int priority = 5,
  }) async {
    final db = await _db;
    final action = SyncAction(
      id: _uuid.v4(),
      actionType: actionType,
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now().toIso8601String(),
      priority: priority,
    );

    await db.insert(
      DbConstants.tableSyncQueue,
      _toMap(action),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Trigger process immediately in case we are currently online
    processQueue();
  }

  /// Sequential queue processing
  Future<void> processQueue() async {
    if (_isProcessing) return;
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) return;

    _isProcessing = true;
    try {
      final db = await _db;

      // Select all actions that are pending or ready for retry
      final nowStr = DateTime.now().toIso8601String();
      final maps = await db.query(
        DbConstants.tableSyncQueue,
        where: "(${DbConstants.colSyncStatus} = ? OR ${DbConstants.colSyncStatus} = ?) "
            "AND (${DbConstants.colNextRetryAt} IS NULL OR ${DbConstants.colNextRetryAt} <= ?)",
        whereArgs: [SyncConstants.statusPending, SyncConstants.statusFailed, nowStr],
        orderBy: '${DbConstants.colPriority} DESC, ${DbConstants.colCreatedAt} ASC',
      );

      final queue = maps.map(_mapAction).toList();
      if (queue.isEmpty) return;

      debugPrint('SyncEngine: Found ${queue.length} actions in offline sync queue.');

      for (final action in queue) {
        await _processAction(action);
      }
    } catch (e) {
      debugPrint('SyncEngine error during queue run: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processAction(SyncAction action) async {
    final db = await _db;
    
    // Set status to syncing
    await db.update(
      DbConstants.tableSyncQueue,
      {DbConstants.colSyncStatus: SyncConstants.statusSyncing},
      where: '${DbConstants.colId} = ?',
      whereArgs: [action.id],
    );

    try {
      // Simulate endpoint push delay
      await Future<void>.delayed(const Duration(milliseconds: 600));

      // Resolve the shipment repository to perform remote syncing
      final shipmentRepo = _ref.read(shipmentRepositoryProvider);

      if (action.actionType == SyncActionType.updateStatus ||
          action.actionType == SyncActionType.createShipment ||
          action.actionType == SyncActionType.updateShipment) {
        // Execute status syncing or CRUD syncing to simulated backend
        await shipmentRepo.syncShipmentLocalToServer(action.entityId);
      } else if (action.actionType == SyncActionType.createCheckpoint) {
        // Save checkpoints
        await db.update(
          DbConstants.tableCheckpoints,
          {DbConstants.colIsSynced: 1},
          where: '${DbConstants.colId} = ?',
          whereArgs: [action.entityId],
        );
      } else if (action.actionType == SyncActionType.deleteShipment) {
        // Simulate remote delete endpoint execution
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }

      // Mark success
      await db.update(
        DbConstants.tableSyncQueue,
        {
          DbConstants.colSyncStatus: SyncConstants.statusDone,
          DbConstants.colLastError: null,
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [action.id],
      );

      // Trigger shipment list reload to reflect dirty clearing
      _ref.read(shipmentListProvider.notifier).loadShipments();

    } catch (err) {
      final updatedRetries = action.retryCount + 1;
      final bool failedPermanently = updatedRetries >= action.maxRetries;

      // Exponential backoff delay schedule calculation: base delay * 2^retry
      final backoffMs = SyncConstants.baseRetryDelayMs * pow(2, action.retryCount);
      final nextRetry = DateTime.now().add(Duration(milliseconds: backoffMs.toInt()));

      await db.update(
        DbConstants.tableSyncQueue,
        {
          DbConstants.colSyncStatus: failedPermanently
              ? SyncConstants.statusCancelled
              : SyncConstants.statusFailed,
          DbConstants.colRetryCount: updatedRetries,
          DbConstants.colLastError: err.toString(),
          DbConstants.colNextRetryAt: failedPermanently ? null : nextRetry.toIso8601String(),
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [action.id],
      );
    }
  }

  SyncAction _mapAction(Map<String, dynamic> map) {
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
  }

  Map<String, dynamic> _toMap(SyncAction action) {
    return {
      DbConstants.colId: action.id,
      DbConstants.colActionType: action.actionType.name,
      DbConstants.colEntityType: action.entityType,
      DbConstants.colEntityId: action.entityId,
      DbConstants.colPayload: jsonEncode(action.payload),
      DbConstants.colSyncStatus: action.status.name,
      DbConstants.colRetryCount: action.retryCount,
      DbConstants.colMaxRetries: action.maxRetries,
      DbConstants.colLastError: action.lastError,
      DbConstants.colCreatedAt: action.createdAt,
      DbConstants.colNextRetryAt: action.nextRetryAt,
      DbConstants.colPriority: action.priority,
    };
  }
}
