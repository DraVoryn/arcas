import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:arcas/auth/auth_service.dart';
import 'package:arcas/providers/theme_provider.dart'
    show sharedPreferencesProvider;
import 'package:arcas/providers/database_provider.dart';

// ==========================================================================
// ENUMS y ESTADOS
// ==========================================================================

/// Estado del flujo de autenticación.
///
/// El flujo es lineal:
/// onboarding → pinSetup → biometricSetup → locked/unlocked
enum AuthStatus {
  /// Primera vez que abre la app. Mostrar onboarding.
  onboarding,

  /// Necesita crear el PIN.
  pinSetup,

  /// PIN creado, pregunta si quiere biometrics.
  biometricSetup,

  /// App bloqueada, necesita autenticarse.
  locked,

  /// Usuario autenticado, tiene acceso completo.
  unlocked,
}

/// Estado completo del sistema de autenticación.
class AuthState {
  /// Estado actual del flujo de auth.
  final AuthStatus status;

  /// Si biometrics está disponible en el dispositivo.
  final bool biometricAvailable;

  /// Si el usuario eligió usar biometrics.
  final bool biometricEnabled;

  /// Cantidad de intentos de PIN fallidos.
  final int failedAttempts;

  /// Si la app puede ser reseteada (5+ intentos fallidos).
  final bool canReset;

  const AuthState({
    required this.status,
    this.biometricAvailable = false,
    this.biometricEnabled = false,
    this.failedAttempts = 0,
    this.canReset = false,
  });

  /// Estado inicial — onboarding para nuevos usuarios.
  factory AuthState.initial() => const AuthState(
        status: AuthStatus.onboarding,
      );

  /// Copy with para crear estados derivados.
  AuthState copyWith({
    AuthStatus? status,
    bool? biometricAvailable,
    bool? biometricEnabled,
    int? failedAttempts,
    bool? canReset,
  }) {
    return AuthState(
      status: status ?? this.status,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      canReset: canReset ?? this.canReset,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, biometric: $biometricAvailable/$biometricEnabled, failedAttempts: $failedAttempts)';
  }
}

// ==========================================================================
// CONSTANTES
// ==========================================================================

/// Clave para guardar si el onboarding fue completado.
const String _onboardingCompletedKey = 'arcas_onboarding_completed';

/// Máximo de intentos fallidos antes de permitir reset.
const int _maxFailedAttempts = 5;

// ==========================================================================
// PROVIDERS
// ==========================================================================

/// Provider para el servicio de autenticación.
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(prefs: prefs);
});

/// Provider principal del estado de autenticación.
/// Usa AsyncNotifier para asegurar que la inicialización async termine
/// antes de que el router pueda redirigir.
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Provider de solo lectura para verificar si está autenticado.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.value?.status == AuthStatus.unlocked;
});

/// Provider para obtener los tipos de biometric disponibles.
final availableBiometricsProvider = FutureProvider<List<BiometricType>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getAvailableBiometrics();
});

// ==========================================================================
// STATE NOTIFIER
// ==========================================================================

/// Maneja el estado de autenticación.
///
/// RESPONSABILIDADES:
/// 1. Inicializar el estado correcto al arrancar (onboarding, pinSetup, o locked)
/// 2. Transicionar entre estados según acciones del usuario
/// 3. Contar intentos fallidos y manejar el lockout
/// 4. Persistir configuración del usuario
class AuthNotifier extends AsyncNotifier<AuthState> {
  AuthService? _authService;
  SharedPreferences? _prefs;

  @override
  Future<AuthState> build() async {
    // Obtenemos las dependencias
    _authService = ref.watch(authServiceProvider);
    _prefs = ref.watch(sharedPreferencesProvider);

    // Inicializar y retornar el estado
    return _initialize();
  }

  // ==========================================================================
  // INICIALIZACIÓN
  // ==========================================================================

