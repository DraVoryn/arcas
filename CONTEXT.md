# ARCAS - Estado del Proyecto

> Última actualización: 2026-03-19
> Versión Flutter: 3.41.4
> Ubicación: `C:\Users\Rafael\proyectos\arcas`

---

## 📱 Qué es Arcas

App de finanzas personales local-first para Android/iOS. Sin backend, sin cloud. Todos los datos viven en el dispositivo del usuario. Protegido con PIN (4-6 dígitos) y biometría (huella/carita).

---

## 🏗️ STACK

| Componente | Tecnología |
|------------|------------|
| Framework | Flutter 3.41.4 |
| State Management | Riverpod 2.6.1 |
| Database | Drift 2.28.2 (SQLite ORM) |
| Routing | GoRouter 14.8.1 |
| Auth | PIN (HMAC-SHA256 + salt) + Biometrics (local_auth) |
| IAP | in_app_purchase 3.2.0 |
| Secure Storage | flutter_secure_storage 9.2.4 |
| Localization | ES (default) + EN |

---

## 📁 ESTRUCTURA

```
lib/
├── auth/
│   ├── auth_service.dart           # PIN hash, biometric, secure storage
│   ├── biometric_position.dart    # Enum: screen / rear / side
│   ├── biometric_setup_screen.dart # Setup de huella con selector de posición
│   ├── lock_screen.dart            # Pantalla de bloqueo
│   ├── onboarding_screen.dart       # Onboarding (localizado ES/EN) + 3 slides
│   ├── pin_setup_screen.dart       # Crear/confirmar PIN
│   └── widgets/
│       └── pin_numpad.dart        # Teclado numérico con botón biometric
├── core/
│   ├── router/
│   │   └── app_router.dart        # GoRouter con redirect logic
│   └── theme/
│       └── app_theme.dart         # Material 3, light/dark
├── database/
│   ├── app_database.dart          # Drift: 5 tablas, MigrationStrategy v3
│   └── app_database.g.dart        # Generado
├── l10n/
│   ├── app_en.arb                 # Claves en inglés
│   ├── app_es.arb                 # Claves en español
│   └── app_localizations.dart      # Generado
├── premium/
│   ├── models/
│   │   ├── freemium_limits.dart   # 3 reportes/mes free
│   │   ├── premium_plan.dart       # $2.99/mes, $23.88/año
│   │   └── report.dart            # Modelo de reporte
│   ├── screens/
│   │   ├── paywall_screen.dart    # Pantalla de compra
│   │   └── premium_settings_screen.dart
│   ├── services/
│   │   └── purchase_service.dart   # Integración IAP
│   └── widgets/
│       ├── premium_badge.dart
│       ├── report_limit_indicator.dart
│       └── upgrade_prompt.dart
├── providers/
│   ├── auth_provider.dart         # AuthNotifier (lock/unlock/deleteAccount)
│   ├── currency_provider.dart      # 10 monedas, formatCurrency()
│   ├── database_provider.dart      # Singleton AppDatabase
│   ├── home_provider.dart         # Balance, transacciones, stats
│   ├── locale_provider.dart        # Preferencia de idioma
│   ├── premium_provider.dart       # Estado premium
│   └── theme_provider.dart        # Light/dark/system
└── ui/
    ├── dialogs/
    │   └── add_transaction_dialog.dart
    └── screens/
        ├── home_screen.dart       # Balance, stats, transacciones recientes
        ├── reportes_screen.dart    # Generador de reportes
        ├── settings_screen.dart   # Logout, delete account, moneda, idioma
        └── transactions_screen.dart # Lista de transacciones con swipe-to-delete
```

---

## 🗄️ BASE DE DATOS (Drift)

### Schema v3 — MigrationStrategy implementada ✅

```sql
transactions (id, description, amount, date, categoryId, type, createdAt)
categories (id, name, icon, color, createdAt)
subscriptions (id, planId, startDate, expirationDate, status, storeTransactionId, createdAt)
report_usage (id, month, year, reportsGenerated, lastReportDate)
reports (id, type, startDate, endDate, totalIncome, totalExpense, balance, categoryBreakdownJson, generatedAt)
```

### MigrationStrategy
```dart
late final MigrationStrategy _migrations = MigrationStrategy(
  onCreate: (m) async => m.createAll(),
  onUpgrade: (m, from, to) async {
    // Placeholder para futuras migraciones
  },
  beforeOpen: (db) async => customStatement('PRAGMA foreign_keys = ON'),
);
```

---

## 🔐 AUTENTICACIÓN

### PIN
- **4-6 dígitos**
- Hash: HMAC-SHA256(pin, salt) — salt aleatorio de 32 bytes
- Comparación en tiempo constante (contra timing attacks)
- Almacenado en `flutter_secure_storage`

### Biometric
- `local_auth` para huella dactilar / Face ID
- **Requiere `FlutterFragmentActivity`** en Android (NO `FlutterActivity`)
- Requiere screen lock del teléfono activo (patrón/PIN/huella)
- Soporta 3 posiciones de sensor: `screen`, `rear`, `side`

