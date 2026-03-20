# ARCAS - Estado del Proyecto

> Última actualización: 2026-03-20
> Versión Flutter: 3.41.4
> Ubicación: `C:\Users\Rafael\proyectos\arcas`

---

## 📱 Qué es Arcas

App de finanzas personales local-first para Android/iOS. Sin backend, sin cloud. Protegido con PIN (4-6 dígitos) + biometría.

---

## 🏗️ STACK

| Componente | Tecnología |
|------------|------------|
| Framework | Flutter 3.41.4 |
| State Management | Riverpod 3.3.1 |
| Database | Drift 2.31.0 (SQLite) |
| Routing | GoRouter 17.1.0 |
| Auth | SharedPreferences + local_auth 3.0.1 |
| IAP | in_app_purchase 3.2.3 |
| Secure Storage | flutter_secure_storage 10.0.0 |

---

## 📁 ESTRUCTURA

```
lib/
├── auth/           # PIN, biometric, lock screen
├── core/          # Router, theme
├── database/      # Drift: transactions, categories, reports
├── l10n/          # ES + EN localization
├── premium/       # Freemium model, reports
├── providers/     # Riverpod providers
└── ui/           # Screens y dialogs
```

---

## 🗄️ BASE DE DATOS

5 tablas: transactions, categories, subscriptions, report_usage, reports.

---

## 🔐 AUTENTICACIÓN

- PIN: 4-6 dígitos, hash SHA-256 + salt (SharedPreferences)
- Biometric: local_auth 3.0.1 (huella/Face ID)
- Flujo: onboarding → pin-setup → biometric-setup → locked → unlocked

---

## ✅ BUGS ARREGLADOS (2026-03-20)

| Bug | Solución |
|-----|----------|
| PIN se perdía al swipe | SharedPreferences en lugar de SecureStorage |
| App iba a onboarding en vez de lock | ref.watch + initialLocation /lock |
| Reportes "too many elements" | query.get() + .first |
| Toggle tema navegaba a home | Router en initState |
| Delete account no borraba datos | Agregado clearAllData() |

---

## 🧪 TESTING

```bash
flutter test      # 48 tests
flutter analyze   # No issues
flutter build apk --debug
```

---

## 🚀 PRÓXIMOS PASOS

- Testear biometric en iOS
- Implementar modelo freemium avanzado
- Agregar más cobertura de tests

---

## 📝 COMMITS

Ver `git log` para historial completo.
