import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_provider.dart';
import '../../../application/bookings/bookings_provider.dart';
import '../../../application/dashboard/dashboard_provider.dart';
import '../../../application/guest_accounts/guest_account_provider.dart';
import '../../../application/rooms/rooms_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/async_utils.dart';
import 'dashboard_header.dart';
import 'dashboard_skeleton.dart';
import 'financial_kpis_card.dart';
import 'operational_kpis_card.dart';
import 'quick_actions_row.dart';
import 'room_status_summary.dart';

/// Dashboard de superadmin/admin — ver SPEC-003.
class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final arrivalsAsync = ref.watch(arrivalsProvider);
    final departuresAsync = ref.watch(departuresProvider);
    final roomsAsync = ref.watch(roomsWithStatusProvider);
    final openAccountsAsync = ref.watch(openGuestAccountsProvider);
    final financialAsync = ref.watch(financialKpisProvider);

    final loading = anyLoading([
      arrivalsAsync,
      departuresAsync,
      roomsAsync,
      openAccountsAsync,
      financialAsync,
    ]);
    final error = firstError([
      arrivalsAsync,
      departuresAsync,
      roomsAsync,
      openAccountsAsync,
      financialAsync,
    ]);

    void refresh() {
      ref
        ..invalidate(arrivalsProvider)
        ..invalidate(departuresProvider)
        ..invalidate(roomsWithStatusProvider)
        ..invalidate(openGuestAccountsProvider)
        ..invalidate(financialKpisProvider);
    }

    if (loading) {
      return const DashboardSkeleton();
    }
    if (error != null) {
      return ErrorState(
        message: 'No se pudieron cargar los datos',
        onRetry: refresh,
      );
    }

    final rooms = roomsAsync.value!;
    final occupied = rooms.where((r) => r.displayStatus == 'occupied').length;

    return RefreshIndicator(
      onRefresh: () async => refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          DashboardHeader(greeting: 'Hola, ${user?.firstName ?? ''}'),
          const SizedBox(height: 20),
          OperationalKpisCard(
            arrivalsToday: arrivalsAsync.value!.length,
            departuresToday: departuresAsync.value!.length,
            occupancyLabel: '$occupied/${rooms.length}',
            openAccountsCount: openAccountsAsync.value!.length,
          ),
          const SizedBox(height: 24),
          const Text(
            'Estado de habitaciones',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          RoomStatusSummary(rooms: rooms),
          const SizedBox(height: 24),
          FinancialKpisCard(kpis: financialAsync.value!),
          const SizedBox(height: 24),
          QuickActionsRow(
            actions: [
              QuickAction(
                label: 'Llegadas',
                icon: Icons.login_outlined,
                onTap: () => context.push(AppRoutes.arrivals),
              ),
              QuickAction(
                label: 'Salidas',
                icon: Icons.logout_outlined,
                onTap: () => context.push(AppRoutes.departures),
              ),
              QuickAction(
                label: 'Habitaciones',
                icon: Icons.bed_outlined,
                onTap: () => context.push(AppRoutes.rooms),
              ),
              QuickAction(
                label: 'Tareas',
                icon: Icons.task_outlined,
                onTap: () => context.push(AppRoutes.housekeepingOverview),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
