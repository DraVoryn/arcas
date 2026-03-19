# Contexto de la Aplicacion Arcas

## Resumen del Proyecto
Arcas es una aplicacion de finanzas personales desarrollada con Flutter. Permite a los usuarios gestionar sus transacciones, categorias, y generar reportes. Incluye funcionalidades premium (compras in-app) y esta localizada en espanol e ingles.

**Repo**: https://github.com/DraVoryn/arcas
**Stack**: Flutter 3.41.4 + Drift + Riverpod + GoRouter + in_app_purchase
**Contribuidor**: DraVoryn <rafhm22@gmail.com>

## Arquitectura y Stack Tecnologico
- **Framework**: Flutter 3.41.4
- **Lenguaje**: Dart 3.x
- **State Management**: Riverpod (v2.6.1)
- **Base de Datos**: Drift (SQLite) con `path_provider`
- **Navegacion**: GoRouter con redirect logic
- **Compras**: in_app_purchase ^3.2.0
- **Seguridad**: flutter_secure_storage + crypto (SHA-256 HMAC)
- **Biometria**: local_auth ^2.3.0
- **Testing**: flutter_test con 48 tests

## Estructura del Proyecto
```
lib/
├── main.dart                    (Entry point con try-catch)
├── core/
│   ├── router/app_router.dart   (GoRouter con auth redirects)
│   ├── theme/app_theme.dart     (Material 3 light/dark)
│   └── utils/date_formatter.dart (Helper para fechas con locale)
├── database/
│   ├── app_database.dart       (Drift con 5 tablas)
│   └── app_database.g.dart     (Generado)
├── providers/
│   ├── database_provider.dart   (Instancia unica global)
│   ├── theme_provider.dart     (Dark mode toggle)
│   ├── locale_provider.dart     (ES/EN/Sistema)
│   ├── auth_provider.dart      (PIN, biometric, auth state)
│   ├── home_provider.dart      (Balance, stats, transacciones)
│   └── premium_provider.dart  (Suscripcion, freemium)
├── auth/
│   ├── auth_service.dart       (Hashing, verificacion PIN)
│   ├── lock_screen.dart       (Pantalla de bloqueo)
│   ├── pin_setup_screen.dart   (Crear PIN)
│   ├── biometric_setup_screen.dart
│   ├── onboarding_screen.dart
│   └── widgets/pin_numpad.dart
├── premium/
│   ├── models/
│   │   ├── premium_plan.dart
│   │   ├── subscription.dart
│   │   ├── report.dart
│   │   ├── category_breakdown.dart
│   │   └── freemium_limits.dart (3 reportes/mes free)
│   ├── services/
│   │   ├── freemium_service.dart
│   │   ├── purchase_service.dart (In-app purchase con stream)
│   │   └── report_service.dart
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
│   │   ├── home_screen.dart        (Balance, stats, transacciones)
│   │   ├── transactions_screen.dart (CRUD completo)
│   │   ├── reportes_screen.dart     (Reportes con freemium)
│   │   └── settings_screen.dart   (Dark mode, idioma, logout)
│   └── dialogs/
│       └── add_transaction_dialog.dart
└── l10n/
    ├── app_localizations.dart      (Base class)
    ├── app_localizations_en.dart   (~470 keys)
    └── app_localizations_es.dart   (~470 keys)
```

## Funcionalidades Implementadas

### Autenticacion
| Feature | Estado | Descripcion |
|---------|--------|-------------|
| PIN setup | ✅ | 4-6 digitos, validacion de debiles |
| PIN hashing | ✅ | SHA-256 HMAC con salt (Random.secure) |
| Lock screen | ✅ | 5 intentos max, shake animation |
| Biometric | ✅ | Face/Fingerprint con auto-retry |
| Onboarding | ✅ | 2 slides para nuevos usuarios |
| Logout | ✅ | Reset completo con confirmacion |

### Home Screen
| Feature | Estado | Descripcion |
|---------|--------|-------------|
| Balance | ✅ | Total en tiempo real (ingresos - gastos) |
| Stats mensuales | ✅ | Ingresos y gastos del mes actual |
| Transacciones recientes | ✅ | Ultimas 10 ordenadas por fecha |
| Pull-to-refresh | ✅ | Invalidates todos los providers |

### Transacciones
| Feature | Estado | Descripcion |
|---------|--------|-------------|
| Agregar | ✅ | Dialog con validacion |
| Editar | ✅ | Tap en item |
| Eliminar | ✅ | Swipe-to-delete con confirmacion |
| Lista real-time | ✅ | Streams de Drift |
| Categorias | ✅ | Nullable en transacciones |

### Reportes
| Feature | Estado | Descripcion |
|---------|--------|-------------|
| Semanal | ✅ | Ultimos 7 dias |
| Mensual | ✅ | Mes actual |
| Custom | ✅ | Date picker para rango |
| Breakdown | ✅ | Por categoria con porcentajes |
| Persistencia | ✅ | Tabla Reports en DB |

### Premium/Freemium
| Feature | Estado | Descripcion |
|---------|--------|-------------|
| Limite free | ✅ | 3 reportes/mes |
| Upgrade prompt | ✅ | Aparece al alcanzar limite |
| Paywall | ✅ | Planes monthly ($4.99) y yearly ($35.99) |
| Purchase | ✅ | Stream listener con manejo de errores |
| Restore | ✅ | Timeout 5 minutos |
| Settings | ✅ | Estado de suscripcion visible |

