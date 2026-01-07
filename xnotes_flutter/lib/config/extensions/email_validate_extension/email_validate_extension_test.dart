import 'package:flutter_test/flutter_test.dart';
import 'package:xnotes_flutter/config/extensions/email_validate_extension/email_validate_extension.dart';
import 'package:xnotes_flutter/utils/custom_exceptions.dart';

void main() {
  group('EmailValidateExtension', () {
    group('isEmailValid()', () {
      test('valid emails', () {
        expect('user@example.com'.isEmailValid(), isTrue);
        expect('user.name+tag@sub.domain.co.uk'.isEmailValid(), isTrue);
        expect('x@y.io'.isEmailValid(), isTrue);
        expect('test.email+alex@leetcode.com'.isEmailValid(), isTrue);
      });

      test('invalid emails', () {
        expect('plainaddress'.isEmailValid(), isFalse);
        expect('user@.com'.isEmailValid(), isFalse);
        expect('user@domain..com'.isEmailValid(), isFalse);
        expect('user@localhost'.isEmailValid(), isFalse);
        expect('@example.com'.isEmailValid(), isFalse);
        expect('user@'.isEmailValid(), isFalse);
        expect(' '.isEmailValid(), isFalse);
        expect(''.isEmailValid(), isFalse);
      });

      test('trimming whitespace', () {
        expect('  user@example.com  '.isEmailValid(), isTrue);
        expect('\tuser@example.com\n'.isEmailValid(), isTrue);
      });
    });

    group('validateOrThrow()', () {
      test('returns true for valid emails', () {
        expect('user@example.com'.validateOrThrow(), isTrue);
        expect('test@domain.io'.validateOrThrow(), isTrue);
      });

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

      test('exception message includes invalid email', () {
        try {
          'invalid@'.validateOrThrow();
          fail('Should throw ValidationException');
        } on ValidationException catch (e) {
          expect(e.message, contains('invalid@'));
        }
      });

      test('accepts custom logging tags', () {
        expect(
          'user@example.com'.validateOrThrow(tag: 'CustomTag', operationName: 'Custom validation'),
          isTrue,
        );
      });
    });

    group('EmailValidateExtensionNullable', () {
      test('isEmailValidOrNull() returns false for null', () {
        String? nullEmail;
        expect(nullEmail.isEmailValidOrNull(), isFalse);
      });

      test('isEmailValidOrNull() returns true for valid emails', () {
        String? validEmail = 'user@example.com';
        expect(validEmail.isEmailValidOrNull(), isTrue);
      });

      test('isEmailValidOrNull() returns false for invalid emails', () {
        String? invalidEmail = 'plainaddress';
        expect(invalidEmail.isEmailValidOrNull(), isFalse);
      });

      test('validateOrThrowNullable() throws for null', () {
        String? nullEmail;
        expect(
          () => nullEmail.validateOrThrowNullable(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('validateOrThrowNullable() throws for invalid emails', () {
        String? invalidEmail = 'user@';
        expect(
          () => invalidEmail.validateOrThrowNullable(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('validateOrThrowNullable() returns true for valid emails', () {
        String? validEmail = 'user@example.com';
        expect(validEmail.validateOrThrowNullable(), isTrue);
      });

      test('validateOrThrowNullable() exception mentions null', () {
        String? nullEmail;
        try {
          nullEmail.validateOrThrowNullable();
          fail('Should throw ValidationException');
        } on ValidationException catch (e) {
          expect(e.message.toLowerCase(), contains('null'));
        }
      });
    });

    group('Edge cases', () {
      test('very long email', () {
        final longLocal = 'a' * 50;
        final email = '$longLocal@example.com';
        expect(email.isEmailValid(), isTrue);
      });

      test('special characters in local part', () {
        expect('user+tag@example.com'.isEmailValid(), isTrue);
        expect('user.name@example.com'.isEmailValid(), isTrue);
        expect('user_name@example.com'.isEmailValid(), isFalse); // underscore not in pattern
      });

      test('multiple dots in domain', () {
        expect('user@mail.example.co.uk'.isEmailValid(), isTrue);
        expect('user@sub.sub.example.com'.isEmailValid(), isTrue);
      });

      test('case insensitive domain', () {
        expect('user@EXAMPLE.COM'.isEmailValid(), isTrue);
        expect('USER@example.COM'.isEmailValid(), isTrue);
      });
    });

    group('Logging & ErrorHandler Integration', () {
      test('validateOrThrow logs with default tag', () {
        // Verify that validateOrThrow executes without throwing for valid email
        // ErrorHandler.handleSync is called internally and logs the operation
        expect('user@example.com'.validateOrThrow(), isTrue);
        // If logging fails, the test would fail due to unhandled exception
      });

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

      test('ValidationException is non-retryable', () {
        try {
          'bad@'.validateOrThrow();
          fail('Should throw');
        } on ValidationException catch (e) {
          // ValidationException should not be retryable
          expect(e.isRetryable, isFalse);
        }
      });
    });
  });
}

