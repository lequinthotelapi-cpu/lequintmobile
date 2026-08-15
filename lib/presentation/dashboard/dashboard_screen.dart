import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/user.dart';
import '../shared/widgets/offline_banner.dart';
import 'widgets/admin_dashboard.dart';
import 'widgets/housekeeper_dashboard.dart';
import 'widgets/manager_dashboard.dart';
import 'widgets/receptionist_dashboard.dart';

/// Router de dashboard por rol — ver SPEC-003, DECISION-009. Provee el
/// fondo/chrome compartido; cada rol arma su propio contenido.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGradientTop,
            AppColors.backgroundGradientBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(child: _dashboardForRole(role)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardForRole(UserRole? role) {
    switch (role) {
      case UserRole.superadmin:
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.manager:
        return const ManagerDashboard();
      case UserRole.receptionist:
        return const ReceptionistDashboard();
      case UserRole.housekeeper:
        return const HousekeeperDashboard();
      case UserRole.guest:
      case null:
        return const SizedBox.shrink();
    }
  }
}
