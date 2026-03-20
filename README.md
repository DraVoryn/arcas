# ARCAS

> Tu arcas personal — App de finanzas personales local-first

![Flutter](https://img.shields.io/badge/Flutter-3.41.4-02569B?logo=flutter)
![Drift](https://img.shields.io/badge/Drift-2.31.0-42A5F5?logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-3.3.1-42A5F5?logo=dart)

---

## 📱 Qué es Arcas

App de finanzas personales para Android/iOS que prioriza la **privacidad** y el **control local**. Todos los datos viven en el dispositivo del usuario — sin backend, sin cloud, sin telemetría.

### Principios de diseño

- **Local-first**: Los datos nunca salen del dispositivo
- **Privacy-by-design**: PIN + biometría protegen el acceso
- **Offline-first**: Funciona 100% sin conexión
- **Transparente**: Código abierto, sin tracking

---

## 🏗️ Arquitectura Técnica

### Stack

| Capa | Tecnología |
|------|------------|
| Framework | Flutter 3.41.4 |
| State Management | Riverpod 3.3.1 (AsyncNotifier) |
| Database | Drift 2.31.0 (SQLite) |
| Routing | GoRouter 17.1.0 (redirect + guards) |
| Auth | HMAC-SHA256 + local_auth 3.0.1 |
| IAP | in_app_purchase 3.2.3 |
| L10n | flutter_localizations (ES + EN) |

### Estructura del proyecto

```
lib/
├── auth/           # Autenticación: PIN, biometric, lock screen
├── core/           # Router, theme, app-level config
├── database/       # Drift: schema, tables, migrations
├── l10n/           # Localización: ARB files
├── premium/        # Modelo freemium, paywall, IAP
├── providers/      # Riverpod providers (state)
└── ui/             # Screens y dialogs (presentational)
```

### Patrones aplicados

- **Container-Presentational**: Separación de lógica y UI
- **Repository Pattern**: Database abstraction vía providers
- **Guard Pattern**: GoRouter redirect para rutas protegidas
- **MigrationStrategy**: Drift schema versioning (v3)

---

## 🔐 Sistema de Autenticación

### Diseño de seguridad

- **PIN**: 4-6 dígitos con HMAC-SHA256 + salt de 32 bytes
- **Comparación en tiempo constante**: Previene timing attacks
- **Biometría**: local_auth con fallback a PIN
- **Storage**: SharedPreferences (no encriptado por compatibilidad con Moto G54 5G)

### Flujo de estados

```
onboarding → pinSetup → biometricSetup → locked ↔ unlocked
```

### Decisiones técnicas

| Decisión | Alternativa | Por qué |
|----------|-------------|---------|
| SharedPreferences no encriptado | flutter_secure_storage | Compatibilidad con dispositivos Android de gama media |
| HMAC-SHA256 | Argon2/bcrypt | Suficiente para PIN numérico, más simple de implementar |
| Biometric guard | Auto-trigger siempre | Respetar preferencia del usuario (`isBiometricEnabled`) |
| MainActivity: FlutterFragmentActivity | FlutterActivity | Requerido por local_auth en Android |

---

## 🗄️ Base de Datos (Drift)

### Schema v3

6 tablas normalizadas:

```sql
transactions (id, description, amount, date, categoryId, type, createdAt)
categories   (id, name, icon, color, createdAt)
subscriptions(id, planId, startDate, expirationDate, status, storeTransactionId, createdAt)
report_usage (id, month, year, reportsGenerated, predictionsGenerated, lastReportDate, lastPredictionDate)
reports      (id, type, startDate, endDate, totalIncome, totalExpense, balance, categoryBreakdownJson, generatedAt)
```

### MigrationStrategy

```dart
MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) { /* v2→v3, v3→v4... */ },
  beforeOpen: (db) => customStatement('PRAGMA foreign_keys = ON'),
)
```

---

## 💰 Modelo Freemium (3-Tiers)

### Free tier

- 3 reportes básicos por mes
- Sin reportes avanzados
- Sin predicciones
- Reset automático mensual

### VIP ($1.99/mes) — Recomendado

- **Reportes básicos ilimitados**
- **5 reportes avanzados por mes**
- **2 predicciones por mes**
- Exportación a CSV
- Soporte prioritario

### Premium ($2.99/mes o $23.88/año)

- **TODO ilimitado**
- Reportes avanzados ilimitados
- Predicciones ilimitadas
- Exportación a PDF
- Funciones pro adicionales

### Implementación

- `freemium_limits.dart`: Límites por tier (Free, VIP, Premium)
- `purchase_service.dart`: Integración IAP para 3 productos
- `paywall_screen.dart`: UI con badge "Recomendado" para VIP
- `premium_provider.dart`: Estado extendido con `isVip` y contadores

---

## 🌐 Internacionalización

- **ES** (default) + **EN**
- `app_es.arb` / `app_en.arb` con claves compartidas
- `flutter gen-l10n` para code generation
- Selector en Settings → Idioma

---

## 💵 Sistema de Monedas

10 monedas soportadas con símbolos correctos:

| Código | Símbolo | Nombre |
|--------|---------|--------|
| USD | $ | Dólar estadounidense |
| EUR | € | Euro |
| ARS | $ | Peso argentino |
| MXN | $ | Peso mexicano |
| COP | $ | Peso colombiano |
| CLP | $ | Peso chileno |
| GTQ | Q | Quetzal guatemalteco |
| BRL | R$ | Real brasileño |
| GBP | £ | Libra esterlina |
| JPY | ¥ | Yen japonés |

### Implementación

- `currency_provider.dart`: State + formatting
- Integrado en: Home, Transactions, AddTransactionDialog
- Prefijo de símbolo en inputs de monto

---

## ✅ Changelog Técnico (Resumen)

### 2026-03-20

- **feat**: Sistema de 3-tiers (Free, VIP, Premium)
- **feat**: VIP tier con $1.99/mes — reportes básicos ilimitados, 5 avanzados/mes, 2 predicciones/mes
- **feat**: Migración BD v2→v3 con columnas predictionsGenerated y lastPredictionDate
- **feat**: Sistema de compras actualizado para soportar VIP
- **feat**: PremiumProvider extendido con `isVip` y contadores de predicciones
- **feat**: UI Paywall con badge "Recomendado" para VIP
- **refactor**: FreemiumService eliminando duplicación de código
- **fix**: Delete account ahora borra DB completa (no solo PIN)
- **fix**: PIN persistencia con SharedPreferences no encriptado
- **fix**: Reportes query con `.first` para evitar "too many elements"
- **fix**: Dark mode toggle sin navegación colateral
- **chore**: Dependencies actualizadas a latest stable (6 fases)

### 2026-03-19

- **feat**: BiometricPosition enum (screen/rear/side)
- **feat**: Onboarding con 3 slides localizado (ES/EN)
- **feat**: Biometric guard (verifica preferencia antes de auto-trigger)
- **fix**: MainActivity → FlutterFragmentActivity para local_auth
- **fix**: Logout = lock (no borra datos)
- **fix**: Delete account con advertencia fuerte
- **feat**: Currency selector con 10 monedas + GTQ agregada

### 2026-03-17

- **init**: SDD inicializado (Spec-Driven Development)
- **feat**: MigrationStrategy con schema v3
- **feat**: 5 tablas Drift con foreign keys
- **feat**: Riverpod AsyncNotifier para auth flow

---

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Análisis estático
flutter analyze

# Build debug
flutter build apk --debug

# Build release
flutter build apk --release
flutter build appbundle --release
```

---

## 🚀 Roadmap

### Próxima release (v1.1.0)
- [ ] Configurar productos VIP/Premium en Google Play Console
- [ ] Implementar closed testing con 12+ testers
- [ ] Crear política de privacidad detallada
- [ ] Agregar screenshots para listing
- [ ] Testear biometría en iOS

### Futuras mejoras
- [ ] Modelo freemium avanzado (2 reportes/semana + 1 avanzado/mes)
- [ ] Reportes avanzados con predicciones mejoradas
- [ ] Mayor cobertura de tests (>80%)
- [ ] E2E tests con integration_test
- [ ] Soporte multi-dispositivo (sync opcional)

---

## 📄 Licencia

MIT License — ver `LICENSE` para detalles.

---

## 🔧 Configuración para Producción

### Requisitos para Google Play Store

1. **Cuenta de desarrollador**: $25 USD (una vez)
2. **Configurar signing release**: `android/key.properties`
3. **Cambiar applicationId**: `com.tudominio.arcas` (ID único)
4. **Agregar permisos**: `INTERNET` en AndroidManifest.xml
5. **Configurar IAP en Play Console**:
   - `premium_monthly` - $2.99/mes
   - `premium_yearly` - $23.88/año
   - `com.arcas.vip.monthly` - $1.99/mes
6. **Crear listing**: Icono 512x512, screenshots, descripción
7. **Política de privacidad**: Obligatoria para apps con datos financieros

### Build para producción

```bash
# 1. Configurar firma (ya existe keystore: android/app/arcas-release.jks)
# 2. Generar AAB
flutter build appbundle --release

# 3. Subir a Google Play Console
#    → Testing → Closed testing → Crear release
```

---

