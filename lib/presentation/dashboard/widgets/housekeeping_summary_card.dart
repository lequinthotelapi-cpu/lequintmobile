import 'package:flutter/material.dart';

import '../../../application/housekeeping/housekeeping_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

/// Resumen de housekeeping (todos los empleados) — solo admin/manager, ver
/// SPEC-003 "Resumen housekeeping" (regla de negocio #4).
class HousekeepingSummaryCard extends StatelessWidget {
  const HousekeepingSummaryCard({required this.counts, super.key});

  final HousekeepingTaskCounts counts;

  @override
  Widget build(BuildContext context) {
    return GlassCard.subtle(
      child: Row(
        children: [
          Expanded(
            child: _Count(
              value: counts.pending,
              label: 'Pendientes',
              color: AppColors.warning,
            ),
          ),
          Expanded(
            child: _Count(
              value: counts.inProgress,
              label: 'En progreso',
              color: AppColors.accentPrimary,
            ),
          ),
          Expanded(
            child: _Count(
              value: counts.completedToday,
              label: 'Completadas hoy',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
