import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para el locale de la app.
///
/// Permite cambiar el idioma manualmente en lugar de depender
/// solo del locale del sistema.
class LocaleNotifier extends StateNotifier<Locale?> {
  static const _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

  static Locale? _loadLocale(SharedPreferences prefs) {
    final localeCode = prefs.getString(_localeKey);
    if (localeCode == null) return null;
    return Locale(localeCode);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
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
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(localeSharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

/// Provider de solo lectura para el locale actual.
final currentLocaleProvider = Provider<Locale?>((ref) {
  return ref.watch(localeNotifierProvider);
});
