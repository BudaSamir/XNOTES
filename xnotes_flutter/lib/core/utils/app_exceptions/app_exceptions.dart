/// Custom exception types for the application
/// 
/// This file defines all custom exception types used throughout the app.
/// Allows for precise error handling and recovery strategies.

/// Base exception for all app errors
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Network-related errors (connectivity, server errors)
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  /// Whether this error is retryable
  bool get isRetryable => true;
}

/// Timeout errors during operations
class TimeoutException extends AppException {
  final Duration timeout;

  TimeoutException({
    required super.message,
    required this.timeout,
    super.originalError,
    super.stackTrace,
  });

  /// Timeout errors are always retryable
  bool get isRetryable => true;
}

/// Configuration errors (missing config, invalid values)
class ConfigException extends AppException {
  ConfigException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  /// Config errors are NOT retryable
  bool get isRetryable => false;
}

/// Authentication/Authorization errors
class AuthException extends AppException {
  final String? code;

  AuthException({
    required super.message,
    this.code,
    super.originalError,
    super.stackTrace,
  });

  /// Auth errors are NOT retryable
  bool get isRetryable => false;
}

/// Initialization errors (setup failures)
class InitializationException extends AppException {
  final String component; // e.g., 'AppConfig', 'ServerCommunication'

  InitializationException({
    required super.message,
    required this.component,
    super.originalError,
    super.stackTrace,
  });

  /// Some initialization errors are retryable (network), others aren't (config)
  bool get isRetryable => originalError is NetworkException || 
                         originalError is TimeoutException;
}

/// Unknown/unexpected errors
class UnknownException extends AppException {
  UnknownException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  /// Unknown errors might be retryable
  bool get isRetryable => true;
}

/// Validation errors for user input or data integrity checks
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  /// Validation errors are not retryable
  bool get isRetryable => false;
}

/// Extension to check if exception is retryable
extension ExceptionRetryable on Exception {
  bool get isRetryable {
    if (this is AppException) {
      final ex = this as AppException;
      if (ex is NetworkException) return ex.isRetryable;
      if (ex is TimeoutException) return ex.isRetryable;
      if (ex is ConfigException) return ex.isRetryable;
      if (ex is AuthException) return ex.isRetryable;
      if (ex is InitializationException) return ex.isRetryable;
      if (ex is UnknownException) return ex.isRetryable;
    }
    return true; // Assume retryable by default
  }

  /// Categorize the exception for logging and analytics
  String get category {
    if (this is NetworkException) return 'network';
    if (this is TimeoutException) return 'timeout';
    if (this is ConfigException) return 'config';
    if (this is AuthException) return 'auth';
    if (this is InitializationException) return 'initialization';
    if (this is UnknownException) return 'unknown';
    return 'uncategorized';
  }
}
