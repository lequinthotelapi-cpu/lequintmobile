import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../domain/models/user.dart';

class NavItemConfig {
  const NavItemConfig({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Ítems del bottom nav por rol — ver SPEC-002.
List<NavItemConfig> bottomNavItemsForRole(UserRole role) {
  switch (role) {
    case UserRole.superadmin:
    case UserRole.admin:
      return const [
        NavItemConfig(
          label: 'Dashboard',
          icon: Icons.home_outlined,
          route: AppRoutes.dashboard,
        ),
        NavItemConfig(
          label: 'Habitaciones',
          icon: Icons.bed_outlined,
          route: AppRoutes.rooms,
        ),
        NavItemConfig(
          label: 'Recepción',
          icon: Icons.desk_outlined,
          route: AppRoutes.frontDesk,
        ),
        NavItemConfig(
          label: 'Housekeeping',
          icon: Icons.cleaning_services_outlined,
          route: AppRoutes.housekeepingOverview,
        ),
      ];
    case UserRole.manager:
      return const [
        NavItemConfig(
          label: 'Dashboard',
          icon: Icons.home_outlined,
          route: AppRoutes.dashboard,
        ),
        NavItemConfig(
          label: 'Habitaciones',
          icon: Icons.bed_outlined,
          route: AppRoutes.rooms,
        ),
        NavItemConfig(
          label: 'Reportes',
          icon: Icons.bar_chart_outlined,
          route: AppRoutes.reports,
        ),
        NavItemConfig(
          label: 'Housekeeping',
          icon: Icons.cleaning_services_outlined,
          route: AppRoutes.housekeepingOverview,
        ),
      ];
    case UserRole.receptionist:
      return const [
        NavItemConfig(
          label: 'Inicio',
          icon: Icons.home_outlined,
          route: AppRoutes.dashboard,
        ),
        NavItemConfig(
          label: 'Llegadas',
          icon: Icons.login_outlined,
          route: AppRoutes.arrivals,
        ),
        NavItemConfig(
          label: 'Salidas',
          icon: Icons.logout_outlined,
          route: AppRoutes.departures,
        ),
        NavItemConfig(
          label: 'Habitaciones',
          icon: Icons.bed_outlined,
          route: AppRoutes.rooms,
        ),
      ];
    case UserRole.housekeeper:
      return const [
        NavItemConfig(
          label: 'Mis Tareas',
          icon: Icons.task_outlined,
          route: AppRoutes.myTasks,
        ),
        NavItemConfig(
          label: 'Habitaciones',
          icon: Icons.bed_outlined,
          route: AppRoutes.rooms,
        ),
        NavItemConfig(
          label: 'Notificaciones',
          icon: Icons.notifications_outlined,
          route: AppRoutes.notifications,
        ),
        NavItemConfig(
          label: 'Perfil',
          icon: Icons.person_outline,
          route: AppRoutes.profile,
        ),
      ];
    case UserRole.guest:
      return const []; // Fuera del MVP — ver docs/product/scope.md
  }
}

/// El housekeeper no tiene ítem "Más" (4 ítems fijos — SPEC-002).
bool hasMoreMenu(UserRole role) => role != UserRole.housekeeper;

/// Opciones del bottom sheet "Más" por rol — ver SPEC-002.
///
/// "Buscar huésped" (mencionado en SPEC-002 para receptionist) se omite:
/// no tiene ruta ni pantalla asignada en ninguna TASK ni en
/// architecture.md — no se inventa aquí.
List<NavItemConfig> moreMenuItemsForRole(UserRole role) {
  switch (role) {
    case UserRole.superadmin:
    case UserRole.admin:
    case UserRole.manager:
    case UserRole.receptionist:
      return const [
        NavItemConfig(
          label: 'Huéspedes en casa',
          icon: Icons.people_outline,
          route: AppRoutes.inHouse,
        ),
        NavItemConfig(
          label: 'Notificaciones',
          icon: Icons.notifications_outlined,
          route: AppRoutes.notifications,
        ),
        NavItemConfig(
          label: 'Perfil',
          icon: Icons.person_outline,
          route: AppRoutes.profile,
        ),
      ];
    case UserRole.housekeeper:
    case UserRole.guest:
      return const [];
  }
}
