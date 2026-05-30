import 'package:flutter_test/flutter_test.dart';
import 'package:simple_class_app/services/auth_service.dart';

void main() {
  group('AuthService', () {
    group('isValidEmail', () {
      test('returns true for valid email addresses', () {
        expect(AuthService.isValidEmail('user@example.com'), true);
        expect(AuthService.isValidEmail('test.user@domain.co.uk'), true);
        expect(AuthService.isValidEmail('admin@app.io'), true);
      });

      test('returns false for invalid email addresses', () {
        expect(AuthService.isValidEmail(''), false);
        expect(AuthService.isValidEmail('plaintext'), false);
        expect(AuthService.isValidEmail('user@'), false);
        expect(AuthService.isValidEmail('@domain.com'), false);
        expect(AuthService.isValidEmail('user@.com'), false);
      });

      test('returns false for emails without domain', () {
        expect(AuthService.isValidEmail('user'), false);
        expect(AuthService.isValidEmail('user@domain'), false);
      });
    });

    group('isValidPassword', () {
      test('returns true for passwords with 6+ characters', () {
        expect(AuthService.isValidPassword('123456'), true);
        expect(AuthService.isValidPassword('password123'), true);
        expect(AuthService.isValidPassword('MySecurePass@2024'), true);
      });

      test('returns false for passwords with less than 6 characters', () {
        expect(AuthService.isValidPassword(''), false);
        expect(AuthService.isValidPassword('12345'), false);
        expect(AuthService.isValidPassword('short'), false);
      });

      test('returns true for exactly 6 characters', () {
        expect(AuthService.isValidPassword('123456'), true);
        expect(AuthService.isValidPassword('abcdef'), true);
      });
    });
  });
}
