import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/flavor/flavor_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Singleton Dio HTTP client with enterprise interceptor chain.
///
/// Interceptor execution order (request): Auth → Logging
/// Interceptor execution order (response): Error → Retry → Logging
final dioClientProvider = Provider<Dio>((ref) {
  return _buildDioClient(ref);
});

Dio _buildDioClient(Ref ref) {
  final config = FlavorConfig.instance;

  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Platform': 'flutter',
        'X-Client-Version': '1.0.0',
      },
    ),
  );

  // Auth interceptor first — injects Bearer token
  dio.interceptors.add(AuthInterceptor(dio, ref));

  // Retry interceptor — handles transient failures
  dio.interceptors.add(RetryInterceptor(dio: dio, retries: 3));

  // Error interceptor — maps DioException → AppError
  dio.interceptors.add(ErrorInterceptor());

  // Logging last — logs final request/response state
  if (config.enableDetailedLogging) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
}
