import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'biometric_position.dart';

/// Servicio de autenticación local.
///
/// RESPONSABILIDADES:
/// 1. Hashing de PIN con bcrypt-like (usamos SHA-256 con salt para simplicidad)
/// 2. Almacenamiento del hash (en SharedPreferences por compatibilidad)
/// 3. Verificación de PIN
/// 4. Autenticación biométrica
///
/// NOTA: Usamos SharedPreferences en lugar de SecureStorage por problemas
/// de compatibilidad con algunos dispositivos Android. Los datos sensibles
/// (PIN) se guardan con hash SHA-256 + salt, que es irreversible.
class AuthService {
  // ==========================================================================
  // CONSTANTES
  // ==========================================================================

  /// PINs que son demasiado comunes y deben ser rechazados.
  static const List<String> _weakPins = [
    '0000', '1111', '2222', '3333', '4444',
    '5555', '6666', '7777', '8888', '9999',
    '1212', '1234', '1230', '12345', '54321',
    '0123', '4321', '0001', '1000', '0070',
    '2000', '3000', '4000', '5000', '6000',
    '7000', '8000', '9000', '1122', '2211',
    '1221', '2112', '1212', '2121', '1010',
    '0101', '1100', '0011', '2020', '0202',
    '1313', '3131', '1414', '4141', '1515',
    '5151', '1616', '6161', '1717', '7171',
    '1818', '8181', '1919', '9191', '2468',
    '1357', '9753', '1590', '2468', '2580',
  ];

  /// Largo mínimo y máximo del PIN.
  static const int _minPinLength = 4;
  static const int _maxPinLength = 6;

  /// Claves para SharedPreferences.
  static const String _pinHashKey = 'arcas_pin_hash';
  static const String _biometricEnabledKey = 'arcas_biometric_enabled';
  static const String _biometricPositionKey = 'arcas_biometric_position';

  // ==========================================================================
  // DEPENDENCIAS
  // ==========================================================================

  final SharedPreferences _prefs;
  final LocalAuthentication _localAuth;

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================

  /// Constructor para uso normal (recibe SharedPreferences inyectado).
  AuthService({
    required SharedPreferences prefs,
    LocalAuthentication? localAuth,
  })  : _prefs = prefs,
        _localAuth = localAuth ?? LocalAuthentication();

  // ==========================================================================
  // MÉTODOS PÚBLICOS: PIN
  // ==========================================================================

  /// Verifica si el PIN tiene un largo válido.
  static bool isValidPinLength(String pin) {
    if (pin.isEmpty) return false;
    if (!RegExp(r'^\d+$').hasMatch(pin)) return false;
    return pin.length >= _minPinLength && pin.length <= _maxPinLength;
  }

  /// Verifica si el PIN es demasiado débil.
  static bool isWeakPin(String pin) {
    return _weakPins.contains(pin);
  }

  /// Genera un salt aleatorio de 32 bytes.
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  /// Genera el hash del PIN usando HMAC-SHA256.
  String hashPin(String pin) {
    final salt = _generateSalt();
    final hmac = Hmac(sha256, utf8.encode(salt));
    final digest = hmac.convert(utf8.encode(pin));
    // Formato: salt:hash (ambos en base64)
    return '$salt:$digest';
  }

  /// Verifica si el PIN ingresado es correcto.
  Future<bool> verifyPin(String pin) async {
    // Si no hay PIN guardado, rechazar
    if (!await isPinSetup()) return false;

    try {
      final storedHash = _prefs.getString(_pinHashKey);
      if (storedHash == null || storedHash.isEmpty) return false;

      // Parsear salt y hash guardado
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final storedDigest = parts[1];

      // Calcular hash del PIN ingresado
      final hmac = Hmac(sha256, utf8.encode(salt));
      final digest = hmac.convert(utf8.encode(pin));

      // Comparación en tiempo constante
      return _constantTimeCompare(digest.toString(), storedDigest);
    } catch (e) {
      // Si hay cualquier error (formato inválido, etc.), rechazar
      return false;
    }
  }

  /// Comparación en tiempo constante para prevenir timing attacks.
  bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Guarda el hash del PIN.
  Future<void> savePinHash(String hash) async {
    await _prefs.setString(_pinHashKey, hash);
  }

  /// Recupera el hash del PIN guardado.
  /// Retorna null si no hay PIN configurado.
  Future<String?> getPinHash() async {
    return _prefs.getString(_pinHashKey);
  }

  /// Verifica si ya hay un PIN configurado.
  Future<bool> isPinSetup() async {
    final hash = _prefs.getString(_pinHashKey);
    print('[AuthService] isPinSetup() -> ${hash != null ? "found (${hash.substring(0, min(10, hash.length))}...)" : "null"}');
    return hash != null && hash.isNotEmpty;
  }

  /// Elimina el PIN (para reset de la app).
  Future<void> clearPin() async {
    await _prefs.remove(_pinHashKey);
    await _prefs.remove(_biometricEnabledKey);
    await _prefs.remove(_biometricPositionKey);
  }

  // ==========================================================================
  // MÉTODOS PÚBLICOS: BIOMETRIC POSITION
  // ==========================================================================

  /// Obtiene la posición del sensor biométrico.
  /// Retorna BiometricPosition.screen por defecto si no está configurado.
  Future<BiometricPosition> getBiometricPosition() async {
    final value = _prefs.getString(_biometricPositionKey);
    switch (value) {
      case 'rear':
        return BiometricPosition.rear;
      case 'side':
        return BiometricPosition.side;
      default:
        return BiometricPosition.screen;
    }
  }

  /// Guarda la posición del sensor biométrico.
  Future<void> setBiometricPosition(BiometricPosition position) async {
    await _prefs.setString(_biometricPositionKey, position.name);
  }

  // ==========================================================================
  // MÉTODOS PÚBLICOS: BIOMETRIC
  // ==========================================================================

  /// Verifica si el dispositivo tiene soporte biométrico.
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene los tipos de biometría disponibles.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Verifica si el usuario habilitó biometrics.
  Future<bool> isBiometricEnabled() async {
    final value = _prefs.getString(_biometricEnabledKey);
    return value == 'true';
  }

  /// Habilita o deshabilita el uso de biometrics.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setString(_biometricEnabledKey, enabled.toString());
  }

  /// Intenta autenticar usando biometrics del dispositivo.
  Future<bool> authenticateWithBiometric({
    String reason = 'Autentícate para acceder a Arcas',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }
}
