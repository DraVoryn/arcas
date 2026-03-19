import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arcas/providers/auth_provider.dart';
import 'package:arcas/ui/screens/home_screen.dart';
import 'package:arcas/ui/screens/transactions_screen.dart';
import 'package:arcas/ui/screens/reportes_screen.dart';
import 'package:arcas/ui/screens/settings_screen.dart';
import 'package:arcas/auth/onboarding_screen.dart';
import 'package:arcas/auth/pin_setup_screen.dart';
import 'package:arcas/auth/biometric_setup_screen.dart';
import 'package:arcas/auth/lock_screen.dart';
import 'package:arcas/premium/screens/paywall_screen.dart';
import 'package:arcas/premium/screens/premium_settings_screen.dart';

// ==========================================================================
// RUTAS PÚBLICAS (sin auth requerida)
// ==========================================================================

/// Rutas que NO requieren autenticación.
const _publicRoutes = [
  '/onboarding',
  '/pin-setup',
  '/biometric-setup',
  '/lock',
  '/paywall',
  '/premium-settings',
];

// ==========================================================================
// FACTORY FUNCTION (para usar con Riverpod)
// ==========================================================================

/// Crea el router de la app.
///
/// ¿Por qué una función y no una clase estática?
/// Porque GoRouter necesita acceder al ProviderScope de Riverpod.
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,

    // =====================================================================
    // REDIRECT LOGIC
    // =====================================================================
    redirect: (BuildContext context, GoRouterState state) {
      // Obtenemos el estado actual de auth (ahora es async)
      final authAsync = ref.read(authNotifierProvider);

      // Si todavía está cargando, permitir acceso a cualquier ruta pública
      // El estado se actualizará cuando termine de cargar
      final authState = authAsync.valueOrNull;
      if (authState == null) {
        final targetRoute = state.uri.path;
        // Permitir acceso a rutas públicas mientras carga
        if (_publicRoutes.contains(targetRoute)) {
          return null;
        }
        // Si intenta ir a una ruta protegida, ir a onboarding temporalmente
        return '/onboarding';
      }

      final targetRoute = state.uri.path;

      // =====================================================================
      // REGLA 1: Rutas públicas → siempre permitir
      // =====================================================================
      if (_publicRoutes.contains(targetRoute)) {
        // Si YA está unlocked y quiere ir a una ruta pública,
        // lo redirigimos a home
        if (authState.status == AuthStatus.unlocked) {
          return '/home';
        }
        // Si está configurando algo, permitir
        return null;
      }

      // =====================================================================
      // REGLA 2: App bloqueada → redirigir a /lock
      // =====================================================================
      if (authState.status == AuthStatus.locked) {
        if (targetRoute != '/lock') {
          return '/lock';
        }
        return null;
      }

      // =====================================================================
      // REGLA 3: Onboarding pendiente → redirigir a /onboarding
      // =====================================================================
      if (authState.status == AuthStatus.onboarding) {
        if (targetRoute != '/onboarding') {
          return '/onboarding';
        }
        return null;
      }

      // =====================================================================
      // REGLA 4: PIN setup pendiente → redirigir a /pin-setup
      // =====================================================================
      if (authState.status == AuthStatus.pinSetup) {
        if (targetRoute != '/pin-setup') {
          return '/pin-setup';
        }
        return null;
      }

      // =====================================================================
      // REGLA 5: Biometric setup pendiente → redirigir a /biometric-setup
      // =====================================================================
      if (authState.status == AuthStatus.biometricSetup) {
        if (targetRoute != '/biometric-setup') {
          return '/biometric-setup';
        }
        return null;
      }

      // =====================================================================
      // REGLA 6: Desbloqueado → permitir acceso
      // =====================================================================
      return null;
    },

    // =====================================================================
    // DEFINICIÓN DE RUTAS
    // =====================================================================
    routes: [
      // ---------------------------------------------------------------------
      // RUTAS DE AUTH (pantallas sin navbar)
      // ---------------------------------------------------------------------
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/biometric-setup',
        builder: (context, state) => const BiometricSetupScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/premium-settings',
        builder: (context, state) => const PremiumSettingsScreen(),
      ),

      // ---------------------------------------------------------------------
      // RUTAS DE LA APP (con navbar)
      // ---------------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransactionsScreen(),
            ),
          ),
          GoRoute(
            path: '/reportes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportesScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

// ==========================================================================
// NAVIGATION BAR (mantiene la implementación existente)
// ==========================================================================

/// Widget que envuelve las pantallas principales con la barra de navegación.
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/reportes')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/reportes');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
