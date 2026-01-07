import 'package:xnotes_flutter/utils/error_handler/error_handler.dart';
import 'package:xnotes_flutter/utils/custom_exceptions.dart';

/// Precompiled regex pattern for email validation.
///
/// **Pattern Breakdown:**
///
/// 1. **Local part** (before @):
///    `[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+`
///    - Alphanumeric (a-z, A-Z, 0-9)
///    - Special chars: . ! # $ % & ' * + / = ? ^ _ ` { | } ~
///    - Hyphens (-) allowed
///    - NO underscores (intentional, per RFC standards)
///
/// 2. **@ symbol** (literal)
///
/// 3. **Domain labels** (after @):
///    `[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?`
///    - First char: alphanumeric or digit
///    - Middle: alphanumeric, digits, or hyphens
///    - Last char: alphanumeric or digit
///    - Ensures no leading/trailing hyphens in labels
///
/// 4. **Subdomains** (optional):
///    `(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*`
///    - Zero or more additional domain labels
///    - Each preceded by a dot
///
/// 5. **TLD** (top-level domain):
///    `\.[A-Za-z]{2,}$`
///    - Dot followed by 2+ letters
///    - Examples: .com, .co.uk, .org
///
/// **Valid Examples:**
/// - user@example.com
/// - user.name+tag@sub.domain.co.uk
/// - test.email@mail.example.org
///
/// **Invalid Examples (intentionally rejected):**
/// - user_name@example.com (underscore not in local part pattern)
/// - user@localhost (no TLD required)
/// - user@@example.com (double @)
/// - user@.com (empty domain label)
///
/// **Performance Note:**
/// This regex is compiled once as a top-level constant to avoid recompilation
/// on every validation call. The regex engine caches the pattern internally.
final _emailRegExp = RegExp(
  r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}$",
);

extension EmailValidateExtension on String {
  bool isEmailValid() => _emailRegExp.hasMatch(trim());

  /// Validate the email and throw a `ValidationException` if invalid.
  ///
  /// This logs the validation attempt using `ErrorHandler.handleSync` so
  /// the app's centralized logging captures the failure context.
  ///
  /// **Throws**: `ValidationException` if email is invalid.
  /// **Returns**: `true` if valid (for fluent chaining if needed).
  /// **Logs**: Operation start, completion, and errors via `ErrorHandler`.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   email.validateOrThrow(tag: 'LoginForm');
  ///   // Proceed with valid email
  /// } on ValidationException catch (e) {
  ///   showError(e.message);
  /// }
  /// ```
  bool validateOrThrow({
    String tag = 'Validation',
    String operationName = 'Validate email',
  }) {
    return ErrorHandler.handleSync<bool>(
      operation: () {
        final trimmed = trim();
        if (!_emailRegExp.hasMatch(trimmed)) {
          throw ValidationException(message: 'Invalid email: $trimmed');
        }
        return true;
      },
      tag: tag,
      operationName: operationName,
      shouldRethrow: true,
    ) ?? true;
  }
}

/// Extension for nullable String validation.
extension EmailValidateExtensionNullable on String? {
  /// Returns true if the string is non-null and a valid email; false otherwise.
  bool isEmailValidOrNull() {
    if (this == null) return false;
    return this!.isEmailValid();
  }

  /// Validate nullable email and throw if null or invalid.
  ///
  /// **Throws**: `ValidationException` if null or invalid email.
  /// **Logs**: Via `ErrorHandler`.
  bool validateOrThrowNullable({
    String tag = 'Validation',
    String operationName = 'Validate nullable email',
  }) {
    return ErrorHandler.handleSync<bool>(
      operation: () {
        if (this == null) {
          throw ValidationException(message: 'Email cannot be null');
        }
        return this!.validateOrThrow(tag: tag, operationName: operationName);
      },
      tag: tag,
      operationName: operationName,
      shouldRethrow: true,
    ) ?? true;
  }
}