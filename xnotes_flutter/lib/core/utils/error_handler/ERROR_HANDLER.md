# ErrorHandler — Full Documentation

This document contains the comprehensive documentation for `ErrorHandler` used across the app.
It explains behavior, configuration, examples, and recommended usage patterns.

---

## Overview

`ErrorHandler` is a centralized utility that standardizes how the app executes operations, logs information, and handles errors. It provides helpers to:

- Execute async operations that return values with timing and error handling (`handle<T>`).
- Execute async void operations (`handleAsync`).
- Execute synchronous operations (`handleSync`).
- Run operations with automatic retry and exponential backoff (`handleWithRetry`).
- Protect operations with timeouts (`handleWithTimeout`).
- Emit structured logs (`log`).

`ErrorHandler` is intentionally minimal in dependencies (uses `dart:developer`) and works well with typed exceptions (see `custom_exceptions.dart`) to make retry decisions deterministic.

---

## API Reference & Examples

### 1) `handle<T>` — Async operation returning a value

Use when you need a return value from an async call and want consistent logging and error handling.

Example:

```dart
final user = await ErrorHandler.handle<User?>(
  tag: 'UserService',
  operationName: 'Fetch user profile',
  operation: () async {
    final response = await api.getUser(userId);
    return User.fromJson(response);
  },
  onError: (error, stackTrace) {
    // Optional: convert to user-visible message or track telemetry
    analytics.trackError('fetch_user_failed', error, stackTrace);
  },
  shouldRethrow: false, // return null on error instead of bubbling
);
```

Behavior:
- Logs start and completion with elapsed time.
- On exception, logs error and stack trace, calls `onError` if provided.
- If `shouldRethrow` is `true`, the exception is rethrown; otherwise `null` is returned.


### 2) `handleAsync` — Async void operations

Use for fire-and-forget or cleanup tasks where you don't need a return value.

```dart
await ErrorHandler.handleAsync(
  tag: 'Analytics',
  operationName: 'Send analytics event',
  operation: () async {
    await analytics.logEvent('user_signup');
  },
  shouldRethrow: false, // swallow failures
);
```


### 3) `handleSync` — Synchronous operations

Use for CPU-bound or synchronous execution that still needs consistent logging and error handling.

```dart
final parsed = ErrorHandler.handleSync<Map<String, dynamic>?>(
  tag: 'Parser',
  operationName: 'Parse server response',
  operation: () => jsonDecode(responseText),
  shouldRethrow: false,
);
```


### 4) `handleWithRetry` — Retry with Exponential Backoff

Wrap operations that may transiently fail (network hiccups) and are safe to retry. Use typed exceptions from `custom_exceptions.dart` to mark retryability.

Parameters:
- `maxRetries` (default 3) — number of retry attempts
- `delayMs` (default 1000) — initial delay before first retry
- `backoffMultiplier` (default 2.0) — multiplier for exponential growth of delay

Example:

```dart
final data = await ErrorHandler.handleWithRetry<List<Item>>(
  tag: 'ApiClient',
  operationName: 'Fetch items',
  operation: () async => await api.getItems(),
  maxRetries: 3,
  delayMs: 1000,
  backoffMultiplier: 2.0,
);
```

Log pattern for retries:

```
[ApiClient] Fetch items - attempt 1
[ApiClient] Fetch items failed (attempt 1/3). Retrying in 1000ms
[ApiClient] Fetch items - attempt 2
...
```

Notes:
- The handler inspects exceptions (via `e.isRetryable`) to avoid retrying non-transient errors.
- If the exception does not expose `isRetryable`, the default is to assume retryable.


### 5) `handleWithTimeout` — Timeout protection

Use to guard long-running operations and ensure the app can recover or fail fast.

```dart
final result = await ErrorHandler.handleWithTimeout<List<Note>>(
  tag: 'NoteService',
  operationName: 'Fetch all notes',
  operation: () async => await api.getAllNotes(),
  timeout: Duration(seconds: 15),
);
```

Behavior:
- On timeout, a `TimeoutException` (from `custom_exceptions.dart`) is thrown and handled like other exceptions.
- The operation is canceled only via the `Future.timeout` mechanism; if the underlying API supports cancellation tokens, prefer that.


### 6) `log` — Structured logging

Use to write developer logs with optional error and stack trace.

```dart
ErrorHandler.log('Storage initialized', tag: 'Storage');
ErrorHandler.log('DB error', tag: 'Database', error: e, stackTrace: st);
```

Logs are emitted via `dart:developer.log` and include the provided `tag` as the logger name.

---

## Typed Exceptions & Retry Strategy

See `lib/utils/custom_exceptions.dart` for typed exceptions such as:
- `NetworkException` (retryable)
- `TimeoutException` (retryable)
- `ConfigException` (not retryable)
- `AuthException` (not retryable)
- `InitializationException` (conditional)
- `UnknownException`

Use these to make retry decisions explicit. Example:

