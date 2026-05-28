import 'package:dio/dio.dart';
import 'app_error.dart';

/// Maps raw DioException and generic exceptions to typed AppError.
abstract final class ErrorMapper {
  ErrorMapper._();

  static AppError fromDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkError();

      case DioExceptionType.badResponse:
        return _fromStatusCode(
          err.response?.statusCode,
          err.response?.data,
        );

      case DioExceptionType.cancel:
        return const NetworkError(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkError(message: 'SSL certificate error.');

      case DioExceptionType.unknown:
        if (err.error is AppError) return err.error as AppError;
        return UnknownError(cause: err.error);
    }
  }

  static AppError fromException(Object error, [StackTrace? st]) {
    if (error is AppError) return error;
    if (error is DioException) return fromDioException(error);
    return UnknownError(cause: error);
  }

  static AppError _fromStatusCode(int? code, dynamic data) {
    final serverMessage = _extractMessage(data);

    switch (code) {
      case 400:
        return ClientError(
          statusCode: 400,
          message: serverMessage ?? 'Bad request. Please check your input.',
        );
      case 401:
        return AuthError(message: serverMessage ?? 'Session expired. Please log in again.');
      case 403:
        return PermissionError(message: serverMessage ?? 'Access denied.');
      case 404:
        return ClientError(statusCode: 404, message: serverMessage ?? 'Resource not found.');
      case 422:
        return ValidationError(
          message: serverMessage ?? 'Validation failed.',
        );
      case 429:
        return ClientError(statusCode: 429, message: 'Too many requests. Please wait and try again.');
      default:
        if (code != null && code >= 500) {
          return ServerError(statusCode: code, message: serverMessage ?? 'Server error. Please try again.');
        }
        return UnknownError(message: 'Unexpected response: $code');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    return null;
  }
}
