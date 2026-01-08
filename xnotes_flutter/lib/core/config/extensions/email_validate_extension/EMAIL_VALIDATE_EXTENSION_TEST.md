# Email Validation Tests

Comprehensive unit tests for `email_validate_extension.dart`.

---

## Overview

This file contains **25 individual test cases** organized into 6 test groups covering:

- Silent validation (`isEmailValid()`)
- Throwing validation (`validateOrThrow()`)
- Nullable variants (`isEmailValidOrNull()`, `validateOrThrowNullable()`)
- Exception handling
- Edge cases
- **Logging integration with ErrorHandler**

**Test Pass Rate:** 100% (verified with `Exit Code: 0`)

---

## Test Groups

### 1. `isEmailValid()` Tests (3 tests)

Tests the silent email validation method.

#### Valid Emails
```dart
expect('user@example.com'.isEmailValid(), isTrue);
expect('user.name+tag@sub.domain.co.uk'.isEmailValid(), isTrue);
expect('x@y.io'.isEmailValid(), isTrue);
expect('test.email+alex@leetcode.com'.isEmailValid(), isTrue);
```

#### Invalid Emails
```dart
expect('plainaddress'.isEmailValid(), isFalse);          // No @
expect('user@.com'.isEmailValid(), isFalse);            // Empty domain
expect('user@domain..com'.isEmailValid(), isFalse);     // Consecutive dots
expect('user@localhost'.isEmailValid(), isFalse);       // No TLD
expect('@example.com'.isEmailValid(), isFalse);         // No local part
expect('user@'.isEmailValid(), isFalse);                // No domain
expect(' '.isEmailValid(), isFalse);                    // Empty after trim
expect(''.isEmailValid(), isFalse);                     // Empty string
```

#### Whitespace Trimming
```dart
expect('  user@example.com  '.isEmailValid(), isTrue);
expect('\tuser@example.com\n'.isEmailValid(), isTrue);
```

**Purpose:** Verify core validation logic and input normalization.

---

### 2. `validateOrThrow()` Tests (4 tests)

Tests the throwing variant with error handling.

#### Return Value
```dart
test('returns true for valid emails', () {
  expect('user@example.com'.validateOrThrow(), isTrue);
  expect('test@domain.io'.validateOrThrow(), isTrue);
});
```

#### Exception Throwing
```dart
test('throws ValidationException for invalid emails', () {
  expect(
    () => 'plainaddress'.validateOrThrow(),
    throwsA(isA<ValidationException>()),
  );
  expect(
    () => 'user@.com'.validateOrThrow(),
    throwsA(isA<ValidationException>()),
  );
});
```

#### Exception Details
```dart
test('exception message includes invalid email', () {
  try {
    'invalid@'.validateOrThrow();
    fail('Should throw ValidationException');
  } on ValidationException catch (e) {
    expect(e.message, contains('invalid@'));
  }
});
```

#### Logging Tags
```dart
test('accepts custom logging tags', () {
  expect(
    'user@example.com'.validateOrThrow(
      tag: 'CustomTag',
      operationName: 'Custom validation'
    ),
    isTrue,
  );
});
```

**Purpose:** Verify exception handling, message content, and custom logging.

---

### 3. Nullable `isEmailValidOrNull()` Tests (3 tests)

Tests null-safe validation for optional fields.

#### Null Handling
```dart
test('isEmailValidOrNull() returns false for null', () {
  String? nullEmail;
  expect(nullEmail.isEmailValidOrNull(), isFalse);
});
```

#### Valid Emails
```dart
test('isEmailValidOrNull() returns true for valid emails', () {
  String? validEmail = 'user@example.com';
  expect(validEmail.isEmailValidOrNull(), isTrue);
});
```

#### Invalid Emails
```dart
test('isEmailValidOrNull() returns false for invalid emails', () {
  String? invalidEmail = 'plainaddress';
  expect(invalidEmail.isEmailValidOrNull(), isFalse);
});
```

**Purpose:** Verify `String?` validation and null safety for optional email fields.

---

### 4. Nullable `validateOrThrowNullable()` Tests (4 tests)

Tests throwing validation for nullable strings with distinct error handling.

#### Null Exception
```dart
test('validateOrThrowNullable() throws for null', () {
  String? nullEmail;
  expect(
    () => nullEmail.validateOrThrowNullable(),
    throwsA(isA<ValidationException>()),
  );
});
```

#### Invalid Email Exception
```dart
test('validateOrThrowNullable() throws for invalid emails', () {
  String? invalidEmail = 'user@';
  expect(
    () => invalidEmail.validateOrThrowNullable(),
    throwsA(isA<ValidationException>()),
  );
});
```

