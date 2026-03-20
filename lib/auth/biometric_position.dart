/// Posición del sensor biométrico en el dispositivo.
///
/// Determina si se muestra un botón en pantalla o solo se usa el prompt.
///
/// - `screen`: Sensor de huellas en pantalla (in-display).
///   Se muestra un botón táctil en la UI para activar el sensor.
///
/// - `rear`: Sensor trasero (montado en la espalda del teléfono).
///   El usuario sabe dónde está el sensor físico. No se muestra botón.
///
/// - `side`: Sensor lateral integrado en el botón de encendido.
///   El usuario presiona el botón de power. No se muestra botón.
enum BiometricPosition {
  screen,
  rear,
  side,
}
