import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcas/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late AuthService authService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      authService = AuthService(prefs: prefs);
    });

    group('PIN validation', () {
      test('isValidPinLength should return true for valid 4-digit PIN', () {
        expect(AuthService.isValidPinLength('1234'), isTrue);
      });

      test('isValidPinLength should return true for valid 5-digit PIN', () {
        expect(AuthService.isValidPinLength('12345'), isTrue);
      });

      test('isValidPinLength should return true for valid 6-digit PIN', () {
        expect(AuthService.isValidPinLength('123456'), isTrue);
      });

      test('isValidPinLength should return false for 3-digit PIN', () {
        expect(AuthService.isValidPinLength('123'), isFalse);
      });

      test('isValidPinLength should return false for 7-digit PIN', () {
        expect(AuthService.isValidPinLength('1234567'), isFalse);
      });

      test('isValidPinLength should return false for empty PIN', () {
        expect(AuthService.isValidPinLength(''), isFalse);
      });

      test('isValidPinLength should return false for non-numeric PIN', () {
        expect(AuthService.isValidPinLength('12ab'), isFalse);
      });

      test('isValidPinLength should return false for PIN with special chars', () {
        expect(AuthService.isValidPinLength('12#4'), isFalse);
      });
    });

    group('Weak PIN detection', () {
      test('isWeakPin should return true for "1234"', () {
        expect(AuthService.isWeakPin('1234'), isTrue);
      });

      test('isWeakPin should return true for "0000"', () {
        expect(AuthService.isWeakPin('0000'), isTrue);
      });

      test('isWeakPin should return true for "1111"', () {
        expect(AuthService.isWeakPin('1111'), isTrue);
      });

      test('isWeakPin should return true for "1212"', () {
        expect(AuthService.isWeakPin('1212'), isTrue);
      });

      test('isWeakPin should return false for random 4-digit PIN', () {
        expect(AuthService.isWeakPin('5829'), isFalse);
      });

      test('isWeakPin should return true for "9999"', () {
        expect(AuthService.isWeakPin('9999'), isTrue);
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
      test('verifyPin should return true for correct PIN', () async {
        final hash = authService.hashPin('1234');
        await authService.savePinHash(hash);
        expect(await authService.verifyPin('1234'), isTrue);
      });

      test('verifyPin should return false for incorrect PIN', () async {
        final hash = authService.hashPin('1234');
        await authService.savePinHash(hash);
        expect(await authService.verifyPin('5678'), isFalse);
      });

      test('verifyPin should return false for invalid hash format', () async {
        await prefs.setString('arcas_pin_hash', 'invalid_hash');
        expect(await authService.verifyPin('1234'), isFalse);
      });

      test('verifyPin should return false for empty PIN', () async {
        final hash = authService.hashPin('1234');
        await authService.savePinHash(hash);
        expect(await authService.verifyPin(''), isFalse);
      });

      test('verifyPin should return false for hash with only one part', () async {
        await prefs.setString('arcas_pin_hash', 'somehash');
        expect(await authService.verifyPin('1234'), isFalse);
      });
    });

    group('Constructor', () {
      test('constructor should create instance with prefs', () {
        expect(authService, isA<AuthService>());
      });
    });
  });
}
