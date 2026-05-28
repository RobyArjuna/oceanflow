import 'package:dio/dio.dart';
import '../../error/app_error.dart';
import '../../error/error_mapper.dart';

/// Maps DioExceptions to typed AppError and re-throws.
/// Runs after retry interceptor — only fires when retries exhausted.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = ErrorMapper.fromDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appError,
        type: err.type,
        response: err.response,
        message: appError.message,
      ),
    );
  }
}