  /// Inicializa el estado de auth según el estado guardado.
  ///
  /// FLUJO:
  /// 1. ¿Hay PIN guardado?
  ///    - NO → onboarding (primera vez)
  ///    - SÍ → ¿biometric habilitado?
  ///            - SÍ → biometricSetup (para confirmar)
  ///            - NO → locked
  Future<AuthState> _initialize() async {
    print('[AuthNotifier] _initialize() START');
    
    // Si no hay authService o prefs todavía, retornar estado inicial
    if (_authService == null || _prefs == null) {
      print('[AuthNotifier] _initialize() -> NULL service or prefs, returning initial');
      return AuthState.initial();
    }

    // Verificar qué hay en SharedPreferences
    final allKeys = _prefs!.getKeys();
    print('[AuthNotifier] SharedPreferences keys: $allKeys');

    // Esperar más tiempo para que todo se inicialice completamente
    // (especialmente después de un restart completo de la app)
    await Future.delayed(const Duration(milliseconds: 1000));
    print('[AuthNotifier] After delay, checking prefs again...');
    final keysAfterDelay = _prefs!.getKeys();
    print('[AuthNotifier] SharedPreferences keys after delay: $keysAfterDelay');

    // Verificar disponibilidad de biometrics
    final biometricAvailable = await _authService!.isBiometricAvailable();
    print('[AuthNotifier] biometricAvailable: $biometricAvailable');

    // Verificar si el onboarding ya fue completado
    final onboardingCompleted =
        _prefs!.getBool(_onboardingCompletedKey) ?? false;
    print('[AuthNotifier] onboardingCompleted: $onboardingCompleted');

    // Verificar si hay PIN configurado (con retry para problemas de timing)
    bool isPinSetup = await _readPinWithRetry();
    print('[AuthNotifier] isPinSetup: $isPinSetup');

    // Verificar si biometrics está habilitado
    final biometricEnabled = await _authService!.isBiometricEnabled();
    print('[AuthNotifier] biometricEnabled: $biometricEnabled');

    AuthStatus newStatus;

    if (!onboardingCompleted) {
      // Primera vez: mostrar onboarding
      newStatus = AuthStatus.onboarding;
      print('[AuthNotifier] -> onboarding (no previous use)');
    } else if (!isPinSetup) {
      // Onboarding completado pero sin PIN: crear PIN
      newStatus = AuthStatus.pinSetup;
      print('[AuthNotifier] -> pinSetup (onboarding done, no PIN)');
    } else {
      // PIN existe: verificar si biometric está pendiente de confirmar
      if (biometricAvailable && !biometricEnabled) {
        newStatus = AuthStatus.biometricSetup;
        print('[AuthNotifier] -> biometricSetup (PIN exists, biometric pending)');
      } else {
        // Todo configurado: app bloqueada esperando auth
        newStatus = AuthStatus.locked;
        print('[AuthNotifier] -> locked (PIN exists, ready to authenticate)');
      }
    }

    print('[AuthNotifier] _initialize() -> status=$newStatus');

    return AuthState(
      status: newStatus,
      biometricAvailable: biometricAvailable,
      biometricEnabled: biometricEnabled,
    );
  }

  /// Lee el estado del PIN con reintentos para manejar timing issues
  /// con secure storage después de un restart de la app.
  Future<bool> _readPinWithRetry({int maxRetries = 5}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final isPinSetup = await _authService!.isPinSetup();
        if (isPinSetup) {
          // ignore: avoid_print
          print('[AuthNotifier] _readPinWithRetry() -> success on attempt ${i + 1}');
          return true;
        }
        // ignore: avoid_print
        print('[AuthNotifier] _readPinWithRetry() attempt ${i + 1}: no PIN found');
      } catch (e) {
        // ignore: avoid_print
        print('[AuthNotifier] _readPinWithRetry() attempt ${i + 1} ERROR: $e');
      }
      
