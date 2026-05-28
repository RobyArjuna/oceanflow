// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShipmentEntity _$ShipmentEntityFromJson(Map<String, dynamic> json) {
  return _ShipmentEntity.fromJson(json);
}

/// @nodoc
mixin _$ShipmentEntity {
  String get id => throw _privateConstructorUsedError;
  String get trackingNumber => throw _privateConstructorUsedError;
  ShipmentStatus get status => throw _privateConstructorUsedError;
  String get origin => throw _privateConstructorUsedError;
  String get destination => throw _privateConstructorUsedError;
  String? get eta => throw _privateConstructorUsedError;
  String? get vesselName => throw _privateConstructorUsedError;
  List<String> get containerIds => throw _privateConstructorUsedError;
  String? get cargoDescription => throw _privateConstructorUsedError;
  double? get weightKg => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  bool get isDirty => throw _privateConstructorUsedError;

  /// Serializes this ShipmentEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShipmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShipmentEntityCopyWith<ShipmentEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShipmentEntityCopyWith<$Res> {
  factory $ShipmentEntityCopyWith(
          ShipmentEntity value, $Res Function(ShipmentEntity) then) =
      _$ShipmentEntityCopyWithImpl<$Res, ShipmentEntity>;
  @useResult
  $Res call(
      {String id,
      String trackingNumber,
      ShipmentStatus status,
      String origin,
      String destination,
      String? eta,
      String? vesselName,
      List<String> containerIds,
      String? cargoDescription,
      double? weightKg,
      String ownerId,
      String createdAt,
      String updatedAt,
      bool isDirty});
}

/// @nodoc
class _$ShipmentEntityCopyWithImpl<$Res, $Val extends ShipmentEntity>
    implements $ShipmentEntityCopyWith<$Res> {
  _$ShipmentEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShipmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trackingNumber = null,
    Object? status = null,
    Object? origin = null,
    Object? destination = null,
    Object? eta = freezed,
    Object? vesselName = freezed,
    Object? containerIds = null,
    Object? cargoDescription = freezed,
    Object? weightKg = freezed,
    Object? ownerId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDirty = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      trackingNumber: null == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShipmentStatus,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      eta: freezed == eta
          ? _value.eta
          : eta // ignore: cast_nullable_to_non_nullable
              as String?,
      vesselName: freezed == vesselName
          ? _value.vesselName
          : vesselName // ignore: cast_nullable_to_non_nullable
              as String?,
      containerIds: null == containerIds
          ? _value.containerIds
          : containerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cargoDescription: freezed == cargoDescription
          ? _value.cargoDescription
          : cargoDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      isDirty: null == isDirty
          ? _value.isDirty
          : isDirty // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShipmentEntityImplCopyWith<$Res>
    implements $ShipmentEntityCopyWith<$Res> {
  factory _$$ShipmentEntityImplCopyWith(_$ShipmentEntityImpl value,
          $Res Function(_$ShipmentEntityImpl) then) =
      __$$ShipmentEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String trackingNumber,
      ShipmentStatus status,
      String origin,
      String destination,
      String? eta,
      String? vesselName,
      List<String> containerIds,
      String? cargoDescription,
      double? weightKg,
      String ownerId,
      String createdAt,
      String updatedAt,
      bool isDirty});
}

