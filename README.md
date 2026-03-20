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

5 tablas normalizadas:

```sql
transactions (id, description, amount, date, categoryId, type, createdAt)
categories   (id, name, icon, color, createdAt)
subscriptions(id, planId, startDate, expirationDate, status, storeTransactionId, createdAt)
report_usage (id, month, year, reportsGenerated, lastReportDate)
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

## 💰 Modelo Freemium

### Free tier

- 3 reportes por mes (cualquier tipo)
- Reset automático mensual
- Todas las features básicas

### Premium ($2.99/mes o $23.88/año)

- Reportes avanzados ilimitados
- Modelo de predicciones
- Exportación a PDF
- Soporte prioritario

### Implementación

- `freemium_limits.dart`: Límites por tier
- `purchase_service.dart`: Integración IAP
- `paywall_screen.dart`: Conversión con l10n

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

- [ ] Testear biometría en iOS
- [ ] Modelo freemium avanzado (2 reportes/semana + 1 avanzado/mes)
- [ ] Reportes avanzados con predicciones
- [ ] Mayor cobertura de tests (>80%)
- [ ] E2E tests con integration_test

---

## 📄 Licencia

MIT License — ver `LICENSE` para detalles.

---

## 🤝 Contribuir

Este proyecto prioriza privacidad y control local. Si querés contribuir, leé primero los principios de diseño en `CONTEXT.md` (no commiteado — es interno del equipo).
