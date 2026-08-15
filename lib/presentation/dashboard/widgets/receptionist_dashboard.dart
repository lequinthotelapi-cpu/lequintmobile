import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_provider.dart';
import '../../../application/bookings/bookings_provider.dart';
import '../../../application/guest_accounts/guest_account_provider.dart';
import '../../../application/rooms/rooms_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../front_desk/widgets/booking_card.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/async_utils.dart';
import 'dashboard_header.dart';
import 'dashboard_skeleton.dart';
import 'quick_actions_row.dart';
import 'room_status_summary.dart';

/// Dashboard de recepcionista — ver SPEC-003. Llegadas/salidas del día son
/// lo más prominente (nota de diseño de la spec).
class ReceptionistDashboard extends ConsumerWidget {
  const ReceptionistDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final arrivalsAsync = ref.watch(arrivalsProvider);
    final departuresAsync = ref.watch(departuresProvider);
    final roomsAsync = ref.watch(roomsWithStatusProvider);
    final openAccountsAsync = ref.watch(openGuestAccountsProvider);

    final loading = anyLoading([
      arrivalsAsync,
      departuresAsync,
      roomsAsync,
      openAccountsAsync,
    ]);
    final error = firstError([
      arrivalsAsync,
      departuresAsync,
      roomsAsync,
      openAccountsAsync,
    ]);

    void refresh() {
      ref
        ..invalidate(arrivalsProvider)
        ..invalidate(departuresProvider)
        ..invalidate(roomsWithStatusProvider)
        ..invalidate(openGuestAccountsProvider);
    }

    if (loading) return const DashboardSkeleton();
    if (error != null) {
      return ErrorState(
        message: 'No se pudieron cargar los datos',
        onRetry: refresh,
      );
    }

    final arrivals = arrivalsAsync.value!;
    final departures = departuresAsync.value!;
    final rooms = roomsAsync.value!;

    return RefreshIndicator(
      onRefresh: () async => refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          DashboardHeader(greeting: 'Hola, ${user?.firstName ?? ''}'),
          const SizedBox(height: 20),
          _ProminentCount(
            icon: Icons.login_outlined,
            count: arrivals.length,
            label: 'Llegadas hoy',
            onSeeAll: () => context.push(AppRoutes.arrivals),
          ),
          if (arrivals.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final booking in arrivals.take(3)) ...[
              BookingCard(
                booking: booking,
                onTap: () =>
                    context.push(AppRoutes.arrivalDetailPath(booking.id)),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 20),
          _ProminentCount(
            icon: Icons.logout_outlined,
            count: departures.length,
            label: 'Salidas hoy',
            onSeeAll: () => context.push(AppRoutes.departures),
          ),
          if (departures.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final booking in departures.take(3)) ...[
              BookingCard(
                booking: booking,
                onTap: () =>
                    context.push(AppRoutes.departureDetailPath(booking.id)),
              ),
              const SizedBox(height: 8),
            ],
          ],
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
          const SizedBox(height: 12),
          Text(
            '${openAccountsAsync.value!.length} cuentas abiertas',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
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
            ],
          ),
        ],
      ),
    );
  }
}

class _ProminentCount extends StatelessWidget {
  const _ProminentCount({
    required this.icon,
    required this.count,
    required this.label,
    required this.onSeeAll,
  });

  final IconData icon;
  final int count;
  final String label;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSeeAll,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPrimary, size: 28),
          const SizedBox(width: 12),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
