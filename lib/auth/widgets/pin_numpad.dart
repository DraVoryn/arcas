import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcas/auth/biometric_position.dart';

/// Widget de teclado numérico custom para ingreso de PIN.
///
/// ¿Por qué no usar el teclado del sistema?
/// - Control total sobre el UX (tamaño, colors, feedback)
/// - Sin autocorrect ni sugerencias molestas
/// - Animaciones y haptic feedback personalizados
/// - Consistencia visual en toda la app
class PinNumpad extends StatelessWidget {
  /// Callback cuando se presiona un número.
  final ValueChanged<String> onNumberPressed;

  /// Callback cuando se presiona delete.
  final VoidCallback onDeletePressed;

  /// Callback cuando se completa el PIN (todos los dígitos ingresados).
  final VoidCallback? onComplete;

  /// Número de dígitos esperado del PIN.
  final int pinLength;

  /// Posición del sensor biométrico para determinar si se muestra el botón.
  final BiometricPosition? biometricPosition;

  /// Callback cuando se presiona el botón biométrico (solo para posición screen).
  final VoidCallback? onBiometricPressed;

  const PinNumpad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    this.onComplete,
    this.pinLength = 6,
    this.biometricPosition,
    this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fila 1: 1, 2, 3
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),

        // Fila 2: 4, 5, 6
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),

        // Fila 3: 7, 8, 9
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),

        // Fila 4: vacío (o biometric), 0, delete
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _NumpadButton(
            label: number,
            onPressed: () => onNumberPressed(number),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    final showBiometricButton = biometricPosition == BiometricPosition.screen;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Biometric button (solo si el sensor está en pantalla)
        if (showBiometricButton)
          GestureDetector(
            onTap: onBiometricPressed,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF5856D6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 32,
                color: Color(0xFF5856D6),
              ),
            ),
          )
        else
          const SizedBox(width: 72, height: 72),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _NumpadButton(
            label: '0',
            onPressed: () => onNumberPressed('0'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _NumpadButton(
            icon: Icons.backspace_outlined,
            onPressed: onDeletePressed,
          ),
        ),
      ],
    );
  }
}

/// Botón individual del numpad.
///
/// Incluye:
/// - Animación de press (escala)
/// - Feedback háptico
/// - Estilos para números vs iconos
class _NumpadButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _NumpadButton({
    this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  State<_NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<_NumpadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animación
    _controller.forward().then((_) => _controller.reverse());

    // Callback
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.label != null
                ? Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                : Icon(
                    widget.icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
          ),
        ),
      ),
    );
  }
}