      if (i < maxRetries - 1) {
        // Exponential backoff: 200ms, 400ms, 600ms, 800ms
        await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
      }
    }
    return false;
  }

  // ==========================================================================
  // ACCIONES DE NAVEGACIÓN
  // ==========================================================================

  /// Completa el onboarding y redirige a PIN setup.
  Future<void> completeOnboarding() async {
    await _prefs!.setBool(_onboardingCompletedKey, true);
    state = AsyncValue.data(state.value!.copyWith(status: AuthStatus.pinSetup));
  }

  /// Skip biometric setup y va directo a la app.
  void skipBiometricSetup() {
    state = AsyncValue.data(state.value!.copyWith(
      status: AuthStatus.unlocked,
      biometricEnabled: false,
    ));
  }

  // ==========================================================================
  // ACCIONES DE AUTENTICACIÓN
  // ==========================================================================

  /// Configura el PIN del usuario.
  Future<({bool success, String? error})> setupPin(
    String pin,
    String confirmPin,
  ) async {
    // Validar largo
    if (!AuthService.isValidPinLength(pin)) {
      return (success: false, error: 'El PIN debe tener entre 4 y 6 dígitos');
    }

    // Validar que no sea PIN débil
    if (AuthService.isWeakPin(pin)) {
      return (success: false, error: 'Este PIN es muy común, elige otro');
    }

    // Validar que confirmación coincida
    if (pin != confirmPin) {
      return (success: false, error: 'Los PINs no coinciden');
    }

    // Generar hash y guardar
    final hash = _authService!.hashPin(pin);
    await _authService!.savePinHash(hash);

    // Transicionar a biometric setup o unlocked
    final currentState = state.value!;
    if (currentState.biometricAvailable) {
      state = AsyncValue.data(currentState.copyWith(status: AuthStatus.biometricSetup));
    } else {
      state = AsyncValue.data(currentState.copyWith(status: AuthStatus.unlocked));
    }

    return (success: true, error: null);
  }

  /// Habilita biometrics como método de autenticación.
  Future<bool> enableBiometric() async {
    final currentState = state.value;
    if (currentState == null || !currentState.biometricAvailable) {
      return false;
    }

    // Hacer una autenticación de prueba
    final success = await _authService!.authenticateWithBiometric(
      reason: 'Activa biometrics para acceder rápidamente',
    );

    if (success) {
      await _authService!.setBiometricEnabled(true);
      state = AsyncValue.data(currentState.copyWith(
        status: AuthStatus.unlocked,
        biometricEnabled: true,
      ));
      return true;
    }

    return false;
  }

  /// Verifica el PIN ingresado por el usuario.
  Future<({bool success, String? error})> verifyPin(String pin) async {
    // Verificar PIN (el servicio ya tiene el hash guardado internamente)
    final isValid = await _authService!.verifyPin(pin);

    final currentState = state.value!;

    if (isValid) {
      // Éxito: resetear contador y desbloquear
      state = AsyncValue.data(currentState.copyWith(
        status: AuthStatus.unlocked,
        failedAttempts: 0,
        canReset: false,
      ));
      return (success: true, error: null);
    }

    // Falló: incrementar contador
    final newFailedAttempts = currentState.failedAttempts + 1;
    final canReset = newFailedAttempts >= _maxFailedAttempts;

    state = AsyncValue.data(currentState.copyWith(
      failedAttempts: newFailedAttempts,
      canReset: canReset,
    ));

    // Mensaje según cantidad de intentos
    final attemptsLeft = _maxFailedAttempts - newFailedAttempts;
    String error;

    if (canReset) {
      error = 'Demasiados intentos. Usa "Olvidé mi PIN" para reiniciar.';
    } else if (attemptsLeft <= 2) {
      error = 'PIN incorrecto. Te quedan $attemptsLeft intentos.';
    } else {
      error = 'PIN incorrecto';
    }

    return (success: false, error: error);
  }

  /// Intenta autenticación con biometrics.
  Future<bool> authenticateWithBiometric() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.biometricEnabled ||
        !currentState.biometricAvailable) {
      return false;
    }

    final success = await _authService!.authenticateWithBiometric();

    if (success) {
      state = AsyncValue.data(currentState.copyWith(
        status: AuthStatus.unlocked,
        failedAttempts: 0,
        canReset: false,
      ));
    }

    return success;
  }

  /// Bloquea la app (logout simple — datos se mantienen).
  ///
  /// Este es el comportamiento correcto de "Cerrar sesión".
  /// El usuario queda en la pantalla de lock, con su PIN y datos intactos.
  void lock() {
    final currentState = state.value;
    if (currentState != null && currentState.status == AuthStatus.unlocked) {
      state = AsyncValue.data(currentState.copyWith(status: AuthStatus.locked));
    }
  }

  // ==========================================================================
  // DELETE ACCOUNT (reset completo — cuidado!)
  // ==========================================================================

  /// Resetea la app completamente (borra PIN, datos, TODO).
  ///
  /// Solo para "Olvidé mi PIN" (5 intentos fallidos) o "Borrar cuenta".
  /// NO para logout normal.
  /// 
  /// Borra TODO: PIN, biometrics, preferencias Y base de datos.
  Future<void> deleteAccount() async {
    // 1. Limpiar secure storage (PIN + biometrics + position)
    await _authService!.clearPin();

    // 2. Resetear onboarding
    await _prefs!.setBool(_onboardingCompletedKey, false);

    // 3. BORRAR BASE DE DATOS (transacciones, categorías, reportes)
    try {
      final db = ref.read(databaseProvider);
      await db.clearAllData();
    } catch (e) {
      // Si falla el clear, continuar de todas formas para no quedar trabado
      print('[AuthNotifier] deleteAccount: error clearing database: $e');
    }

    // 4. Volver al inicio del flujo de auth
    final currentState = state.value;
    state = AsyncValue.data(AuthState.initial().copyWith(
      biometricAvailable: currentState?.biometricAvailable ?? false,
    ));
  }

  /// Alias de deleteAccount para compatibilidad hacia atrás con "Olvidaste PIN"
  /// (que requería 5 intentos fallidos). Ahora borramos cuenta directamente.
  Future<void> resetApp() async {
    await deleteAccount();
  }
}
