import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:arcas/core/theme/app_theme.dart';
import 'package:arcas/core/router/app_router.dart';
import 'package:arcas/providers/theme_provider.dart';
import 'package:arcas/providers/locale_provider.dart';
import 'package:arcas/providers/premium_provider.dart';
import 'package:arcas/l10n/app_localizations.dart';
import 'package:arcas/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localeSharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(database),
      ],
      child: const ArcasApp(),
    ),
  );
}

class ArcasApp extends ConsumerWidget {
  const ArcasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final locale = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      title: 'Arcas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _mapThemeMode(themeMode),
      locale: locale, // Locale del usuario o null (sistema)

      // =====================================================================
      // ROUTER CONFIG
      // =====================================================================
      routerConfig: createRouter(ref),

      // =====================================================================
      // LOCALIZATION
      // =====================================================================
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
    );
  }

  ThemeMode _mapThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
