import '../../../../core/auth/auth_state.dart';

abstract interface class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<void> logout();
  Future<UserEntity?> tryAutoLogin();
}
