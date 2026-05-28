abstract final class DbConstants {
  DbConstants._();

  // Database meta
  static const dbName = 'oceanflow.db';
  static const dbVersion = 2;

  // Table names
  static const tableShipments = 'shipments';
  static const tableCheckpoints = 'tracking_checkpoints';
  static const tableSyncQueue = 'sync_queue';
  static const tableNotifications = 'notifications';
  static const tableAiConversations = 'ai_conversations';

  // Shared columns
  static const colId = 'id';
  static const colCreatedAt = 'created_at';
  static const colUpdatedAt = 'updated_at';

  // Shipment columns
  static const colTrackingNumber = 'tracking_number';
  static const colStatus = 'status';
  static const colOrigin = 'origin';
  static const colDestination = 'destination';
  static const colEta = 'eta';
  static const colVesselName = 'vessel_name';
  static const colContainerIds = 'container_ids';
  static const colCargoDescription = 'cargo_description';
  static const colWeightKg = 'weight_kg';
  static const colOwnerId = 'owner_id';
  static const colIsDirty = 'is_dirty';
  static const colCachedAt = 'cached_at';

  // Checkpoint columns
  static const colShipmentId = 'shipment_id';
  static const colLocation = 'location';
  static const colNotes = 'notes';
  static const colProofImagePath = 'proof_image_path';
  static const colScannedCode = 'scanned_code';
  static const colOperatorId = 'operator_id';
  static const colIsSynced = 'is_synced';

  // Sync queue columns
  static const colActionType = 'action_type';
  static const colEntityType = 'entity_type';
  static const colEntityId = 'entity_id';
  static const colPayload = 'payload';
  static const colSyncStatus = 'status';
  static const colRetryCount = 'retry_count';
  static const colMaxRetries = 'max_retries';
  static const colLastError = 'last_error';
  static const colNextRetryAt = 'next_retry_at';
  static const colPriority = 'priority';

  // Notification columns
  static const colTitle = 'title';
  static const colBody = 'body';
  static const colType = 'type';
  static const colReferenceId = 'reference_id';
  static const colIsRead = 'is_read';

  // AI conversation columns
  static const colRole = 'role';
  static const colContent = 'content';
  static const colShipmentContextId = 'shipment_context_id';
}
