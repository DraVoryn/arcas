import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:arcas/auth/auth_service.dart';
import 'package:arcas/providers/theme_provider.dart'
    show sharedPreferencesProvider;

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
  return AuthService();
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
  return authState.valueOrNull?.status == AuthStatus.unlocked;
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
    // Si no hay authService o prefs todavía, retornar estado inicial
    if (_authService == null || _prefs == null) {
      return AuthState.initial();
    }

    // Verificar disponibilidad de biometrics
    final biometricAvailable = await _authService!.isBiometricAvailable();

    // Verificar si el onboarding ya fue completado
    final onboardingCompleted =
        _prefs!.getBool(_onboardingCompletedKey) ?? false;

    // Verificar si hay PIN configurado
    final isPinSetup = await _authService!.isPinSetup();

    // Verificar si biometrics está habilitado
    final biometricEnabled = await _authService!.isBiometricEnabled();

    AuthStatus newStatus;

    if (!onboardingCompleted) {
      // Primera vez: mostrar onboarding
      newStatus = AuthStatus.onboarding;
    } else if (!isPinSetup) {
      // Onboarding completado pero sin PIN: crear PIN
      newStatus = AuthStatus.pinSetup;
    } else {
      // PIN existe: verificar si biometric está pendiente de confirmar
      if (biometricAvailable && !biometricEnabled) {
        newStatus = AuthStatus.biometricSetup;
      } else {
        // Todo configurado: app bloqueada esperando auth
        newStatus = AuthStatus.locked;
      }
    }

    return AuthState(
      status: newStatus,
      biometricAvailable: biometricAvailable,
      biometricEnabled: biometricEnabled,
    );
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
    if (!_authService!.isValidPinLength(pin)) {
      return (success: false, error: 'El PIN debe tener entre 4 y 6 dígitos');
    }

    // Validar que no sea PIN débil
    if (_authService!.isWeakPin(pin)) {
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
    // Obtener hash guardado
    final storedHash = await _authService!.getPinHash();
    if (storedHash == null) {
      return (success: false, error: 'No hay PIN configurado');
    }

    // Verificar PIN
    final isValid = _authService!.verifyPin(pin, storedHash);

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

  /// Bloquea la app manualmente (llamado desde app lifecycle).
  void lock() {
    final currentState = state.value;
    if (currentState != null && currentState.status == AuthStatus.unlocked) {
      state = AsyncValue.data(currentState.copyWith(status: AuthStatus.locked));
    }
  }

  // ==========================================================================
  // RESET (Olvidaste PIN)
  // ==========================================================================

  /// Resetea la app completamente.
  Future<void> resetApp() async {
    final currentState = state.value;
    if (currentState == null || !currentState.canReset) return;

    // Limpiar secure storage
    await _authService!.clearPin();

    // Resetear onboarding
    await _prefs!.setBool(_onboardingCompletedKey, false);

    // Volver al inicio
    state = AsyncValue.data(AuthState.initial().copyWith(
      biometricAvailable: currentState.biometricAvailable,
    ));
  }
}
