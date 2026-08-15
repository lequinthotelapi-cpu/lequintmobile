import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/auth/auth_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../auth/login_screen.dart';
import 'temporary_home_screen.dart';

/// Puente entre el estado de Riverpod y el `refreshListenable` de GoRouter:
/// notifica al router cada vez que cambia [authNotifierProvider] para que
/// reevalúe `redirect`.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, _) => notifyListeners());
  }
}

/// Router mínimo para TASK-004: solo login + protección de rutas por
/// estado de autenticación. TASK-005 reemplaza [AppRoutes.dashboard] por el
/// `ShellRoute` con bottom nav y agrega el resto de las rutas del MVP sobre
/// esta misma configuración.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      switch (authState) {
        case AuthInitial():
          return null;
        case AuthAuthenticated():
          return isLoggingIn ? AppRoutes.dashboard : null;
        case AuthLoading():
        case AuthUnauthenticated():
        case AuthError():
          return isLoggingIn ? null : AppRoutes.login;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const TemporaryHomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => const ColoredBox(
      color: AppColors.backgroundSolid,
      child: Center(
        child: Text(
          'Página no encontrada',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    ),
  );
});
