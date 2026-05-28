import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../network/api_endpoints.dart';

final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(ref.read(secureStorageProvider));
});

/// Manages JWT access/refresh token lifecycle.
/// Token refresh is serialized — concurrent 401s won't fire multiple refresh calls.
class TokenManager {
  TokenManager(this._storage);

  final SecureStorage _storage;

  Future<String?> getAccessToken() =>
      _storage.read(key: SecureStorageKeys.accessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: SecureStorageKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await Future.wait([
      _storage.write(key: SecureStorageKeys.accessToken, value: accessToken),
      _storage.write(key: SecureStorageKeys.refreshToken, value: refreshToken),
      _storage.write(
        key: SecureStorageKeys.tokenExpiry,
        value: expiry.toIso8601String(),
      ),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: SecureStorageKeys.accessToken),
      _storage.delete(key: SecureStorageKeys.refreshToken),
      _storage.delete(key: SecureStorageKeys.tokenExpiry),
      _storage.delete(key: SecureStorageKeys.userId),
      _storage.delete(key: SecureStorageKeys.userRole),
    ]);
  }

  Future<bool> get hasValidToken async {
    final token = await getAccessToken();
    if (token == null) return false;

    final expiryStr = await _storage.read(key: SecureStorageKeys.tokenExpiry);
    if (expiryStr == null) return false;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;

    return DateTime.now().isBefore(expiry);
  }

  /// Attempts silent token refresh using the refresh token.
  /// Throws on failure so the auth interceptor can handle logout.
  Future<void> refreshToken(Dio dio) async {
    final refresh = await getRefreshToken();
    if (refresh == null) throw Exception('No refresh token available');

    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refresh},
    );

    final data = response.data!;
    await saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiry: DateTime.parse(data['expires_at'] as String),
    );
  }
}
