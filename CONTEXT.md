# Contexto de la Aplicacion Arcas

## Resumen del Proyecto
Arcas es una aplicacion de finanzas personales desarrollada con Flutter. Permite a los usuarios gestionar sus transacciones, categorias, y generar reportes. Incluye funcionalidades premium (compras in-app) y esta localizada en espanol e ingles.

**Repo**: https://github.com/DraVoryn/arcas

## Arquitectura y Stack Tecnologico
- **Framework**: Flutter 3.41.4
- **Lenguaje**: Dart 3.x
- **State Management**: Riverpod (v2.6.1 + annotation/generator)
- **Base de Datos**: Drift (SQLite) con `path_provider`
- **Patron de Arquitectura**: Clean Architecture
- **Testing**: flutter_test con 48 tests
- **In-App Purchases**: in_app_purchase ^3.2.0

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
│   ├── database_provider.dart    (instancia unica global)
│   ├── theme_provider.dart
│   ├── locale_provider.dart
│   ├── auth_provider.dart
│   ├── home_provider.dart
│   └── premium_provider.dart
├── auth/
│   ├── auth_service.dart         (PIN + hashing)
│   ├── lock_screen.dart
│   ├── pin_setup_screen.dart
│   ├── biometric_setup_screen.dart
│   ├── onboarding_screen.dart
│   └── widgets/pin_numpad.dart
├── premium/
│   ├── models/
│   │   ├── premium_plan.dart
│   │   ├── subscription.dart
│   │   ├── report.dart
│   │   ├── category_breakdown.dart
│   │   └── freemium_limits.dart
│   ├── services/
│   │   ├── freemium_service.dart (limites freemium)
│   │   ├── purchase_service.dart (in-app purchases)
│   │   └── report_service.dart   (generacion de reportes)
│   ├── screens/
│   │   ├── paywall_screen.dart
│   │   └── premium_settings_screen.dart
│   └── widgets/
│       ├── premium_badge.dart
│       ├── report_limit_indicator.dart
│       ├── upgrade_prompt.dart
│       └── report_card.dart
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart      (balance, stats, transacciones recientes)
│   │   ├── transactions_screen.dart (CRUD completo)
│   │   ├── reportes_screen.dart  (reportes con freemium)
│   │   └── settings_screen.dart  (dark mode, idioma, premium)
│   ├── dialogs/
│   │   └── add_transaction_dialog.dart
│   └── widgets/
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_es.dart
```

## Funcionalidades Implementadas

### Autenticacion
- PIN de 4 digitos con validacion de contrasenas debiles
- Hashing con salt cryptografico
- Soporte biometric (huella/facial)
- Onboarding inicial para nuevos usuarios

### Transacciones
- CRUD completo: crear, leer, editar, eliminar
- Categorias personalizables
- Tipos: income (ingreso) y expense (gasto)
- Filtrado por fechas y categorias

### Reportes
- Reportes semanales, mensuales y personalizados
- Breakdown por categoria
- Balance total con ingresos y gastos
- Persistencia de reportes generados

### Premium/Freemium
- 3 reportes gratis por mes para usuarios gratuitos
- Reportes ilimitados para usuarios premium
- Integracion con Google Play y App Store via in_app_purchase
- Flujo de compra con stream listener para estados async
- Restauracion de compras implementada

### UI/UX
- Material 3 Design
- Dark Mode con persistencia
- Localizacion completa: Espanol e Ingles (26+ keys)
- Pull-to-refresh en listas
- Swipe-to-delete en transacciones

## Estado de GitHub
- **Repo**: github.com/DraVoryn/arcas
- **Ramas**: main (production-ready)
- **Commits**: 16 commits en main
- **Contribuidores**: Solo DraVoryn <rafhm22@gmail.com>

## Build Status
- flutter analyze: 0 issues found
- flutter test: 48 tests passing
- Debug APK: Compila correctamente

## CI/CD
- **PR Checks**: Activo (.github/workflows/pr-checks.yml)
  - flutter analyze
  - flutter test
  - flutter build apk (artifact)
- **Release Workflow**: Template listo (.github/workflows/release.yml)
  - Necesita secrets para activar

## Secrets para Deploy

### Google Play (necesarios 5)
| Secret | Descripcion |
|--------|-------------|
| ANDROID_SIGNING_KEYSTORE | Keystore .jks en base64 |
| ANDROID_KEYSTORE_PASSWORD | Contrasena del keystore |
| ANDROID_KEY_ALIAS | Alias de la key |
| ANDROID_KEY_PASSWORD | Contrasena de la key |
| PLAY_SERVICE_ACCOUNT_JSON | JSON de GCP Service Account |

### App Store (necesarios 3)
| Secret | Descripcion |
|--------|-------------|
| IOS_CERTIFICATE | Certificado .p12 en base64 |
| IOS_CERTIFICATE_PASSWORD | Contrasena del certificado |
| IOS_PROVISIONING_PROFILE | .mobileprovision en base64 |

## Configuracion Requerida en Stores

### Google Play Console
1. Crear app "Arcas"
2. Configurar producto "premium_monthly" (ej: $4.99/mes)
3. Configurar producto "premium_yearly" (ej: $35.99/ano)
4. Crear Service Account en GCP
5. Generar keystore de release:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000
   ```

### App Store Connect
1. Crear app "Arcas"
2. Crear suscripcion en Features > Subscriptions
3. Configurar grupo de suscripcion
4. Generar certificados de Apple Developer

## Ultima Actualizacion
2026-03-19
