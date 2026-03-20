import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcas/providers/auth_provider.dart';
import 'package:arcas/auth/widgets/pin_numpad.dart';
import 'package:arcas/l10n/app_localizations.dart';
import 'package:arcas/auth/biometric_position.dart';
import 'package:arcas/auth/auth_service.dart';

/// Pantalla de bloqueo.
///
/// Se muestra cuando:
/// - La app se abre después de estar en background > 30s
/// - El usuario fue redirigido por el router
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  // PIN actual
  String _pin = '';

  // Error a mostrar
  String? _errorMessage;

  // ¿Está verificando? (para loading state)
  bool _isVerifying = false;

  // Largo máximo del PIN
  static const int _maxPinLength = 6;

  // Posición del sensor biométrico
  BiometricPosition? _biometricPosition;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de shake para errores
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Cargar posición del sensor biométrico
    _loadBiometricPosition();

    // Auto-intentar biometric SOLO SI está habilitado
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.read(authNotifierProvider).value;
      if (authState?.biometricEnabled == true) {
        await _tryBiometric();
      }
    });
  }

  Future<void> _loadBiometricPosition() async {
    final authService = ref.read(authServiceProvider);
    final position = await authService.getBiometricPosition();
    if (mounted) {
      setState(() {
        _biometricPosition = position;
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  Future<void> _tryBiometric() async {
    final authState = ref.read(authNotifierProvider).value;
    if (authState == null || !authState.biometricEnabled) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .authenticateWithBiometric();

    if (success && mounted) {
      context.go('/home');
    }
  }

  void _onNumberPressed(String number) {
    // Limpiar error
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    // Verificar largo máximo
    if (_pin.length >= _maxPinLength) return;

    // Agregar dígito
    setState(() {
      _pin += number;
    });

    // Si llegó al máximo, verificar
    if (_pin.length == _maxPinLength) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final result =
        await ref.read(authNotifierProvider.notifier).verifyPin(_pin);

    setState(() {
      _isVerifying = false;
    });

    if (result.success) {
      // Ir a la app
      if (mounted) {
        context.go('/home');
      }
    } else {
      // Error: shake + mensaje
      _shakeController.forward().then((_) => _shakeController.reset());
      setState(() {
        _pin = '';
        _errorMessage = result.error;
      });
    }
  }

  void _showResetDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.forgotPin),
        content: Text(l10n.forgotPinResetWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).resetApp();
              if (mounted) {
                context.go('/onboarding');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE63946),
            ),
            child: Text(l10n.resetApp),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Usar .value para obtener el estado desde AsyncNotifier
    final authState = ref.watch(authNotifierProvider).value;

    // Valores por defecto mientras carga
    final int failedAttempts = authState?.failedAttempts ?? 0;
    final biometricEnabled = authState?.biometricEnabled ?? false;
    final canReset = authState?.canReset ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Logo / Icono
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2A9D8F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 36,
                color: Color(0xFF2A9D8F),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              l10n.appLocked,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              l10n.enterPinToContinue,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 32),

            // Indicadores de PIN
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeAnimation.value *
                        ((_shakeController.value * 10).toInt().isEven
                            ? 1
                            : -1),
                    0,
                  ),
                  child: child,
                );
              },
              child: _buildPinDots(_pin.length),
            ),
            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFE63946),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFE63946),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Contador de intentos
            if (failedAttempts > 0 && failedAttempts < 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.attemptsRemaining(5 - failedAttempts),
                  style: TextStyle(
                    fontSize: 14,
                    color: failedAttempts >= 3
                        ? const Color(0xFFF4A261)
                        : const Color(0xFF6B7280),
                    fontWeight: failedAttempts >= 3
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),

            const Spacer(flex: 2),

            // Numpad
            PinNumpad(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
              pinLength: _maxPinLength,
              biometricPosition: _biometricPosition,
              onBiometricPressed: _tryBiometric,
            ),

            const Spacer(flex: 1),

            // Botón biometric
            if (biometricEnabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OutlinedButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint_rounded, size: 24),
                  label: Text(l10n.fingerprint),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5856D6),
                    side: const BorderSide(color: Color(0xFF5856D6)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Link reset
            if (canReset)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: _showResetDialog,
                  child: Text(
                    l10n.forgotPin,
                    style: const TextStyle(
                      color: Color(0xFFE63946),
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: _showResetDialog,
                  child: Text(
                    l10n.forgotPin,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(int filledCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_maxPinLength, (index) {
        final isFilled = index < filledCount;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 14 : 14,
          height: isFilled ? 14 : 14,
          decoration: BoxDecoration(
            color: isFilled ? const Color(0xFF2A9D8F) : Colors.transparent,
            border: Border.all(
              color: _errorMessage != null
                  ? const Color(0xFFE63946)
                  : const Color(0xFF2A9D8F),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
        );
      }),
    );
  }
}
