import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../domain/models/guest_account.dart';

/// Cuentas abiertas ordenadas por saldo DESC, máximo 5 — ver SPEC-010
/// sección 5.
List<GuestAccount> topOpenAccountsByBalance(
  List<GuestAccount> accounts, {
  int limit = 5,
}) {
  final sorted = [...accounts]..sort((a, b) => b.balance.compareTo(a.balance));
  return sorted.take(limit).toList();
}

class OpenAccountsList extends StatelessWidget {
  const OpenAccountsList({
    required this.accounts,
    required this.onTap,
    super.key,
  });

  final List<GuestAccount> accounts;
  final void Function(GuestAccount account) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final account in accounts) ...[
          _OpenAccountTile(account: account, onTap: () => onTap(account)),
          if (account != accounts.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _OpenAccountTile extends StatelessWidget {
  const _OpenAccountTile({required this.account, required this.onTap});

  final GuestAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final daysOpen = DateTime.now().difference(account.checkInDate).inDays;

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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.guestName} · Hab. ${account.roomNumber}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saldo: ${account.balance.toCurrency()} · '
                      '$daysOpen ${daysOpen == 1 ? 'día' : 'días'}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
