// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SyncAction _$SyncActionFromJson(Map<String, dynamic> json) {
  return _SyncAction.fromJson(json);
}

/// @nodoc
mixin _$SyncAction {
  String get id => throw _privateConstructorUsedError;
  SyncActionType get actionType => throw _privateConstructorUsedError;
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  SyncStatus get status => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get nextRetryAt => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;

  /// Serializes this SyncAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncActionCopyWith<SyncAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncActionCopyWith<$Res> {
  factory $SyncActionCopyWith(
          SyncAction value, $Res Function(SyncAction) then) =
      _$SyncActionCopyWithImpl<$Res, SyncAction>;
  @useResult
  $Res call(
      {String id,
      SyncActionType actionType,
      String entityType,
      String entityId,
      Map<String, dynamic> payload,
      SyncStatus status,
      int retryCount,
      int maxRetries,
      String? lastError,
      String createdAt,
      String? nextRetryAt,
      int priority});
}

/// @nodoc
class _$SyncActionCopyWithImpl<$Res, $Val extends SyncAction>
    implements $SyncActionCopyWith<$Res> {
  _$SyncActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actionType = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? payload = null,
    Object? status = null,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? lastError = freezed,
    Object? createdAt = null,
    Object? nextRetryAt = freezed,
    Object? priority = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as SyncActionType,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncActionImplCopyWith<$Res>
    implements $SyncActionCopyWith<$Res> {
  factory _$$SyncActionImplCopyWith(
          _$SyncActionImpl value, $Res Function(_$SyncActionImpl) then) =
      __$$SyncActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SyncActionType actionType,
      String entityType,
      String entityId,
      Map<String, dynamic> payload,
      SyncStatus status,
      int retryCount,
      int maxRetries,
      String? lastError,
      String createdAt,
      String? nextRetryAt,
      int priority});
}

/// @nodoc
class __$$SyncActionImplCopyWithImpl<$Res>
    extends _$SyncActionCopyWithImpl<$Res, _$SyncActionImpl>
    implements _$$SyncActionImplCopyWith<$Res> {
  __$$SyncActionImplCopyWithImpl(
      _$SyncActionImpl _value, $Res Function(_$SyncActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actionType = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? payload = null,
    Object? status = null,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? lastError = freezed,
    Object? createdAt = null,
    Object? nextRetryAt = freezed,
    Object? priority = null,
  }) {
    return _then(_$SyncActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as SyncActionType,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncActionImpl implements _SyncAction {
  const _$SyncActionImpl(
      {required this.id,
      required this.actionType,
      required this.entityType,
      required this.entityId,
      required final Map<String, dynamic> payload,
      this.status = SyncStatus.pending,
      this.retryCount = 0,
      this.maxRetries = 5,
      this.lastError,
      required this.createdAt,
      this.nextRetryAt,
      this.priority = 5})
      : _payload = payload;

  factory _$SyncActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncActionImplFromJson(json);

  @override
  final String id;
  @override
  final SyncActionType actionType;
  @override
  final String entityType;
  @override
  final String entityId;
  final Map<String, dynamic> _payload;
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  @JsonKey()
  final SyncStatus status;
  @override
  @JsonKey()
  final int retryCount;
  @override
  @JsonKey()
  final int maxRetries;
  @override
  final String? lastError;
  @override
  final String createdAt;
  @override
  final String? nextRetryAt;
  @override
  @JsonKey()
  final int priority;

  @override
  String toString() {
    return 'SyncAction(id: $id, actionType: $actionType, entityType: $entityType, entityId: $entityId, payload: $payload, status: $status, retryCount: $retryCount, maxRetries: $maxRetries, lastError: $lastError, createdAt: $createdAt, nextRetryAt: $nextRetryAt, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.nextRetryAt, nextRetryAt) ||
                other.nextRetryAt == nextRetryAt) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      actionType,
      entityType,
      entityId,
      const DeepCollectionEquality().hash(_payload),
      status,
      retryCount,
      maxRetries,
      lastError,
      createdAt,
      nextRetryAt,
      priority);

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncActionImplCopyWith<_$SyncActionImpl> get copyWith =>
      __$$SyncActionImplCopyWithImpl<_$SyncActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncActionImplToJson(
      this,
    );
  }
}

abstract class _SyncAction implements SyncAction {
  const factory _SyncAction(
      {required final String id,
      required final SyncActionType actionType,
      required final String entityType,
      required final String entityId,
      required final Map<String, dynamic> payload,
      final SyncStatus status,
      final int retryCount,
      final int maxRetries,
      final String? lastError,
      required final String createdAt,
      final String? nextRetryAt,
      final int priority}) = _$SyncActionImpl;

  factory _SyncAction.fromJson(Map<String, dynamic> json) =
      _$SyncActionImpl.fromJson;

  @override
  String get id;
  @override
  SyncActionType get actionType;
  @override
  String get entityType;
  @override
  String get entityId;
  @override
  Map<String, dynamic> get payload;
  @override
  SyncStatus get status;
  @override
  int get retryCount;
  @override
  int get maxRetries;
  @override
  String? get lastError;
  @override
  String get createdAt;
  @override
  String? get nextRetryAt;
  @override
  int get priority;

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncActionImplCopyWith<_$SyncActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
