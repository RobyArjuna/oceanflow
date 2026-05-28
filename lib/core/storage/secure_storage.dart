import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

/// Type-safe wrapper over FlutterSecureStorage.
/// All sensitive data (tokens, credentials) must flow through this class.
class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  Future<String?> read({required String key}) => _storage.read(key: key);

  Future<void> delete({required String key}) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<bool> containsKey({required String key}) =>
      _storage.containsKey(key: key);
}

/// Storage key constants to avoid magic strings.
abstract final class SecureStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';
  static const userRole = 'user_role';
  static const tokenExpiry = 'token_expiry';
}
