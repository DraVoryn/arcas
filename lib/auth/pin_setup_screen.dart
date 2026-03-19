import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcas/providers/auth_provider.dart';
import 'package:arcas/auth/widgets/pin_numpad.dart';

/// Pantalla para crear el PIN de seguridad.
///
/// FLUJO:
/// 1. Usuario ingresa PIN (4-6 dígitos)
/// 2. Validación en tiempo real (no PINs débiles)
/// 3. Usuario confirma PIN (debe coincidir)
/// 4. Guarda hash y redirige a biometric setup
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  // PIN actual (lo que va ingresando)
  String _pin = '';

  // Confirmación del PIN (segunda vuelta)
  String _confirmPin = '';

  // ¿Estamos en modo confirmación?
  bool _isConfirming = false;

  // Error a mostrar
  String? _errorMessage;

  // Largo máximo del PIN
  static const int _maxPinLength = 6;
  static const int _minPinLength = 4;

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  void _onNumberPressed(String number) {
    // Limpiar error
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    // Verificar largo máximo
    final currentPin = _isConfirming ? _confirmPin : _pin;
    if (currentPin.length >= _maxPinLength) return;

    // Agregar dígito
    setState(() {
      if (_isConfirming) {
        _confirmPin += number;
      } else {
        _pin += number;
      }
    });

    // Verificar si se completó el PIN
    _checkPinComplete();
  }

  void _onDeletePressed() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // ConfirmPin vacío: volver a crear PIN desde cero
          // El usuario debe ingresar un PIN nuevo
          _isConfirming = false;
          _pin = ''; // LIMPIAR PIN ANTERIOR
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  void _checkPinComplete() {
    final currentPin = _isConfirming ? _confirmPin : _pin;

    // ¿Llegó al mínimo?
    if (currentPin.length < _minPinLength) return;

    // ¿Llegó al máximo o el usuario dejó de escribir?
    // Por ahora, esperamos a que llegue al máximo para confirmar
    if (currentPin.length == _maxPinLength) {
      _trySubmitPin();
    }
  }

  Future<void> _trySubmitPin() async {
    if (_pin.length < _minPinLength) return;

    if (!_isConfirming) {
      // Primera vez: ir a confirmación
      setState(() {
        _isConfirming = true;
        _errorMessage = null;
      });
    } else {
      // Confirmación: verificar que coincidan
      if (_pin != _confirmPin) {
        setState(() {
          _confirmPin = '';
          _errorMessage = 'Los PINs no coinciden. Intenta de nuevo.';
        });
        return;
      }

      // Todo bien: guardar PIN
      final result = await ref
          .read(authNotifierProvider.notifier)
          .setupPin(_pin, _confirmPin);

      if (result.success) {
        // Ir a biometric setup
        context.go('/biometric-setup');
      } else {
        // Error del servicio
        setState(() {
          _pin = '';
          _confirmPin = '';
          _isConfirming = false;
          _errorMessage = result.error;
        });
      }
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () {
                      if (_isConfirming) {
                        setState(() {
                          _isConfirming = false;
                          _confirmPin = '';
                          _errorMessage = null;
                          // NO limpiamos _pin - el usuario puede querer corregir
                        });
                      } else {
                        context.pop();
                      }
                    },
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Icono
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2A9D8F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: Color(0xFF2A9D8F),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              _isConfirming ? 'Confirmá tu PIN' : 'Creá tu PIN',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              _isConfirming
                  ? 'Ingresá el mismo PIN nuevamente'
                  : 'Este código protegerá tus datos',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),

            // Indicadores de PIN
            _buildPinDots(currentPin.length),
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

            const Spacer(flex: 2),

            // Numpad
            PinNumpad(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
              onComplete: _trySubmitPin,
              pinLength: _maxPinLength,
            ),

            const Spacer(flex: 1),
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
        final isActive = index < _minPinLength || filledCount >= _minPinLength;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 16 : 14,
          height: isFilled ? 16 : 14,
          decoration: BoxDecoration(
            color: isFilled
                ? (isActive ? const Color(0xFF2A9D8F) : const Color(0xFFE63946))
                : Colors.transparent,
            border: Border.all(
              color: isFilled
                  ? (isActive
                      ? const Color(0xFF2A9D8F)
                      : const Color(0xFFE63946))
                  : const Color(0xFFD1D5DB),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
