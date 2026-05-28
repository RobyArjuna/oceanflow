import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 100,
    colors: true,
    printEmojis: true,
  ),
);

/// Structured request/response logger for development builds.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '→ ${options.method} ${options.path}\n'
      '  Headers: ${_sanitizeHeaders(options.headers)}\n'
      '  Query: ${options.queryParameters}\n'
      '  Body: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      '← ${response.statusCode} ${response.requestOptions.path}\n'
      '  Body: ${response.data.toString().substring(0, _clamp(response.data.toString().length, 500))}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✗ ${err.requestOptions.method} ${err.requestOptions.path}\n'
      '  Status: ${err.response?.statusCode}\n'
      '  Error: ${err.message}',
      error: err.error,
    );
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = 'Bearer ***';
    }
    return sanitized;
  }

  int _clamp(int value, int max) => value < max ? value : max;
}