```dart
try {
  await ErrorHandler.handleWithRetry(
    tag: 'Api',
    operationName: 'Get resource',
    operation: () async => await api.fetch(),
  );
} catch (e) {
  if ((e as dynamic).isRetryable == true) {
    // handle as transient
  } else {
    // show user-friendly permanent error
  }
}
```

---

## Recommended Patterns

- Keep the operation lambda focused: do not pass UI code into the operation. Use `onError` to transform errors for the UI.
- Prefer returning `null` via `shouldRethrow: false` for best-effort operations where a failure is safe.
- For critical init flows (e.g., loading configuration), prefer `handleWithTimeout` + `shouldRethrow: true` so failures propagate to the startup logic.
- Use `handleWithRetry` for idempotent network reads, not for operations that create or mutate remote state unless they are designed to be idempotent.

---

## Example: Robust startup sequence

```dart
await ErrorHandler.handle<void>(
  tag: 'Startup',
  operationName: 'Initialize app',
  operation: () async {
    await Future.wait([
      AppConfig.initialize(),
      ServerCommunication.initialize(),
    ]);
  },
  onError: (e, st) {
    // Report to telemetry and show error UI
    telemetry.captureException(e, st);
  },
);
```

For startups that must not hang, wrap in a timeout:

```dart
await ErrorHandler.handleWithTimeout<void>(
  tag: 'Startup',
  operationName: 'Initialize app (timeout protected)',
  operation: () async {
    await Future.wait([
      AppConfig.initialize(),
      ServerCommunication.initialize(),
    ]);
  },
  timeout: Duration(seconds: 30),
);
```

---

## Troubleshooting & FAQs

Q: My retry attempts are not happening — why?
A: Ensure the thrown exception is marked retryable (use the typed exceptions) or that the thrown object exposes `isRetryable` as `true`.

Q: I need cancellation support for long tasks.
A: `handleWithTimeout` uses `Future.timeout`. If you require cooperative cancellation, design your long-running API to accept a cancellation token and check it inside the operation.

Q: Can I integrate with Sentry / Crashlytics?
A: Yes. Provide an `onError` callback to send errors to external services before rethrowing or swallowing.

---

## File Locations

- `lib/utils/error_handler/error_handler.dart` — compact summary and implementation.
- `lib/utils/error_handler/error_handler.md` — this full documentation file.
- `lib/utils/custom_exceptions.dart` — typed exceptions recommended for use with `ErrorHandler`.

---

If you'd like, I can also:
- Add a small unit test harness demonstrating each API entry point.
- Integrate `ErrorHandler` with an existing telemetry provider.
- Generate a short quick-reference cheat sheet for the team.
# ErrorHandler — Full Documentation

This document contains the comprehensive documentation for `ErrorHandler` used across the app.
It explains behavior, configuration, examples, and recommended usage patterns.

---

## Overview

`ErrorHandler` is a centralized utility that standardizes how the app executes operations, logs information, and handles errors. It provides helpers to:

- Execute async operations that return values with timing and error handling (`handle<T>`).
- Execute async void operations (`handleAsync`).
- Execute synchronous operations (`handleSync`).
- Run operations with automatic retry and exponential backoff (`handleWithRetry`).
- Protect operations with timeouts (`handleWithTimeout`).
- Emit structured logs (`log`).

`ErrorHandler` is intentionally minimal in dependencies (uses `dart:developer`) and works well with typed exceptions (see `custom_exceptions.dart`) to make retry decisions deterministic.

---

## API Reference & Examples

### 1) `handle<T>` — Async operation returning a value

Use when you need a return value from an async call and want consistent logging and error handling.

