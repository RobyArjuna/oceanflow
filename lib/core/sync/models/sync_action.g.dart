// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncActionImpl _$$SyncActionImplFromJson(Map<String, dynamic> json) =>
    _$SyncActionImpl(
      id: json['id'] as String,
      actionType: $enumDecode(_$SyncActionTypeEnumMap, json['actionType']),
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      status: $enumDecodeNullable(_$SyncStatusEnumMap, json['status']) ??
          SyncStatus.pending,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 5,
      lastError: json['lastError'] as String?,
      createdAt: json['createdAt'] as String,
      nextRetryAt: json['nextRetryAt'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$$SyncActionImplToJson(_$SyncActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actionType': _$SyncActionTypeEnumMap[instance.actionType]!,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'payload': instance.payload,
      'status': _$SyncStatusEnumMap[instance.status]!,
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'lastError': instance.lastError,
      'createdAt': instance.createdAt,
      'nextRetryAt': instance.nextRetryAt,
      'priority': instance.priority,
    };

const _$SyncActionTypeEnumMap = {
  SyncActionType.updateStatus: 'UPDATE_STATUS',
  SyncActionType.createCheckpoint: 'CREATE_CHECKPOINT',
  SyncActionType.createShipment: 'CREATE_SHIPMENT',
  SyncActionType.updateShipment: 'UPDATE_SHIPMENT',
  SyncActionType.deleteShipment: 'DELETE_SHIPMENT',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.done: 'done',
  SyncStatus.failed: 'failed',
  SyncStatus.cancelled: 'cancelled',
};
