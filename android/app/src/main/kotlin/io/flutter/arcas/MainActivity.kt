package io.flutter.arcas

import io.flutter.embedding.android.FlutterFragmentActivity

/// MainActivity debe extender FlutterFragmentActivity para que local_auth funcione.
///
/// local_auth usa fragmentos de Android para mostrar el prompt de biometric.
/// Con FlutterActivity (sin fragmentos), el prompt no se puede mostrar correctamente.
class MainActivity: FlutterFragmentActivity()
