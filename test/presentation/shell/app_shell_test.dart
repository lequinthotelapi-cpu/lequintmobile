import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lequintmobile/application/notifications/notifications_provider.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/presentation/shell/app_shell.dart';
import 'package:lequintmobile/presentation/shell/bottom_nav_config.dart';

Widget _buildShellApp(UserRole role) {
  final items = bottomNavItemsForRole(role);
  final router = GoRouter(
    initialLocation: items.first.route,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell, role: role),
        branches: [
          for (final item in items)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: item.route,
                  builder: (context, state) => const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      unreadNotificationsCountProvider.overrideWith(
        (ref) => const Stream<int>.empty(),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets(
    'superadmin ve Dashboard, Habitaciones, Recepción, Housekeeping y Más',
    (tester) async {
      await tester.pumpWidget(_buildShellApp(UserRole.superadmin));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Habitaciones'), findsOneWidget);
      expect(find.text('Recepción'), findsOneWidget);
      expect(find.text('Housekeeping'), findsOneWidget);
      expect(find.text('Más'), findsOneWidget);
    },
  );

  testWidgets(
    'manager ve Dashboard, Habitaciones, Reportes, Housekeeping y Más',
    (tester) async {
      await tester.pumpWidget(_buildShellApp(UserRole.manager));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Reportes'), findsOneWidget);
      expect(find.text('Housekeeping'), findsOneWidget);
      expect(find.text('Más'), findsOneWidget);
    },
  );

  testWidgets('receptionist ve Inicio, Llegadas, Salidas, Habitaciones y Más', (
    tester,
  ) async {
    await tester.pumpWidget(_buildShellApp(UserRole.receptionist));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Llegadas'), findsOneWidget);
    expect(find.text('Salidas'), findsOneWidget);
    expect(find.text('Habitaciones'), findsOneWidget);
    expect(find.text('Más'), findsOneWidget);
  });

  testWidgets(
    'housekeeper ve Mis Tareas, Habitaciones, Notificaciones, Perfil — sin Más (4 ítems fijos)',
    (tester) async {
      await tester.pumpWidget(_buildShellApp(UserRole.housekeeper));
      await tester.pumpAndSettle();

      expect(find.text('Mis Tareas'), findsOneWidget);
      expect(find.text('Habitaciones'), findsOneWidget);
      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Más'), findsNothing);
    },
  );
}