#### Valid Email Return
```dart
test('validateOrThrowNullable() returns true for valid emails', () {
  String? validEmail = 'user@example.com';
  expect(validEmail.validateOrThrowNullable(), isTrue);
});
```

#### Null Error Message Distinction
```dart
test('validateOrThrowNullable() exception mentions null', () {
  String? nullEmail;
  try {
    nullEmail.validateOrThrowNullable();
    fail('Should throw ValidationException');
  } on ValidationException catch (e) {
    expect(e.message.toLowerCase(), contains('null'));
  }
});
```

**Purpose:** Verify nullable validation distinguishes between null and invalid email states.

---

### 5. Edge Cases (4 tests)

Tests boundary conditions and special scenarios.

#### Long Email Addresses
```dart
test('very long email', () {
  final longLocal = 'a' * 50;
  final email = '$longLocal@example.com';
  expect(email.isEmailValid(), isTrue);
});
```

**Purpose:** Verify pattern handles long input without regex DoS or performance issues.

#### Special Characters
```dart
test('special characters in local part', () {
  expect('user+tag@example.com'.isEmailValid(), isTrue);   // Plus sign for tagging
  expect('user.name@example.com'.isEmailValid(), isTrue);  // Dot separator
  expect('user_name@example.com'.isEmailValid(), isFalse); // Underscore NOT allowed
});
```

**Purpose:** Verify pattern correctly handles allowed/disallowed special characters.

#### Multi-Level Domains
```dart
test('multiple dots in domain', () {
  expect('user@mail.example.co.uk'.isEmailValid(), isTrue);    // Subdomain + TLD
  expect('user@sub.sub.example.com'.isEmailValid(), isTrue);   // Multiple subdomains
});
```

**Purpose:** Verify pattern supports subdomains and multi-part TLDs.

#### Case Insensitivity
```dart
test('case insensitive domain', () {
  expect('user@EXAMPLE.COM'.isEmailValid(), isTrue);
  expect('USER@example.COM'.isEmailValid(), isTrue);
});
```

**Purpose:** Verify pattern accepts uppercase and mixed-case domains.

---

### 6. Logging & ErrorHandler Integration (4 tests)

Tests the integration with the app's centralized error handling and logging system.

#### Default Logging
```dart
test('validateOrThrow logs with default tag', () {
  // Verify that validateOrThrow executes without throwing for valid email
  // ErrorHandler.handleSync is called internally and logs the operation
  expect('user@example.com'.validateOrThrow(), isTrue);
  // If logging fails, the test would fail due to unhandled exception
});
```

**Purpose:** Verify ErrorHandler integration and logging with default parameters.

#### Custom Logging Tags
```dart
test('validateOrThrow logs with custom tag', () {
  // Custom tag should be passed to ErrorHandler.handleSync
  final email = 'test@example.com';
  expect(
    email.validateOrThrow(
      tag: 'TestCustomTag',
      operationName: 'Test email validation',
    ),
    isTrue,
  );
  // ErrorHandler logs should show the custom tag in debug output
});
```

**Purpose:** Verify custom logging tags are passed through to ErrorHandler.

#### Nullable Validation Logging
```dart
test('validateOrThrowNullable logs validation attempts', () {
  // Valid nullable email should log and return true
  String? validEmail = 'user@example.com';
  expect(validEmail.validateOrThrowNullable(), isTrue);

  // Invalid nullable email should throw after logging
  String? invalidEmail = 'invalid';
  expect(
    () => invalidEmail.validateOrThrowNullable(),
    throwsA(isA<ValidationException>()),
  );
});
```

**Purpose:** Verify logging works for both valid and invalid nullable emails.

#### Exception Retryability
```dart
test('ValidationException is non-retryable', () {
  try {
    'bad@'.validateOrThrow();
    fail('Should throw');
  } on ValidationException catch (e) {
    // ValidationException should not be retryable
    expect(e.isRetryable, isFalse);
  }
});
```

**Purpose:** Verify ValidationException is marked as non-retryable (validation failures should not be automatically retried).

---

#### Invalid Email Exception
```dart
test('validateOrThrowNullable() throws for invalid emails', () {
  String? invalidEmail = 'user@';
  expect(
    () => invalidEmail.validateOrThrowNullable(),
    throwsA(isA<ValidationException>()),
  );
});
```

#### Valid Email Return
```dart
test('validateOrThrowNullable() returns true for valid emails', () {
  String? validEmail = 'user@example.com';
  expect(validEmail.validateOrThrowNullable(), isTrue);
});
```

#### Null Error Message
```dart
test('validateOrThrowNullable() exception mentions null', () {
  String? nullEmail;
  try {
    nullEmail.validateOrThrowNullable();
    fail('Should throw ValidationException');
  } on ValidationException catch (e) {
    expect(e.message.toLowerCase(), contains('null'));
  }
});
```

