# Contexto de la Aplicacion Arcas

## Resumen del Proyecto
Arcas es una aplicacion de finanzas personales desarrollada con Flutter. Permite a los usuarios gestionar sus transacciones, categorias, y generar reportes. Incluye funcionalidades premium (compras in-app) y esta localizada en espanol e ingles.

**Repo**: https://github.com/DraVoryn/arcas

## Arquitectura y Stack Tecnologico
- **Framework**: Flutter 3.x
- **Lenguaje**: Dart 3.x
- **State Management**: Riverpod (v2.4.0 + annotation/generator)
- **Base de Datos**: Drift (SQLite) con `path_provider`
- **Patron de Arquitectura**: Clean Architecture (Core, Domain, Database, UI)

## Estructura del Proyecto
```
lib/
├── core/               # Tema, Router, Configuraciones globales
│   ├── router/app_router.dart
│   └── theme/app_theme.dart
├── database/           # Capa de datos (Drift/SQLite)
│   ├── app_database.dart
│   ├── app_database.g.dart
│   └── daos/           # TransactionDAO, CategoryDAO, ReportUsageDAO
├── domain/             # Logica de negocio y servicios
│   ├── freemium_service.dart
│   └── purchase_service.dart
├── models/             # Modelos de datos (Freezed)
│   └── premium_plan.dart + .g.dart + .freezed.dart
├── network/            # Clientes de API (Freemium)
│   └── freemium_api_client.dart
├── providers/          # Riverpod providers
│   └── freemium_provider.dart
├── ui/
│   ├── screens/        # HomeScreen, TransactionsScreen, ReportesScreen, SettingsScreen
│   └── widgets/        # UpgradePrompt, PremiumBadge, ReportLimitIndicator, etc.
├── l10n/               # Localizacion (i18n) - ES + EN
└── main.dart           # Punto de entrada
```

## Caracteristicas Implementadas

### Completado
1. **Gestion de Finanzas**: Transacciones y categorias (CRUD completo)
2. **Reportes Premium**: UI completa + PurchaseService
3. **Premium/Freemium**: Sistema de compras in-app (In-App Purchase)
4. **Localizacion**: Spanish (ES) + English (EN), 30+ strings
5. **Navegacion**: GoRouter configurado
6. **UI Base**: Theme, launcher icons, splash screen
7. **Dark Mode**: Toggle en Settings screen con persistencia
8. **Testing**: 28 tests unitarios pasando
9. **CI/CD**: GitHub Actions (pub get, build_runner, analyze, test)
10. **Conventional Commits**: Configurado

### Pendiente
1. Testing en dispositivo
2. Release Workflow
3. Publicacion en stores

## Estado de GitHub
- **Repo**: github.com/DraVoryn/arcas
- **Ramas**: `main`, `feature/reportes-premium`
- **Contribuidores**: Solo DraVoryn <rafhm22@gmail.com>
- **Historial**: 1 commit inicial limpio
- **Ultimo commit**: Dark Mode (2026-03-18)

## Ultima fecha de actualizacion del contexto
2026-03-18
