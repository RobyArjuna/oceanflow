import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String username,
    required String email,
    required UserRole role,
    String? displayName,
    String? token,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('supervisor')
  supervisor,
  @JsonValue('operator')
  operator,
  @JsonValue('driver')
  driver,
}
