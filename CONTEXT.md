# Contexto de la Aplicacion Arcas

## Resumen del Proyecto
Arcas es una aplicacion de finanzas personales desarrollada con Flutter. Permite a los usuarios gestionar sus transacciones, categorias, y generar reportes. Incluye funcionalidades premium (compras in-app) y esta localizada en espanol e ingles.

**Repo**: https://github.com/DraVoryn/arcas

## Arquitectura y Stack Tecnologico
- **Framework**: Flutter 3.41.4
- **Lenguaje**: Dart 3.x
- **State Management**: Riverpod (v2.6.1 + annotation/generator)
- **Base de Datos**: Drift (SQLite) con `path_provider`
- **Patron de Arquitectura**: Clean Architecture (Core, Database, Providers, UI)
- **Testing**: flutter_test con 48 tests

## Estructura del Proyecto
```
lib/
├── main.dart
├── core/
│   ├── router/app_router.dart
│   └── theme/app_theme.dart
├── database/
│   ├── app_database.dart
│   └── app_database.g.dart
├── providers/
│   ├── theme_provider.dart
│   ├── locale_provider.dart
│   └── auth_provider.dart
├── auth/
│   ├── auth_service.dart
│   ├── lock_screen.dart
│   ├── pin_setup_screen.dart
│   ├── biometric_setup_screen.dart
│   ├── onboarding_screen.dart
│   └── widgets/pin_numpad.dart
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── transactions_screen.dart
│   │   ├── reportes_screen.dart
│   │   └── settings_screen.dart
│   ├── dialogs/
│   │   └── add_transaction_dialog.dart
│   └── widgets/
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_es.dart
```

## Caracteristicas Implementadas

### Completado
1. **Dark Mode**: Toggle en Settings con persistencia
2. **Theme Provider**: ThemeNotifier con SharedPreferences
3. **Navegacion**: GoRouter configurado
4. **Base de Datos**: Drift con Transactions y Categories
5. **Localizacion**: Spanish + English
6. **Material 3**: Light y Dark themes
7. **Tests**: 48 tests unitarios pasando
8. **CI/CD**: PR checks workflow (analyze, test, build APK)
9. **Auth Local**: PIN setup + biometric authentication

### Pendiente
1. **Premium/Freemium Reports**: Sistema de reportes con limites freemium y compras in-app
2. **Reportes UI**: Interfaz completa de reportes semanal/mensual
3. **Database CRUD**: Operaciones completas de transactions y categories
4. **Release Workflow**: Template listo, necesita secrets de stores

## Estado de GitHub
- **Repo**: github.com/DraVoryn/arcas
- **Ramas**: main, feature/reportes-premium (sincronizadas)
- **Contribuidores**: Solo DraVoryn <rafhm22@gmail.com>
- **Historial**: Limpio

## Build Status
- flutter analyze: No issues found
- flutter test: 48 tests passing
- Debug APK: Compila correctamente

## CI/CD
- **PR Checks**: Activo (.github/workflows/pr-checks.yml)
  - flutter analyze
  - flutter test
  - flutter build apk (artifact)
- **Release**: Template listo (.github/workflows/release.yml)
  - Necesita secrets para activar

## Secrets para Deploy (futuro)
### Google Play
- ANDROID_SIGNING_KEYSTORE
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_ALIAS
- ANDROID_KEY_PASSWORD
- PLAY_SERVICE_ACCOUNT_JSON

### iOS App Store
- IOS_CERTIFICATE
- IOS_CERTIFICATE_PASSWORD
- IOS_PROVISIONING_PROFILE

## Nota Importante
Durante la limpieza de git history, git filter-repo elimino archivos de lib/ accidentalmente.
Se recrearon los archivos esenciales. Premium features (reportes freemium + in_app_purchase) aun no estan implementadas.

## Ultima actualizacion
2026-03-19
