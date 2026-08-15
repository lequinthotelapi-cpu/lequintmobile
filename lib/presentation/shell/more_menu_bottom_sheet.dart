import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/models/user.dart';
import 'bottom_nav_config.dart';

/// Bottom sheet del ítem "Más" — lista de secciones del rol no incluidas
/// en el bottom nav (SPEC-002).
class MoreMenuBottomSheet extends StatelessWidget {
  const MoreMenuBottomSheet({required this.role, super.key});

  final UserRole role;

  static Future<void> show(BuildContext context, UserRole role) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MoreMenuBottomSheet(role: role),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = moreMenuItemsForRole(role);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.glassElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassElevatedBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              ListTile(
                leading: Icon(item.icon, color: AppColors.textPrimary),
                title: Text(
                  item.label,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(item.route);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
