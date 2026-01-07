# Email Validation Extension

This folder contains email validation utilities with two main components:

1. **`email_validate_extension.dart`** — Implementation of email validation methods
2. **`email_validate_test.dart`** — Comprehensive unit tests

---

## Quick Start

### Installation

Add the import to your Dart/Flutter file:

```dart
import 'package:xnotes_flutter/config/extensions/email_validate_extension/email_validate_extension.dart';
```

### Basic Usage

```dart
// Silent validation
if (email.isEmailValid()) {
  print('Email is valid');
}

// Throwing validation with logging
try {
  email.validateOrThrow(tag: 'LoginForm');
  await signIn(email);
} on ValidationException catch (e) {
  showError('Invalid email: ${e.message}');
}

// Nullable string handling
String? maybeEmail = getUserInput();
if (maybeEmail.isEmailValidOrNull()) {
  print('Email provided and valid');
}
```

---

## Overview

The email validation extension provides Dart/Flutter String extensions for validating email addresses with integrated error handling and logging via the app's `ErrorHandler`.

### Features

- ✅ RFC-compliant email pattern validation
- ✅ Silent validation (returns `bool`) for quick checks
- ✅ Throwing validation with automatic logging
- ✅ Nullable string support (`String?`)
- ✅ Automatic input trimming
- ✅ Integration with app error handling system
- ✅ Detailed regex pattern documentation
- ✅ Comprehensive test coverage

---

## Implementation: `email_validate_extension.dart`

### What It Does

Extends the `String` class with email validation methods. Provides two extensions:

1. **`EmailValidateExtension`** — For non-null `String` validation
2. **`EmailValidateExtensionNullable`** — For nullable `String?` validation

### Methods

#### `bool isEmailValid()`

Returns `true` if the string is a valid email, `false` otherwise. Silent, no logging.

**Example:**
```dart
final email = 'user@example.com';
if (email.isEmailValid()) {
  print('Valid email');
}
```

**Use case:** Quick UI checks (enable/disable submit button)

---

#### `bool validateOrThrow({String tag, String operationName})`

Validates the email and throws `ValidationException` if invalid. Logs via `ErrorHandler.handleSync`.

**Parameters:**
- `tag` (default: `'Validation'`) — Logger tag for identifying the source
- `operationName` (default: `'Validate email'`) — Human-readable operation description

**Returns:** `true` if valid

**Throws:** `ValidationException` if email is invalid

**Example:**
```dart
try {
  emailInput.validateOrThrow(tag: 'LoginForm', operationName: 'Validate login email');
  // Proceed with sign-in
  await authService.signIn(emailInput, password);
} on ValidationException catch (e) {
  showErrorDialog('Invalid email: ${e.message}');
} 
```

**Use case:** Critical operations where validation failure is a recoverable error (form submission, registration)

---

#### `bool isEmailValidOrNull()` (Nullable)

Returns `true` if non-null and valid email, `false` for null or invalid.

**Example:**
```dart
String? maybeEmail = getUserInput();
if (maybeEmail.isEmailValidOrNull()) {
  print('Email is valid');
}
```

**Use case:** Optional email fields in forms

---

#### `bool validateOrThrowNullable({String tag, String operationName})` (Nullable)

Validates nullable email, throws if null or invalid.

**Throws:** 
- `ValidationException` with message `'Email cannot be null'` if null
- `ValidationException` with invalid email details if invalid

**Example:**
```dart
try {
  String? emailField;
  emailField.validateOrThrowNullable(tag: 'RegistrationForm');
  // Proceed
} on ValidationException catch (e) {
  print('Validation failed: ${e.message}');
}
```

**Use case:** Required email fields with null-safety checks

---

## Email Pattern

The regex pattern used (`_emailRegExp`) validates:

✅ **Valid:**
- `user@example.com`
- `user.name+tag@sub.domain.co.uk`
- `test.email+alex@leetcode.com`

❌ **Invalid:**
- `plainaddress` (no @)
- `user@.com` (empty domain)
- `user@localhost` (no TLD)
- `@example.com` (no local part)
- `user@domain..com` (consecutive dots)

---

## Integration with Error Handler

All `validateOrThrow` variants use `ErrorHandler.handleSync()` for centralized logging:

```dart
// Logged automatically:
// [Validation] Validate email started
// [Validation] Validate email completed
// OR
// [Validation] Failed to Validate email (with error details)
```

See [ErrorHandler documentation](../../../utils/error_handler/ERROR_HANDLER.md) for more details.

---

## Usage Examples

### Form Validation (Flutter Widget)

```dart
class EmailFormField extends StatefulWidget {
  @override
  State<EmailFormField> createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<EmailFormField> {
  String _email = '';
  String? _errorText;

  void _handleSubmit() {
    try {
      _email.validateOrThrow(tag: 'EmailForm', operationName: 'Validate form email');
      // Submit the form
      _submitForm(_email);
    } on ValidationException catch (e) {
      setState(() => _errorText = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        setState(() {
          _email = value;
          _errorText = value.isEmailValid() ? null : 'Invalid email';
        });
      },
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _errorText,
      ),
    );
  }
}
```

