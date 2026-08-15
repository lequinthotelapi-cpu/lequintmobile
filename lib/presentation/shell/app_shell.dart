import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/notifications/notifications_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../domain/models/user.dart';
import 'bottom_nav_config.dart';
import 'more_menu_bottom_sheet.dart';

/// Contenedor del shell: bottom nav diferenciada por rol +
/// `StatefulNavigationShell` de GoRouter (preserva el estado de cada
/// pestaña — equivalente a `IndexedStack`, ver SPEC-002).
class AppShell extends ConsumerWidget {
  const AppShell({
    required this.navigationShell,
    required this.role,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = bottomNavItemsForRole(role);
    final showMore = hasMoreMenu(role);
    final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _GlassBottomNav(
        items: items,
        currentIndex: navigationShell.currentIndex,
        onItemTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        showMore: showMore,
        unreadCount: unreadCount,
        onMoreTap: () => MoreMenuBottomSheet.show(context, role),
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onItemTap,
    required this.showMore,
    required this.unreadCount,
    required this.onMoreTap,
  });

  final List<NavItemConfig> items;
  final int currentIndex;
  final ValueChanged<int> onItemTap;
  final bool showMore;
  final int unreadCount;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomInset, top: 8),
          decoration: const BoxDecoration(
            color: AppColors.glassElevated,
            border: Border(
              top: BorderSide(color: AppColors.glassElevatedBorder),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavBarItem(
                    label: items[i].label,
                    icon: items[i].icon,
                    isActive: i == currentIndex,
                    // El badge solo aparece directamente en el ícono de
                    // Notificaciones cuando el rol lo tiene como pestaña
                    // propia (housekeeper); el resto lo ve en "Más".
                    unreadCount:
                        !showMore && items[i].route == AppRoutes.notifications
                        ? unreadCount
                        : 0,
                    onTap: () => onItemTap(i),
                  ),
                ),
              if (showMore)
                Expanded(
                  child: _NavBarItem(
                    label: 'Más',
                    icon: Icons.menu,
                    isActive: false,
                    unreadCount: unreadCount,
                    onTap: onMoreTap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.unreadCount,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accentPrimary : AppColors.textTertiary;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 22),
                if (unreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: _UnreadBadge(count: unreadCount),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