/// @nodoc
class __$$ShipmentEntityImplCopyWithImpl<$Res>
    extends _$ShipmentEntityCopyWithImpl<$Res, _$ShipmentEntityImpl>
    implements _$$ShipmentEntityImplCopyWith<$Res> {
  __$$ShipmentEntityImplCopyWithImpl(
      _$ShipmentEntityImpl _value, $Res Function(_$ShipmentEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShipmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trackingNumber = null,
    Object? status = null,
    Object? origin = null,
    Object? destination = null,
    Object? eta = freezed,
    Object? vesselName = freezed,
    Object? containerIds = null,
    Object? cargoDescription = freezed,
    Object? weightKg = freezed,
    Object? ownerId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDirty = null,
  }) {
    return _then(_$ShipmentEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      trackingNumber: null == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShipmentStatus,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      eta: freezed == eta
          ? _value.eta
          : eta // ignore: cast_nullable_to_non_nullable
              as String?,
      vesselName: freezed == vesselName
          ? _value.vesselName
          : vesselName // ignore: cast_nullable_to_non_nullable
              as String?,
      containerIds: null == containerIds
          ? _value._containerIds
          : containerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cargoDescription: freezed == cargoDescription
          ? _value.cargoDescription
          : cargoDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      isDirty: null == isDirty
          ? _value.isDirty
          : isDirty // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShipmentEntityImpl implements _ShipmentEntity {
  const _$ShipmentEntityImpl(
      {required this.id,
      required this.trackingNumber,
      required this.status,
      required this.origin,
      required this.destination,
      this.eta,
      this.vesselName,
      final List<String> containerIds = const [],
      this.cargoDescription,
      this.weightKg,
      required this.ownerId,
      required this.createdAt,
      required this.updatedAt,
      this.isDirty = false})
      : _containerIds = containerIds;

  factory _$ShipmentEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShipmentEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String trackingNumber;
  @override
  final ShipmentStatus status;
  @override
  final String origin;
  @override
  final String destination;
  @override
  final String? eta;
  @override
  final String? vesselName;
  final List<String> _containerIds;
  @override
  @JsonKey()
  List<String> get containerIds {
    if (_containerIds is EqualUnmodifiableListView) return _containerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_containerIds);
  }

  @override
  final String? cargoDescription;
  @override
  final double? weightKg;
  @override
  final String ownerId;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  @JsonKey()
  final bool isDirty;

  @override
  String toString() {
    return 'ShipmentEntity(id: $id, trackingNumber: $trackingNumber, status: $status, origin: $origin, destination: $destination, eta: $eta, vesselName: $vesselName, containerIds: $containerIds, cargoDescription: $cargoDescription, weightKg: $weightKg, ownerId: $ownerId, createdAt: $createdAt, updatedAt: $updatedAt, isDirty: $isDirty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShipmentEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.origin, origin) || other.origin == origin) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.eta, eta) || other.eta == eta) &&
            (identical(other.vesselName, vesselName) ||
                other.vesselName == vesselName) &&
            const DeepCollectionEquality()
                .equals(other._containerIds, _containerIds) &&
            (identical(other.cargoDescription, cargoDescription) ||
                other.cargoDescription == cargoDescription) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDirty, isDirty) || other.isDirty == isDirty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      trackingNumber,
      status,
      origin,
      destination,
      eta,
      vesselName,
      const DeepCollectionEquality().hash(_containerIds),
      cargoDescription,
      weightKg,
      ownerId,
      createdAt,
      updatedAt,
      isDirty);

  /// Create a copy of ShipmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShipmentEntityImplCopyWith<_$ShipmentEntityImpl> get copyWith =>
      __$$ShipmentEntityImplCopyWithImpl<_$ShipmentEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShipmentEntityImplToJson(
      this,
    );
  }
}

abstract class _ShipmentEntity implements ShipmentEntity {
  const factory _ShipmentEntity(
      {required final String id,
      required final String trackingNumber,
      required final ShipmentStatus status,
      required final String origin,
      required final String destination,
      final String? eta,
      final String? vesselName,
      final List<String> containerIds,
      final String? cargoDescription,
      final double? weightKg,
      required final String ownerId,
      required final String createdAt,
      required final String updatedAt,
      final bool isDirty}) = _$ShipmentEntityImpl;

  factory _ShipmentEntity.fromJson(Map<String, dynamic> json) =
      _$ShipmentEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get trackingNumber;
  @override
  ShipmentStatus get status;
  @override
  String get origin;
  @override
  String get destination;
  @override
  String? get eta;
  @override
  String? get vesselName;
  @override
  List<String> get containerIds;
  @override
  String? get cargoDescription;
  @override
  double? get weightKg;
  @override
  String get ownerId;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  bool get isDirty;

  /// Create a copy of ShipmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShipmentEntityImplCopyWith<_$ShipmentEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
