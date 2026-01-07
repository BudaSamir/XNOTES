# ErrorHandler Unit Tests

This file documents the unit tests in `error_handler_test.dart` and how to run them.

## Purpose

The tests exercise the core `ErrorHandler` helpers to ensure:

- `handleSync` executes synchronous operations and returns expected values.
- `handle<T>` executes async operations that return values.
- `handleAsync` executes async void operations without throwing when `shouldRethrow=false`.
- `handleWithRetry` retries transient errors (using `NetworkException`) and eventually succeeds.
- `handleWithTimeout` returns `null` on timeout when `shouldRethrow=false`.

These tests are small and deterministic; they use short delays so they run quickly during CI.

## Running the tests

Run the single test file with:

```bash
flutter test lib/utils/error_handler/error_handler_test.dart
```

Run all tests in the project with:

```bash
flutter test
```

## Notes and guidance

- The retry test uses `NetworkException` to simulate a transient failure; ensure the exception class remains retryable.
- The timeout test uses `shouldRethrow: false` to assert the handler returns `null` on timeout; change behavior if your app prefers throwing.
- If you add more tests, place them in this directory and add short descriptions here.

---

## Detailed Test Descriptions

Below are the tests included in `error_handler_test.dart` with their intent and expected outcomes.

- `handleSync returns result`
	- Intent: Verify `handleSync<T>` executes synchronous operations and returns the computed value.
	- Setup: operation returns `42`.
	- Expectation: function returns `42` and no exceptions are thrown.

- `handle returns result`
	- Intent: Verify `handle<T>` executes an async operation and returns its result.
	- Setup: async operation returns `7`.
	- Expectation: returned value is `7`.

- `handleAsync executes without error`
	- Intent: Verify `handleAsync` runs async void operations and honors `shouldRethrow`.
	- Setup: a small operation sets a local flag; `shouldRethrow: false`.
	- Expectation: the flag becomes `true`, and no exception propagates.

- `handleWithRetry succeeds after retries`
	- Intent: Validate retry logic and exponential/backoff behavior for transient errors.
	- Setup: operation throws `NetworkException` on first two attempts and returns `123` on the third.
	- Parameters: `maxRetries: 3`, `delayMs: 10`, `backoffMultiplier: 1.0` (small delays for CI speed).
	- Expectation: final return is `123`, and total attempts equals 3.

- `handleWithTimeout returns null on timeout when shouldRethrow=false`
	- Intent: Ensure `handleWithTimeout` enforces a timeout and returns `null` when `shouldRethrow` is false.
	- Setup: operation waits 200ms; timeout is 50ms; `shouldRethrow: false`.
	- Expectation: result is `null`, no exception escapes the handler.

---

## Extending Tests

- Add tests for `handleWithRetry` non-retryable errors (e.g., `ConfigException`) to assert no retries occur.
- Add tests for `handle` and `handleAsync` with `shouldRethrow: true` to ensure exceptions propagate when expected.
- Add tests that assert logging was called by injecting a custom logger or by listening to `dart:developer` (integration-style).

## CI Recommendations

- Keep retry delays short in unit tests to avoid long-running CI jobs; use tiny `delayMs` values for deterministic coverage.
- For flaky tests related to scheduling or timers, increase timeouts slightly or mock time when possible.

---

If you want, I can add more tests (e.g., non-retryable error behavior, logging verification) or run the test file now and report results.
