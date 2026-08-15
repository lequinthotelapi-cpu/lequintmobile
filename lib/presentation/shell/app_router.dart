import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/auth/auth_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../domain/models/user.dart';
import '../auth/login_screen.dart';
import '../housekeeping/complete_task_screen.dart';
import '../housekeeping/my_tasks_screen.dart';
import '../housekeeping/task_detail_screen.dart';
import 'app_shell.dart';
import 'bottom_nav_config.dart';
import 'placeholder_screen.dart';
import 'splash_screen.dart';

/// Puente entre el estado de Riverpod y el `refreshListenable` de GoRouter:
/// notifica al router cada vez que cambia [authNotifierProvider] para que
/// reevalúe `redirect`.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, _) => notifyListeners());
  }
}

String _homeRouteForRole(UserRole role) =>
    role == UserRole.housekeeper ? AppRoutes.myTasks : AppRoutes.dashboard;

/// Guarda de acceso para las rutas raíz de cada pestaña del shell
/// (SPEC-002, regla: "si un rol intenta acceder a una ruta no permitida →
/// redirigir a su home"). Las subpantallas que se agreguen en TASKs
/// futuras (detalle de reserva, cuenta, etc.) implementan su propia
/// verificación de permisos según su propia SPEC.
bool _roleCanAccessTabRoute(UserRole role, String route) {
  switch (route) {
    case AppRoutes.dashboard:
      return role != UserRole.housekeeper;
    case AppRoutes.frontDesk:
      return role == UserRole.superadmin || role == UserRole.admin;
    case AppRoutes.housekeepingOverview:
      return role == UserRole.superadmin ||
          role == UserRole.admin ||
          role == UserRole.manager;
    case AppRoutes.reports:
      return role == UserRole.manager;
    case AppRoutes.myTasks:
      return role == UserRole.housekeeper;
    case AppRoutes.arrivals:
    case AppRoutes.departures:
      // Lectura permitida también a manager (SPEC-006/007); solo
      // housekeeper queda fuera.
      return role != UserRole.housekeeper;
    default:
      return true;
  }
}

String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authNotifierProvider);
  final location = state.matchedLocation;
  final isSplash = location == AppRoutes.splash;
  final isLogin = location == AppRoutes.login;

  switch (authState) {
    case AuthInitial():
      return isSplash ? null : AppRoutes.splash;
    case AuthLoading():
    case AuthUnauthenticated():
    case AuthError():
      return isLogin ? null : AppRoutes.login;
    case AuthAuthenticated(:final user):
      final home = _homeRouteForRole(user.role);
      if (isSplash || isLogin) return home;
      if (!_roleCanAccessTabRoute(user.role, location)) return home;
      return null;
  }
}

List<GoRoute> _moreMenuRoutes(UserRole role) => [
  for (final item in moreMenuItemsForRole(role))
    GoRoute(
      path: item.route,
      builder: (context, state) => PlaceholderScreen(title: item.label),
    ),
];

/// Pantalla real para las rutas ya implementadas; el resto sigue mostrando
/// [PlaceholderScreen] hasta que su TASK correspondiente las construya.
Widget _screenForTabRoute(String route, String label) {
  switch (route) {
    case AppRoutes.myTasks:
      return const MyTasksScreen();
    default:
      return PlaceholderScreen(title: label);
  }
}

StatefulShellRoute _shellRoute(UserRole role) {
  final items = bottomNavItemsForRole(role);
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(navigationShell: navigationShell, role: role),
    branches: [
      for (final item in items)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: item.route,
              builder: (context, state) =>
                  _screenForTabRoute(item.route, item.label),
            ),
          ],
        ),
    ],
  );
}

/// El árbol de rutas se reconstruye cuando cambia el rol del usuario
/// (null↔rol, o de un rol a otro) para que cada uno tenga exactamente las
/// pestañas del shell que le corresponden (SPEC-002) — no un único árbol
/// compartido con ítems ocultos. Esto solo ocurre en login/logout, una
/// transición de navegación ya disruptiva de por sí.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);
  final role = ref.watch(currentUserRoleProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      if (role != null) ..._moreMenuRoutes(role),
      // Rutas "push" fuera del shell (sin bottom nav) — igual que las de
      // "Más": pantallas de detalle/formulario, no pestañas persistentes.
      if (role != null)
        GoRoute(
          path: AppRoutes.taskDetail,
          builder: (context, state) =>
              TaskDetailScreen(taskId: state.pathParameters['id']!),
        ),
      if (role != null)
        GoRoute(
          path: AppRoutes.completeTask,
          builder: (context, state) =>
              CompleteTaskScreen(taskId: state.pathParameters['id']!),
        ),
      if (role != null) _shellRoute(role),
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