Example:

 
final user = await ErrorHandler.handle<User?>(
  tag: 'UserService',
  operationName: 'Fetch user profile',
  operation: () async {
    final response = await api.getUser(userId);
    return User.fromJson(response);
  },
  onError: (error, stackTrace) {
    // Optional: convert to user-visible message or track telemetry
    analytics.trackError('fetch_user_failed', error, stackTrace);
  },
  shouldRethrow: false, // return null on error instead of bubbling
);
```

Behavior:


### 2) `handleAsync` — Async void operations

Use for fire-and-forget or cleanup tasks where you don't need a return value.

```dart
await ErrorHandler.handleAsync(
  tag: 'Analytics',
  operationName: 'Send analytics event',
  operation: () async {
    await analytics.logEvent('user_signup');
  },
  shouldRethrow: false, // swallow failures
);
```


### 3) `handleSync` — Synchronous operations

Use for CPU-bound or synchronous execution that still needs consistent logging and error handling.

```dart
final parsed = ErrorHandler.handleSync<Map<String, dynamic>?>(
  tag: 'Parser',
  operationName: 'Parse server response',
  operation: () => jsonDecode(responseText),
  shouldRethrow: false,
);
```


### 4) `handleWithRetry` — Retry with Exponential Backoff

Wrap operations that may transiently fail (network hiccups) and are safe to retry. Use typed exceptions from `custom_exceptions.dart` to mark retryability.

Parameters:
- `maxRetries` (default 3) — number of retry attempts
- `delayMs` (default 1000) — initial delay before first retry
- `backoffMultiplier` (default 2.0) — multiplier for exponential growth of delay

Example:

```dart
final data = await ErrorHandler.handleWithRetry<List<Item>>(
  tag: 'ApiClient',
  operationName: 'Fetch items',
  operation: () async => await api.getItems(),
  maxRetries: 3,
  delayMs: 1000,
  backoffMultiplier: 2.0,
);
```

Log pattern for retries:

```
[ApiClient] Fetch items - attempt 1
[ApiClient] Fetch items failed (attempt 1/3). Retrying in 1000ms
[ApiClient] Fetch items - attempt 2
...
```

Notes:
- The handler inspects exceptions (via `e.isRetryable`) to avoid retrying non-transient errors.
- If the exception does not expose `isRetryable`, the default is to assume retryable.


### 5) `handleWithTimeout` — Timeout protection

Use to guard long-running operations and ensure the app can recover or fail fast.

```dart
final result = await ErrorHandler.handleWithTimeout<List<Note>>(
  tag: 'NoteService',
  operationName: 'Fetch all notes',
  operation: () async => await api.getAllNotes(),
  timeout: Duration(seconds: 15),
);
```

Behavior:
- On timeout, a `TimeoutException` (from `custom_exceptions.dart`) is thrown and handled like other exceptions.
- The operation is canceled only via the `Future.timeout` mechanism; if the underlying API supports cancellation tokens, prefer that.


### 6) `log` — Structured logging

Use to write developer logs with optional error and stack trace.

```dart
ErrorHandler.log('Storage initialized', tag: 'Storage');
ErrorHandler.log('DB error', tag: 'Database', error: e, stackTrace: st);
```

Logs are emitted via `dart:developer.log` and include the provided `tag` as the logger name.

---

## Typed Exceptions & Retry Strategy

See `lib/utils/custom_exceptions.dart` for typed exceptions such as:
- `NetworkException` (retryable)
- `TimeoutException` (retryable)
- `ConfigException` (not retryable)
- `AuthException` (not retryable)
- `InitializationException` (conditional)
- `UnknownException`

Use these to make retry decisions explicit. Example:

```dart
try {
  await ErrorHandler.handleWithRetry(
    tag: 'Api',
    operationName: 'Get resource',
    operation: () async => await api.fetch(),
  );
} catch (e) {
  if ((e as dynamic).isRetryable == true) {
    // handle as transient
  } else {
    // show user-friendly permanent error
  }
}
```

---

## Recommended Patterns

- Keep the operation lambda focused: do not pass UI code into the operation. Use `onError` to transform errors for the UI.
- Prefer returning `null` via `shouldRethrow: false` for best-effort operations where a failure is safe.
- For critical init flows (e.g., loading configuration), prefer `handleWithTimeout` + `shouldRethrow: true` so failures propagate to the startup logic.
- Use `handleWithRetry` for idempotent network reads, not for operations that create or mutate remote state unless they are designed to be idempotent.

---

## Example: Robust startup sequence

```dart
await ErrorHandler.handle<void>(
  tag: 'Startup',
  operationName: 'Initialize app',
  operation: () async {
    await Future.wait([
      AppConfig.initialize(),
      ServerCommunication.initialize(),
    ]);
  },
  onError: (e, st) {
    // Report to telemetry and show error UI
    telemetry.captureException(e, st);
  },
);
```

For startups that must not hang, wrap in a timeout:

```dart
await ErrorHandler.handleWithTimeout<void>(
  tag: 'Startup',
  operationName: 'Initialize app (timeout protected)',
  operation: () async {
    await Future.wait([
      AppConfig.initialize(),
      ServerCommunication.initialize(),
    ]);
  },
  timeout: Duration(seconds: 30),
);
```

---

## Troubleshooting & FAQs

Q: My retry attempts are not happening — why?
A: Ensure the thrown exception is marked retryable (use the typed exceptions) or that the thrown object exposes `isRetryable` as `true`.

Q: I need cancellation support for long tasks.
A: `handleWithTimeout` uses `Future.timeout`. If you require cooperative cancellation, design your long-running API to accept a cancellation token and check it inside the operation.

Q: Can I integrate with Sentry / Crashlytics?
A: Yes. Provide an `onError` callback to send errors to external services before rethrowing or swallowing.

---

## File Locations

- `lib/utils/error_handler.dart` — compact summary and implementation.
- `lib/utils/ERROR_HANDLER.md` — this full documentation file.
- `lib/utils/custom_exceptions.dart` — typed exceptions recommended for use with `ErrorHandler`.

---

If you'd like, I can also:
- Add a small unit test harness demonstrating each API entry point.
- Integrate `ErrorHandler` with an existing telemetry provider.
- Generate a short quick-reference cheat sheet for the team.
