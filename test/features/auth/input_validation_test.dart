import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Input Validation Rules', () {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );

    test('Valid email addresses pass regex validation', () {
      final validEmails = [
        'user@ira.ai',
        'aakansha.sharma@example.com',
        'test+tag@domain.co.in',
        'firstname.lastname@sub.domain.org',
      ];

      for (final email in validEmails) {
        expect(emailRegex.hasMatch(email), isTrue, reason: 'Failed on $email');
      }
    });

    test('Invalid email addresses fail regex validation', () {
      final invalidEmails = [
        'plainaddress',
        '@missingusername.com',
        'missingdomain@.com',
        'missingat.domain.com',
        'spaces in@email.com',
      ];

      for (final email in invalidEmails) {
        expect(emailRegex.hasMatch(email), isFalse, reason: 'Should fail on $email');
      }
    });

    test('Password minimum length rule (8 characters)', () {
      expect('1234567'.length >= 8, isFalse);
      expect('12345678'.length >= 8, isTrue);
      expect('MySecurePassword2026!'.length >= 8, isTrue);
    });
  });
}
