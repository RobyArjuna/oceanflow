// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShipmentEntityImpl _$$ShipmentEntityImplFromJson(Map<String, dynamic> json) =>
    _$ShipmentEntityImpl(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      status: $enumDecode(_$ShipmentStatusEnumMap, json['status']),
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      eta: json['eta'] as String?,
      vesselName: json['vesselName'] as String?,
      containerIds: (json['containerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cargoDescription: json['cargoDescription'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      ownerId: json['ownerId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isDirty: json['isDirty'] as bool? ?? false,
    );

Map<String, dynamic> _$$ShipmentEntityImplToJson(
        _$ShipmentEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackingNumber': instance.trackingNumber,
      'status': _$ShipmentStatusEnumMap[instance.status]!,
      'origin': instance.origin,
      'destination': instance.destination,
      'eta': instance.eta,
      'vesselName': instance.vesselName,
      'containerIds': instance.containerIds,
      'cargoDescription': instance.cargoDescription,
      'weightKg': instance.weightKg,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'isDirty': instance.isDirty,
    };

const _$ShipmentStatusEnumMap = {
  ShipmentStatus.pending: 'pending',
  ShipmentStatus.loaded: 'loaded',
  ShipmentStatus.atPort: 'at_port',
  ShipmentStatus.sailing: 'sailing',
  ShipmentStatus.arrived: 'arrived',
  ShipmentStatus.delivered: 'delivered',
};
