import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../domain/services/financial_calculator.dart';
import '../../shared/widgets/glass_card.dart';

/// Barras horizontales simples (sin librería de gráficos) — ver SPEC-010
/// sección 4.
class RevenueBySourceBars extends StatelessWidget {
  const RevenueBySourceBars({required this.sources, super.key});

  final List<RevenueBySource> sources;

  @override
  Widget build(BuildContext context) {
    final maxAmount = sources.fold<double>(
      0,
      (max, source) => source.amount > max ? source.amount : max,
    );

    return GlassCard.subtle(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final source in sources) ...[
            if (source != sources.first) const SizedBox(height: 12),
            _SourceBar(source: source, maxAmount: maxAmount),
          ],
        ],
      ),
    );
  }
}

class _SourceBar extends StatelessWidget {
  const _SourceBar({required this.source, required this.maxAmount});

  final RevenueBySource source;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final fraction = maxAmount > 0 ? source.amount / maxAmount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                source.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              source.amount.toCurrency(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.glassSecondary,
            valueColor: const AlwaysStoppedAnimation(AppColors.accentPrimary),
          ),
        ),
      ],
    );
  }
}
