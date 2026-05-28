// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserEntityImpl _$$UserEntityImplFromJson(Map<String, dynamic> json) =>
    _$UserEntityImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      displayName: json['displayName'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$$UserEntityImplToJson(_$UserEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'displayName': instance.displayName,
      'token': instance.token,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.supervisor: 'supervisor',
  UserRole.operator: 'operator',
  UserRole.driver: 'driver',
};