### Settings
| Feature | Estado | Descripcion |
|---------|--------|-------------|
| Dark mode | ✅ | Toggle con persistencia |
| Idioma | ✅ | ES/EN/Sistema con modal |
| Premium link | ✅ | Navega a /premium-settings |
| Logout | ✅ | Reset app + confirmacion |
| Acerca de | ✅ | showAboutDialog con icono |

## Base de Datos

### Tablas
| Tabla | Campos | Operations |
|-------|--------|------------|
| Transactions | id, description, amount, date, categoryId, type, createdAt | CRUD completo + streams |
| Categories | id, name, icon, color, createdAt | CRUD completo |
| Subscriptions | id, planId, startDate, expirationDate, status, storeTransactionId | Insert + get active |
| Reports | id, type, startDate, endDate, totals, breakdownJson, generatedAt | Insert + queries |
| ReportUsage | id, month, year, reportsGenerated, lastReportDate | Track monthly usage |

### Providers de Datos
```dart
databaseProvider          // Instancia unica global
transactionsStreamProvider  // Watch all transactions
allCategoriesProvider      // Watch categories
totalBalanceProvider       // Calculado desde transactions
recentTransactionsProvider  // Top 10
monthlyStatsProvider       // Stats del mes actual
```

## Navegacion

### Rutas
```
/onboarding           -> OnboardingScreen (sin navbar)
/pin-setup           -> PinSetupScreen (sin navbar)
/biometric-setup    -> BiometricSetupScreen (sin navbar)
/lock                -> LockScreen (sin navbar)
/paywall             -> PaywallScreen (sin navbar)
/premium-settings   -> PremiumSettingsScreen (sin navbar)

Shell (con navbar):
/home                -> HomeScreen
/transactions        -> TransactionsScreen
/reportes            -> ReportesScreen
/settings            -> SettingsScreen
```

### Auth Redirects
| Estado | Ruta | Condicion |
|--------|------|-----------|
| newUser | /onboarding | Sin onboarding previo |
| needsPin | /pin-setup | Sin PIN configurado |
| needsBiometric | /biometric-setup | Biometric disponible pero no habilitado |
| locked | /lock | Cualquier ruta protegida |

## Localizacion
- **Espanol**: ~470 keys
- **English**: ~470 keys
- **Sistema**: Hereda del dispositivo
- **Coverage**: 100% de todas las pantallas

## Error Handling
| Area | Manejo |
|------|--------|
| DB init | Try-catch en main() con pantalla de error |
| Purchase | PurchaseErrorType enum (storeUnavailable, networkError, userCancelled, etc) |
| Network | Timeout + catch exceptions |

## Build Status
- `flutter analyze`: 0 issues found
- `flutter test`: 48 tests passing
- `flutter build appbundle --release`: Exitoso (~45MB)

## CI/CD
- **PR Checks**: Activo (pr-checks.yml)
  - flutter analyze
  - flutter test
  - flutter build apk (artifact)
- **Release**: Template listo (release.yml)
  - Necesita secrets para activar

## Secrets para Deploy

### Android
| Secret | Descripcion |
|--------|-------------|
| ANDROID_SIGNING_KEYSTORE | Keystore .jks en base64 |
| ANDROID_KEYSTORE_PASSWORD | Contrasena del keystore |
| ANDROID_KEY_ALIAS | Alias de la key |
| ANDROID_KEY_PASSWORD | Contrasena de la key |
| PLAY_SERVICE_ACCOUNT_JSON | GCP Service Account |

### iOS
| Secret | Descripcion |
|--------|-------------|
| IOS_CERTIFICATE | Certificado .p12 en base64 |
| IOS_CERTIFICATE_PASSWORD | Contrasena del certificado |
| IOS_PROVISIONING_PROFILE | .mobileprovision en base64 |

## Issues Conocidos
1. **Sin DB migrations**: schemaVersion 2 sin onUpgrade handler
2. **Onboarding hardcoded**: Slides no estan en l10n
3. **Biometric retry**: Podria verificar enabled flag antes de auto-retry

## Pendientes para Publicacion
1. Configurar productos in-app en Google Play Console
2. Crear Service Account de GCP
3. Configurar bundle ID (com.arcas.app)
4. Screenshots reales de la app
5. Descripcion y categorizacion en stores

## Pendientes Nice-to-Have
- Export PDF (placeholder existe)
- Advanced Analytics (placeholder existe)
- Priority Support (placeholder existe)
- Early Access Features (placeholder existe)
- Widget de home screen

## Ultima Actualizacion
2026-03-19

## Commits Recientes
```
4d6d95b Agrega formateo de fechas con locale de la app
f0a0532 Agrega keystore al gitignore
fc995bd Mejoras de manejo de errores
2384baa Agrega opcion de logout en Settings
bf8ca21 Agrega localizacion a pantallas de autenticacion y navegacion
03556bc Agrega localizacion completa a pantallas premium
54dcdfa Arregla seguridad de auth y localizacion en transacciones
6c08518 Corrige localizaciones y actualiza Kotlin a 2.1.0
```
