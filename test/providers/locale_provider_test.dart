import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcas/providers/locale_provider.dart';

void main() {
  group('LocaleNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state should be null when no stored value', () {
      final notifier = LocaleNotifier(prefs);
      expect(notifier.state, isNull);
    });

    test('initial state should be Spanish when stored as es', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = LocaleNotifier(prefs);
      expect(notifier.state, isNotNull);
      expect(notifier.state!.languageCode, 'es');
    });

    test('initial state should be English when stored as en', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = LocaleNotifier(prefs);
      expect(notifier.state, isNotNull);
      expect(notifier.state!.languageCode, 'en');
    });

    test('setLocale should change state and persist', () async {
      final notifier = LocaleNotifier(prefs);
      
      await notifier.setLocale(const Locale('en'));
      
      expect(notifier.state, const Locale('en'));
      expect(prefs.getString('app_locale'), 'en');
    });

    test('setLocale to null should remove key', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = LocaleNotifier(prefs);
      
      await notifier.setLocale(null);
      
      expect(notifier.state, isNull);
      expect(prefs.getString('app_locale'), isNull);
    });

    test('setLocale should persist language code only', () async {
      final notifier = LocaleNotifier(prefs);
      
      await notifier.setLocale(const Locale('es', 'MX'));
      
      expect(notifier.state!.languageCode, 'es');
      expect(prefs.getString('app_locale'), 'es');
    });
  });

  group('currentLocaleProvider', () {
    test('should watch localeNotifierProvider state', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = LocaleNotifier(prefs);
      
      final locale = notifier.state;
      expect(locale, isNotNull);
      expect(locale!.languageCode, 'en');
    });
  });
}