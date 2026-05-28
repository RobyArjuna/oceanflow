import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipment_entity.freezed.dart';
part 'shipment_entity.g.dart';

enum ShipmentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('loaded')
  loaded,
  @JsonValue('at_port')
  atPort,
  @JsonValue('sailing')
  sailing,
  @JsonValue('arrived')
  arrived,
  @JsonValue('delivered')
  delivered,
}

@freezed
class ShipmentEntity with _$ShipmentEntity {
  const factory ShipmentEntity({
    required String id,
    required String trackingNumber,
    required ShipmentStatus status,
    required String origin,
    required String destination,
    String? eta,
    String? vesselName,
    @Default([]) List<String> containerIds,
    String? cargoDescription,
    double? weightKg,
    required String ownerId,
    required String createdAt,
    required String updatedAt,
    @Default(false) bool isDirty,
  }) = _ShipmentEntity;

  factory ShipmentEntity.fromJson(Map<String, dynamic> json) =>
      _$ShipmentEntityFromJson(json);
}
