import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_action.freezed.dart';
part 'sync_action.g.dart';

enum SyncActionType {
  @JsonValue('UPDATE_STATUS')
  updateStatus,
  @JsonValue('CREATE_CHECKPOINT')
  createCheckpoint,
  @JsonValue('CREATE_SHIPMENT')
  createShipment,
  @JsonValue('UPDATE_SHIPMENT')
  updateShipment,
  @JsonValue('DELETE_SHIPMENT')
  deleteShipment,
}

enum SyncStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('syncing')
  syncing,
  @JsonValue('done')
  done,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class SyncAction with _$SyncAction {
  const factory SyncAction({
    required String id,
    required SyncActionType actionType,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    @Default(SyncStatus.pending) SyncStatus status,
    @Default(0) int retryCount,
    @Default(5) int maxRetries,
    String? lastError,
    required String createdAt,
    String? nextRetryAt,
    @Default(5) int priority,
  }) = _SyncAction;

  factory SyncAction.fromJson(Map<String, dynamic> json) =>
      _$SyncActionFromJson(json);
}
