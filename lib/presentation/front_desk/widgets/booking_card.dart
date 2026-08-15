import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/booking.dart';

/// Tarjeta de reserva en listas de llegadas/salidas — ver
/// docs/ux/components.md "BookingCard".
class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.booking,
    required this.onTap,
    this.balance,
    super.key,
  });

  final Booking booking;

  /// Saldo de la cuenta — solo se pasa en la lista de salidas (SPEC-007).
  final double? balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassSecondary,
            border: Border.all(color: AppColors.glassSecondaryBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      booking.guestName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (booking.status == BookingStatus.confirmed ||
                      booking.status == BookingStatus.pending)
                    _BookingStatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Hab. ${booking.roomNumber} · ${booking.roomType} · '
                '${booking.nights} noche(s)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (balance != null) ...[
                const SizedBox(height: 8),
                _BalanceIndicator(balance: balance!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingStatusBadge extends StatelessWidget {
  const _BookingStatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == BookingStatus.confirmed;
    final color = isConfirmed ? AppColors.success : AppColors.warning;
    final label = isConfirmed ? 'CONFIRMADA' : 'PENDIENTE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _BalanceIndicator extends StatelessWidget {
  const _BalanceIndicator({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final isSettled = balance == 0;
    final color = isSettled ? AppColors.success : AppColors.warning;

    return Row(
      children: [
        Icon(
          isSettled ? Icons.check_circle : Icons.warning_amber_rounded,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          'Saldo: \$${balance.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
