import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  AppThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _loadTheme(prefs);
  }

  static AppThemeMode _loadTheme(SharedPreferences prefs) {
    final value = prefs.getString(_themeKey);
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeKey, mode.name);
  }

  void toggleTheme() {
    final newMode = state == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    setTheme(newMode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);
