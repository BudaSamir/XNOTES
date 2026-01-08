import 'dart:developer' as developer;

import 'package:xnotes_flutter/core/utils/app_exceptions/app_exceptions.dart';

/// Concise ErrorHandler summary.
///
/// Full documentation, detailed explanations, and examples have been moved
/// to: lib/utils/error_handler/error_handler.md
///
/// Quick usage summary:
/// - Use `handle<T>` for async operations that return a value.
/// - Use `handleAsync` for async operations that return void.
/// - Use `handleSync` for synchronous operations.
/// - Use `handleWithRetry` to add automatic retries with exponential backoff.
/// - Use `handleWithTimeout` to guard long-running operations with a timeout.
/// - Use `log` for structured developer logging.
///
/// See the full README at lib/utils/error_handler/error_handler.md for advanced examples,
/// typed-exception details, and recommended patterns.
class ErrorHandler {
  ErrorHandler._();

  /// Executes an async operation with error handling and logging.
  /// 
  /// Automatically logs:
  /// - Operation start time
  /// - Execution duration in milliseconds
  /// - Errors with stack traces
  /// 
  /// **Parameters:**
  /// - [operation]: The async function to execute that returns a value of type T
  /// - [tag]: Logger tag for identifying the source (e.g., 'UserService')
  /// - [operationName]: Human-readable description (e.g., 'Fetch user data')
  /// - [onError]: Optional callback invoked when an error occurs
  /// - [shouldRethrow]: Whether to rethrow the error (default: true)
  /// 
  /// **Returns:** The result of [operation], or null if error occurs and shouldRethrow=false
  /// 
  /// **Example:**
  /// ```dart
  /// final data = await ErrorHandler.handle<List<Note>>(
  ///   tag: 'NoteService',
  ///   operationName: 'Load all notes',
  ///   operation: () async {
  ///     return await database.fetchAllNotes();
  ///   },
  /// );
  /// ```
  static Future<T?> handle<T>({
    required Future<T> Function() operation,
    required String tag,
    required String operationName,
    void Function(dynamic error, StackTrace stackTrace)? onError,
    bool shouldRethrow = true,
  }) async {
    try {
      log('$operationName started', tag: tag);
      final startTime = DateTime.now();

      final result = await operation();

      final duration = DateTime.now().difference(startTime);
      log(
        '$operationName completed in ${duration.inMilliseconds}ms',
        tag: tag,
      );

      return result;
    } catch (e, stackTrace) {
      log(
        'Failed to $operationName',
        tag: tag,
        error: e,
        stackTrace: stackTrace,
      );

      onError?.call(e, stackTrace);

      if (shouldRethrow) {
        rethrow;
      }
      return null;
    }
  }

  /// Executes an async void operation with error handling and logging.
  /// 
  /// Use this for "fire and forget" operations or cleanup tasks.
  /// Does not return a value.
  /// 
  /// **Parameters:**
  /// - [operation]: The async void function to execute
  /// - [tag]: Logger tag for identifying the source
  /// - [operationName]: Human-readable description
  /// - [onError]: Optional callback for error handling
  /// - [shouldRethrow]: Whether to rethrow the error (default: true)
  /// 
  /// **Example:**
  /// ```dart
  /// await ErrorHandler.handleAsync(
  ///   tag: 'Cache',
  ///   operationName: 'Clear cache',
  ///   operation: () async {
  ///     await cache.clear();
  ///   },
  ///   shouldRethrow: false, // Don't stop app if cache clear fails
  /// );
  /// ```
  static Future<void> handleAsync({
    required Future<void> Function() operation,
    required String tag,
    required String operationName,
    void Function(dynamic error, StackTrace stackTrace)? onError,
    bool shouldRethrow = true,
  }) async {
    try {
      log('$operationName started', tag: tag);
      await operation();
      log('$operationName completed', tag: tag);
    } catch (e, stackTrace) {
      log(
        'Failed to $operationName',
        tag: tag,
        error: e,
        stackTrace: stackTrace,
      );

      onError?.call(e, stackTrace);

      if (shouldRethrow) {
        rethrow;
      }
    }
  }

  /// Executes a synchronous operation with error handling and logging.
  /// 
  /// Use for CPU-bound operations that don't require async/await.
  /// 
  /// **Parameters:**
  /// - [operation]: The sync function to execute that returns a value of type T
  /// - [tag]: Logger tag for identifying the source
  /// - [operationName]: Human-readable description
  /// - [onError]: Optional callback for error handling
  /// - [shouldRethrow]: Whether to rethrow the error (default: true)
  /// 
  /// **Returns:** The result of [operation], or null if error occurs and shouldRethrow=false
  /// 
  /// **Example:**
  /// ```dart
  /// final isValid = ErrorHandler.handleSync(
  ///   tag: 'Validation',
  ///   operationName: 'Parse JSON',
  ///   operation: () {
  ///     return jsonDecode(jsonString);
  ///   },
  ///   onError: (error, stackTrace) {
  ///     logger.recordError(error, stackTrace);
  ///   },
  /// );
  /// ```
  static T? handleSync<T>({
    required T Function() operation,
    required String tag,
    required String operationName,
    void Function(dynamic error, StackTrace stackTrace)? onError,
    bool shouldRethrow = true,
  }) {
    try {
      log('$operationName started', tag: tag);
      final result = operation();
      log('$operationName completed', tag: tag);
      return result;
    } catch (e, stackTrace) {
      log(
        'Failed to $operationName',
        tag: tag,
        error: e,
        stackTrace: stackTrace,
      );

      onError?.call(e, stackTrace);

      if (shouldRethrow) {
        rethrow;
      }
      return null;
    }
  }