### Métodos de AuthNotifier
```dart
lock()           // Logout: solo bloquea, NO borra nada
deleteAccount()  // Reset completo: borra PIN + biometric + prefs
resetApp()       // Alias de deleteAccount()
```

### Flags en SecureStorage
- `_pinHashKey`: hash del PIN
- `_biometricEnabledKey`: bool
- `_biometricPositionKey`: 'screen' | 'rear' | 'side'
- **encryptedSharedPreferences: false** (por compatibilidad con Moto G54 5G)

---

## 💰 PREMIUM / FREEMIUM

### Free
- **3 reportes/mes** (cualquier tipo)
- Reset mensual automático

### Premium Monthly: **$2.99/mes**
- Reportes avanzados ilimitados
- Modelo de predicciones
- Reporte pro con gráficos detallados
- Exportar a PDF
- Soporte prioritario

### Premium Yearly: **$23.88/año**
- Todo lo de Monthly
- Acceso anticipado a nuevas funciones

---

## 💵 MONEDAS

10 monedas soportadas:

| Código | Símbolo | Nombre |
|--------|---------|--------|
| USD | $ | Dólar estadounidense |
| EUR | € | Euro |
| ARS | $ARS | Peso argentino |
| MXN | $MX | Peso mexicano |
| COP | $COP | Peso colombiano |
| CLP | $CLP | Peso chileno |
| GTQ | Q | Quetzal guatemalteco |
| BRL | R$ | Real brasileño |
| GBP | £ | Libra esterlina |
| JPY | ¥ | Yen japonés |

Se muestran con el símbolo de la moneda elegida en:
- **Home** (balance, stats)
- **Transactions** (lista)
- **AddTransaction** (input de monto con prefijo)

---

## 🌐 LOCALIZACIÓN

- **ES** (default): `app_es.arb`
- **EN**: `app_en.arb`
- Generado con `flutter gen-l10n`
- Selector en Settings → Idioma

---

## ⚠️ BUGS CONOCIDOS

| Bug | Gravedad | Status | Notas |
|-----|----------|--------|-------|
| PIN no persiste al cerrar app | 🔴 CRÍTICO | 🔧 Fix aplicado | Cambiado `encryptedSharedPreferences: false`. Necesita test en dispositivo |
| Dark mode toggle → home | 🟡 INVESTIGAR | ❓ | No hay navegación en el código. Necesito aclaración del usuario |
| Refresh en Home no funciona | 🟡 INVESTIGAR | ❓ | `ref.invalidate()` sobre StreamProviders debería funcionar |
| Moneda no cambia en Premium | 🟢 MINOR | 📋 Pendiente | No impacta el flujo de compra |
| Modelo freemium avanzado | 📋 FEATURE | 📋 Pendiente | Usuario quiere: 2 reportes/semana + 1 avanzado/mes para free |

---

## ✅ ARREGLOS IMPLEMENTADOS (2026-03-19)

### Auth Improvements
- [x] MigrationStrategy en app_database.dart
- [x] Onboarding con l10n (3 slides)
- [x] Biometric guard (verifica `isBiometricEnabled` antes de auto-retry)
- [x] BiometricPosition enum + persistencia
- [x] UI selector de posición (screen/rear/side)

### Bug Fixes
- [x] MainActivity → FlutterFragmentActivity (biometric funciona)
- [x] Logout = lock (no más borra PIN)
- [x] Delete account con WARNING fuerte
- [x] Redirect de /paywall y /premium-settings corregido
- [x] Currency selector scrollable (no más overflow)
- [x] Símbolos de moneda corregidos ($MX, $COP, $CLP, $ARS)
- [x] Paywall errores en ES/EN (no más hardcoded)
- [x] Premium precio $2.99/mes, $23.88/año
- [x] Botón de ajustes en Reportes eliminado

### Nuevas Features
- [x] Currency provider con 10 monedas
- [x] Currency integrada en Home, Transactions, AddTransaction
- [x] GTQ (Quetzal guatemalteco) agregada

---

## 🧪 TESTING

```bash
# Ejecutar todos los tests
flutter test

# Análisis estático
flutter analyze

# Build debug APK
flutter build apk --debug
```

---

## 🚀 PRÓXIMOS PASOS

1. **Testear PIN persistence** después del fix de `encryptedSharedPreferences: false`
2. **Aclarar** comportamiento del dark mode toggle
3. **Diseñar** modelo de reportes avanzados + predicciones para premium
4. **Implementar** modelo freemium avanzado (2 normales/semana + 1 avanzado/mes)
5. **Testear** biometric en el Moto G54 5G (ya funcionando con FlutterFragmentActivity)
6. **Correr** `flutter test` para verificar que todo pasa

---

## 📝 COMMITS

Ver `git log` para historial completo. Los commits usan formato conventional commits en español.
