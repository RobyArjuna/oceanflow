import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesStorageProvider = Provider<PreferencesStorage>(
  (ref) => PreferencesStorage(),
);

/// Non-sensitive preferences storage wrapper.
/// Use for UI settings, feature flags, and non-critical state.
class PreferencesStorage {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setString(String key, String value) async =>
      (await _instance).setString(key, value);

  Future<String?> getString(String key) async =>
      (await _instance).getString(key);

  Future<void> setBool(String key, bool value) async =>
      (await _instance).setBool(key, value);

  Future<bool?> getBool(String key) async =>
      (await _instance).getBool(key);

  Future<void> setInt(String key, int value) async =>
      (await _instance).setInt(key, value);

  Future<int?> getInt(String key) async =>
      (await _instance).getInt(key);

  Future<void> remove(String key) async =>
      (await _instance).remove(key);

  Future<void> clear() async => (await _instance).clear();
}

abstract final class PrefKeys {
  static const themeMode = 'theme_mode';
  static const lastSyncAt = 'last_sync_at';
  static const onboardingComplete = 'onboarding_complete';
  static const selectedRole = 'selected_role';
  static const notificationsEnabled = 'notifications_enabled';
}
