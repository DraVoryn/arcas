# Contexto de la Aplicacion Arcas

## Resumen del Proyecto
Arcas es una aplicacion de finanzas personales desarrollada con Flutter. Permite a los usuarios gestionar sus transacciones, categorias, y generar reportes. Incluye funcionalidades premium (compras in-app) y esta localizada en espanol e ingles.

**Repo**: https://github.com/DraVoryn/arcas

## Arquitectura y Stack Tecnologico
- **Framework**: Flutter 3.x
- **Lenguaje**: Dart 3.x
- **State Management**: Riverpod (v2.4.0 + annotation/generator)
- **Base de Datos**: Drift (SQLite) con `path_provider`
- **Patron de Arquitectura**: Clean Architecture (Core, Database, Providers, UI)

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
│   └── theme_provider.dart
├── ui/screens/
│   ├── home_screen.dart
│   ├── transactions_screen.dart
│   ├── reportes_screen.dart
│   └── settings_screen.dart
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

### Pendiente
1. Tests unitarios (se perdieron en cleanup de git)
2. Premium/Freemium features completas
3. CI/CD workflows
4. Fix Gradle/Kotlin version warnings

## Estado de GitHub
- **Repo**: github.com/DraVoryn/arcas
- **Ramas**: main, feature/reportes-premium (sincronizadas)
- **Contribuidores**: Solo DraVoryn <rafhm22@gmail.com>
- **Historial**: Limpio, 2 commits

## Build Status
- flutter analyze: No issues
- Debug APK: 150MB
- Warnings: Gradle 8.5.0, Kotlin 2.0.21 (no criticos)

## Nota Importante
Durante la limpieza de git history, git filter-repo elimino archivos de lib/ accidentalmente. 
Se recrearon los archivos esenciales. Tests y workflows de CI/CD se perdieron y deben reconstruirse.

## Ultima actualizacion
2026-03-18
