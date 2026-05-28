/// Sealed class hierarchy for typed, domain-aware error handling.
/// All errors propagate through the app as AppError subtypes.
sealed class AppError implements Exception {
  const AppError();

  String get message;
}

/// No internet connection or connection timed out.
final class NetworkError extends AppError {
  const NetworkError({this.message = 'No internet connection. Please check your network.'});

  @override
  final String message;
}

/// 401 Unauthorized — session expired or invalid credentials.
final class AuthError extends AppError {
  const AuthError({this.message = 'Session expired. Please log in again.'});

  @override
  final String message;
}

/// 403 Forbidden — insufficient role permissions.
final class PermissionError extends AppError {
  const PermissionError({
    this.message = 'You do not have permission to perform this action.',
    this.requiredRole,
  });

  @override
  final String message;
  final String? requiredRole;
}

/// 4xx client-side errors (excluding 401, 403).
final class ClientError extends AppError {
  const ClientError({required this.statusCode, required this.message});

  final int statusCode;

  @override
  final String message;
}

/// 5xx server errors.
final class ServerError extends AppError {
  const ServerError({
    required this.statusCode,
    this.message = 'A server error occurred. Please try again later.',
  });

  final int statusCode;

  @override
  final String message;
}

/// SQLite / local database failures.
final class DatabaseError extends AppError {
  const DatabaseError({required this.message, this.cause});

  @override
  final String message;
  final Object? cause;
}

/// Sync queue action failed after exhausting retries.
final class SyncError extends AppError {
  const SyncError({required this.message, this.failedActionId});

  @override
  final String message;
  final String? failedActionId;
}

/// Validation error — user input or data contract mismatch.
final class ValidationError extends AppError {
  const ValidationError({required this.message, this.fields = const {}});

  @override
  final String message;
  final Map<String, String> fields;
}

/// Catch-all for truly unexpected errors.
final class UnknownError extends AppError {
  const UnknownError({this.message = 'An unexpected error occurred.', this.cause});

  @override
  final String message;
  final Object? cause;
}
