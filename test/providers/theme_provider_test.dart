import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/providers/theme_provider.dart';

void main() {
  group('ThemeNotifier', () {
    test('initial state should be system when no stored value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(themeNotifierProvider);
      expect(state, AppThemeMode.system);
      
      container.dispose();
    });

    test('initial state should be light when stored as light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(themeNotifierProvider);
      expect(state, AppThemeMode.light);
      
      container.dispose();
    });

    test('initial state should be dark when stored as dark', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(themeNotifierProvider);
      expect(state, AppThemeMode.dark);
      
      container.dispose();
    });

    test('setTheme should change state and persist', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(themeNotifierProvider.notifier);
      
      await notifier.setTheme(AppThemeMode.dark);
      
      final state = container.read(themeNotifierProvider);
      expect(state, AppThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');
      
      container.dispose();
    });

    test('toggleTheme should switch from light to dark', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(themeNotifierProvider.notifier);
      
      notifier.toggleTheme();
      
      final state = container.read(themeNotifierProvider);
      expect(state, AppThemeMode.dark);
      
      container.dispose();
    });

    test('toggleTheme should switch from dark to light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(themeNotifierProvider.notifier);
      
      notifier.toggleTheme();
      
      final state = container.read(themeNotifierProvider);
      expect(state, AppThemeMode.light);
      
      container.dispose();
    });

    test('toggleTheme from system should go to light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(themeNotifierProvider.notifier);
      
      notifier.toggleTheme();
      
      final state = container.read(themeNotifierProvider);
      expect(state, AppThemeMode.light);
      
      container.dispose();
    });
  });

  group('AppThemeMode enum', () {
    test('enum values should be light, dark, system', () {
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
      expect(AppThemeMode.values, contains(AppThemeMode.system));
    });

    test('enum name should match string value', () {
      expect(AppThemeMode.light.name, 'light');
      expect(AppThemeMode.dark.name, 'dark');
      expect(AppThemeMode.system.name, 'system');
    });
  });
}
