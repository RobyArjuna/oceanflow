import 'app_flavor.dart';

/// Centralized environment configuration per flavor.
/// All environment-specific values (URLs, keys, flags) are resolved here.
class FlavorConfig {
  FlavorConfig._();

  static FlavorConfig? _instance;
  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig must be initialized before use.');
    return _instance!;
  }

  static void initialize(AppFlavor flavor) {
    _instance = FlavorConfig._()
      .._flavor = flavor
      .._values = _FlavorValues.from(flavor);
  }

  late AppFlavor _flavor;
  late _FlavorValues _values;

  AppFlavor get flavor => _flavor;

  bool get isDev => _flavor == AppFlavor.dev;
  bool get isStaging => _flavor == AppFlavor.staging;
  bool get isProd => _flavor == AppFlavor.prod;

  String get baseUrl => _values.baseUrl;
  String get geminiApiKey => _values.geminiApiKey;
  bool get enableMockApi => _values.enableMockApi;
  bool get enableDetailedLogging => _values.enableDetailedLogging;
  int get syncIntervalMinutes => _values.syncIntervalMinutes;
}

class _FlavorValues {
  final String baseUrl;
  final String geminiApiKey;
  final bool enableMockApi;
  final bool enableDetailedLogging;
  final int syncIntervalMinutes;

  const _FlavorValues({
    required this.baseUrl,
    required this.geminiApiKey,
    required this.enableMockApi,
    required this.enableDetailedLogging,
    required this.syncIntervalMinutes,
  });

  factory _FlavorValues.from(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return const _FlavorValues(
          baseUrl: 'http://localhost:3000/api/v1',
          geminiApiKey: 'YOUR_GEMINI_API_KEY_DEV', // Replace with real key
          enableMockApi: true,
          enableDetailedLogging: true,
          syncIntervalMinutes: 1,
        );
      case AppFlavor.staging:
        return const _FlavorValues(
          baseUrl: 'https://staging-api.oceanflow.io/api/v1',
          geminiApiKey: 'YOUR_GEMINI_API_KEY_STAGING',
          enableMockApi: false,
          enableDetailedLogging: true,
          syncIntervalMinutes: 5,
        );
      case AppFlavor.prod:
        return const _FlavorValues(
          baseUrl: 'https://api.oceanflow.io/api/v1',
          geminiApiKey: 'YOUR_GEMINI_API_KEY_PROD',
          enableMockApi: false,
          enableDetailedLogging: false,
          syncIntervalMinutes: 15,
        );
    }
  }
}
