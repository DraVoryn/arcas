import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/providers/locale_provider.dart';

void main() {
  group('LocaleNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state should be null when no stored value', () async {
      final container = ProviderContainer(
        overrides: [
          localeSharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(localeNotifierProvider);
      
      expect(state, isNull);
      
      container.dispose();
    });

    test('initial state should be Spanish when stored as es', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          localeSharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(localeNotifierProvider);
      
      expect(state, isNotNull);
      expect(state!.languageCode, 'es');
      
      container.dispose();
    });

    test('initial state should be English when stored as en', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          localeSharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(localeNotifierProvider);
      
      expect(state, isNotNull);
      expect(state!.languageCode, 'en');
      
      container.dispose();
    });

    test('setLocale should change state and persist', () async {
      final container = ProviderContainer(
        overrides: [
          localeSharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(localeNotifierProvider.notifier);
      
      await notifier.setLocale(const Locale('en'));
      
      final state = container.read(localeNotifierProvider);
      expect(state, const Locale('en'));
      expect(prefs.getString('app_locale'), 'en');
      
      container.dispose();
    });

    test('setLocale to null should remove key', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          localeSharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(localeNotifierProvider.notifier);
      
      await notifier.setLocale(null);
      
      final state = container.read(localeNotifierProvider);
      expect(state, isNull);
      expect(prefs.getString('app_locale'), isNull);
      
      container.dispose();
    });

    test('setLocale should persist language code only', () async {
      final container = ProviderContainer(
        overrides: [
          localeSharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(localeNotifierProvider.notifier);
      
      await notifier.setLocale(const Locale('es', 'MX'));
      
      final state = container.read(localeNotifierProvider);
      expect(state!.languageCode, 'es');
      expect(prefs.getString('app_locale'), 'es');
      
      container.dispose();
    });
  });

  group('currentLocaleProvider', () {
    test('should watch localeNotifierProvider state', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      
      final container = ProviderContainer(
        overrides: [
          localeSharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final locale = container.read(currentLocaleProvider);
      
      expect(locale, isNotNull);
      expect(locale!.languageCode, 'en');
      
      container.dispose();
    });
  });
}
