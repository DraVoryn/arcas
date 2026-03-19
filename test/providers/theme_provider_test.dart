import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcas/providers/theme_provider.dart';

void main() {
  group('ThemeNotifier', () {
    test('initial state should be system when no stored value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);
      expect(notifier.state, AppThemeMode.system);
    });

    test('initial state should be light when stored as light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);
      expect(notifier.state, AppThemeMode.light);
    });

    test('initial state should be dark when stored as dark', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);
      expect(notifier.state, AppThemeMode.dark);
    });

    test('setTheme should change state and persist', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setTheme(AppThemeMode.dark);
      
      expect(notifier.state, AppThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('toggleTheme should switch from light to dark', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);
      
      notifier.toggleTheme();
      
      expect(notifier.state, AppThemeMode.dark);
    });

    test('toggleTheme should switch from dark to light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);
      
      notifier.toggleTheme();
      
      expect(notifier.state, AppThemeMode.light);
    });

    test('toggleTheme from system should go to light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeNotifier(prefs);
      
      notifier.toggleTheme();
      
      expect(notifier.state, AppThemeMode.light);
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