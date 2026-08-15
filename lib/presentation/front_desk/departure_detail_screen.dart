import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/bookings/bookings_provider.dart';
import '../../application/guest_accounts/guest_account_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/models/booking.dart';
import '../../domain/models/guest_account.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';

/// Detalle de reserva + ejecución de check-out — ver SPEC-007.
class DepartureDetailScreen extends ConsumerStatefulWidget {
  const DepartureDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  ConsumerState<DepartureDetailScreen> createState() =>
      _DepartureDetailScreenState();
}

class _DepartureDetailScreenState extends ConsumerState<DepartureDetailScreen> {
  bool _isCheckingOut = false;

  Future<void> _checkOut(Booking booking, String userId) async {
    setState(() => _isCheckingOut = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .checkOut(bookingId: booking.id, userId: userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-out realizado — ${booking.guestName}, '
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
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final departuresAsync = ref.watch(departuresProvider);
    final userId = ref.watch(currentUserProvider)?.uid;

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
            'Detalle de salida',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: departuresAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonCard(height: 400),
            ),
            error: (error, stackTrace) => ErrorState(
              message: 'No se pudo cargar la reserva',
              onRetry: () => ref.invalidate(departuresProvider),
            ),
            data: (bookings) {
              final booking = findBookingById(bookings, widget.bookingId);
              if (booking == null) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No se encontró la reserva',
                  subtitle: 'Puede que ya se haya procesado el check-out.',
                );
              }

              final accountAsync = ref.watch(
                guestAccountByBookingProvider(booking.id),
              );

              return accountAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: SkeletonCard(height: 400),
                ),
                error: (error, stackTrace) => ErrorState(
                  message: 'No se pudo cargar la cuenta del huésped',
                  onRetry: () =>
                      ref.invalidate(guestAccountByBookingProvider(booking.id)),
                ),
                data: (account) => _DepartureDetailBody(
                  booking: booking,
                  account: account,
                  isCheckingOut: _isCheckingOut,
                  onCheckOut: (account == null || userId == null)
                      ? null
                      : () => ConfirmDialog.show(
                          context: context,
                          title: '¿Confirmar check-out?',
                          message:
                              '${booking.guestName}\n'
                              'Habitación ${booking.roomNumber} — ${booking.roomType}\n'
                              'Estadía: ${booking.nights} noches\n'
                              'Total pagado: \$${account.paid.toStringAsFixed(2)}',
                          confirmLabel: 'Confirmar Check-Out',
                          confirmColor: AppColors.success,
                          onConfirm: () => _checkOut(booking, userId),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DepartureDetailBody extends StatelessWidget {
  const _DepartureDetailBody({
    required this.booking,
    required this.account,
    required this.isCheckingOut,
    required this.onCheckOut,
  });

  final Booking booking;
  final GuestAccount? account;
  final bool isCheckingOut;
  final VoidCallback? onCheckOut;

  @override
  Widget build(BuildContext context) {
    final balance = account?.balance;
    final canCheckOut = balance == 0;

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
            ],
          ),
          const SizedBox(height: 16),
          const _SectionTitle('CUENTA'),
          const SizedBox(height: 8),
          _GlassSection(
            children: [
              _InfoRow(
                'Total',
                account == null
                    ? 'N/A'
                    : '\$${account!.total.toStringAsFixed(2)}',
              ),
              _InfoRow(
                'Pagado',
                account == null
                    ? 'N/A'
                    : '\$${account!.paid.toStringAsFixed(2)}',
              ),
              _InfoRow(
                'Saldo',
                account == null
                    ? 'N/A'
                    : '\$${account!.balance.toStringAsFixed(2)}',
              ),
            ],
          ),
          if (account != null && account!.balance > 0) ...[
            const SizedBox(height: 16),
            _BalanceWarning(account: account!),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (!canCheckOut || isCheckingOut) ? null : onCheckOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                disabledBackgroundColor: AppColors.textDisabled,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isCheckingOut
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Realizar Check-Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          if (account == null) ...[
            const SizedBox(height: 8),
            const Text(
              'No se encontró la cuenta del huésped',
              style: TextStyle(color: AppColors.warning, fontSize: 12),
            ),
          ] else if (!canCheckOut) ...[
            const SizedBox(height: 8),
            Text(
              'El huésped tiene saldo pendiente de '
              '\$${account!.balance.toStringAsFixed(2)}. Debe saldar la '
              'cuenta antes del check-out.',
              style: const TextStyle(color: AppColors.warning, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceWarning extends StatelessWidget {
  const _BalanceWarning({required this.account});

  final GuestAccount account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠ Saldo pendiente: \$${account.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'El huésped debe saldar su cuenta antes del check-out.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push(AppRoutes.accountDetailPath(account.id)),
            child: const Text(
              'Ver cuenta →',
              style: TextStyle(
                color: AppColors.accentPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