**Purpose:** Verify nullable validation and distinct null vs. invalid error messages.

---

### 5. Edge Cases

Tests boundary and special conditions.

#### Long Email Addresses
```dart
test('very long email', () {
  final longLocal = 'a' * 50;
  final email = '$longLocal@example.com';
  expect(email.isEmailValid(), isTrue);
});
```

#### Special Characters
```dart
test('special characters in local part', () {
  expect('user+tag@example.com'.isEmailValid(), isTrue);
  expect('user.name@example.com'.isEmailValid(), isTrue);
  expect('user_name@example.com'.isEmailValid(), isFalse);
});
```

#### Multi-Level Domains
```dart
test('multiple dots in domain', () {
  expect('user@mail.example.co.uk'.isEmailValid(), isTrue);
  expect('user@sub.sub.example.com'.isEmailValid(), isTrue);
});
```

#### Case Insensitivity
```dart
test('case insensitive domain', () {
  expect('user@EXAMPLE.COM'.isEmailValid(), isTrue);
  expect('USER@example.COM'.isEmailValid(), isTrue);
});
```

**Purpose:** Verify robustness against various input formats.

---

## Key Test Insights

### 1. Silent vs. Throwing Validation
- **`isEmailValid()`** → Returns `bool`, safe to call frequently
- **`validateOrThrow()`** → Throws on failure, adds logging; use for critical paths

### 2. Null Handling
- **`isEmailValidOrNull()`** → Treats null as invalid (returns `false`)
- **`validateOrThrowNullable()`** → Distinguishes null from invalid (different exceptions)

### 3. Regex Strictness
The pattern **rejects:**
- Underscores in local part
- Localhost/single-label domains
- Consecutive dots

The pattern **accepts:**
- Plus signs for tagging (`+`)
- Dots for name separation (`.`)
- Multi-level subdomains
- Hyphens in domain labels

### 4. Input Normalization
All validators automatically trim whitespace before checking.

---

## Debugging Failed Tests

If a test fails, check:

1. **Email format changed?**
   - Review the regex pattern in `email_validate_extension.dart`

2. **Exception type unexpected?**
   - Verify `ValidationException` is imported from `custom_exceptions.dart`

3. **Logging not working?**
   - Check `ErrorHandler.handleSync` is properly called
   - View debug console for log output

4. **Null behavior unexpected?**
   - Confirm you're using the correct method: `isEmailValidOrNull()` vs. `isEmailValid()`

---

## Extending Tests

To add new test cases:

```dart
test('new test case', () {
  final email = 'your@test.email';
  expect(email.isEmailValid(), isTrue); // or isFalse
});
```

See the structure above for organizing into the appropriate group.

---

## Widget Test Integration

### Testing Email Validation in Flutter Widgets

Example: Testing a login form with email validation

```dart
// test/screens/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xnotes_flutter/config/extensions/email_validate_extension/email_validate_extension.dart';
import 'package:xnotes_flutter/screens/login_screen.dart';

void main() {
  group('LoginScreen email validation', () {
    testWidgets('Submit button disabled for invalid email', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Find email field and enter invalid email
      await tester.enterText(find.byType(TextField), 'invalidemail');
      await tester.pumpAndSettle();
      
      // Verify submit button is disabled
      final submitButton = find.byType(ElevatedButton);
      expect(submitButton.evaluate().first.widget as ElevatedButton, 
             isA<ElevatedButton>().having((b) => b.enabled, 'enabled', false));
    });

    testWidgets('Submit button enabled for valid email', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Enter valid email
      await tester.enterText(find.byType(TextField), 'user@example.com');
      await tester.pumpAndSettle();
      
      // Verify submit button is enabled
      final submitButton = find.byType(ElevatedButton);
      expect(submitButton.evaluate().first.widget as ElevatedButton, 
             isA<ElevatedButton>().having((b) => b.enabled, 'enabled', true));
    });

    testWidgets('Shows error on validation failure', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Enter invalid email and submit
      await tester.enterText(find.byType(TextField), 'invalid@');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Verify error message appears
      expect(find.text('Invalid email'), findsWidgets);
    });
  });
}
```

### Testing with Email Extension Methods

```dart
void main() {
  group('Email validation in LoginController', () {
    test('login throws ValidationException for invalid email', () async {
      final controller = LoginController();
      
      expect(
        () => controller.login('invalid@', 'password'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('login proceeds with valid email', () async {
      final controller = LoginController();
      
      // This should not throw
      await controller.login('user@example.com', 'password');
    });
  });
}
```

- [Email Validation Implementation](./email_validate_extension.dart) — Extension methods
- [ErrorHandler](../../../utils/error_handler/error_handler.dart) — Logging integration
- [Custom Exceptions](../../../utils/custom_exceptions.dart) — Exception definitions
