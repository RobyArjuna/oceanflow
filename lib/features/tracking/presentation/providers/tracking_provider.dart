import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/sync/models/sync_action.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../shipment/domain/entities/shipment_entity.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';

final trackingProvider = Provider<TrackingService>((ref) {
  return TrackingService(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
    ref,
  );
});

class TrackingService {
  final AppDatabase _dbHelper;
  final SyncEngine _syncEngine;
  final Ref _ref;
  final _uuid = const Uuid();

  TrackingService(this._dbHelper, this._syncEngine, this._ref);

  Future<void> submitCheckpoint({
    required String shipmentId,
    required ShipmentStatus status,
    String? location,
    String? notes,
    String? proofImagePath,
    String? scannedCode,
    required String operatorId,
  }) async {
    final db = await _dbHelper.database;
    final checkpointId = 'chk_${_uuid.v4()}';
    final createdAt = DateTime.now().toIso8601String();

    // 1. Persist checkpoint locally to database
    await db.insert(
      DbConstants.tableCheckpoints,
      {
        DbConstants.colId: checkpointId,
        DbConstants.colShipmentId: shipmentId,
        DbConstants.colStatus: status.name,
        DbConstants.colLocation: location,
        DbConstants.colNotes: notes,
        DbConstants.colProofImagePath: proofImagePath,
        DbConstants.colScannedCode: scannedCode,
        DbConstants.colOperatorId: operatorId,
        DbConstants.colIsSynced: 0,
        DbConstants.colCreatedAt: createdAt,
      },
    );

    // 2. Optimistically update local shipment status cache
    await _ref.read(shipmentRepositoryProvider).updateShipmentStatusLocal(shipmentId, status);
    
    // Trigger shipment log reload so UI lists sync status dirty icons
    await _ref.read(shipmentListProvider.notifier).loadShipments();

    // 3. Enqueue status modification sync action
    await _syncEngine.enqueue(
      actionType: SyncActionType.updateStatus,
      entityType: 'shipment',
      entityId: shipmentId,
      payload: {
        'shipment_id': shipmentId,
        'status': status.name,
        'updated_at': createdAt,
      },
    );

    // 4. Enqueue checkpoint creation sync action
    await _syncEngine.enqueue(
      actionType: SyncActionType.createCheckpoint,
      entityType: 'checkpoint',
      entityId: checkpointId,
      payload: {
        'id': checkpointId,
        'shipment_id': shipmentId,
        'status': status.name,
        'location': location,
        'notes': notes,
        'proof_image': proofImagePath,
        'scanned_code': scannedCode,
        'operator_id': operatorId,
        'created_at': createdAt,
      },
    );
  }
}
