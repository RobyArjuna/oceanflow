import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/token_manager.dart';
import '../api_endpoints.dart';

/// Injects JWT Bearer token into every request.
/// Handles 401 responses by attempting token refresh once (token rotation).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenManager = _ref.read(tokenManagerProvider);
    final token = await tokenManager.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Attempt token refresh on 401, then retry once
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != ApiEndpoints.refreshToken) {
      try {
        final tokenManager = _ref.read(tokenManagerProvider);
        await tokenManager.refreshToken(_dio);

        // Retry original request with new token
        final token = await tokenManager.getAccessToken();
        final opts = Options(
          method: err.requestOptions.method,
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $token',
          },
        );

        final response = await _dio.request<dynamic>(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: opts,
        );

        return handler.resolve(response);
      } catch (_) {
        // Refresh failed — force logout
        final tokenManager = _ref.read(tokenManagerProvider);
        await tokenManager.clearTokens();
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
