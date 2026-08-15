import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/services/report_period.dart';

/// Selector de período (Hoy/Semana/Mes/Año) — ver SPEC-010.
class PeriodSelectorChips extends StatelessWidget {
  const PeriodSelectorChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final period in ReportPeriod.values) ...[
            if (period != ReportPeriod.values.first) const SizedBox(width: 8),
            _PeriodChip(
              period: period,
              isSelected: selected == period,
              onTap: () => onChanged(period),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  final ReportPeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPrimary.withValues(alpha: 0.15)
              : AppColors.glassPrimary,
          border: Border.all(
            color: isSelected
                ? AppColors.accentPrimary.withValues(alpha: 0.5)
                : AppColors.glassPrimaryBorder,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          period.label,
          style: TextStyle(
            color: isSelected
                ? AppColors.accentPrimary
                : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
