import 'dart:math';
import 'package:dio/dio.dart';

/// Retries failed requests with exponential backoff.
/// Only retries on transient network errors and 5xx server errors.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.retries = 3});

  final Dio dio;
  final int retries;

  static const _retriesKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retriesKey] as int?) ?? 0;
    final shouldRetry = _isRetryable(err) && attempt < retries;

    if (!shouldRetry) {
      return handler.next(err);
    }

    // Exponential backoff: 500ms, 1s, 2s, 4s...
    final delayMs = (500 * pow(2, attempt)).toInt();
    await Future.delayed(Duration(milliseconds: delayMs));

    final updatedOptions = err.requestOptions.copyWith(
      extra: {...err.requestOptions.extra, _retriesKey: attempt + 1},
    );

    try {
      final response = await dio.fetch<dynamic>(updatedOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
