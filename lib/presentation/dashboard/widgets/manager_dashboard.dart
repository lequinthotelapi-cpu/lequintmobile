import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_provider.dart';
import '../../../application/bookings/bookings_provider.dart';
import '../../../application/dashboard/dashboard_provider.dart';
import '../../../application/housekeeping/housekeeping_provider.dart';
import '../../../application/rooms/rooms_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/async_utils.dart';
import 'dashboard_header.dart';
import 'dashboard_skeleton.dart';
import 'financial_kpis_card.dart';
import 'housekeeping_summary_card.dart';
import 'quick_actions_row.dart';
import 'room_status_summary.dart';

/// Dashboard de manager — ver SPEC-003.
class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final arrivalsAsync = ref.watch(arrivalsProvider);
    final departuresAsync = ref.watch(departuresProvider);
    final roomsAsync = ref.watch(roomsWithStatusProvider);
    final financialAsync = ref.watch(financialKpisProvider);
    final tasksAsync = ref.watch(allTasksProvider);

    final loading = anyLoading([
      arrivalsAsync,
      departuresAsync,
      roomsAsync,
      financialAsync,
      tasksAsync,
    ]);
    final error = firstError([
      arrivalsAsync,
      departuresAsync,
      roomsAsync,
      financialAsync,
      tasksAsync,
    ]);

    void refresh() {
      ref
        ..invalidate(arrivalsProvider)
        ..invalidate(departuresProvider)
        ..invalidate(roomsWithStatusProvider)
        ..invalidate(financialKpisProvider)
        ..invalidate(allTasksProvider);
    }

    if (loading) return const DashboardSkeleton();
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
          Row(
            children: [
              Expanded(
                child: _MiniKpi(
                  value: '${arrivalsAsync.value!.length}',
                  label: 'Llegadas hoy',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniKpi(
                  value: '${departuresAsync.value!.length}',
                  label: 'Salidas hoy',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniKpi(
                  value: '$occupied/${rooms.length}',
                  label: 'Ocupación',
                ),
              ),
            ],
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
          const Text(
            'Housekeeping',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          HousekeepingSummaryCard(
            counts: countHousekeepingTasks(tasksAsync.value!),
          ),
          const SizedBox(height: 24),
          QuickActionsRow(
            actions: [
              QuickAction(
                label: 'Reportes',
                icon: Icons.bar_chart_outlined,
                onTap: () => context.push(AppRoutes.reports),
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

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
