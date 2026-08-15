import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/bookings/bookings_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/models/booking.dart';
import '../../domain/models/user.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';

/// Detalle de reserva + ejecución de check-in — ver SPEC-006.
///
/// El badge VIP y el piso de la habitación (mencionados en la SPEC) no se
/// muestran: `Booking` no trae `floor` ni el flag `vip` del huésped, y no
/// existe un `GuestRepository`/`RoomRepository` provider en el alcance de
/// esta TASK para resolverlos — queda documentado como pendiente.
class ArrivalDetailScreen extends ConsumerStatefulWidget {
  const ArrivalDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  ConsumerState<ArrivalDetailScreen> createState() =>
      _ArrivalDetailScreenState();
}

class _ArrivalDetailScreenState extends ConsumerState<ArrivalDetailScreen> {
  bool _isCheckingIn = false;

  Future<void> _checkIn(Booking booking, String userId) async {
    setState(() => _isCheckingIn = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .checkIn(bookingId: booking.id, userId: userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in realizado — ${booking.guestName}, '
            'Hab. ${booking.roomNumber}',
          ),
        ),
      );
      context.pop();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isCheckingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arrivalsAsync = ref.watch(arrivalsProvider);
    final role = ref.watch(currentUserRoleProvider);
    final userId = ref.watch(currentUserProvider)?.uid;
    final canCheckIn =
        role == UserRole.receptionist ||
        role == UserRole.admin ||
        role == UserRole.superadmin;

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
            'Detalle de llegada',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: arrivalsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonCard(height: 360),
            ),
            error: (error, stackTrace) => ErrorState(
              message: 'No se pudo cargar la reserva',
              onRetry: () => ref.invalidate(arrivalsProvider),
            ),
            data: (bookings) {
              final booking = findBookingById(bookings, widget.bookingId);
              if (booking == null) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No se encontró la reserva',
                  subtitle: 'Puede que ya se haya procesado el check-in.',
                );
              }
              return _ArrivalDetailBody(
                booking: booking,
                canCheckIn: canCheckIn,
                isCheckingIn: _isCheckingIn,
                onCheckIn: userId == null
                    ? null
                    : () => ConfirmDialog.show(
                        context: context,
                        title: '¿Confirmar check-in?',
                        message:
                            '${booking.guestName}\n'
                            'Habitación ${booking.roomNumber} — ${booking.roomType}\n'
                            'Check-out: ${booking.checkOutDate.toShortDateEs()} '
                            '(${booking.nights} noches)',
                        confirmLabel: 'Confirmar Check-In',
                        confirmColor: AppColors.success,
                        onConfirm: () => _checkIn(booking, userId),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ArrivalDetailBody extends StatelessWidget {
  const _ArrivalDetailBody({
    required this.booking,
    required this.canCheckIn,
    required this.isCheckingIn,
    required this.onCheckIn,
  });

  final Booking booking;
  final bool canCheckIn;
  final bool isCheckingIn;
  final VoidCallback? onCheckIn;

  @override
  Widget build(BuildContext context) {
    final isConfirmed = booking.status == BookingStatus.confirmed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.guestName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('RESERVA'),
          const SizedBox(height: 8),
          _GlassSection(
            children: [
              _InfoRow('Número', booking.bookingNumber),
              _InfoRow(
                'Habitación',
                '${booking.roomNumber} — ${booking.roomType}',
              ),
              _InfoRow('Check-in', booking.checkInDate.toShortDateEs()),
              _InfoRow('Check-out', booking.checkOutDate.toShortDateEs()),
              _InfoRow('Noches', '${booking.nights}'),
              _InfoRow(
                'Adultos · Niños',
                '${booking.adults} · ${booking.children}',
              ),
              _InfoRow('Total', '\$${booking.totalPrice.toStringAsFixed(2)}'),
              _InfoRow('Estado', isConfirmed ? 'Confirmada' : 'Pendiente'),
            ],
          ),
          if (booking.specialRequests != null &&
              booking.specialRequests!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionTitle('SOLICITUDES ESPECIALES'),
            const SizedBox(height: 8),
            _GlassSection(
              children: [
                Text(
                  booking.specialRequests!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          if (canCheckIn) ...[
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: (!isConfirmed || isCheckingIn) ? null : onCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  disabledBackgroundColor: AppColors.textDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isCheckingIn
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Realizar Check-In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (!isConfirmed) ...[
              const SizedBox(height: 8),
              const Text(
                'La reserva debe estar confirmada para hacer check-in',
                style: TextStyle(color: AppColors.warning, fontSize: 12),
              ),
            ],
          ],
        ],
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