### Login Controller

```dart
class LoginController {
  Future<void> login(String email, String password) async {
    try {
      email.validateOrThrow(tag: 'LoginController');
      final user = await authService.login(email, password);
      // Navigate to home
    } on ValidationException catch (e) {
      ErrorHandler.log('Login validation failed: ${e.message}', tag: 'LoginController');
      // Show error to user
    }
  }
}
```

### Registration with Nullable Email

```dart
class RegistrationForm {
  String name = '';
  String? secondaryEmail; // Optional

  Future<void> register() async {
    try {
      // Primary email required
      name.validateOrThrow(tag: 'RegistrationForm', operationName: 'Validate user name');
      
      // Secondary email optional but if provided, must be valid
      if (secondaryEmail != null) {
        secondaryEmail.validateOrThrowNullable(tag: 'RegistrationForm');
      }
      
      // Proceed with registration
      await userService.createUser(name, secondaryEmail);
    } on ValidationException catch (e) {
      print('Registration error: ${e.message}');
    }
  }
}
```

---

## Custom Logging Tags

Customize logging tags for different contexts:

```dart
// Form validation
email.validateOrThrow(tag: 'LoginForm', operationName: 'Validate login email');

// API request
email.validateOrThrow(tag: 'APIService', operationName: 'Validate recipient email');

// Batch processing
email.validateOrThrow(tag: 'BatchProcessor', operationName: 'Validate email in batch');
```

This helps identify validation failures in the app's centralized logs.

---

## Exceptions

All `validateOrThrow` methods throw `ValidationException`:

```dart
// From custom_exceptions.dart
class ValidationException extends AppException {
  final String message; // e.g., "Invalid email: user@"
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  bool get isRetryable => false; // Not retryable
}
```

---

## Advanced Usage

### Batch Email Validation

```dart
Future<Map<String, bool>> validateEmailBatch(List<String> emails) async {
  final results = <String, bool>{};
  
  for (final email in emails) {
    try {
      email.validateOrThrow(tag: 'BatchValidator');
      results[email] = true;
    } on ValidationException catch (e) {
      ErrorHandler.log('Batch validation failed: ${e.message}', tag: 'BatchValidator');
      results[email] = false;
    }
  }
  
  return results;
}
```

### Email Subscription/Newsletter Form

```dart
class NewsletterForm {
  String _email = '';
  bool _agreedToTerms = false;
  
  Future<void> subscribe() async {
    try {
      // Validate email with context
      _email.validateOrThrow(tag: 'NewsletterForm', operationName: 'Validate subscriber email');
      
      // Validate terms
      if (!_agreedToTerms) {
        throw ValidationException(message: 'You must agree to the terms');
      }
      
      // Subscribe
      await api.subscribeToNewsletter(_email);
    } on ValidationException catch (e) {
      showErrorSnackbar(e.message);
    }
  }
}
```

### Email List Filtering

```dart
// Filter valid emails from a list
List<String> filterValidEmails(List<String> emails) {
  return emails.where((email) => email.isEmailValid()).toList();
}

// Partition into valid and invalid
Map<bool, List<String>> partitionEmails(List<String> emails) {
  return emails.fold(
    {true: <String>[], false: <String>[]},
    (acc, email) {
      acc[email.isEmailValid()]!.add(email);
      return acc;
    },
  );
}
```

### Async Email Verification (with API)

```dart
Future<bool> isEmailRegistered(String email) async {
  try {
    // First validate format
    email.validateOrThrow(tag: 'EmailVerification');
    
    // Then check with API
    final exists = await api.checkEmailExists(email);
    return exists;
  } on ValidationException catch (e) {
    ErrorHandler.log('Email format invalid: ${e.message}', tag: 'EmailVerification');
    return false;
  }
}
```

---

## Performance Notes

- The email regex pattern is **precompiled** as a top-level `_emailRegExp` constant to avoid recompilation on every call
- `isEmailValid()` is synchronous and lightweight — safe to call frequently (e.g., on every keystroke)
- `validateOrThrow()` adds logging overhead; avoid calling repeatedly in tight loops
- For batch operations (100+ emails), consider using `isEmailValid()` instead of `validateOrThrow()` to avoid excessive logging

---

## Troubleshooting

### "ValidationException: Invalid email: user@"
**Cause:** Email doesn't match the regex pattern (missing TLD, extra @, etc.)
**Solution:** Check the email format against the valid examples in the README

### "No instance of ValidationException"
**Cause:** Import missing or wrong extension method called
**Solution:** Ensure `import 'package:xnotes_flutter/config/extensions/email_validate_extension/email_validate_extension.dart';` is present

### "Test failing on valid email"
**Cause:** Regex pattern too strict or email has unsupported characters
**Solution:** Check the regex documentation in the code comments or relax the pattern if needed

---

## See Also

- [Email Validation Tests](./email_validate_test.dart) — Comprehensive test coverage
- [Email Validation Test Guide](./EMAIL_VALIDATE_EXTENSION_TEST.md) — Testing documentation
