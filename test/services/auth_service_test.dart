import 'package:flutter_test/flutter_test.dart';
import 'package:arcas/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('PIN validation', () {
      test('isValidPinLength should return true for valid 4-digit PIN', () {
        expect(authService.isValidPinLength('1234'), isTrue);
      });

      test('isValidPinLength should return true for valid 5-digit PIN', () {
        expect(authService.isValidPinLength('12345'), isTrue);
      });

      test('isValidPinLength should return true for valid 6-digit PIN', () {
        expect(authService.isValidPinLength('123456'), isTrue);
      });

      test('isValidPinLength should return false for 3-digit PIN', () {
        expect(authService.isValidPinLength('123'), isFalse);
      });

      test('isValidPinLength should return false for 7-digit PIN', () {
        expect(authService.isValidPinLength('1234567'), isFalse);
      });

      test('isValidPinLength should return false for empty PIN', () {
        expect(authService.isValidPinLength(''), isFalse);
      });

      test('isValidPinLength should return false for non-numeric PIN', () {
        expect(authService.isValidPinLength('12ab'), isFalse);
      });

      test('isValidPinLength should return false for PIN with special chars', () {
        expect(authService.isValidPinLength('12#4'), isFalse);
      });
    });

    group('Weak PIN detection', () {
      test('isWeakPin should return true for "1234"', () {
        expect(authService.isWeakPin('1234'), isTrue);
      });

      test('isWeakPin should return true for "0000"', () {
        expect(authService.isWeakPin('0000'), isTrue);
      });

      test('isWeakPin should return true for "1111"', () {
        expect(authService.isWeakPin('1111'), isTrue);
      });

      test('isWeakPin should return true for "1212"', () {
        expect(authService.isWeakPin('1212'), isTrue);
      });

      test('isWeakPin should return false for random 4-digit PIN', () {
        expect(authService.isWeakPin('5829'), isFalse);
      });

      test('isWeakPin should return true for "9999"', () {
        expect(authService.isWeakPin('9999'), isTrue);
      });
    });

    group('PIN hashing', () {
      test('hashPin should return non-empty string', () {
        final hash = authService.hashPin('1234');
        expect(hash, isNotEmpty);
      });

      test('hashPin should contain separator', () {
        final hash = authService.hashPin('1234');
        expect(hash.contains(':'), isTrue);
      });

      test('hashPin should return different hash for different PINs', () {
        final hash1 = authService.hashPin('1234');
        final hash2 = authService.hashPin('5678');
        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('PIN verification', () {
      test('verifyPin should return true for correct PIN', () {
        final hash = authService.hashPin('1234');
        expect(authService.verifyPin('1234', hash), isTrue);
      });

      test('verifyPin should return false for incorrect PIN', () {
        final hash = authService.hashPin('1234');
        expect(authService.verifyPin('5678', hash), isFalse);
      });

      test('verifyPin should return false for invalid hash format', () {
        expect(authService.verifyPin('1234', 'invalid_hash'), isFalse);
      });

      test('verifyPin should return false for empty PIN', () {
        final hash = authService.hashPin('1234');
        expect(authService.verifyPin('', hash), isFalse);
      });

      test('verifyPin should return false for hash with only one part', () {
        expect(authService.verifyPin('1234', 'somehash'), isFalse);
      });
    });

    group('Factory', () {
      test('factory constructor should create instance', () {
        final service = AuthService();
        expect(service, isA<AuthService>());
      });

      test('multiple factory calls should create different instances', () {
        final service1 = AuthService();
        final service2 = AuthService();
        expect(identical(service1, service2), isFalse);
      });
    });
  });
}