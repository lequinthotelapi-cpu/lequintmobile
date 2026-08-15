import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/guest_accounts/guest_account_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../../domain/models/guest_account.dart';
import '../../domain/models/user.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import 'guest_account_labels.dart';
import 'widgets/charge_item_tile.dart';
import 'widgets/payment_item_tile.dart';

/// Roles que pueden agregar cargos — ver SPEC-011 "Permisos".
bool canAddCharge(UserRole? role) =>
    role == UserRole.receptionist ||
    role == UserRole.admin ||
    role == UserRole.superadmin;

/// Detalle de cuenta de huésped — ver SPEC-011.
class GuestAccountScreen extends ConsumerWidget {
  const GuestAccountScreen({required this.accountId, super.key});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(guestAccountProvider(accountId));
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Cuenta de huésped',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: accountAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonCard(height: 500),
            ),
            error: (error, stackTrace) => ErrorState(
              message: 'No se pudo cargar la cuenta',
              onRetry: () => ref.invalidate(guestAccountProvider(accountId)),
            ),
            data: (account) {
              if (account == null) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No se encontró la cuenta',
                );
              }
              return _GuestAccountBody(
                account: account,
                canAddCharge: canAddCharge(role),
                onRefresh: () async =>
                    ref.invalidate(guestAccountProvider(accountId)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GuestAccountBody extends StatelessWidget {
  const _GuestAccountBody({
    required this.account,
    required this.canAddCharge,
    required this.onRefresh,
  });

  final GuestAccount account;
  final bool canAddCharge;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final balanceColor = account.balance > 0
        ? AppColors.error
        : AppColors.success;
    final charges = [...account.charges]
      ..sort((a, b) => b.date.compareTo(a.date));
    final payments = [...account.payments]
      ..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          Text(
            account.guestName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hab. ${account.roomNumber} · Check-in: '
            '${account.checkInDate.toShortDateEs()}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: account.status == GuestAccountStatus.open
                      ? AppColors.success
                      : AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                account.status.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionTitle('RESUMEN'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassPrimary,
              border: Border.all(color: AppColors.glassPrimaryBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _SummaryRow('Subtotal', account.subtotal.toCurrency()),
                _SummaryRow('IVA', account.tax.toCurrency()),
                _SummaryRow('Total', account.total.toCurrency()),
                _SummaryRow('Pagado', account.paid.toCurrency()),
                const Divider(color: AppColors.glassPrimaryBorder, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      account.balance.toCurrency(),
                      style: TextStyle(
                        color: balanceColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('CARGOS'),
          const SizedBox(height: 8),
          if (charges.isEmpty)
            const _EmptySection('Sin cargos registrados')
          else
            for (final charge in charges) ...[
              ChargeItemTile(charge: charge),
              if (charge != charges.last) const SizedBox(height: 8),
            ],
          const SizedBox(height: 20),
          const _SectionTitle('PAGOS'),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            const _EmptySection('Sin pagos registrados')
          else
            for (final payment in payments) ...[
              PaymentItemTile(payment: payment),
              if (payment != payments.last) const SizedBox(height: 8),
            ],
          if (canAddCharge && account.status == GuestAccountStatus.open) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.addChargePath(account.id)),
                icon: const Icon(Icons.add),
                label: const Text('Agregar Cargo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
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

class _EmptySection extends StatelessWidget {
  const _EmptySection(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
    );
  }
}
