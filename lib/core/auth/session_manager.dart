import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import 'auth_state.dart';
import 'token_manager.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(
    ref.watch(secureStorageProvider),
    ref.watch(tokenManagerProvider),
  );
});

class SessionManager {
  final SecureStorage _secureStorage;
  final TokenManager _tokenManager;

  SessionManager(this._secureStorage, this._tokenManager);

  static const _userKey = 'current_user';

  Future<void> saveSession({
    required UserEntity user,
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await _tokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiry,
    );
    await _secureStorage.write(
      key: SecureStorageKeys.userId,
      value: user.id,
    );
    await _secureStorage.write(
      key: SecureStorageKeys.userRole,
      value: user.role.name,
    );
    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserEntity?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null) return null;
    try {
      return UserEntity.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<UserRole?> getUserRole() async {
    final roleStr = await _secureStorage.read(key: SecureStorageKeys.userRole);
    if (roleStr == null) return null;
    return UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.operator,
    );
  }

  Future<void> clearSession() async {
    await _tokenManager.clearTokens();
    await _secureStorage.delete(key: _userKey);
  }

  Future<bool> get isSessionValid async {
    return await _tokenManager.hasValidToken &&
        (await getCurrentUser() != null);
  }
}
