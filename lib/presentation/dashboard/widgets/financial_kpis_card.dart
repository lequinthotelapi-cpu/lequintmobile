import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../domain/services/financial_calculator.dart';
import '../../shared/widgets/kpi_card.dart';

/// KPIs financieros del mes actual (solo admin/manager) — ver SPEC-003.
/// Mismas 4 tarjetas que describe SPEC-003 para el dashboard de inicio:
/// Ingresos, Ocupación, RevPAR, Por cobrar (`adr` no se muestra aquí —
/// solo aparece en ReportsScreen/TASK-013, ver SPEC-010).
class FinancialKpisCard extends StatelessWidget {
  const FinancialKpisCard({required this.kpis, super.key});

  final FinancialKpis kpis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresos del mes',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          kpis.revenue.toCurrency(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            KPICard(
              value: '${kpis.occupancyRate.toStringAsFixed(1)}%',
              label: 'Ocupación',
              icon: Icons.pie_chart_outline,
            ),
            KPICard(
              value: kpis.revPAR.toCurrency(),
              label: 'RevPAR',
              icon: Icons.trending_up,
            ),
            KPICard(
              value: kpis.accountsReceivable.toCurrency(),
              label: 'Por cobrar',
              icon: Icons.hourglass_bottom_outlined,
              color: kpis.accountsReceivable > 0 ? AppColors.warning : null,
            ),
          ],
        ),
      ],
    );
  }
}
