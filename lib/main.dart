import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:arcas/core/theme/app_theme.dart';
import 'package:arcas/core/router/app_router.dart';
import 'package:arcas/providers/theme_provider.dart';
import 'package:arcas/providers/locale_provider.dart';
import 'package:arcas/providers/database_provider.dart';
import 'package:arcas/l10n/app_localizations.dart';
import 'package:arcas/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
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
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error initializing app'),
              const SizedBox(height: 8),
              Text(e.toString()),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: main,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class ArcasApp extends ConsumerStatefulWidget {
  const ArcasApp({super.key});

  @override
  ConsumerState<ArcasApp> createState() => _ArcasAppState();
}

class _ArcasAppState extends ConsumerState<ArcasApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(ref);
  }

  @override
  Widget build(BuildContext context) {
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
      routerConfig: _router,

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
