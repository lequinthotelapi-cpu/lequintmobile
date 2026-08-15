import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../domain/models/guest_account.dart';
import '../guest_account_labels.dart';

/// Ítem de la lista de cargos en GuestAccountScreen — ver SPEC-011.
class ChargeItemTile extends StatelessWidget {
  const ChargeItemTile({required this.charge, super.key});

  final Charge charge;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Expanded(
                child: Text(
                  charge.description.isEmpty
                      ? charge.type.label
                      : charge.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                charge.total.toCurrency(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${charge.amount.toCurrency()} x ${charge.quantity} · '
            '${charge.date.toShortDateEs()}',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