  /// Logs a message with optional error and stack trace information.
  /// 
  /// All log messages include a timestamp and are tagged for easy filtering.
  /// 
  /// **Parameters:**
  /// - [message]: The log message
  /// - [tag]: Logger tag (namespace) for this log
  /// - [error]: Optional error object to log
  /// - [stackTrace]: Optional stack trace (use with [error])
  /// 
  /// **Example:**
  /// ```dart
  /// // Simple info log
  /// ErrorHandler.log('App initialized', tag: 'Main');
  /// 
  /// // Error log with context
  /// ErrorHandler.log(
  ///   'Database connection failed',
  ///   tag: 'Database',
  ///   error: exception,
  ///   stackTrace: stackTrace,
  /// );
  /// ```
  static void log(
    String message, {
    required String tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Executes an async operation with automatic retry on failure
  /// 
  /// **Parameters:**
  /// - [operation]: The async function to execute
  /// - [tag]: Logger tag
  /// - [operationName]: Operation description
  /// - [maxRetries]: Maximum number of retry attempts (default: 3)
  /// - [delayMs]: Initial delay in milliseconds between retries (default: 1000)
  /// - [backoffMultiplier]: Multiplier for exponential backoff (default: 2.0)
  /// - [shouldRethrow]: Whether to rethrow after all retries fail
  /// 
  /// **Example:**
  /// ```dart
  /// final result = await ErrorHandler.handleWithRetry<User>(
  ///   tag: 'UserService',
  ///   operationName: 'Fetch user',
  ///   operation: () async => await api.getUser(id),
  ///   maxRetries: 3,
  /// );
  /// ```
  static Future<T?> handleWithRetry<T>({
    required Future<T> Function() operation,
    required String tag,
    required String operationName,
    int maxRetries = 3,
    int delayMs = 1000,
    double backoffMultiplier = 2.0,
    bool shouldRethrow = true,
  }) async {
    int attempt = 0;
    Duration delay = Duration(milliseconds: delayMs);

    while (attempt <= maxRetries) {
      try {
        log('$operationName - attempt ${attempt + 1}', tag: tag);
        final startTime = DateTime.now();

        final result = await operation();

        final duration = DateTime.now().difference(startTime);
        log(
          '$operationName completed in ${duration.inMilliseconds}ms',
          tag: tag,
        );

        return result;
      } catch (e, stackTrace) {
        attempt++;
        final isRetryable = (e as dynamic).isRetryable ?? true;
        final hasMoreAttempts = attempt <= maxRetries;

        if (hasMoreAttempts && isRetryable) {
          log(
            '$operationName failed (attempt $attempt/$maxRetries). Retrying in ${delay.inMilliseconds}ms',
            tag: tag,
            error: e,
          );

          await Future.delayed(delay);
          delay = Duration(
            milliseconds: (delay.inMilliseconds * backoffMultiplier).toInt(),
          );
        } else {
          log(
            'Failed to $operationName after $attempt attempts',
            tag: tag,
            error: e,
            stackTrace: stackTrace,
          );

          if (shouldRethrow) {
            rethrow;
          }
          return null;
        }
      }
    }

    return null;
  }

  /// Executes an async operation with timeout
  /// 
  /// **Parameters:**
  /// - [operation]: The async function to execute
  /// - [tag]: Logger tag
  /// - [operationName]: Operation description
  /// - [timeout]: Maximum time to wait (default: 30 seconds)
  /// - [shouldRethrow]: Whether to rethrow timeout errors
  /// 
  /// **Example:**
  /// ```dart
  /// final result = await ErrorHandler.handleWithTimeout<List<Note>>(
  ///   tag: 'NoteService',
  ///   operationName: 'Fetch all notes',
  ///   operation: () async => await api.getAllNotes(),
  ///   timeout: Duration(seconds: 15),
  /// );
  /// ```
  static Future<T?> handleWithTimeout<T>({
    required Future<T> Function() operation,
    required String tag,
    required String operationName,
    Duration timeout = const Duration(seconds: 30),
    bool shouldRethrow = true,
  }) async {
    try {
      log('$operationName started (timeout: ${timeout.inSeconds}s)', tag: tag);
      final startTime = DateTime.now();

      final result = await operation().timeout(timeout, onTimeout: () {
        throw TimeoutException(
          message: 'Operation timed out after ${timeout.inSeconds}s',
          timeout: timeout,
        );
      });

      final duration = DateTime.now().difference(startTime);
      log(
        '$operationName completed in ${duration.inMilliseconds}ms',
        tag: tag,
      );

      return result;
    } catch (e, stackTrace) {
      log(
        'Failed to $operationName',
        tag: tag,
        error: e,
        stackTrace: stackTrace,
      );

      if (shouldRethrow) {
        rethrow;
      }
      return null;
    }
  }
}
