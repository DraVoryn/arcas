import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:arcas/providers/auth_provider.dart';
import 'package:arcas/l10n/app_localizations.dart';

/// Pantalla para configurar biometrics (Face ID / Touch ID).
///
/// FLUJO:
/// - Si biometrics disponible: muestra opción de activar
/// - Si no disponible: va directo a la app
/// - "Activar" → prueba biometric → si funciona, habilita
/// - "Omitir" → va directo a la app sin biometrics
class BiometricSetupScreen extends ConsumerStatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  ConsumerState<BiometricSetupScreen> createState() =>
      _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends ConsumerState<BiometricSetupScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de pulso para el ícono
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  Future<void> _enableBiometric() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final success =
        await ref.read(authNotifierProvider.notifier).enableBiometric();

    if (success) {
      // Ir a la app
      if (mounted) {
        context.go('/home');
      }
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = l10n.biometricEnableError;
      });
    }
  }

  void _skip() {
    ref.read(authNotifierProvider.notifier).skipBiometricSetup();
    context.go('/home');
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Obtiene el nombre del biometric según la plataforma.
  String _getBiometricName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Huella digital';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'biometrics';
  }

  /// Obtiene el ícono según el tipo de biometric.
  IconData _getBiometricIcon(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return Icons.face_rounded;
    } else if (types.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint_rounded;
    }
    return Icons.fingerprint_rounded;
  }

  /// Obtiene el color según el tipo de biometric.
  Color _getBiometricColor(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return const Color(0xFF007AFF); // Azul Apple
    }
    return const Color(0xFF5856D6); // Púrpura genérico
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final biometricsAsync = ref.watch(availableBiometricsProvider);
    final biometricTypes = biometricsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animación del ícono
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: _getBiometricColor(biometricTypes).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(70),
                  ),
                  child: Icon(
                    _getBiometricIcon(biometricTypes),
                    size: 72,
                    color: _getBiometricColor(biometricTypes),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Título
              Text(
                l10n.enableBiometric,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),

              // Subtítulo
              Text(
                l10n.useBiometricToUnlock(_getBiometricName(biometricTypes).toLowerCase()),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Beneficios
              _buildBenefit(
                Icons.timer_outlined,
                l10n.biometricFaster,
                l10n.biometricFasterDesc,
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.security_outlined,
                l10n.biometricSafer,
                l10n.biometricSaferDesc,
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                Icons.touch_app_outlined,
                l10n.biometricEasier,
                l10n.biometricEasierDesc,
              ),

              const Spacer(flex: 2),

              // Error
              if (_hasError)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFE63946),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Color(0xFFE63946),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Botón activar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enableBiometric,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getBiometricColor(biometricTypes),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getBiometricIcon(biometricTypes), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              l10n.enable,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Skip
              TextButton(
                onPressed: _skip,
                child: Text(
                  l10n.skipForNow,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2A9D8F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2A9D8F),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
