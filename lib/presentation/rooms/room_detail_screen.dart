import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/guest_accounts/guest_account_provider.dart';
import '../../application/housekeeping/housekeeping_provider.dart';
import '../../application/rooms/rooms_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/models/housekeeping_task.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import 'room_status_display.dart';

/// Detalle de habitación — ver SPEC-008.
class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen({required this.roomId, super.key});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsWithStatusProvider);

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Habitaciones',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: roomsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonCard(height: 320),
            ),
            error: (error, stackTrace) => ErrorState(
              message: 'No se pudo cargar la habitación',
              onRetry: () => ref.invalidate(roomsWithStatusProvider),
            ),
            data: (rooms) {
              final room = rooms.where((r) => r.id == roomId).firstOrNull;
              if (room == null) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No se encontró la habitación',
                );
              }

              final visuals = roomStatusVisuals(room.displayStatus);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habitación ${room.roomNumber}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: visuals.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          visuals.label,
                          style: TextStyle(
                            color: visuals.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _GlassSection(
                      children: [
                        _InfoRow('Piso', '${room.floor}'),
                        _InfoRow('Tipo', room.roomType),
                        _InfoRow('Capacidad', '${room.capacity} personas'),
                        _InfoRow(
                          'Precio base',
                          '\$${room.basePrice.toStringAsFixed(2)}/noche',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (room.displayStatus == 'occupied' &&
                        room.activeBooking != null) ...[
                      const _SectionTitle('HUÉSPED ACTUAL'),
                      const SizedBox(height: 8),
                      _GlassSection(
                        children: [
                          _InfoRow('Nombre', room.activeBooking!.guestName),
                          _InfoRow(
                            'Check-out',
                            room.activeBooking!.checkOutDate.toShortDateEs(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _AccountLink(bookingId: room.activeBooking!.id),
                    ],
                    if (room.displayStatus == 'reserved' &&
                        room.activeBooking != null) ...[
                      const SizedBox(height: 12),
                      _ActionLink(
                        label: 'Ver reserva →',
                        onTap: () => context.push(
                          AppRoutes.arrivalDetailPath(room.activeBooking!.id),
                        ),
                      ),
                    ],
                    if (room.displayStatus == 'cleaning' ||
                        room.displayStatus == 'maintenance') ...[
                      const SizedBox(height: 12),
                      _ActiveTaskLink(
                        roomId: room.id,
                        label: room.displayStatus == 'cleaning'
                            ? 'Ver tarea de limpieza →'
                            : 'Ver tarea de mantenimiento →',
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Resuelve la cuenta del huésped a partir del booking activo para armar
/// el enlace "Ver cuenta" (GuestAccountScreen es TASK-014).
class _AccountLink extends ConsumerWidget {
  const _AccountLink({required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(guestAccountByBookingProvider(bookingId));
    final account = accountAsync.valueOrNull;
    if (account == null) return const SizedBox.shrink();

    return _ActionLink(
      label: 'Ver cuenta del huésped →',
      onTap: () => context.push(AppRoutes.accountDetailPath(account.id)),
    );
  }
}

class _ActiveTaskLink extends ConsumerWidget {
  const _ActiveTaskLink({required this.roomId, required this.label});

  final String roomId;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(allTasksProvider);
    final task = tasksAsync.valueOrNull
        ?.where(
          (t) =>
              t.roomId == roomId &&
              (t.status == TaskStatus.pending ||
                  t.status == TaskStatus.inProgress),
        )
        .firstOrNull;
    if (task == null) return const SizedBox.shrink();

    return _ActionLink(
      label: label,
      onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accentPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassPrimary,
        border: Border.all(color: AppColors.glassPrimaryBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
