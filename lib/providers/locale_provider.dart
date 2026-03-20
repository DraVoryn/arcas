import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para el locale de la app.
///
/// Permite cambiar el idioma manualmente en lugar de depender
/// solo del locale del sistema.
class LocaleNotifier extends Notifier<Locale?> {
  static const _localeKey = 'app_locale';

  @override
  Locale? build() {
    final prefs = ref.watch(localeSharedPreferencesProvider);
    return _loadLocale(prefs);
  }

  static Locale? _loadLocale(SharedPreferences prefs) {
    final localeCode = prefs.getString(_localeKey);
    if (localeCode == null) return null;
    return Locale(localeCode);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = ref.read(localeSharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }
}

/// Provider para SharedPreferences.
/// Definido aquí porque settings_screen necesita acceso.
final localeSharedPreferencesProvider =
    Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider principal del locale.
final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

/// Provider de solo lectura para el locale actual.
final currentLocaleProvider = Provider<Locale?>((ref) {
  return ref.watch(localeNotifierProvider);
});
