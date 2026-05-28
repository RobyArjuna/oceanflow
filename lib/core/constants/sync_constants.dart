abstract final class SyncConstants {
  SyncConstants._();

  // Queue
  static const maxRetries = 5;
  static const baseRetryDelayMs = 500;
  static const maxRetryDelayMs = 30000; // 30 seconds cap

  // Workmanager task identifiers
  static const backgroundSyncTaskName = 'oceanflow_background_sync';
  static const backgroundSyncTaskTag = 'sync';

  // Priority levels (higher = processed first)
  static const priorityHigh = 10;
  static const priorityNormal = 5;
  static const priorityLow = 1;

  // Action types
  static const actionCreateCheckpoint = 'CREATE_CHECKPOINT';
  static const actionUpdateStatus = 'UPDATE_STATUS';
  static const actionUploadProof = 'UPLOAD_PROOF';
  static const actionScanCode = 'SCAN_CODE';

  // Entity types
  static const entityShipment = 'shipment';
  static const entityCheckpoint = 'checkpoint';

  // Status values stored in DB
  static const statusPending = 'pending';
  static const statusSyncing = 'syncing';
  static const statusDone = 'done';
  static const statusFailed = 'failed';
  static const statusCancelled = 'cancelled';
}
