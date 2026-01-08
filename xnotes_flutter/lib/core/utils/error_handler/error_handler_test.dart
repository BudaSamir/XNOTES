/// Unit tests for `ErrorHandler`.
///
/// See the detailed test README at:
/// `lib/utils/error_handler/error_handler_test.md`
///
/// Run this specific test file with:
/// ```bash
/// flutter test lib/utils/error_handler/error_handler_test.dart
/// ```
import 'package:flutter_test/flutter_test.dart';
import 'package:xnotes_flutter/core/utils/error_handler/error_handler.dart';
import 'package:xnotes_flutter/core/utils/app_exceptions/app_exceptions.dart';

void main() {
  test('handleSync returns result', () {
    final v = ErrorHandler.handleSync<int>(
      operation: () => 42,
      tag: 'Test',
      operationName: 'sync',
    );
    expect(v, 42);
  });

  test('handle returns result', () async {
    final v = await ErrorHandler.handle<int>(
      operation: () async => 7,
      tag: 'Test',
      operationName: 'async',
    );
    expect(v, 7);
  });

  test('handleAsync executes without error', () async {
    var called = false;
    await ErrorHandler.handleAsync(
      operation: () async {
        called = true;
      },
      tag: 'Test',
      operationName: 'asyncVoid',
      shouldRethrow: false,
    );
    expect(called, isTrue);
  });

  test('handleWithRetry succeeds after retries', () async {
    int attempts = 0;
    final result = await ErrorHandler.handleWithRetry<int>(
      operation: () async {
        attempts++;
        if (attempts < 3) {
          throw NetworkException(message: 'transient');
        }
        return 123;
      },
      tag: 'Test',
      operationName: 'retryOp',
      maxRetries: 3,
      delayMs: 10,
      backoffMultiplier: 1.0,
    );

    expect(result, 123);
    expect(attempts, 3);
  });

  test('handleWithTimeout returns null on timeout when shouldRethrow=false', () async {
    final result = await ErrorHandler.handleWithTimeout<int>(
      operation: () async {
        await Future.delayed(Duration(milliseconds: 200));
        return 1;
      },
      tag: 'Test',
      operationName: 'timeoutOp',
      timeout: Duration(milliseconds: 50),
      shouldRethrow: false,
    );
    expect(result, isNull);
  });
}
